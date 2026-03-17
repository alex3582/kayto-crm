# Kayto Tech CRM — Supabase Keep-Alive Setup

This workflow automatically pings your Supabase project every **4 days**
to prevent it from pausing on the free tier (which pauses after 7 days of inactivity).

---

## Setup Steps

### 1. Create a GitHub Repository

- Go to [github.com](https://github.com) and create a free account if you don't have one
- Create a new repository called `kayto-crm` (can be private)
- Upload this `.github/` folder and your `kayto_crm.html` file to the repo

### 2. Add Your Supabase Credentials as Secrets

GitHub Actions uses **Secrets** so your credentials are never exposed in code.

1. In your GitHub repo, go to **Settings → Secrets and variables → Actions**
2. Click **New repository secret** and add the following two secrets:

| Secret Name | Where to find it |
|---|---|
| `SUPABASE_URL` | Supabase dashboard → Project Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Supabase dashboard → Project Settings → API → `anon` `public` key |

### 3. That's it

GitHub will automatically run the workflow every 4 days at 8:00 AM Perth time.

You can also trigger it manually at any time:
- Go to your repo → **Actions** tab → **Supabase Keep-Alive** → **Run workflow**

---

## How it works

The workflow sends a simple HTTP GET request to your Supabase REST API endpoint.
This counts as activity and resets the inactivity timer.

- ✅ If Supabase responds with a 200 status, the ping is logged as successful
- ⚠️ If it gets an unexpected response, the workflow fails and GitHub will email you

---

## Cost

**$0.00** — GitHub Actions is free for public repos and includes
**2,000 minutes/month free** for private repos. This workflow uses less than
1 minute per run, so roughly 8 minutes/month — well within the free allowance.
