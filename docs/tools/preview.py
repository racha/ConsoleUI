#!/usr/bin/env python3
"""Render the Jekyll docs into a static folder for local review."""

from __future__ import annotations

import html
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "_preview"
PROJECT = {
    "name": "ConsoleUI",
    "version": "1.0.1",
    "interface": "11200",
    "author": "HouseLegend",
    "repository": "https://github.com/racha/ConsoleUI",
    "releases": "https://github.com/racha/ConsoleUI/releases",
    "download": "https://github.com/racha/ConsoleUI/releases/latest",
    "issues": "https://github.com/racha/ConsoleUI/issues",
    "interact": "https://github.com/vargv666/Interact",
}

NAV = [
    ("Start here", [
        ("Home", "/"),
        ("Install", "/getting-started/install/"),
        ("Controller setup", "/getting-started/controller-setup/"),
        ("First launch", "/getting-started/first-launch/"),
    ]),
    ("Controller", [
        ("Steam Standard", "/controller/steam-standard/"),
        ("Steam MouseLOCK", "/controller/steam-mouselock/"),
        ("Other mappers", "/controller/other-mappers/"),
        ("Mapping reference", "/controller/mapping-reference/"),
    ]),
    ("Features", [
        ("Action bars", "/features/action-bars/"),
        ("Mouse Look", "/features/mouse-look/"),
        ("Bindings", "/features/bindings/"),
        ("Quick Menu", "/features/quick-menu/"),
        ("Rings", "/features/rings/"),
        ("Touch bars and cursor", "/features/touch-cursor/"),
        ("Keyboard", "/features/keyboard/"),
        ("HUD and Frames", "/features/hud-frames/"),
        ("Profiles", "/features/profiles/"),
    ]),
    ("Help", [
        ("Settings", "/reference/settings/"),
        ("Commands", "/reference/commands/"),
        ("Troubleshooting", "/reference/troubleshooting/"),
        ("FAQ", "/reference/faq/"),
        ("Compatibility", "/reference/compatibility/"),
        ("Credits", "/reference/credits/"),
    ]),
    ("Development", [
        ("Overview", "/development/overview/"),
        ("Architecture", "/development/architecture/"),
        ("Public API", "/development/api/"),
        ("Cursor integrations", "/development/cursor-integrations/"),
        ("Input and bindings", "/development/input-and-bindings/"),
        ("Settings and profiles", "/development/settings-and-profiles/"),
        ("Localization", "/development/localization/"),
        ("Visual language", "/development/visual-language/"),
        ("Extending ConsoleUI", "/development/extending/"),
        ("Testing and releases", "/development/testing-releases/"),
        ("Documentation", "/development/documentation/"),
    ]),
]


def rel_url(path: str) -> str:
    if path == "/":
        return "/"
    if not path.endswith("/"):
        return "/" + path.lstrip("/")
    return "/" + path.strip("/") + "/"


def replace_liquid(text: str) -> str:
    text = re.sub(
        r"\{\{\s*site\.data\.project\.(\w+)\s*\}\}",
        lambda m: PROJECT.get(m.group(1), ""),
        text,
    )
    text = re.sub(
        r"\{\{\s*'([^']+)'\s*\|\s*relative_url\s*\}\}",
        lambda m: rel_url(m.group(1)),
        text,
    )
    return text


def parse_front(text: str) -> tuple[dict[str, str], str]:
    meta: dict[str, str] = {}
    if not text.startswith("---"):
        return meta, text
    parts = text.split("---", 2)
    if len(parts) < 3:
        return meta, text
    for line in parts[1].splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            meta[key.strip()] = value.strip().strip('"')
    return meta, parts[2].lstrip("\n")


def inline(text: str) -> str:
    text = html.escape(text)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    return text


def convert_md(src: str) -> str:
    lines = src.splitlines()
    out: list[str] = []
    i = 0
    in_code = False
    code: list[str] = []
    in_ul = False
    in_ol = False
    in_table = False
    table: list[str] = []

    def close_lists() -> None:
        nonlocal in_ul, in_ol
        if in_ul:
            out.append("</ul>")
            in_ul = False
        if in_ol:
            out.append("</ol>")
            in_ol = False

    def close_table() -> None:
        nonlocal in_table, table
        if not in_table:
            return
        rows = table
        table = []
        in_table = False
        if len(rows) < 2:
            return
        out.append("<div class='table-wrap'><table>")
        headers = [c.strip() for c in rows[0].strip("|").split("|")]
        out.append("<thead><tr>" + "".join(f"<th>{inline(h)}</th>" for h in headers) + "</tr></thead><tbody>")
        for row in rows[2:]:
            cells = [c.strip() for c in row.strip("|").split("|")]
            out.append("<tr>" + "".join(f"<td>{inline(c)}</td>" for c in cells) + "</tr>")
        out.append("</tbody></table></div>")

    while i < len(lines):
        line = lines[i]
        if line.startswith("```"):
            close_lists()
            close_table()
            if in_code:
                out.append("<pre><code>" + html.escape("\n".join(code)) + "</code></pre>")
                code = []
                in_code = False
            else:
                in_code = True
            i += 1
            continue
        if in_code:
            code.append(line)
            i += 1
            continue
        stripped = line.strip()
        if stripped.startswith("<"):
            close_lists()
            close_table()
            chunk = [line]
            i += 1
            if re.match(r"<([a-zA-Z0-9]+)[\s>]", stripped):
                tag = re.match(r"<([a-zA-Z0-9]+)", stripped).group(1)
                if not stripped.endswith(f"</{tag}>") and not stripped.endswith("/>"):
                    while i < len(lines) and f"</{tag}>" not in lines[i]:
                        chunk.append(lines[i])
                        i += 1
                    if i < len(lines):
                        chunk.append(lines[i])
                        i += 1
            out.append("\n".join(chunk))
            continue
        if stripped.startswith("|"):
            close_lists()
            in_table = True
            table.append(stripped)
            i += 1
            continue
        close_table()
        if re.match(r"^#{1,3} ", stripped):
            close_lists()
            level = len(stripped) - len(stripped.lstrip("#"))
            out.append(f"<h{level}>{inline(stripped[level + 1:])}</h{level}>")
        elif stripped.startswith("- "):
            if not in_ul:
                close_lists()
                out.append("<ul>")
                in_ul = True
            out.append(f"<li>{inline(stripped[2:])}</li>")
        elif re.match(r"^\d+\. ", stripped):
            if not in_ol:
                close_lists()
                out.append("<ol>")
                in_ol = True
            out.append(f"<li>{inline(re.sub(r'^\d+\. ', '', stripped))}</li>")
        elif stripped == "":
            close_lists()
        else:
            close_lists()
            out.append(f"<p>{inline(stripped)}</p>")
        i += 1
    close_lists()
    close_table()
    return "\n".join(out)


