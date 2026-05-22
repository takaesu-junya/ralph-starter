# HOW_RALPH_WORKS

Ralph の中心は単純です。

1. 作業を小さな単位に分ける
2. AI に 1 回で 1 単位だけ進めさせる
3. 進捗をファイルに残す
4. 完了するまで同じループを繰り返す

## 準備フェーズ

`ralph-plan` skill が、対話しながら次のスプリントディレクトリを作ります。

```text
ralph/sprints/<sprint-name>/
├── PRD.json
├── PROMPT.md
├── progress.txt
└── decisions.md
```

## 実行フェーズ

`ralph.sh` がスプリントの入力を読み、headless の AI 実行を繰り返します。

```text
ralph.sh
  -> AI に入力を渡す
  -> AI が作業する
  -> 進捗を書き残す
  -> まだ終わっていなければ次のループへ
```

## 完了

全部終わったと AI が判断したら、完了シグナルを出します。

```text
<promise>COMPLETE</promise>
```

`ralph.sh` はこの文字列を見つけてループを終了します。

この仕組みは、特定の言語・フレームワーク・アプリ仕様には依存しません。
