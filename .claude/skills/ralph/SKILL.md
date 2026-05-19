---
name: ralph
description: Ralph Wiggum パターンの最小実装。PRD.json と PROMPT.md を起点に、1 イテレーション 1 ストーリーで自律的に実装・テスト・コミットを進める。
---

# Ralph Skill (minimal)

このスキルは Ralph Wiggum パターン（同じ PROMPT を高頻度ループで AI に投げ、
途中状態をファイルに書き残しながら長尺タスクを完遂させる手法）の最小構成です。

## 前提となるファイル配置

```
<sprint_dir>/
├── PRD.json          # 何を作るか（受け入れ基準つき）
├── PROMPT.md         # Ralph への常駐指示書
├── progress.txt      # 進捗ログ（Ralph が書く）
└── decisions.md      # 設計判断の引き継ぎ（Ralph が書く）
```

ループスクリプトはリポジトリルートの `ralph.sh`。
`./ralph.sh <sprint_dir> [max_iterations]` で起動します。

## このスキルが担保するルール

1. **1 イテレーション 1 ストーリー**: `PRD.json` の `stories[]` から
   未完（`passes: false`）を 1 つだけ選び、完了させる。複数を同時に進めない。
2. **完了条件は `passes: true`**: ストーリーの受け入れ基準 (`criteria[]`) を
   すべて満たすまで作業を終わらせず、満たした時点で `PRD.json` の
   `passes` を `true` に更新する。
3. **状態はファイルに書く**: 何をやったか・なぜそうしたかは
   `progress.txt` と `decisions.md` に残す。次イテレーションの自分が
   読んで判断できる粒度で書く。
4. **コミット単位はストーリー単位**: ストーリー完了ごとに 1 コミット。
   コミットメッセージに対応する story id を含める。
5. **完了シグナル**: すべての story が `passes: true` になったら、
   出力の最後に `<promise>COMPLETE</promise>` を書く。

## 1 イテレーションの動き

1. `PRD.json` を読み、`passes: false` のうち id が最小のものを 1 つ選ぶ
2. `criteria[]` を満たす実装をする
3. テスト・型チェック・lint を走らせて緑にする
4. `git add` → `git commit`
5. `PRD.json` の該当 story を `passes: true` に書き換える
6. `progress.txt` に「何を / どう / なぜ」を追記する
7. 次に持ち越したい判断があれば `decisions.md` に追記する
8. まだ未完 story が残っていれば終了（ループに次を任せる）
9. すべて `passes: true` なら、最後に `<promise>COMPLETE</promise>` を出す

## やってはいけないこと

- PROMPT.md / SKILL.md / ralph.sh を勝手に書き換えること（タスクと無関係な変更）
- 複数 story を同じイテレーションで進めること
- 受け入れ基準を満たさないまま `passes: true` に書き換えること
- `<promise>COMPLETE</promise>` を未完成のまま出力すること
- progress.txt や decisions.md の過去ログを上書き・削除すること（追記のみ）

## テンプレート

- `templates/PRD.example.json`: 新しいスプリントを作るときの PRD ひな形
- `templates/PROMPT.example.md`: PROMPT.md のひな形

## 参考

- 本家解説: https://ghuntley.com/ralph/
- 実践 Tips: https://www.aihero.dev/posts/11-tips-for-ai-coding-with-ralph-wiggum
