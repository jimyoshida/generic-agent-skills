---
name: explainer
description: Explain a technology, technique, tool, platform, or concept using a structured format (Kind, Background, and more). Triggered when the user wants a structured tech overview. Keywords include "explain", "explainer", "tech overview", "describe tool", "what is".
---

# Tech Explainer

Explain a given technology, technique, tool, platform, or concept using the structured format below. Use the context7 MCP tools to fetch up-to-date documentation when available. Write clearly and concisely in English.

## Trigger

When the user asks to explain, describe, or break down a specific technology, technique, tool, platform, or concept using this structured format. Keywords include "explain", "explainer", "tech overview", "describe tool", "what is".

## Instructions

Given a topic, produce an explanation with the following sections:

### Kind

Define what the topic is and categorize it (e.g., programming language, design pattern, protocol, framework, platform, algorithm, etc.).

### Background

Describe the background context and the problem(s) this topic solves. Why does it exist? What need does it address?

### Mechanism

Explain how it works: the operating principles, architecture, or implementation details. Highlight its strengths and key characteristics.

### Inspired by

List what influenced or inspired the topic — predecessor technologies, research papers, other tools, or concepts it draws from.

### History

Provide a brief history and timeline of major milestones (creation, major releases, adoption events, etc.).

### Related to

List similar or related items — alternatives, competitors, complementary technologies, or concepts in the same domain.

### Story

Write a concrete user story that illustrates a practical use case. Describe a realistic scenario where someone would use this technology to solve a problem.

### Code

Provide code examples used in the story above. Keep them minimal, runnable, and well-commented.

## Guidelines

- Fetch current documentation via context7 when the topic is a library, framework, or tool.
- Keep each section focused and concise — prefer bullet points or short paragraphs.
- Use accurate, up-to-date information. If uncertain about details, state so explicitly.
- Adapt the depth of each section to the complexity of the topic.
- The Code section may be omitted if the topic is purely conceptual (e.g., a design principle or methodology).
