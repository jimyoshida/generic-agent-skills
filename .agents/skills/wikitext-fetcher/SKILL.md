---
name: wikitext-fetcher
description: Use when the user gives a Wikipedia (or any MediaWiki) page URL and wants its raw source. Fetches the underlying MediaWiki wikitext (the raw markup) for the page via the MediaWiki API. Triggers on "get the wikitext", "fetch the MediaWiki source", "raw wiki source", "wikitext of this page", or pasting a wikipedia.org/wiki/... URL and asking for its source.
version: 1.0.0
allowed-tools: Bash, Read
---

# Wikitext Fetcher

Given a Wikipedia / MediaWiki page URL, fetch the page's raw **wikitext** (the
MediaWiki markup source) and return it to the user.

Input URL: `$ARGUMENTS`

## What "MediaWiki source" means

The rendered HTML page at `https://en.wikipedia.org/wiki/Foo` is generated from
raw markup called **wikitext**. This skill retrieves that wikitext, not the HTML.

## Steps

1. **Identify the URL.** Use `$ARGUMENTS` if provided; otherwise use the URL the
   user pasted in the conversation. If no URL is available, ask for one.

2. **Fetch the wikitext** by running the helper script that ships in this
   skill's own `scripts/` directory:

   ```bash
   python3 "<this-skill-dir>/scripts/get_wikitext.py" "<URL>"
   ```

   `<this-skill-dir>` is the folder this SKILL.md lives in. Depending on how the
   skill was installed it resolves to one of:
   `~/.claude/skills/wikitext-fetcher`, `~/.copilot/skills/wikitext-fetcher`, or
   `~/.agents/skills/wikitext-fetcher`.

   If `python3` is unavailable, use `python`. The script:
   - Parses the wiki host (e.g. `en.wikipedia.org`, `ja.wikipedia.org`,
     `en.wiktionary.org`) and the page title from either a `/wiki/<Title>` path
     or a `/w/index.php?title=<Title>` query.
   - Calls the MediaWiki API:
     `https://<host>/w/api.php?action=query&prop=revisions&rvprop=content&rvslots=main&formatversion=2&format=json&redirects=1&titles=<Title>`
   - Follows redirects and prints the raw wikitext (UTF-8) to stdout.
   - Fetches via `curl` (primary), which validates against the OS trust store —
     reliable even where Python's own CA bundle is missing/expired. It falls back
     to Python's `urllib` only if `curl` is not on PATH. No setup needed.

3. **Save the result to a file in the current working directory** (the project /
   repo root the user is working in — **not** a temp or scratchpad directory).
   Redirect the script's stdout to `<PageTitle>.wikitext`, where `<PageTitle>` is
   the page title with characters illegal in filenames (`/ \ : * ? " < > |`)
   replaced by `_`. For example:

   ```bash
   python3 "<this-skill-dir>/scripts/get_wikitext.py" "<URL>" > "K6_(software).wikitext"
   ```

   Then tell the user the saved path and show a short excerpt. If the script exits
   non-zero, report the error instead of writing an empty file.

## Manual fallback (no Python at all)

Fetch the raw source directly — the MediaWiki `action=raw` endpoint returns
plain wikitext:

```bash
curl -sL "https://<host>/w/index.php?title=<Title>&action=raw"
```

Extract `<host>` and `<Title>` from the URL by hand (URL-decode the title,
keep underscores or spaces — MediaWiki accepts either). This avoids JSON parsing
but does not report redirects explicitly.

## Notes

- Works for any MediaWiki site that exposes `/w/api.php`, not just Wikipedia.
- A missing page yields an error/`missing` flag — report that clearly rather
  than returning empty output.
- Do not strip or "clean up" the wikitext unless the user asks; return it as-is.
