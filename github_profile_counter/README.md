# GitHub Profile Unique Visitor Counter (100% free)

Unique **click-to-count** counter for [yannigoyal](https://github.com/yannigoyal) — **no Firebase Blaze**, no credit card required.

Uses **Cloudflare Workers + KV** (free tier: 100k requests/day).

## Deploy (one-time, ~5 min)

### 1. Free Cloudflare account

Sign up: https://dash.cloudflare.com/sign-up

### 2. Install & login

```bash
cd github_profile_counter/cloudflare
npm install
npx wrangler login
```

### 3. Create KV namespace

```bash
npx wrangler kv namespace create PROFILE_COUNTER
npx wrangler kv namespace create PROFILE_COUNTER --preview
```

Copy the two `id` values into `wrangler.toml` (replace `REPLACE_AFTER_KV_CREATE` and `REPLACE_AFTER_KV_PREVIEW_CREATE`).

### 4. Deploy

```bash
npm run deploy
```

You'll get a URL like:
```
https://github-profile-counter.YOUR_SUBDOMAIN.workers.dev
```

### 5. Add to profile README

Repo: **https://github.com/yannigoyal/yannigoyal** → `README.md`

Replace `YOUR_WORKER_URL` with your workers.dev URL (no trailing slash):

```markdown
## 👥 Profile visitors

[![Unique visitors](YOUR_WORKER_URL/profileBadge?user=yannigoyal)](YOUR_WORKER_URL/profileHit?user=yannigoyal)

👆 Click the badge to count yourself once — repeat clicks won't add again.
```

## How it works

| Endpoint | Purpose |
|----------|---------|
| `/profileHit?user=yannigoyal` | Count once, set cookie, redirect to GitHub |
| `/profileBadge?user=yannigoyal` | SVG badge with total (read-only) |

**Uniqueness:** cookie (1 year) + KV key per IP+User-Agent hash.

## Test

```bash
npm run dev
# open http://localhost:8787/profileBadge?user=yannigoyal
```

## Firebase folder

The `functions/` folder is optional (needs **Blaze** billing). Use **cloudflare/** instead — completely free.

## Limits (free tier)

- Workers: 100,000 requests/day
- KV writes: 1,000/day (enough for ~1000 new unique visitors/day)

More than enough for a GitHub profile.
