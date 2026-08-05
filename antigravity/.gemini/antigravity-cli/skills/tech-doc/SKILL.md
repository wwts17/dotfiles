---
name: tech-doc
description: Write structured, concise technical design documents, architectural proposals, and plans. Activate when documenting technical proposals, API schemas, or system architecture.
---

# Technical Documentation Guidelines

Structure technical design documents and implementation proposals for clarity, readability, and maintainability.

## Document Structure

1. **Goal & Background:** State problem context, scope boundaries, and core objectives.
2. **User Review Required:** Highlight critical design choices, breaking changes, or trade-offs using GitHub alert blocks.
3. **Proposed Architecture:** Group changes by component with explicit code diffs and Mermaid diagrams.
4. **Verification Plan:** Provide exact automated test commands and manual verification steps.

## Formatting Rules

- Use GitHub-flavored Markdown alerts (`>[!IMPORTANT]`, `>[!NOTE]`).
- Keep bullet points concise and avoid wrapping long paragraphs.
- Format clickable file links as `[filename](file:///absolute/path/to/file)`.