def nav_html(current: str) -> str:
    blocks = []
    for title, items in NAV:
        links = []
        for name, url in items:
            cls = " class='is-current' aria-current='page'" if url == current else ""
            links.append(f"<li><a href='{rel_url(url)}'{cls}>{html.escape(name)}</a></li>")
        blocks.append(f"<p class='nav-group'>{html.escape(title)}</p><ul>{''.join(links)}</ul>")
    return "\n".join(blocks)


def page_html(meta: dict[str, str], body: str, current: str, is_home: bool) -> str:
    title = meta.get("title", "ConsoleUI")
    desc = meta.get("description", "Play original Vanilla WoW with a controller.")
    if is_home:
        main = body
    else:
        crumbs = (
            "<nav class='crumbs' aria-label='Breadcrumb'>"
            f"<a href='{rel_url('/')}'>Guide</a><span aria-hidden='true'> / </span>"
            f"<span>{html.escape(title)}</span></nav>"
        )
        main = (
            f"{crumbs}<p class='eyebrow'>ConsoleUI guide</p>"
            f"<h1>{html.escape(title)}</h1>"
            f"<p class='lede'>{html.escape(desc)}</p>"
            f"<article class='page-content'>{body}</article>"
        )
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{html.escape(title)} · ConsoleUI</title>
  <meta name="description" content="{html.escape(desc)}">
  <link rel="icon" href="/assets/icons/favicon.png">
  <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
  <a class="skip-link" href="#content">Skip to content</a>
  <header class="topbar">
    <a class="brand" href="/" aria-label="ConsoleUI home">
      <img src="/assets/images/brand/consoleui-wordmark.svg" alt="ConsoleUI." width="168">
    </a>
    <div class="top-actions">
      <a href="{rel_url('/')}">Guide</a>
      <a href="{PROJECT['download']}">Download</a>
      <a href="{PROJECT['repository']}">GitHub</a>
      <span class="version-badge">{PROJECT['version']}</span>
      <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-nav">Menu</button>
    </div>
  </header>
  <div class="site-shell">
    <nav id="site-nav" class="sidebar" aria-label="Documentation navigation">
      {nav_html(current)}
    </nav>
    <main class="content" id="content">{main}</main>
  </div>
  <footer class="footer">
    <span>ConsoleUI by {PROJECT['author']} · Interface {PROJECT['interface']}</span>
    <span class="footer-links">
      <a href="{rel_url('/reference/credits/')}">Credits</a>
      <a href="{PROJECT['issues']}">Report a problem</a>
    </span>
  </footer>
  <script src="/assets/js/site.js"></script>
</body>
</html>
"""


def find_pages() -> list[Path]:
    pages = []
    for path in ROOT.rglob("*.md"):
        if path.name in {"README.md"} or "_preview" in path.parts or path.parent.name == "tools":
            continue
        pages.append(path)
    return pages


def permalink_of(meta: dict[str, str], path: Path) -> str:
    if "permalink" in meta:
        return meta["permalink"]
    if path.name == "index.md":
        return "/"
    rel = path.relative_to(ROOT).with_suffix("").as_posix()
    return f"/{rel}/"


def main() -> None:
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir()
    shutil.copytree(ROOT / "assets", OUT / "assets")
    (OUT / "assets" / "css" / "style.css").write_text(
        (ROOT / "assets" / "css" / "style.css").read_text()
        + "\nimg, a { max-width: 100%; }\n"
        + "a[href^='assets/'] { }\n",
        encoding="utf-8",
    )
    for path in find_pages():
        meta, body = parse_front(path.read_text(encoding="utf-8"))
        permalink = permalink_of(meta, path)
        body = replace_liquid(body)
        body = convert_md(body)
        is_home = permalink == "/"
        rendered = page_html(meta, body, permalink, is_home)
        if permalink == "/":
            dest = OUT / "index.html"
        else:
            dest = OUT / permalink.strip("/") / "index.html"
            dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(rendered, encoding="utf-8")
        print(dest.relative_to(OUT))
    readme = (ROOT.parent / "README.md").read_text(encoding="utf-8")
    readme = readme.replace("docs/assets/", "/assets/")
    (OUT / "github-readme.html").write_text(
        page_html(
            {"title": "GitHub README preview", "description": "Local rendering of the repository README."},
            convert_md(replace_liquid(readme)),
            "/",
            True,
        ),
        encoding="utf-8",
    )
    print("github-readme.html")


if __name__ == "__main__":
    main()
