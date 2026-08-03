# The Polymod Framework

A terminal-styled static site for **The Polymod Framework** — a modular support system for solo, early-stage and young entrepreneurs. Built with [Hugo](https://gohugo.io/) and deployed to GitHub Pages.

**Live site:** <https://intxk.github.io/thepolymodframework/>

Publishing model: **push to `main` → auto-build → auto-deploy.** No build servers, no databases, no manual deployment.

---

## Table of contents

- [Project structure](#project-structure)
- [Local development](#local-development)
- [Writing a post](#writing-a-post)
- [Post lifecycle](#post-lifecycle)
  - [Publish a post](#publish-a-post)
  - [Update a post](#update-a-post)
  - [Remove a post](#remove-a-post)
- [Tags & archives](#tags--archives)
- [Navigation & theme](#navigation--theme)
- [Editing the homepage](#editing-the-homepage)
- [Configuration](#configuration)
- [Deployment](#deployment)

---

## Project structure

```
.
├── .github/workflows/hugo.yml   # CI/CD: builds & deploys on every push to main
├── assets/css/main.css          # all styling (terminal theme, posts, nav)
├── content/
│   ├── _index.md                # home page front matter (title only)
│   ├── posts/                   # BLOG: one folder per post
│   │   └── <node> <title>/
│   │       ├── post.md          # the post (committed — you author this)
│   │       └── ...              # attachments (images, PDFs, etc.)
│   └── sections/                # homepage content cards (editable)
│       ├── 01-chaos.md
│       ├── 02-versatile.md
│       ├── 03-solutions.md
│       └── 04-cta.md
├── layouts/                     # Hugo templates (nav, posts, tags, base)
├── scripts/prepare-posts.ps1    # post.md → index.md + injects date from node
├── hugo.toml                    # site config (URL, subtitles, brand mark)
└── .gitignore
```

---

## Local development

**Prerequisites**

- [Hugo](https://gohugo.io/installation/) **extended edition, v0.164.0** (used by CI; pin the same version locally)
- PowerShell 5.1+ or PowerShell 7 (`pwsh`) — Windows ships PowerShell 5.1 by default

**Clone & preview**

```powershell
git clone https://github.com/INTxK/thepolymodframework.git
cd thepolymodframework
pwsh ./scripts/prepare-posts.ps1   # or: powershell -File ./scripts/prepare-posts.ps1
hugo server -D                     # -D includes draft posts in the preview
```

Open <http://localhost:1313>.

Why the `prepare-posts.ps1` step? Hugo renders each post folder as a *leaf bundle*, which requires an `index.md` entry point. You author `post.md`; the script copies it to `index.md` and injects a `date` field derived from the `node` field. `index.md` is git-ignored and regenerated on every build (including CI), so it never needs to be committed or manually edited.

> Note: `hugo server` works without the script, but the injected `date` (from `node`) is what sorts posts newest-first, so run the script for a faithful preview.

---

## Writing a post

Each post lives in its own folder under `content/posts/`:

```
content/posts/2026-08-03-07-30-00 hello-polymod/
├── post.md
└── sample.txt
```

### Folder naming

```
<node> <title>
```

- `<node>` — unique id in `YYYY-MM-DD-hh-mm-ss` form (required)
- `<title>` — URL slug; spaces are converted to dashes by Hugo

The folder name above produces the URL:

```
/posts/2026-08-03-07-30-00-hello-polymod/
```

### Front matter

`post.md` looks like this:

```markdown
---
title: "Hello, Polymod"
node: "2026-08-03-07-30-00"
tags:
  - meta
  - hello
summary: "First post to validate the publishing pipeline."
draft: true
---

Your post body in standard Markdown goes here.
```

| Field     | Required | Purpose                                                        |
|-----------|----------|----------------------------------------------------------------|
| `title`   | yes      | Post title (shown in the nav list and post page).              |
| `node`    | yes      | Unique id `YYYY-MM-DD-hh-mm-ss`. Drives the displayed date, newest-first ordering, and the URL. Must match the folder-name prefix. |
| `tags`    | no       | YAML list. Automatically creates archive pages under `/tags/`. |
| `summary` | no       | One-line description shown beneath the title on the posts page. |
| `draft`   | no       | Set `draft: true` to keep the post unpublished. Remove the field to publish. |

### Body & attachments

The body is standard Markdown — headings, code, bold/italic, lists, quotes, tables all work.

Attachments (images, PDFs, archives) sit in the same folder and are linked **relative to the post**:

```markdown
[Download the sample](./sample.txt)
```

You can mix every kind of file and reference it the same way.

---

## Post lifecycle

Three operations, all follow the same rhythm: **change files → commit → push → the site updates itself.**

### Publish a post

1. Create the folder and files:

   ```powershell
   cd content/posts
   New-Item -ItemType Directory -Path "2026-08-03-07-30-00 hello-polymod"
   ```

2. Write `post.md` (see [Writing a post](#writing-a-post)); leave `draft` out to make it live.
3. Verify locally: `pwsh ../../scripts/prepare-posts.ps1` then `hugo server -D` from the repo root.
4. Commit and push:

   ```powershell
   git add content/posts/"2026-08-03-07-30-00 hello-polymod"
   git commit -m "Add post: hello-polymod"
   git push origin main
   ```

5. The deploy workflow runs; your post appears at `/posts/<node>-<title>/` and at the top of `/posts/`.

### Update a post

1. Edit `post.md` (fix a typo, add content, change `tags`/`summary`).
2. Commit and push:

   ```powershell
   git add -A
   git commit -m "Update post: hello-polymod"
   git push origin main
   ```

The regenerated `index.md` is picked up automatically — you never touch it. Change the folder name (the `node` prefix) if you want to change the post's URL/date.

### Remove a post

1. Delete the whole folder:

   ```powershell
   git rm -r "content/posts/2026-08-03-07-30-00 hello-polymod"
   git commit -m "Remove post: hello-polymod"
   git push origin main
   ```

The post (and its attachment links) disappear from the site on the next deploy.

> **Unpublished drafts:** if you're not ready to delete a post but don't want it visible, set `draft: true` instead of removing it. Drafts are never deployed; flip the flag back to re-publish.

---

## Tags & archives

Tags need zero configuration. Add `tags` to the front matter and Hugo generates:

- `/tags/` — a cloud of every tag with a usage count
- `/tags/<tag>/` — an archive listing all posts carrying that tag

Each post page shows its tag chips, linking back to the archive.

---

## Navigation & theme

- A compact nav strip (`~ home posts`) appears at the top of every page; the active page is highlighted.
- Posts render in a wrapped, readable column that stays centered on wide screens and collapses on mobile.
- Everything uses the site's terminal aesthetic (monospace, bracket styles) defined in `assets/css/main.css`.

There is a sample post at `content/posts/2026-08-03-07-30-00 hello-polymod/` — useful as a reference, and safe to delete whenever you want.

---

## Editing the homepage

The homepage content lives in `content/sections/`, one Markdown file per card, ordered by the `weight` field:

```markdown
---
title: "Designed for Entrepreneurs Navigating Chaos"
weight: 1
---

Your section body in Markdown…
```

To add a section: create `content/sections/05-your-section.md` with `weight: 5` (or any number to slot into the order). To reorder, adjust `weight` values. To remove, delete the file. Push to deploy.

---

## Configuration

Site-wide settings live in `hugo.toml`:

| Key                    | What it controls                                 |
|------------------------|--------------------------------------------------|
| `baseURL`              | The live site URL (change if the site moves).    |
| `[params] author`      | Author name (shown in page footers/metadata).    |
| `[params] company`     | Company name.                                    |
| `[params] subtitle_line1` / `subtitle_line2` | Hero taglines on the homepage.      |
| `[params] brand_mark`  | ASCII brand mark rendered in the hero.           |
| `[taxonomies] tag`     | Enables the tag system — leave as-is.            |

`brand_mark` is a TOML literal string; backslashes inside it must be doubled (`\\`) or Hugo will reject the file.

---

## Deployment

Deployment is handled entirely by `.github/workflows/hugo.yml`, which runs on every push to `main` (and can be triggered manually from the Actions tab):

1. **Checkout** the repo
2. **Setup Hugo** (v0.164.0, extended)
3. **Prepare post bundles** — runs `pwsh ./scripts/prepare-posts.ps1` (PowerShell is preinstalled on GitHub runners)
4. **Build** — `hugo --minify`
5. **Upload** the `public/` artifact
6. **Deploy** to GitHub Pages

Track a run with `gh run watch`, or watch it live under **Actions → "Deploy Hugo site to Pages"**. The deployment environment URL is set from the workflow and displayed on the Actions page.

**To move the site to another repository or domain:** update `baseURL` in `hugo.toml`, and in GitHub enable Pages (**Settings → Pages → Build and deployment → GitHub Actions**).
