import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const root = dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  base: process.env.GITHUB_ACTIONS ? "/ConsoleUI/" : "/",
  plugins: [react()],
  server: {
    host: "127.0.0.1",
    port: 8767,
    fs: { allow: [root, resolve(root, "..")] },
  },
  preview: {
    host: "127.0.0.1",
    port: 8767,
  },
});
