#!/usr/bin/env python3
"""Fetch the raw MediaWiki wikitext for a given Wikipedia/MediaWiki page URL.

Usage:
    python3 get_wikitext.py "https://en.wikipedia.org/wiki/Python_(programming_language)"

Prints the page's raw wikitext to stdout. Exits non-zero on error.
"""
import json
import shutil
import subprocess
import sys
import urllib.parse
import urllib.request


def parse_wiki_url(url: str):
    """Return (host, title) parsed from a MediaWiki page URL."""
    parsed = urllib.parse.urlparse(url)
    if not parsed.scheme:
        parsed = urllib.parse.urlparse("https://" + url)

    host = parsed.netloc
    if not host:
        raise ValueError(f"Could not determine wiki host from URL: {url}")

    # Case 1: /w/index.php?title=Foo
    query = urllib.parse.parse_qs(parsed.query)
    if "title" in query and query["title"]:
        return host, query["title"][0]

    # Case 2: /wiki/Foo  (or other article path ending in /Title)
    path = parsed.path
    marker = "/wiki/"
    if marker in path:
        title = path.split(marker, 1)[1]
    else:
        # Fallback: last path segment
        title = path.rstrip("/").rsplit("/", 1)[-1]

    if not title:
        raise ValueError(f"Could not determine page title from URL: {url}")

    # URL-decode (%20 -> space, etc.); MediaWiki accepts spaces or underscores.
    title = urllib.parse.unquote(title)
    return host, title


USER_AGENT = "wikitext-fetcher/1.0 (Claude Code skill)"


def build_api_url(host: str, title: str) -> str:
    params = {
        "action": "query",
        "prop": "revisions",
        "rvprop": "content",
        "rvslots": "main",
        "formatversion": "2",
        "format": "json",
        "redirects": "1",
        "titles": title,
    }
    return f"https://{host}/w/api.php?" + urllib.parse.urlencode(params)


def parse_api_json(data: dict, host: str, title: str) -> str:
    pages = data.get("query", {}).get("pages", [])
    if not pages:
        raise RuntimeError(f"No page data returned for '{title}' on {host}.")

    page = pages[0]
    if page.get("missing"):
        raise RuntimeError(f"Page not found: '{page.get('title', title)}' on {host}.")

    revisions = page.get("revisions")
    if not revisions:
        raise RuntimeError(f"No revision content available for '{title}' on {host}.")

    return revisions[0]["slots"]["main"]["content"]


def _fetch_curl(url: str) -> dict:
    """Primary transport. curl validates against the OS trust store, so it works
    even where Python's OpenSSL CA bundle is missing/misconfigured. curl-level
    --max-time/--retry make a transient network stall self-recover and abort
    cleanly instead of hanging the caller."""
    curl = shutil.which("curl")
    if not curl:
        raise RuntimeError("curl not found on PATH")
    result = subprocess.run(
        [curl, "-sSL", "--fail",
         "--connect-timeout", "15",
         "--max-time", "30",
         "--retry", "2", "--retry-delay", "2",
         "-A", USER_AGENT, url],
        capture_output=True,
        text=True,
        encoding="utf-8",
        timeout=90,  # > worst-case curl (2 retries x 30s); curl aborts first
    )
    if result.returncode != 0:
        raise RuntimeError(f"curl failed (exit {result.returncode}): {result.stderr.strip()}")
    return json.loads(result.stdout)


def _fetch_urllib(url: str) -> dict:
    """Last-resort transport for hosts without curl. Depends on Python's own CA
    bundle, which may be missing/expired on some machines."""
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def fetch_wikitext(host: str, title: str) -> str:
    url = build_api_url(host, title)
    # curl first (reliable trust store); urllib only if curl is unavailable/fails.
    data = None
    transport_errors = []
    for name, fetch in (("curl", _fetch_curl), ("urllib", _fetch_urllib)):
        try:
            data = fetch(url)
            break
        except Exception as exc:  # noqa: BLE001 - try the next transport
            transport_errors.append(f"{name}: {exc}")
    if data is None:
        raise RuntimeError("all fetch methods failed -> " + "; ".join(transport_errors))
    # Parse errors (e.g. missing page) are raised as-is, not retried per transport.
    return parse_api_json(data, host, title)


def main(argv):
    # Wikitext is UTF-8; the console's default (e.g. cp1252 on Windows) can't
    # encode it. Force stdout/stderr to UTF-8 so output isn't mangled.
    for stream in (sys.stdout, sys.stderr):
        reconfig = getattr(stream, "reconfigure", None)
        if reconfig:
            reconfig(encoding="utf-8")

    if len(argv) != 2:
        print("Usage: get_wikitext.py <wikipedia-page-url>", file=sys.stderr)
        return 2
    try:
        host, title = parse_wiki_url(argv[1])
        text = fetch_wikitext(host, title)
    except Exception as exc:  # noqa: BLE001 - surface a clean message
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    sys.stdout.write(text)
    if not text.endswith("\n"):
        sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
