import { useEffect, useState } from "react";
import { Link, Navigate, useLocation, useNavigate } from "react-router-dom";

import { crumbs, navigation, neighbors, normalizePath, pageOrder, project, asset, pageTitle } from "./data.js";
import { getDoc, searchDocs } from "./content.js";
import { Home } from "./Home.jsx";
import { SiteFx } from "./SiteFx.jsx";

function isModifiedClick(event) {
  return event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0;
}

function DocHtml({ html }) {
  const navigate = useNavigate();
  const base = import.meta.env.BASE_URL.replace(/\/$/, "") || "";

  function onClick(event) {
    const anchor = event.target.closest("a");
    if (!anchor || isModifiedClick(event)) return;
    const href = anchor.getAttribute("href");
    if (!href || href.startsWith("#") || href.startsWith("mailto:") || href.startsWith("http")) return;
    const url = new URL(anchor.href, window.location.href);
    if (url.origin !== window.location.origin) return;
    event.preventDefault();
    let path = url.pathname;
    if (base && path.startsWith(base)) path = path.slice(base.length) || "/";
    navigate(path + url.hash);
  }

  return <div className="doc-html" onClick={onClick} dangerouslySetInnerHTML={{ __html: html }} />;
}

function highlight(text, query) {
  if (!query || !text) return text;
  const i = text.toLowerCase().indexOf(query.toLowerCase());
  if (i < 0) return text;
  return (
    <>
      {text.slice(0, i)}
      <mark>{text.slice(i, i + query.length)}</mark>
      {text.slice(i + query.length)}
    </>
  );
}

function Search({ open, onClose }) {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");
  const [active, setActive] = useState(0);
  const hits = searchDocs(query);

  useEffect(() => {
    setActive(0);
  }, [query, open]);

  useEffect(() => {
    if (!open) setQuery("");
  }, [open]);

  if (!open) return null;

  function go(url) {
    navigate(url);
    onClose();
  }

  return (
    <div className="search-backdrop" onClick={onClose}>
      <div
        className="search-dialog"
        role="dialog"
        aria-modal="true"
        aria-label="Search the guide"
        onClick={(event) => event.stopPropagation()}
      >
        <input
          autoFocus
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search pages and page content"
          aria-label="Search pages and page content"
          onKeyDown={(event) => {
            if (event.key === "Escape") onClose();
            if (event.key === "ArrowDown") {
              event.preventDefault();
              setActive((i) => Math.min(i + 1, hits.length - 1));
            }
            if (event.key === "ArrowUp") {
              event.preventDefault();
              setActive((i) => Math.max(i - 1, 0));
            }
            if (event.key === "Enter" && hits[active]) go(hits[active].url);
          }}
        />
        <ul>
          {hits.map((hit, i) => (
            <li key={`${hit.url}-${hit.heading}`}>
              <button
                type="button"
                className={i === active ? "is-active" : ""}
                onMouseEnter={() => setActive(i)}
                onClick={() => go(hit.url)}
              >
                <strong>{hit.title}</strong>
                {hit.heading ? <span className="search-heading">{hit.heading}</span> : null}
                {query.trim() && hit.snippet ? (
                  <small>{highlight(hit.snippet, query.trim())}</small>
                ) : hit.description ? (
                  <small>{hit.description}</small>
                ) : null}
              </button>
            </li>
          ))}
          {hits.length === 0 ? <li className="search-empty">No pages or passages match.</li> : null}
        </ul>
      </div>
    </div>
  );
}

