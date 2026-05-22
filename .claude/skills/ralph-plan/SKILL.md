---
name: ralph-plan
description: Ralph ループに渡すスプリントを準備する。ユーザーと対話し、PRD.json / PROMPT.md / progress.txt / decisions.md を ralph/sprints/<sprint-name>/ に配置する。
---

# ralph-plan Skill

この skill は、Ralph 実行前の準備フェーズを担当します。

## 進め方

- ユーザーに 1 度に 1 つだけ質問する
- それぞれの質問に、可能ならおすすめを添える
- コードや既存ファイルを読めば分かることは、ユーザーに聞かずに確認する
- 実装技術や細かい設計を、この skill 側で勝手に固定しない

## ralph-plan skill が作るもの

```text
ralph/sprints/<sprint-name>/
├── PRD.json
├── PROMPT.md
├── progress.txt
└── decisions.md
```

## PRD.json

Ralph が進める作業単位を置きます。

- すべての作業は最初 `passes: false`
- Ralph が完了した作業だけ `passes: true` にする
- 1 回のループで進められる程度に小さくする

## PROMPT.md

Ralph が毎回読む常駐指示です。

書く内容は、ループの進め方に絞ります。

- headless で動くこと
- 1 回に 1 つだけ進めること
- 進捗を追記すること
- 全部終わったら `<promise>COMPLETE</promise>` を出すこと

特定の言語、フレームワーク、ディレクトリ設計、コマンドは必要がある場合だけスプリント側で決めます。

## 状態ファイル

- `progress.txt`: Ralph の作業ログ
- `decisions.md`: 後続ループに残したい判断

どちらも最初は空で作ります。

## 最後に返すもの

- 作ったスプリントディレクトリ
- 作業単位の短い一覧
- 起動コマンド

```sh
./ralph.sh ralph/sprints/<sprint-name> [N]
```

## 守ること

- この skill は、特定のアプリ仕様や技術スタックを押し付けない
- 不明点を大量に並べず、1 問ずつ確認する
- ユーザーが求めていない実装詳細をドキュメントに書き込みすぎない
