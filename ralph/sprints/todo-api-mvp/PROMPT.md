# PROMPT.md — TODO 管理 API MVP スプリント

このファイルは Ralph が毎イテレーション読み込む常駐指示書です。
PRD.json に書かれた story を 1 イテレーション 1 ストーリーで進めてください。

## このスプリントの目的

`docker compose up -d` だけで動く TODO 管理 API（CRUD + PostgreSQL）の MVP を、
受け入れ基準を満たす最小実装で完成させること。

## 実行モード

あなたは headless モード（非対話）で動いています。**質問・承認依頼は禁止** です。
判断に迷う場合は、合理的なデフォルトを 1 つ選んで実装し、選んだ理由を
`decisions.md` に追記してください。次イテレーションの自分が読んで再判断できます。

## 技術スタック

- Python 3.12
- FastAPI（HTTP）
- SQLAlchemy 2.x（ORM）
- Alembic（マイグレーション）
- PostgreSQL 16（docker compose で起動）
- uv（パッケージ管理）
- pytest（テスト）
- ruff（フォーマッタ & Linter）

別ライブラリを足さなければ進まないと判断した場合は、`decisions.md` に
理由を書いてから足してください。

## 1 イテレーションでやること

1. PRD.json の `passes: false` の中から **id が最小の 1 件** を選ぶ
2. その story の `criteria[]` をすべて満たす実装をする
3. `ruff format && ruff check` を緑にする
4. `pytest` を緑にする
5. `docker compose up -d` 後にローカル疎通確認できる範囲は curl で叩いて確認する
6. `git add -A` して、コミットメッセージ `feat: <story title> [story-<id>]` でコミット
7. PRD.json の該当 story の `passes` を `true` に書き換えてコミット（同じコミットに混ぜてよい）
8. `progress.txt` に、このイテレーションで「何を / どう / なぜ」を 5 行以内で追記
9. 持ち越したい設計判断があれば `decisions.md` に追記
10. まだ `passes: false` の story が残っているなら、ここで終了
11. すべての story が `passes: true` になったなら、出力末尾に `<promise>COMPLETE</promise>` と書く

## ローカルルール

- DB 接続文字列は環境変数 `DATABASE_URL` から取る
- テスト用 DB は本番テーブルと分離する（pytest 用に別 DB or 別スキーマ）
- API レスポンスは JSON、日時は ISO 8601（UTC）
- HTTP ステータスは 201 (Create) / 200 (Read, Update) / 204 (Delete) / 404 / 422 を守る
- ファイル / 関数 / クラス名は snake_case / PascalCase の Python 慣習に従う
- 不要なコメントは書かない。命名で説明できる範囲は命名で済ます

## やってはいけない

- `PROMPT.md` / `ralph.sh` / `.claude/skills/` の書き換え（タスクと無関係な変更）
- 複数 story を同じイテレーションで進めること
- 受け入れ基準を満たさないままの `passes: true`
- `<promise>COMPLETE</promise>` を未完成のまま出力すること
- `.env` のコミット（`.env.example` だけコミット）
- 既存の `progress.txt` / `decisions.md` を上書き・削除すること（追記のみ）

## 困ったとき

- 同じエラーで 2 回以上ループしたら、`decisions.md` に状況を書いて
  別アプローチに切り替える
- どうしても進めない場合は、無理にコミットせず `progress.txt` に
  ブロッカーを書いて終了する（次イテレーションの自分が読む）
