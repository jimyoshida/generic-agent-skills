---
name: wiki-history-checker
description: Use when the user provides the wikitext of a MediaWiki/Wikipedia article (a .wikitext/.txt file or pasted markup) and wants to find events its chronology is MISSING. Works on dedicated "Timeline of ..." pages AND on the History section of any ordinary article. Parses the existing dated entries, numbers them, researches notable events for the theme, cross-checks against the latest version/release info, and reports gaps as suggested new entries with the entry number each would take. Triggers on "find missing events", "gaps in this timeline", "check this history", "what's missing from this history/timeline", "research this timeline", "suggest events for this timeline".
version: 1.0.0
allowed-tools: Read, WebSearch, WebFetch
---

# Wiki History Checker

Given the **wikitext** of a MediaWiki article, work out its **theme**, catalog
the events it **already lists** (numbered), research what notable events
**should** appear, and produce **edit-ready additions** for the missing ones —
each tagged with the entry number it would occupy and carrying **full citation
info** so it can be pasted straight into the article.

**The goal is to help update the article.** Output must be ready to paste, not
just advice — every suggested event ships with a complete, verifiable citation.

Input (a `.wikitext`/`.txt` file path, or raw wikitext): `$ARGUMENTS`

## Scope

Two kinds of input, in order of preference:

1. **A dedicated chronology article** — "Timeline of X", "History of X", "List of
   X by year", or any article whose body is a dated list/table of events.
2. **An ordinary article with a `== History ==` section** — most subject
   articles (software, companies, products, people) narrate their chronology in a
   History section as prose. **Prefer reading that History section over expecting
   a "Timeline of…" article** — it's the common case, and its dated sentences are
   an implicit timeline worth checking. Also mine the infobox for dates
   (founded/released/latest release, etc.).

If the article has neither a chronological body nor a History section and no
dated events anywhere, say so and stop rather than inventing a timeline.

## Steps

### 1. Read the wikitext

The user supplies the wikitext directly — either a **file path** (`Read` it) or
**pasted markup** in the conversation. There is no fetching step. If neither is
present, ask for the wikitext.

### 2. Identify the theme

From the title and lead section, state the timeline's **theme** and its
**scope** in one line — subject, geography, and the time span it covers (e.g.
"Timeline of aviation — worldwide, powered flight from 1903 to present"). The
scope bounds what counts as "missing": an event outside the article's stated
span or subject is out of scope, not a gap.

### 3. Parse and number the existing entries

Extract every dated event from the wikitext into chronological order. Timelines
appear in several markups — handle whichever is present:

- Bulleted/`*` or `#` lists with a leading date.
- Wikitables (`{| ... |}`) with a date column.
- `; date : event` definition lists, section-per-year headings, etc.

For each entry capture **(date, one-line description)**. Assign **entry numbers**
`1..N` in chronological order — these are the reference handles used throughout.
If the article already numbers its rows, keep those numbers and say so. Report
the count and the covered span (first date → last date).

### 4. Research candidate events

Using `WebSearch` / `WebFetch` and your own knowledge, assemble the set of
notable events that a well-developed timeline on this theme would include, within
the article's scope. Good sources: the topic's main Wikipedia article and its
"See also" siblings, other-language versions of the same timeline, authoritative
domain references. Prefer events with a verifiable date and a citation.

**Record full citation info for every candidate**, because these will become
`<ref>` tags in the article. For each event, capture enough to build a complete
citation template — for a web source that means **title, URL, website/publisher,
publication date, author (if named), and access date (today)**; use `{{Cite
web}}`, `{{Cite news}}`, `{{Cite press release}}`, etc. as appropriate. An event
you cannot cite this fully is not edit-ready — either dig up the source or label
it "unverified — needs a source" and keep it out of the paste-ready output.

**Always check the latest version / current state.** For anything that ships
releases or evolves (software, standards, products, organizations), look up the
**current latest version and its date** from an authoritative source (GitHub
releases, official release notes, the project site) and compare it to:

- the **infobox** "latest release" fields, and
- the most recent event the History/timeline actually narrates.

Timelines and infoboxes go stale fast. Flag when the article's latest-version
info is out of date, and treat every release/milestone newer than the last
narrated event as a missing entry. Note the article's last-covered date
explicitly in the report.

### 5. Diff → find the gaps

Compare the researched set against the numbered existing entries. A candidate is
**missing** only if no existing entry already covers it (watch for the same event
phrased differently or dated to an adjacent year). Also flag, separately and
briefly, any **thin periods** — long date ranges with few or no entries — as
areas likely under-covered.

### 6. Report

Lead with the theme/scope line and the existing-entry stats (count + span). Then
give the **suggested missing events** as a table, most clearly-missing first:

| # (insert at) | Date | Suggested event | Why it belongs | Citation |
|---------------|------|-----------------|----------------|----------|

- **# (insert at)** is the entry number the event would take in the current
  chronological numbering — e.g. `between 12 and 13`, or `new 1` if it predates
  everything. Because inserts shift later numbers, express positions relative to
  the **current** numbering; don't renumber the whole list.
- **Citation** is the source's key details (title + URL + date), not a bare link
  — the full metadata recorded in step 4.

Then — this is the main deliverable — give the **ready-to-paste wikitext**: the
new/updated entries in the article's existing markup (same list/table/prose
style), each with a complete `<ref>{{Cite ...}}</ref>` built from the recorded
citation. If the latest-version info in the infobox is stale, also give the
corrected infobox field(s). The user should be able to paste your output into the
article with no further editing.

## Guidelines

- **Suggest, don't fabricate.** Every proposed event needs a real, checkable date
  and source. If you can't verify one, label it "unverified — needs a source"
  rather than presenting it as fact.
- Respect the article's stated scope — don't pad it with out-of-theme or
  out-of-span events, and note when a candidate is borderline.
- **Every paste-ready entry carries a complete citation.** The purpose is to
  update the article, so an addition without a full, verifiable `<ref>` is not
  finished work — cite it or drop it from the paste-ready output.
- Add, don't destroy: the paste-ready output supplies new entries (and corrected
  stale fields like the infobox latest release); it must not delete or reword the
  article's existing sourced content.
- If the timeline is already comprehensive for its scope, say so plainly instead
  of manufacturing gaps.
- Note the article's last-covered date; timelines often lag recent events, which
  is a common and useful class of gap to surface.
