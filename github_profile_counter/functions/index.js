const crypto = require("crypto");
const { onRequest } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

const DEFAULT_USER = "yannigoyal";
const COOKIE_MAX_AGE = 60 * 60 * 24 * 365; // 1 year

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

function readCookie(req, name) {
  const header = req.headers.cookie;
  if (!header) return null;
  for (const part of header.split(";")) {
    const [key, ...rest] = part.trim().split("=");
    if (key === name) return decodeURIComponent(rest.join("="));
  }
  return null;
}

function visitorFingerprint(req, username) {
  const ip =
    req.headers["x-forwarded-for"]?.split(",")[0]?.trim() ||
    req.ip ||
    "unknown";
  const ua = req.headers["user-agent"] || "unknown";
  return crypto
    .createHash("sha256")
    .update(`${username}:${ip}:${ua}`)
    .digest("hex")
    .slice(0, 32);
}

async function registerUniqueVisit(req, username) {
  const cookie = readCookie(req, cookieName(username));
  if (cookie) {
    return { counted: false, visitorId: cookie, reason: "cookie" };
  }

  const visitorId = visitorFingerprint(req, username);
  const visitorRef = db.doc(`profile_visitors/${username}_${visitorId}`);
  const counterRef = db.doc(`profile_counters/${username}`);

  let counted = false;
  await db.runTransaction(async (tx) => {
    const visitorSnap = await tx.get(visitorRef);
    if (visitorSnap.exists) return;

    tx.set(visitorRef, {
      username,
      visitorId,
      countedAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      counterRef,
      {
        username,
        total: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    counted = true;
  });

  return { counted, visitorId, reason: counted ? "new" : "duplicate" };
}

function badgeSvg(total, username) {
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

exports.profileHit = onRequest(
  {
    region: "us-central1",
    invoker: "public",
  },
  async (req, res) => {
    const username = normalizeUsername(req.query.user);
    const { counted, visitorId } = await registerUniqueVisit(req, username);

    res.setHeader(
      "Set-Cookie",
      `${cookieName(username)}=${visitorId}; Max-Age=${COOKIE_MAX_AGE}; Path=/; HttpOnly; Secure; SameSite=Lax`,
    );
    res.setHeader("Cache-Control", "no-store");

    if (req.query.format === "json") {
      res.status(200).json({
        username,
        counted,
        profile: `https://github.com/${username}`,
      });
      return;
    }

    res.redirect(302, `https://github.com/${username}`);
  },
);

exports.profileBadge = onRequest(
  {
    region: "us-central1",
    invoker: "public",
  },
  async (req, res) => {
    const username = normalizeUsername(req.query.user);
    const snap = await db.doc(`profile_counters/${username}`).get();
    const total = snap.exists ? Number(snap.data()?.total || 0) : 0;

    res.setHeader("Content-Type", "image/svg+xml; charset=utf-8");
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    res.status(200).send(badgeSvg(total, username));
  },
);
