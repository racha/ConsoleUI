import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { navigation } from "../src/data.js";

const webRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const repositoryRoot = resolve(webRoot, "..");
const docsRoot = resolve(repositoryRoot, "docs");
const markdownFiles = [];

function walk(directory) {
  for (const name of readdirSync(directory)) {
    const file = resolve(directory, name);
    if (statSync(file).isDirectory()) walk(file);
    else if (name.endsWith(".md")) markdownFiles.push(file);
  }
}

walk(docsRoot);

const routes = new Set(["/"]);
for (const file of markdownFiles) {
  const source = readFileSync(file, "utf8");
  const permalink = source.match(/^permalink:\s*(\S+)/m);
  if (permalink) routes.add(permalink[1]);
}

const failures = [];

function checkRoute(route, source) {
  if (!route || route.startsWith("#") || /^[a-z]+:/i.test(route)) return;
  const clean = route.split(/[?#]/)[0];
  if (clean.startsWith("/assets/")) {
    const asset = resolve(docsRoot, clean.slice(1));
    if (!existsSync(asset)) failures.push(`${source}: missing asset ${clean}`);
    return;
  }
  if (clean.startsWith("/") && !routes.has(clean)) {
    failures.push(`${source}: missing route ${clean}`);
  }
}

for (const file of markdownFiles) {
  const source = readFileSync(file, "utf8");
  const label = file.slice(repositoryRoot.length + 1);
  for (const match of source.matchAll(/["'](\/[^"']+)["']\s*\|\s*relative_url/g)) {
    checkRoute(match[1], label);
  }
  for (const match of source.matchAll(/\]\(([^)]+)\)/g)) {
    const target = match[1].trim().replace(/^<|>$/g, "");
    if (!target.includes("{{")) checkRoute(target, label);
  }
  for (const match of source.matchAll(/(?:href|src)=["'](\/[^"']+)["']/g)) {
    checkRoute(match[1], label);
  }
}

for (const group of navigation) {
  for (const item of group.items) checkRoute(item.url, `navigation:${item.title}`);
}

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log(`Documentation routes and assets OK (${markdownFiles.length} pages, ${routes.size} routes)`);
