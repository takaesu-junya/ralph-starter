# ralph-starter

Ralph Wiggum パターンを試すためのスターターリポジトリです。

これは、作るもの・使う技術・実行環境を細かく決めるためのリポジトリではありません。
Ralph を試す人が、自分の題材と道具を選べる状態を保つための最小スターターです。
Docker を使っても使わなくてもよく、PHP / Laravel でも Rust でも、好きな道具で構いません。
ライブラリを使っても、あえて自作しても構いません。

目的は 1 つだけです。

> Ralph に渡す入力を用意し、AI の headless ループで小さな作業を積み上げる流れを体験する。

## 読む順番

- [docs/HOW_RALPH_WORKS.md](docs/HOW_RALPH_WORKS.md): ループの仕組み
- [.claude/skills/ralph-plan/README.md](.claude/skills/ralph-plan/README.md): `ralph-plan` skill の説明

## 基本の流れ

1. `/ralph-plan ...` で Ralph 用のスプリントを準備する
2. `./ralph.sh ralph/sprints/<sprint-name> [N]` でループを回す
3. 進捗はスプリントディレクトリ内のファイルと Git 履歴に残る

```text
/ralph-plan <やりたいこと> の Ralph スプリントを準備して
```

```sh
./ralph.sh ralph/sprints/<sprint-name> [N]
```

`N` は最大イテレーション数です。途中で止めても、ファイルと Git 履歴に進捗が残ります。

## ralph-plan Skill

`ralph-plan` は、Ralph を回す前にスプリントを準備するための skill です。

```text
/ralph-plan <やりたいこと> の Ralph スプリントを準備して
```

## ralph-plan がすること

- ユーザーと対話して、Ralph に渡す作業単位を整理する
- `ralph/sprints/<sprint-name>/` を作る
- Ralph が読む入力ファイルと、Ralph が追記する状態ファイルを置く
- 最後に `./ralph.sh ...` の起動コマンドを提示する

## ralph-plan skill が作るもの

```text
ralph/sprints/<sprint-name>/
├── PRD.json
├── PROMPT.md
├── progress.txt
└── decisions.md
```

## Ralph Wiggum パターン

Ralph は、同じ指示を AI に繰り返し渡し、途中状態をファイルに残しながら作業を進めるパターンです。

基本要素は 3 つです。

- 小さな作業単位
- 毎回読み込む常駐指示
- 完了シグナル

`ralph-plan` は、Ralph が迷わずループに入れるように、最初の入力を用意します。

## grill-me との関係

`ralph-plan` は、`grill-me` と同じく 1 問ずつ確認しながら進めます。

違いは、`ralph-plan` の出力が Ralph 用のスプリントファイルであることです。

## 参考

- https://ghuntley.com/ralph/
- https://www.humanlayer.dev/blog/brief-history-of-ralph
