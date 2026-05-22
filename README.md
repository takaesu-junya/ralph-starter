# ralph-starter

Ralph Wiggum パターンを試すためのスターターリポジトリです。

このリポジトリは、特定のアプリケーション仕様や技術スタックを教えるためのものではありません。
Docker を使っても使わなくてもよく、PHP / Laravel でも Rust でも、好きな道具で構いません。
ライブラリを使っても、あえて自作しても構いません。

目的は 1 つだけです。

> Ralph に渡す入力を用意し、AI の headless ループで小さな作業を積み上げる流れを体験する。

## 読む順番

- [docs/ABOUT_RALPH.md](docs/ABOUT_RALPH.md): Ralph の使い方
- [docs/HOW_RALPH_WORKS.md](docs/HOW_RALPH_WORKS.md): ループの仕組み
- [.claude/skills/ralph-plan/README.md](.claude/skills/ralph-plan/README.md): `ralph-plan` skill の説明

## 基本の流れ

1. `/ralph-plan ...` で Ralph 用のスプリントを準備する
2. `./ralph.sh ralph/sprints/<sprint-name> [N]` でループを回す
3. 進捗はスプリントディレクトリ内のファイルと Git 履歴に残る
