---
name: dictionary
description: Use as an English-Japanese / Japanese-English dictionary and thesaurus. Triggered when the user wants to look up word meanings, translations, synonyms, antonyms, collocations, or etymology. Keywords include "meaning", "define", "translate", "synonym", "antonym", "collocation", "etymology", "thesaurus", "dictionary".
---

# English-Japanese / Japanese-English Dictionary & Thesaurus

Look up the word or phrase provided in $ARGUMENTS and respond as a dictionary/thesaurus.

## Language Detection

- If the input is in English: use English-to-Japanese mode
- If the input is in Japanese: use Japanese-to-English mode
- If explicitly specified by the user, follow their instruction

## English-to-Japanese Mode

For the given English word or phrase, output the following sections:

### 1. Basic Information
- **Headword**: the word (with IPA pronunciation)
- **Parts of speech**: all applicable
- **Definitions**: list major Japanese translations per part of speech, ordered by frequency

### 2. Synonyms
- List 5-10 synonyms with brief Japanese notes on nuance differences

### 3. Antonyms
- List antonyms with Japanese translations

### 4. Collocations
- List common co-occurring expressions grouped by pattern (verb+noun, adjective+noun, adverb+verb, etc.)
- Include Japanese translations for each collocation

### 5. Etymology / PIE Root
- Identify the Proto-Indo-European (PIE) root of the word and explain its meaning
- List other English words sharing the same PIE root
- Briefly describe the derivation path, including intermediate forms (Latin, Greek, etc.) where possible

### 6. Example Sentences
- Provide 2-3 representative sentences with Japanese translations

## Japanese-to-English Mode

For the given Japanese word or phrase, output the following sections:

### 1. Basic Information
- **Headword**: the Japanese word (with reading in hiragana)
- **English translations**: multiple English equivalents with explanations of nuance differences

### 2. Japanese Synonyms
- List similar Japanese expressions

### 3. English Synonym Expansion
- For each English translation listed above, provide additional English synonyms

### 4. Example Sentences
- Provide 2-3 pairs of Japanese and corresponding English sentences

## Output Format

- Use Markdown with headings and bullet lists for readability
- Look up the word/phrase given in $ARGUMENTS
