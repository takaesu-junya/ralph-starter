#!/bin/bash
set -euo pipefail

# Ralph Wiggum - autonomous task execution loop (minimal generic version)
#
# Usage:
#   ./ralph.sh <sprint_dir> [max_iterations]
# Example:
#   ./ralph.sh ralph/sprints/todo-api-mvp 10
#
# このスクリプトは「PRD.json と PROMPT.md と progress.txt とログを合成し、
# claude CLI に渡してループを回す」というだけの薄いラッパーです。
#
# 責務分離:
#   - ralph.sh        : ループ・終了判定・ログ合成だけ。AI への指示は一切書かない
#   - PRD.json        : WHAT — 何を作るか（passes フラグで進捗管理）
#   - PROMPT.md       : ループ手続き（1 イテ 1 ストーリー、完了シグナル、headless 等）
#   - AGENTS.md       : HOW — 技術スタック・規約・実コマンド（リポジトリルート）
#                       Claude Code が cwd→CLAUDE.md→@AGENTS.md の経路で自動ロードする
#
# Sub issue 連携や PR 作成のような外部副作用も PROMPT.md 側で
# AI に gh コマンドを叩かせて実現します（このスクリプトには書きません）。

trap 'echo ""; echo "=== INTERRUPTED ==="; exit 130' INT TERM

SPRINT_DIR="${1:?Usage: ./ralph.sh <sprint_dir> [max_iterations]}"
MAX_ITERATIONS="${2:-10}"
ITERATION=0

if [ ! -d "$SPRINT_DIR" ]; then
  echo "Error: ディレクトリが見つかりません: $SPRINT_DIR"
  exit 1
fi

SPRINT_DIR_ABS="$(cd "$SPRINT_DIR" && pwd)"
PRD_FILE_ABS="$SPRINT_DIR_ABS/PRD.json"
PROMPT_FILE_ABS="$SPRINT_DIR_ABS/PROMPT.md"
PROGRESS_FILE_ABS="$SPRINT_DIR_ABS/progress.txt"
LOG_FILE="$SPRINT_DIR_ABS/ralph-output.log"

if [ ! -f "$PRD_FILE_ABS" ]; then
  echo "Error: PRD.json が見つかりません: $PRD_FILE_ABS"
  exit 1
fi
if [ ! -f "$PROMPT_FILE_ABS" ]; then
  echo "Error: PROMPT.md が見つかりません: $PROMPT_FILE_ABS"
  exit 1
fi

# 全出力をターミナルとログファイルに同時出力
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Ralph Wiggum Log Started: $(date '+%Y-%m-%d %H:%M:%S') ==="
echo "Sprint:         $SPRINT_DIR_ABS"
echo "Max iterations: $MAX_ITERATIONS"
echo "Log file:       $LOG_FILE"
echo ""

while [ "$ITERATION" -lt "$MAX_ITERATIONS" ]; do
  ITERATION=$((ITERATION + 1))
  echo ""
  echo "--- Iteration $ITERATION / $MAX_ITERATIONS ---"
  echo "$(date '+%Y-%m-%d %H:%M:%S')"

  PROMPT="## Sprint Directory
$SPRINT_DIR_ABS

## PRD.json (current state — WHAT to build)
\`\`\`json
$(cat "$PRD_FILE_ABS")
\`\`\`

## progress.txt (prior progress)
\`\`\`
$(cat "$PROGRESS_FILE_ABS" 2>/dev/null || echo "No progress yet - first iteration")
\`\`\`

## ralph-output.log (previous execution log - last 300 lines)
\`\`\`
$(tail -n 300 "$LOG_FILE" 2>/dev/null || echo "No log yet")
\`\`\`

---

$(cat "$PROMPT_FILE_ABS")
"

  OUTPUT=$(claude -p \
    --max-turns 200 \
    "$PROMPT" \
    --allowedTools \
      "Bash(git *)" \
      "Bash(gh *)" \
      "Bash(jq *)" \
      "Bash(mv *)" \
      "Bash(cp *)" \
      "Bash(mkdir *)" \
      "Bash(ls *)" \
      "Bash(cat *)" \
      "Bash(echo *)" \
      "Bash(rm *)" \
      "Bash(touch *)" \
      "Bash(chmod *)" \
      "Bash(pwd)" \
      "Bash(cd *)" \
      "Bash(date *)" \
      "Bash(wc *)" \
      "Bash(head *)" \
      "Bash(tail *)" \
      "Bash(diff *)" \
      "Bash(sort *)" \
      "Bash(which *)" \
      "Bash(env *)" \
      "Bash(curl *)" \
      "Bash(docker *)" \
      "Bash(docker-compose *)" \
      "Bash(docker compose *)" \
      "Bash(php *)" \
      "Bash(composer *)" \
      "Bash(artisan *)" \
      "Bash(pint *)" \
      "Bash(phpunit *)" \
      "Bash(phpstan *)" \
      "Read" \
      "Write" \
      "Edit" \
      "Glob" \
      "Grep" \
      "Skill" \
    2>&1) || true

  echo "$OUTPUT"

  if echo "$OUTPUT" | grep -q '<promise>COMPLETE</promise>'; then
    echo ""
    echo "=== COMPLETE ==="
    echo "All stories completed at iteration $ITERATION"
    exit 0
  fi

  echo "--- Iteration $ITERATION done ---"
done

echo ""
echo "=== MAX ITERATIONS REACHED ==="
echo "Completed $MAX_ITERATIONS iterations without COMPLETE signal."
echo "Check $PROGRESS_FILE_ABS for current progress."
exit 2
