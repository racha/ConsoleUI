# ConsoleUI documentation site

Pages source is the markdown in this folder. The live site is the Vite + React
app in `web/`. GitHub Actions builds `web/` and deploys `web/dist` to
`https://racha.github.io/ConsoleUI/`.

Do not open these files with `file://`. Liquid in the markdown is expanded by
the app (`site.data.project.*` and `relative_url`).

## Local preview

```sh
cd web
npm install
npm run dev
```

Then open `http://127.0.0.1:8767/`.
