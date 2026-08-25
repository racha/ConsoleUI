import { useEffect, useRef, useState } from "react";

import { asset } from "./data.js";

const SRC = asset("assets/images/brand/consoleui-plus.png");
const GAP = 40;

function radius(size) {
  return size * 0.46;
}

function hits(a, b) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  const min = radius(a.size) + radius(b.size) + GAP;
  return dx * dx + dy * dy < min * min;
}

function rollSize() {
  const bucket = Math.random();
  if (bucket < 0.3) return 68 + Math.random() * 28;
  if (bucket < 0.65) return 120 + Math.random() * 44;
  return 190 + Math.random() * 80;
}

function seed(w, h) {
  const want = Math.max(6, Math.min(11, Math.floor((w * h) / 240000)));
  const out = [];
  let tries = 0;
  while (out.length < want && tries < 500) {
    tries += 1;
    const size = rollSize();
    const r = radius(size) + GAP;
    const item = {
      x: r + Math.random() * Math.max(1, w - r * 2),
      y: r + Math.random() * Math.max(1, h - r * 2),
      size,
      vx: (Math.random() < 0.5 ? -1 : 1) * (6 + Math.random() * 22),
      vy: (Math.random() < 0.5 ? -1 : 1) * (6 + Math.random() * 22),
    };
    if (out.some((other) => hits(item, other))) continue;
    out.push(item);
  }
  return out;
}

function bounce(items, w, h, dt) {
  const n = items.length;
  for (let i = 0; i < n; i += 1) {
    const a = items[i];
    a.x += a.vx * dt;
    a.y += a.vy * dt;
    const r = radius(a.size);
    if (a.x < r) {
      a.x = r;
      a.vx = Math.abs(a.vx);
    } else if (a.x > w - r) {
      a.x = w - r;
      a.vx = -Math.abs(a.vx);
    }
    if (a.y < r) {
      a.y = r;
      a.vy = Math.abs(a.vy);
    } else if (a.y > h - r) {
      a.y = h - r;
      a.vy = -Math.abs(a.vy);
    }
  }
  for (let i = 0; i < n; i += 1) {
    for (let j = i + 1; j < n; j += 1) {
      const a = items[i];
      const b = items[j];
      if (!hits(a, b)) continue;
      const dx = a.x - b.x;
      const dy = a.y - b.y;
      const d = Math.hypot(dx, dy) || 1;
      const overlap = radius(a.size) + radius(b.size) + GAP - d;
      const nx = dx / d;
      const ny = dy / d;
      a.x += nx * overlap * 0.5;
      a.y += ny * overlap * 0.5;
      b.x -= nx * overlap * 0.5;
      b.y -= ny * overlap * 0.5;
      const av = a.vx * nx + a.vy * ny;
      const bv = b.vx * nx + b.vy * ny;
      a.vx += (bv - av) * nx;
      a.vy += (bv - av) * ny;
      b.vx += (av - bv) * nx;
      b.vy += (av - bv) * ny;
    }
  }
}

function paint(field, pack) {
  if (!field) return;
  const els = field.children;
  for (let i = 0; i < pack.length; i += 1) {
    const item = pack[i];
    const el = els[i];
    if (!el) continue;
    el.style.transform = `translate3d(${item.x - item.size / 2}px, ${item.y - item.size / 2}px, 0)`;
  }
}

export function SiteFx() {
  const fieldRef = useRef(null);
  const packRef = useRef([]);
  const [items, setItems] = useState([]);

  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    let w = window.innerWidth;
    let h = window.innerHeight;
    packRef.current = seed(w, h);
    setItems(packRef.current.map((item) => ({ ...item })));
    if (reduce) return undefined;

    let last = performance.now();
    let frame = 0;
    function tick(now) {
      const dt = Math.min(0.05, (now - last) / 1000);
      last = now;
      bounce(packRef.current, w, h, dt);
      paint(fieldRef.current, packRef.current);
      frame = requestAnimationFrame(tick);
    }
    frame = requestAnimationFrame(tick);

    function onResize() {
      w = window.innerWidth;
      h = window.innerHeight;
      packRef.current = seed(w, h);
      setItems(packRef.current.map((item) => ({ ...item })));
    }
    window.addEventListener("resize", onResize);
    return () => {
      cancelAnimationFrame(frame);
      window.removeEventListener("resize", onResize);
    };
  }, []);

  return (
    <div className="site-fx" aria-hidden="true">
      <div className="site-fx-gold" />
      <div className="site-fx-field" ref={fieldRef}>
        {items.map((item, i) => (
          <img
            key={i}
            className="site-fx-dot"
            src={SRC}
            alt=""
            width={item.size}
            height={item.size}
            style={{
              width: item.size,
              height: item.size,
              transform: `translate3d(${item.x - item.size / 2}px, ${item.y - item.size / 2}px, 0)`,
            }}
          />
        ))}
      </div>
    </div>
  );
}
