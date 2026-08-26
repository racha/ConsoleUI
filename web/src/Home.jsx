import { Link } from "react-router-dom";

import { asset, project } from "./data.js";

const features = [
  { to: "/features/action-bars/", name: "Action bars", blurb: "Controller, Flat, and Full. Modifier pages, stance, pet." },
  { to: "/features/mouse-look/", name: "Mouse Look", blurb: "Lock the camera. Unlock with right-click." },
  { to: "/features/quick-menu/", name: "Quick Menu", blurb: "Bags, map, spellbook, quests, social, chat, settings." },
  { to: "/features/rings/", name: "Rings", blurb: "Your eight-slice spell and item wheels." },
  { to: "/features/touch-cursor/", name: "Cursor and touch", blurb: "Stick through Blizzard panels. Optional phone and Deck bars." },
  { to: "/features/keyboard/", name: "Keyboard", blurb: "Radial chat. Y space, X erase, A send, B close." },
];

export function Home() {
  return (
    <main id="content" className="landing">
      <section className="landing-hero">
        <div className="landing-hero-copy">
          <img
            className="landing-mark"
            src={asset("assets/images/brand/consoleui-wordmark.svg")}
            alt="ConsoleUI."
            width="640"
            height="142"
          />
          <p className="landing-kicker">
            Original Vanilla <span aria-hidden="true">·</span> {project.client}
          </p>
          <h1>
            Play Vanilla
            <br />
            with a controller.
          </h1>
          <p className="landing-lead">
            Action bars, Mouse Look, Quick Menu, Rings, a virtual cursor, touch bars, and a radial
            keyboard. Built for the original 1.12 client.
          </p>
          <div className="landing-cta">
            <a className="landing-download" href={project.download}>
              Download latest
            </a>
            <Link className="landing-guide" to="/getting-started/install/">
              Open the guide
            </Link>
          </div>
        </div>
        <div className="landing-hero-shot">
          <img
            src={asset("assets/images/gameplay/consoleui-gameplay-overview.png")}
            alt="ConsoleUI Controller action bars, player and target frames, and XP bar during outdoor Vanilla gameplay."
          />
        </div>
      </section>

      <ol className="landing-steps">
        <li>
          <Link to="/getting-started/install/">
            <span>01</span>
            Install both folders
          </Link>
        </li>
        <li>
          <Link to="/getting-started/controller-setup/">
            <span>02</span>
            Pick a camera
          </Link>
        </li>
        <li>
          <Link to="/getting-started/first-launch/">
            <span>03</span>
            First launch
          </Link>
        </li>
      </ol>

      <section className="landing-camera">
        <header>
          <h2>Two cameras. Same addon.</h2>
          <p>Pick the mapper layout that matches how you want to look around.</p>
        </header>
        <div className="landing-split">
          <Link className="landing-shot" to="/controller/steam-standard/">
            <img
              src={asset("assets/images/controller-setup/steam-community-layout-standard.png")}
              alt="HouseLegend Standard ConsoleUI controller layout. Right-stick move parks the cursor top-left and holds right-click."
            />
            <div>
              <h3>Standard</h3>
              <p>
                Right-stick move parks the cursor top-left and holds right-click. Mouse Look stays
                off. Center the stick to use the cursor.
              </p>
            </div>
          </Link>
          <Link className="landing-shot" to="/controller/steam-mouselock/">
            <img
              src={asset("assets/images/controller-setup/steam-community-layout-mouselock.png")}
              alt="HouseLegend MouseLOCK ConsoleUI controller layout. WASD also sends F9. R3 unlocks."
            />
            <div>
              <h3>MouseLOCK</h3>
              <p>WASD also starts Mouse Look. R3 unlocks. Unlock before using touch.</p>
            </div>
          </Link>
        </div>
        <p className="landing-note">
          Vanilla has no gamepad API. Steam Input or another mapper turns the pad into keys. F9 is
          only the MouseLOCK WASD companion. Do not add mapper commands for jump, casts, or UI
          actions.
        </p>
      </section>

      <section className="landing-index">
        <h2>In the guide</h2>
        <ul>
          {features.map((item) => (
            <li key={item.to}>
              <Link to={item.to}>
                <strong>{item.name}</strong>
                <span>{item.blurb}</span>
              </Link>
            </li>
          ))}
        </ul>
      </section>

      <section className="landing-meta">
        <p>
          OctoWoW, TurtleWoW, RavenCraft, Capybara Paradise. Not Retail, not modern Classic.
        </p>
        <p>
          <a href={project.interact}>Interact</a> is a separate client mod for loot, herbs, veins,
          and NPCs. It is not in the ZIP.
        </p>
        <p>
          Extend it from the{" "}
          <Link to="/development/overview/">developer overview</Link>,{" "}
          <Link to="/development/api/">public API</Link>, and{" "}
          <Link to="/development/cursor-integrations/">cursor integrations</Link>.
        </p>
        <p>
          Made by {project.author}. Full project credits are listed in <code>/cui</code> → About and
          on the <Link to="/reference/credits/">Credits</Link> page. {project.legal} Version notes are on the{" "}
          <Link to="/reference/changelog/">Changelog</Link>. If something fails, start with{" "}
          <Link to="/reference/troubleshooting/">Troubleshooting</Link> and include{" "}
          <code>/cui test</code> when you <a href={project.issues}>open an issue</a>.
        </p>
      </section>
    </main>
  );
}
