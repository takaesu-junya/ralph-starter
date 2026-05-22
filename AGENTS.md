# AGENTS.md

このリポジトリは Ralph Wiggum パターンを試すためのスターターです。

ここには、実装方式を縛る細かい技術要件は置きません。Ralph を体験する人は、好きな言語、
フレームワーク、実行環境、ライブラリを選んで構いません。

## 目的

- Ralph の準備フェーズと実行ループを試す
- `ralph-plan` でスプリントを作る
- `ralph.sh` で headless ループを回す
- 進捗をファイルと Git 履歴に残す

## ファイルの役割

- `AGENTS.md`: このリポジトリの最小方針
- `CLAUDE.md`: Claude Code 用のブリッジ
- `ralph.sh`: Ralph ループを回すスクリプト
- `ralph/sprints/<sprint>/`: Ralph が読むスプリント入力
- `.claude/skills/ralph-plan/`: スプリント準備用 skill
- `.claude/skills/grill-me/`: 対話で意思決定を詰めるための skill

## 方針

- 実装の詳細は、スプリントごとの `PRD.json` と `PROMPT.md` に任せる
- このスターター自体には、特定のアプリ仕様や技術スタックを固定しない
- 迷ったら、Ralph の説明と最小限の運用情報だけを残す

## 注意

- シークレットや個人情報はコミットしない
- 既存のスプリントや作業ログを消す場合は、必要性を確認してから行う
