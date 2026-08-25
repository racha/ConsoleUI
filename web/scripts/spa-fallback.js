import { copyFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const dist = resolve(dirname(fileURLToPath(import.meta.url)), "../dist");
copyFileSync(resolve(dist, "index.html"), resolve(dist, "404.html"));
console.log("wrote dist/404.html for GitHub Pages");
