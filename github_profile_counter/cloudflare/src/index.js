const DEFAULT_USER = "yannigoyal";
const COOKIE_MAX_AGE = 60 * 60 * 24 * 365;

function normalizeUsername(raw) {
  const username = String(raw || DEFAULT_USER)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9-]/g, "");
  return username || DEFAULT_USER;
}

function cookieName(username) {
  return `ghvc_${username}`;
}

function readCookie(request, name) {
  const header = request.headers.get("Cookie");
  if (!header) return null;
  for (const part of header.split(";")) {
    const [key, ...rest] = part.trim().split("=");
    if (key === name) return decodeURIComponent(rest.join("="));
  }
  return null;
}

async function visitorFingerprint(request, username) {
  const ip = request.headers.get("CF-Connecting-IP") || "unknown";
  const ua = request.headers.get("User-Agent") || "unknown";
  const data = new TextEncoder().encode(`${username}:${ip}:${ua}`);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(hash)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("")
    .slice(0, 32);
}

async function registerUniqueVisit(request, env, username) {
  const existingCookie = readCookie(request, cookieName(username));
  if (existingCookie) {
    return { counted: false, visitorId: existingCookie };
  }

  const visitorId = await visitorFingerprint(request, username);
  const visitorKey = `v:${username}:${visitorId}`;
  const already = await env.KV.get(visitorKey);
  if (already) {
    return { counted: false, visitorId };
  }

  await env.KV.put(visitorKey, "1");
  const totalKey = `total:${username}`;
  const current = Number((await env.KV.get(totalKey)) || "0");
  await env.KV.put(totalKey, String(current + 1));

  return { counted: true, visitorId };
}

function badgeSvg(total) {
  const label = `👥 ${total} unique visitor${total === 1 ? "" : "s"}`;
  const width = Math.max(180, label.length * 7 + 24);
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="28" role="img" aria-label="${label}">
  <title>${label}</title>
  <linearGradient id="g" x2="0" y2="100%">
    <stop offset="0%" stop-color="#6366F1"/>
    <stop offset="100%" stop-color="#14B8A6"/>
  </linearGradient>
  <rect width="${width}" height="28" rx="6" fill="#111218"/>
  <rect x="1" y="1" width="${width - 2}" height="26" rx="5" fill="url(#g)" opacity="0.18"/>
  <text x="12" y="19" fill="#E8E9F0" font-family="Segoe UI, Helvetica, Arial, sans-serif" font-size="13" font-weight="600">${label}</text>
</svg>`;
}

function withVisitorCookie(response, username, visitorId) {
  const headers = new Headers(response.headers);
  headers.append(
    "Set-Cookie",
    `${cookieName(username)}=${visitorId}; Max-Age=${COOKIE_MAX_AGE}; Path=/; HttpOnly; Secure; SameSite=Lax`,
  );
  headers.set("Cache-Control", "no-store");
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const username = normalizeUsername(url.searchParams.get("user"));
    const path = url.pathname.replace(/\/+$/, "") || "/";

    if (path === "/profileHit" || path === "/hit") {
      const { counted, visitorId } = await registerUniqueVisit(
        request,
        env,
        username,
      );

      if (url.searchParams.get("format") === "json") {
        return withVisitorCookie(
          new Response(
            JSON.stringify({
              username,
              counted,
              profile: `https://github.com/${username}`,
            }),
            { headers: { "Content-Type": "application/json" } },
          ),
          username,
          visitorId,
        );
      }

      return withVisitorCookie(
        Response.redirect(`https://github.com/${username}`, 302),
        username,
        visitorId,
      );
    }

    if (path === "/profileBadge" || path === "/badge") {
      const total = Number(
        (await env.KV.get(`total:${username}`)) || "0",
      );
      return new Response(badgeSvg(total), {
        headers: {
          "Content-Type": "image/svg+xml; charset=utf-8",
          "Cache-Control": "no-cache, no-store, must-revalidate",
        },
      });
    }

    return new Response("GitHub profile counter — use /profileHit or /profileBadge", {
      status: 404,
    });
  },
};
