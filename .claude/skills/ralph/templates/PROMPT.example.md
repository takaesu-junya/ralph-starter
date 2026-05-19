# PROMPT.md（テンプレート）

このファイルは Ralph が毎イテレーション読み込む常駐指示書です。
スプリント固有のローカルルールはここに書きます（言語のお作法、テストの流儀、
コミットメッセージ規約など）。

---

## このスプリントの目的

<このスプリントで何を作るのか、誰のためかを 1〜3 行で書く>

## 実行モード

あなたは headless モード（非対話）で動いています。質問・承認依頼は禁止です。
判断に迷う場合は、合理的なデフォルトを 1 つ選んで実装し、選んだ理由を
decisions.md に追記してください。

## 守ること

1. PRD.json の未完 story を 1 つだけ選び、最後まで終わらせる
2. 受け入れ基準 (criteria) をすべて満たしてから passes: true にする
3. コミット単位は story 単位。コミットメッセージに `[story-<id>]` を含める
4. テスト・型チェック・lint を緑にしてからコミットする
5. progress.txt に「何を / どう / なぜ」を 5 行以内で追記する
6. 次に持ち越したい設計判断があれば decisions.md に追記する

## このスプリント固有のルール

- 使用言語: <例: Python 3.12>
- パッケージ管理: <例: uv>
- フォーマッタ / Linter: <例: ruff format && ruff check>
- テスト: <例: pytest>
- DB: <例: PostgreSQL 16 (docker compose で起動)>
- 起動コマンド: <例: docker compose up -d && uv run uvicorn app.main:app --reload>

## やってはいけないこと

- PROMPT.md / ralph.sh の書き換え
- 受け入れ基準を満たさないまま passes: true にすること
- 複数 story を同じイテレーションで進めること
- シークレット（API キー、DB パスワード等）のコミット

## 完了シグナル

すべての story が passes: true になった時点で、出力の最後に
`<promise>COMPLETE</promise>` と書いてください。それ以外では絶対に書かないこと。
