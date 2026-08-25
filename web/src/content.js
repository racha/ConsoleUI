import { marked } from "marked";

import { project } from "./data.js";

const rawFiles = {
  ...import.meta.glob("../../docs/*.md", { query: "?raw", import: "default", eager: true }),
  ...import.meta.glob("../../docs/getting-started/*.md", { query: "?raw", import: "default", eager: true }),
  ...import.meta.glob("../../docs/controller/*.md", { query: "?raw", import: "default", eager: true }),
  ...import.meta.glob("../../docs/features/*.md", { query: "?raw", import: "default", eager: true }),
  ...import.meta.glob("../../docs/reference/*.md", { query: "?raw", import: "default", eager: true }),
  ...import.meta.glob("../../docs/development/*.md", { query: "?raw", import: "default", eager: true }),
};

function parseFrontMatter(raw) {
  const match = String(raw).match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: String(raw) };
  const meta = {};
  match[1].split(/\r?\n/).forEach((line) => {
    const cut = line.indexOf(":");
    if (cut < 0) return;
    const key = line.slice(0, cut).trim();
    let value = line.slice(cut + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    meta[key] = value;
  });
  return { meta, body: match[2] };
}

function expandLiquid(markdown) {
  const base = import.meta.env.BASE_URL;
  return markdown
    .replace(/\{\{\s*site\.data\.project\.(\w+)\s*\}\}/g, (_, key) => project[key] || "")
    .replace(/\{\{\s*'([^']*)'\s*\|\s*relative_url\s*\}\}/g, (_, path) => {
      if (path === "/") return base;
      return base + path.replace(/^\//, "");
    });
}

function slugify(text) {
  return String(text)
    .replace(/<[^>]*>/g, "")
    .toLowerCase()
    .replace(/&[a-z0-9#]+;/g, "")
    .replace(/[^\w\s-]/g, "")
    .trim()
    .replace(/[\s_]+/g, "-");
}

function withHeadingIds(html) {
  return html.replace(/<h([1-6])>([\s\S]*?)<\/h\1>/g, (_, depth, inner) => {
    const id = slugify(inner);
    return `<h${depth} id="${id}">${inner}</h${depth}>`;
  });
}

function searchText(body) {
  return String(body)
    .replace(/```[\w-]*\n?/g, " ")
    .replace(/`/g, "")
    .replace(/<[^>]+>/g, " ")
    .replace(/\{\{[^}]+\}\}/g, " ")
    .replace(/[#*_\[\]]/g, " ")
    .replace(/\|/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function snippetAround(text, query) {
  const hay = text.toLowerCase();
  const i = hay.indexOf(query);
  if (i < 0) {
    return text.length > 160 ? `${text.slice(0, 157)}…` : text;
  }
  const start = Math.max(0, i - 42);
  const end = Math.min(text.length, i + query.length + 90);
  return `${start > 0 ? "…" : ""}${text.slice(start, end)}${end < text.length ? "…" : ""}`;
}

marked.use({ gfm: true });

function pathFromFile(file) {
  const rel = file.replace(/\\/g, "/").replace(/^.*\/docs\//, "");
  if (rel === "index.md") return "/";
  return `/${rel.replace(/\.md$/, "")}/`;
}

const SKIP = {
  "README.md": true,
  "404.md": true,
};

export const docs = Object.keys(rawFiles)
  .filter((file) => !SKIP[file.replace(/\\/g, "/").split("/").pop()])
  .map((file) => {
    const { meta, body } = parseFrontMatter(rawFiles[file]);
    const expanded = expandLiquid(body);
    const html = withHeadingIds(marked.parse(expanded, { async: false }));
    const url = meta.permalink || pathFromFile(file);
    return {
      url,
      title: meta.title || "ConsoleUI",
      description: meta.description || "",
      layout: meta.layout || "page",
      html,
      markdown: expanded,
      text: searchText(`${meta.title || ""} ${meta.description || ""} ${expanded}`),
    };
  });

const byUrl = {};
docs.forEach((doc) => {
  byUrl[doc.url] = doc;
});

export function getDoc(path) {
  if (!path || path === "/") return byUrl["/"] || null;
  const withSlash = path.endsWith("/") ? path : `${path}/`;
  return byUrl[withSlash] || byUrl[path] || null;
}

function sectionEntries(doc, markdown) {
  const sections = [{ heading: doc.title, id: "", body: [] }];
  markdown.split(/\r?\n/).forEach((line) => {
    const heading = line.match(/^(#{1,6})\s+(.+?)\s*$/);
    if (heading) {
      sections.push({ heading: searchText(heading[2]), id: slugify(heading[2]), body: [] });
      return;
    }
    const htmlHeading = line.match(/^<h[1-6] id="([^"]+)">([\s\S]*?)<\/h[1-6]>$/);
    if (htmlHeading) {
      sections.push({ heading: searchText(htmlHeading[2]), id: htmlHeading[1], body: [] });
      return;
    }
    sections[sections.length - 1].body.push(line);
  });
  return sections.map((section) => {
    const text = searchText(section.body.join(" "));
    return {
      url: section.id ? `${doc.url}#${section.id}` : doc.url,
      title: doc.title,
      heading: section.id ? section.heading : "",
      description: section.id ? "" : doc.description,
      text,
    };
  }).filter((row) => row.text || row.heading || row.description);
}

export const searchIndex = docs.flatMap((doc) => sectionEntries(doc, doc.markdown));

export function searchDocs(query) {
  const q = query.trim().toLowerCase();
  if (!q) {
    return searchIndex.filter((row) => !row.heading).slice(0, 8);
  }
  const hits = [];
  searchIndex.forEach((row) => {
    const hay = `${row.title} ${row.heading} ${row.description} ${row.text}`.toLowerCase();
    if (!hay.includes(q)) return;
    let rank = 0;
    if (row.title.toLowerCase().includes(q)) rank += 4;
    if (row.heading && row.heading.toLowerCase().includes(q)) rank += 3;
    if (row.description.toLowerCase().includes(q)) rank += 2;
    if (row.text.toLowerCase().includes(q)) rank += 1;
    hits.push({
      ...row,
      rank,
      snippet: snippetAround(row.text || row.description || row.heading || row.title, q),
    });
  });
  hits.sort((a, b) => b.rank - a.rank || a.title.localeCompare(b.title));
  return hits.slice(0, 16);
}
