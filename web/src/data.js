export function asset(path) {
  return import.meta.env.BASE_URL + String(path).replace(/^\//, "");
}

export const HOME_TITLE = "ConsoleUI - By HouseLegend";

export function pageTitle(name) {
  if (!name) return HOME_TITLE;
  return `ConsoleUI - ${name}`;
}

export const project = {
  name: "ConsoleUI",
  tagline: "Play original Vanilla WoW with a controller.",
  version: "1.0.2",
  interface: "11200",
  client: "1.12",
  author: "HouseLegend",
  repository: "https://github.com/racha/ConsoleUI",
  releases: "https://github.com/racha/ConsoleUI/releases",
  download: "https://github.com/racha/ConsoleUI/releases/latest",
  issues: "https://github.com/racha/ConsoleUI/issues",
  pages: "https://racha.github.io/ConsoleUI/",
  interact: "https://github.com/vargv666/Interact",
  blizzard: "https://www.blizzard.com",
  legal: "World of Warcraft is a trademark of Blizzard Entertainment. This project is for educational purposes only. It is not affiliated with Blizzard or any private server.",
};

export const navigation = [
  {
    title: "Start here",
    items: [
      { title: "Home", url: "/" },
      { title: "Install", url: "/getting-started/install/" },
      { title: "Controller setup", url: "/getting-started/controller-setup/" },
      { title: "First launch", url: "/getting-started/first-launch/" },
    ],
  },
  {
    title: "Controller",
    items: [
      { title: "Steam Standard", url: "/controller/steam-standard/" },
      { title: "Steam MouseLOCK", url: "/controller/steam-mouselock/" },
      { title: "Other mappers", url: "/controller/other-mappers/" },
      { title: "Mapping reference", url: "/controller/mapping-reference/" },
    ],
  },
  {
    title: "Features",
    items: [
      { title: "Action bars", url: "/features/action-bars/" },
      { title: "Mouse Look", url: "/features/mouse-look/" },
      { title: "Bindings", url: "/features/bindings/" },
      { title: "Quick Menu", url: "/features/quick-menu/" },
      { title: "Rings", url: "/features/rings/" },
      { title: "Touch bars and cursor", url: "/features/touch-cursor/" },
      { title: "Keyboard", url: "/features/keyboard/" },
      { title: "HUD and Frames", url: "/features/hud-frames/" },
      { title: "Profiles", url: "/features/profiles/" },
    ],
  },
  {
    title: "Help",
    items: [
      { title: "Settings", url: "/reference/settings/" },
      { title: "Commands", url: "/reference/commands/" },
      { title: "Changelog", url: "/reference/changelog/" },
      { title: "Troubleshooting", url: "/reference/troubleshooting/" },
      { title: "FAQ", url: "/reference/faq/" },
      { title: "Compatibility", url: "/reference/compatibility/" },
      { title: "Credits", url: "/reference/credits/" },
    ],
  },
  {
    title: "Development",
    items: [
      { title: "Overview", url: "/development/overview/" },
      { title: "Architecture", url: "/development/architecture/" },
      { title: "Public API", url: "/development/api/" },
      { title: "Cursor integrations", url: "/development/cursor-integrations/" },
      { title: "Input and bindings", url: "/development/input-and-bindings/" },
      { title: "Settings and profiles", url: "/development/settings-and-profiles/" },
      { title: "Localization", url: "/development/localization/" },
      { title: "Visual language", url: "/development/visual-language/" },
      { title: "Extending ConsoleUI", url: "/development/extending/" },
      { title: "Testing and releases", url: "/development/testing-releases/" },
      { title: "Documentation", url: "/development/documentation/" },
    ],
  },
];

export const pageOrder = [
  { title: "Home", url: "/" },
  { title: "Install", url: "/getting-started/install/" },
  { title: "Controller setup", url: "/getting-started/controller-setup/" },
  { title: "First launch", url: "/getting-started/first-launch/" },
  { title: "Steam Standard", url: "/controller/steam-standard/" },
  { title: "Steam MouseLOCK", url: "/controller/steam-mouselock/" },
  { title: "Other mappers", url: "/controller/other-mappers/" },
  { title: "Mapping reference", url: "/controller/mapping-reference/" },
  { title: "Action bars", url: "/features/action-bars/" },
  { title: "Mouse Look", url: "/features/mouse-look/" },
  { title: "Bindings", url: "/features/bindings/" },
  { title: "Quick Menu", url: "/features/quick-menu/" },
  { title: "Rings", url: "/features/rings/" },
  { title: "Touch bars and cursor", url: "/features/touch-cursor/" },
  { title: "Keyboard", url: "/features/keyboard/" },
  { title: "HUD and Frames", url: "/features/hud-frames/" },
  { title: "Profiles", url: "/features/profiles/" },
  { title: "Settings", url: "/reference/settings/" },
  { title: "Commands", url: "/reference/commands/" },
  { title: "Changelog", url: "/reference/changelog/" },
  { title: "Troubleshooting", url: "/reference/troubleshooting/" },
  { title: "FAQ", url: "/reference/faq/" },
  { title: "Compatibility", url: "/reference/compatibility/" },
  { title: "Credits", url: "/reference/credits/" },
  { title: "Developer overview", url: "/development/overview/" },
  { title: "Architecture", url: "/development/architecture/" },
  { title: "Public API", url: "/development/api/" },
  { title: "Cursor integrations", url: "/development/cursor-integrations/" },
  { title: "Input and bindings", url: "/development/input-and-bindings/" },
  { title: "Settings and profiles", url: "/development/settings-and-profiles/" },
  { title: "Localization", url: "/development/localization/" },
  { title: "Visual language", url: "/development/visual-language/" },
  { title: "Extending ConsoleUI", url: "/development/extending/" },
  { title: "Testing and releases", url: "/development/testing-releases/" },
  { title: "Documentation", url: "/development/documentation/" },
];

export function normalizePath(path) {
  if (!path || path === "/") return "/";
  return path.endsWith("/") ? path : path + "/";
}

export function neighbors(path) {
  const url = normalizePath(path);
  const i = pageOrder.findIndex((p) => p.url === url);
  if (i < 0) return { prev: null, next: null };
  return {
    prev: i > 0 ? pageOrder[i - 1] : null,
    next: i < pageOrder.length - 1 ? pageOrder[i + 1] : null,
  };
}

export function crumbs(path) {
  const url = normalizePath(path);
  if (url === "/") return [];
  const current = pageOrder.find((p) => p.url === url);
  const group = navigation.find((g) => g.items.some((item) => item.url === url));
  const out = [{ title: "Home", url: "/" }];
  if (group) out.push({ title: group.title, url: group.items[0].url });
  if (current) out.push({ title: current.title, url: current.url });
  return out;
}
