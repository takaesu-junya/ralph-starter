# ralph-plan Skill

`ralph-plan` は、Ralph を回す前にスプリントを準備するための skill です。

```text
/ralph-plan <やりたいこと> の Ralph スプリントを準備して
```

## 何をするか

- ユーザーと対話して、Ralph に渡す作業単位を整理する
- `ralph/sprints/<sprint-name>/` を作る
- Ralph が読む入力ファイルと、Ralph が追記する状態ファイルを置く
- 最後に `./ralph.sh ...` の起動コマンドを提示する

## 作るもの

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

この skill は、Ralph が迷わずループに入れるように、最初の入力を用意します。

## grill-me との関係

`ralph-plan` は、`grill-me` と同じく 1 問ずつ確認しながら進めます。

違いは、`ralph-plan` の出力が Ralph 用のスプリントファイルであることです。

## 参考

- https://ghuntley.com/ralph/
- https://www.humanlayer.dev/blog/brief-history-of-ralph
