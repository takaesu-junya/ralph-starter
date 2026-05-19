---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

---

<!--
Source: https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
License: MIT (© 2026 Matt Pocock)
Imported verbatim. 汎用の「意思決定木を 1 問ずつ潰す」スキル。
Ralph スプリント準備の文脈では、`ralph-plan` スキルが内部的にこの手法を採用しているので、
PRD.json を作りたい場合は `/ralph-plan` 経由で呼び出すと、最終的に
ralph/sprints/<sprint-name>/ に成果物が出力される。Ralph と無関係な設計検討では
このスキルを直接 `/grill-me` で呼んでよい。詳細は ../ralph-plan/README.md と
../../../docs/HOW_RALPH_WORKS.md を参照。
-->
