# PROMPT.md — TODO 管理 Web アプリ MVP スプリント

このファイルは Ralph が毎イテレーション読み込む常駐指示書（ループ手続き）です。

- **WHAT**（何を作るか・受け入れ基準）→ `PRD.json`
- **HOW**（技術スタック・コーディング規約・実コマンド）→ リポジトリルートの `AGENTS.md`
- **ループ手続き**（このファイル）

## このスプリントの目的

`docker compose up -d` の後ブラウザで `/todos` を開くと操作できる TODO 管理 Web アプリ
（Laravel MVC + Blade + PostgreSQL）の MVP を、受け入れ基準を満たす最小実装で完成させること。

## 実行モード

あなたは headless モード（非対話）で動いています。**質問・承認依頼は禁止** です。
判断に迷う場合は、合理的なデフォルトを 1 つ選んで実装し、選んだ理由を
`decisions.md` に追記してください。次イテレーションの自分が読んで再判断できます。

## 1 イテレーションでやること

1. PRD.json の `passes: false` の中から **id が最小の 1 件** を選ぶ
2. その story の `criteria[]` をすべて満たす実装をする（規約・コマンドは AGENTS.md 参照）
3. AGENTS.md の「実コマンド」に従って format / lint / test を緑にする
4. `docker compose up -d` 後にローカル疎通確認できる範囲は curl で `/todos` 等を叩いて HTTP 応答を確認する（ブラウザ自体は人間が後で開く）
5. `git add -A` して、コミットメッセージ `feat: <story title> [story-<id>]` でコミット
6. PRD.json の該当 story の `passes` を `true` に書き換えてコミット（同じコミットに混ぜてよい）
7. `progress.txt` に、このイテレーションで「何を / どう / なぜ」を 5 行以内で追記
8. 持ち越したい設計判断があれば `decisions.md` に追記
9. まだ `passes: false` の story が残っているなら、ここで終了
10. すべての story が `passes: true` になったなら、出力末尾に `<promise>COMPLETE</promise>` と書く

## やってはいけない

- `PROMPT.md` / `AGENTS.md` / `ralph.sh` / `.claude/skills/` の書き換え（タスクと無関係な変更）
- 複数 story を同じイテレーションで進めること
- 受け入れ基準を満たさないままの `passes: true`
- `<promise>COMPLETE</promise>` を未完成のまま出力すること
- 既存の `progress.txt` / `decisions.md` を上書き・削除すること（追記のみ）

## 困ったとき

- 同じエラーで 2 回以上ループしたら、`decisions.md` に状況を書いて
  別アプローチに切り替える
- どうしても進めない場合は、無理にコミットせず `progress.txt` に
  ブロッカーを書いて終了する（次イテレーションの自分が読む）