function Layout({ children, current }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const location = useLocation();

  useEffect(() => {
    setMenuOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    if (!menuOpen) {
      document.documentElement.classList.remove("mobile-menu-open");
      document.body.classList.remove("mobile-menu-open");
      return undefined;
    }
    document.documentElement.classList.add("mobile-menu-open");
    document.body.classList.add("mobile-menu-open");
    function closeOnEscape(event) {
      if (event.key === "Escape") setMenuOpen(false);
    }
    window.addEventListener("keydown", closeOnEscape);
    return () => {
      document.documentElement.classList.remove("mobile-menu-open");
      document.body.classList.remove("mobile-menu-open");
      window.removeEventListener("keydown", closeOnEscape);
    };
  }, [menuOpen]);

  useEffect(() => {
    function onKey(event) {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setSearchOpen(true);
      }
      if (event.key === "Escape") setSearchOpen(false);
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return (
    <div className="site-root">
      <SiteFx />
      <a className="skip-link" href="#content">
        Skip to content
      </a>
      <header className="topbar">
        <Link className="brand" to="/" aria-label="ConsoleUI home">
          <img src={asset("assets/images/brand/consoleui-wordmark.svg")} alt="ConsoleUI." width="168" height="39" />
        </Link>
        <div className="top-actions">
          <button type="button" className="search-launch" aria-label="Search the guide" onClick={() => setSearchOpen(true)}>
            <span className="search-label">Search</span>
            <span className="search-symbol" aria-hidden="true">⌕</span>
            <kbd>⌘K</kbd>
          </button>
          <Link to="/">Guide</Link>
          <Link to="/reference/changelog/">Changelog</Link>
          <a href={project.download}>Download latest</a>
          <a href={project.repository}>GitHub</a>
          <span className="version-badge">{project.version}</span>
          <button
            className="menu-toggle"
            type="button"
            aria-expanded={menuOpen ? "true" : "false"}
            aria-controls="site-nav"
            aria-label={menuOpen ? "Close navigation" : "Open navigation"}
            onClick={() => setMenuOpen((open) => !open)}
          >
            {menuOpen ? "Close" : "Menu"}
          </button>
        </div>
      </header>
      <button
        className={menuOpen ? "nav-scrim open" : "nav-scrim"}
        type="button"
        aria-label="Close navigation"
        onClick={() => setMenuOpen(false)}
      />
      <div className="site-shell">
        <nav id="site-nav" className={menuOpen ? "sidebar open" : "sidebar"} aria-label="Documentation">
          {navigation.map((group) => (
            <div key={group.title}>
              <p className="nav-group">{group.title}</p>
              <ul>
                {group.items.map((item) => (
                  <li key={item.url}>
                    <Link className={current === item.url ? "is-current" : ""} to={item.url}>
                      {item.title}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </nav>
        {children}
      </div>
      <footer className="footer">
        <div className="footer-row">
          <span>
            ConsoleUI by {project.author} · {project.client}
          </span>
          <span className="footer-links">
            <Link to="/reference/credits/">Credits</Link>
            <a href={project.issues}>Report a problem</a>
          </span>
        </div>
        <p className="footer-legal">{project.legal}</p>
      </footer>
      <Search open={searchOpen} onClose={() => setSearchOpen(false)} />
    </div>
  );
}

function DocPage() {
  const location = useLocation();
  const path = normalizePath(location.pathname);
  const doc = getDoc(path);
  const trail = crumbs(path);
  const { prev, next } = neighbors(path);

  useEffect(() => {
    if (location.hash) {
      const id = decodeURIComponent(location.hash.slice(1));
      const node = document.getElementById(id);
      if (node) {
        node.scrollIntoView();
        return;
      }
    }
    window.scrollTo(0, 0);
  }, [location.pathname, location.hash]);

  useEffect(() => {
    document.title = pageTitle(doc && path !== "/" ? doc.title : "");
    const desc = document.querySelector('meta[name="description"]');
    if (desc) desc.setAttribute("content", doc?.description || project.tagline);
  }, [doc, path]);

  if (!doc) {
    return (
      <main id="content" className="content">
        <p className="eyebrow">Missing page</p>
        <h1>That page is not in the guide.</h1>
        <p>
          Return to the <Link to="/">documentation home</Link> or start with{" "}
          <Link to="/getting-started/install/">Install</Link>.
        </p>
      </main>
    );
  }

  return (
    <main id="content" className="content">
      {trail.length > 0 ? (
        <nav className="crumbs" aria-label="Breadcrumb">
          {trail.map((item, i) =>
            i < trail.length - 1 ? (
              <span key={item.url}>
                <Link to={item.url}>{item.title}</Link>
                <span> / </span>
              </span>
            ) : (
              <span key={item.url}>{item.title}</span>
            )
          )}
        </nav>
      ) : null}
      <p className="eyebrow">{trail[1]?.title || "Guide"}</p>
      <h1>{doc.title}</h1>
      {doc.description ? <p className="lede">{doc.description}</p> : null}
      <DocHtml html={doc.html} />
      {prev || next ? (
        <nav className="page-nav">
          {prev ? (
            <Link to={prev.url}>
              <small>Previous</small>
              {prev.title}
            </Link>
          ) : (
            <span />
          )}
          {next ? (
            <Link className="next" to={next.url}>
              <small>Next</small>
              {next.title}
            </Link>
          ) : null}
        </nav>
      ) : null}
    </main>
  );
}

export function App() {
  const location = useLocation();
  const path = normalizePath(location.pathname);
  const known = pageOrder.some((page) => page.url === path) || path === "/";
  const landing = path === "/";

  useEffect(() => {
    if (!landing) return;
    document.title = pageTitle();
    const desc = document.querySelector('meta[name="description"]');
    if (desc) desc.setAttribute("content", project.tagline);
  }, [landing]);

  if (location.pathname !== "/" && !location.pathname.endsWith("/")) {
    return <Navigate to={`${location.pathname}/${location.search}${location.hash}`} replace />;
  }

  return (
    <Layout current={known ? path : ""}>
      {landing ? <Home /> : <DocPage />}
    </Layout>
  );
}
