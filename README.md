# ralph-starter

Ralph Wiggum パターンを試すためのスターターリポジトリです。

これは、作るもの・使う技術・実行環境を細かく決めるためのリポジトリではありません。
Ralph を試す人が、自分の題材と道具を選べる状態を保つための最小スターターです。
Docker を使っても使わなくてもよく、PHP / Laravel でも Rust でも、好きな道具で構いません。
ライブラリを使っても、あえて自作しても構いません。

目的は 1 つだけです。

> Ralph に渡す入力を用意し、AI の headless ループで小さな作業を積み上げる流れを体験する。

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

## Ralph の仕組み

Ralph の中心は単純です。

1. 作業を小さな単位に分ける
2. AI に 1 回で 1 単位だけ進めさせる
3. 進捗をファイルに残す
4. 完了するまで同じループを繰り返す

### 準備フェーズ

`ralph-plan` skill が、対話しながら次のスプリントディレクトリを作ります。

```text
ralph/sprints/<sprint-name>/
├── PRD.json
├── PROMPT.md
├── progress.txt
└── decisions.md
```

### 実行フェーズ

`ralph.sh` がスプリントの入力を読み、headless の AI 実行を繰り返します。

```text
ralph.sh
  -> AI に入力を渡す
  -> AI が作業する
  -> 進捗を書き残す
  -> まだ終わっていなければ次のループへ
```

### 完了

全部終わったと AI が判断したら、完了シグナルを出します。

```text
<promise>COMPLETE</promise>
```

`ralph.sh` はこの文字列を見つけてループを終了します。

この仕組みは、特定の言語・フレームワーク・アプリ仕様には依存しません。

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
