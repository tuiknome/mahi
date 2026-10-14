# Split — self-hosted on Supabase

This folder is the complete Split app, ready to run on your own web address with its own sign-up, login and database.

| File | What it is |
|---|---|
| `index.html` | The whole app. The only file you edit, and only once (step 3). |
| `schema.sql` | Creates the database table, privacy rules and video storage. |
| `manifest.json`, `icon-*.png` | Lets people add Split to their iPhone home screen with an icon. |
| `split-data-export.json` | Your current data from the Claude version, ready to import (step 6). |

Setup takes about 20–30 minutes. Both services have free plans that are plenty for a team.

---

## 1. Create a Supabase project

1. Go to **supabase.com**, sign up, and click **New project**.
2. Name it `split`, set a database password (save it somewhere), pick the region closest to you, and click **Create new project**.
3. Wait a minute or two for it to finish setting up.

## 2. Create the database

1. In your project, open **SQL Editor** (left sidebar) → **New query**.
2. Open `schema.sql` from this folder, copy everything, paste it in, and click **Run**.
3. You should see "Success. No rows returned."

This creates one private table for everyone's data. Supabase's Row Level Security makes sure each person can only ever read or change their own rows, and it creates a storage area for exercise videos.

## 3. Connect the app to Supabase

1. In Supabase, open **Project Settings → API** (or **Data API**).
2. Copy the **Project URL** and the **anon / public** key. Do not use the `service_role` key, which must stay secret.
3. Open `index.html` in any text editor and find this block near the top of the main script (search for `SUPABASE SETUP`):

   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT-ID.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
   ```

4. Replace the two values with yours and save.

The anon key is designed to be public. The privacy rules from step 2 are what protect the data.

## 4. Put it online with GitHub and Vercel

1. Go to **github.com**, sign up, and create a new repository called `split`. It can be private.
2. On the new repository page, click **uploading an existing file**, drag in **everything in this folder except `split-data-export.json`**, and click **Commit changes**.
3. Go to **vercel.com**, sign up with your GitHub account, click **Add New → Project**, pick the `split` repository, and click **Deploy**. No settings need changing.
4. After about a minute you get a link like `split-yourname.vercel.app`. That's your app. You can connect your own domain later in Vercel's settings.

## 5. Set up sign-in emails

1. In Supabase, open **Authentication → URL Configuration**.
2. Set **Site URL** to your Vercel link, for example `https://split-yourname.vercel.app`.
3. Add the same link under **Redirect URLs**.
4. Under **Authentication → Sign In / Providers → Email**, choose whether new accounts must confirm their email. Leaving it on is safer.

Supabase's built-in email sender is limited to a few emails per hour, which is fine for testing. For a team, add your own email sender under **Authentication → Emails → SMTP Settings**. Resend, SendGrid or Postmark all have free tiers.

## 6. Create your account and import your data

1. Open your Vercel link, tap **Create account**, and sign in.
2. Go to **Targets → Account → Import data** and choose `split-data-export.json`.
3. Your supplements, recovery tools, settings, the Baseball Strong schedule and your logged and planned days appear.

Exercise and drill videos added in the Claude version stay there. Re-add them in the new app from each exercise's play button.

## 7. Add it to the iPhone home screen

Open the link in **Safari** → tap **Share** → **Add to Home Screen**. Split opens full-screen with its own icon, like an app.

---

## Adding people

Anyone with the link can tap **Create account**. Each person's data is completely private to their login.

To control who can join, turn off **Allow new users to sign up** in Supabase under **Authentication → Sign In / Providers**. Then invite people from **Authentication → Users → Invite user**.

Everyone currently sees the same Baseball Strong program, S2 profile and starting supplements, which are Cullen's. Per-person programs, profiles or a coach view can be added later.

## Making changes later

1. Edit `index.html`, or ask Claude to make the change and send you the updated file.
2. In GitHub, open the repository → `index.html` → upload the new version and commit.
3. Vercel redeploys automatically in about a minute. Users' data is untouched because it lives in Supabase, not in the file.

Most changes, like new drills, foods or screens, only touch `index.html`. You'd only need Supabase again for structural changes such as a coach view, and you'd get the exact SQL to paste.

If an update breaks something, open the project in Vercel → **Deployments**, pick the previous one, and click **Promote to Production** to roll back.

## What's different from the Claude version

- **Sign-in:** Email and password, or a one-time email link, instead of a Claude account.
- **AI features are off:** "Describe it" meal estimates and the Whoop screenshot import used Claude, so they're hidden here. Everything else works the same. They can be added back later with a Supabase Edge Function and an Anthropic API key.
- **Export:** **Export my data** (Targets → Account) downloads a backup file at any time.
- **Videos:** Stored in Supabase Storage with a 50 MB limit per clip. The app also asks for clips under 20 MB to keep phone uploads fast.
