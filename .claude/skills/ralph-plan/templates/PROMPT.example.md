# PROMPT.md（テンプレート）

このファイルは Ralph が毎イテレーション読み込む常駐指示書（ループ手続き）です。

役割分担:

- **WHAT**（何を作るか・受け入れ基準）→ `PRD.json`
- **HOW**（技術スタック・規約・実コマンド）→ リポジトリルートの `AGENTS.md`
- **ループ手続き**（このファイル）

技術スタックや lint / test コマンドのようなプロジェクト恒久ファクトはここには書かず、
ルートの `AGENTS.md` に集約してください（Claude Code が自動ロードします）。
このファイルにはスプリントごとに変わる手続きだけを書きます。

---

## このスプリントの目的

<このスプリントで何を作るのか、誰のためかを 1〜3 行で書く>

## 実行モード

あなたは headless モード（非対話）で動いています。質問・承認依頼は禁止です。
判断に迷う場合は、合理的なデフォルトを 1 つ選んで実装し、選んだ理由を
decisions.md に追記してください。

## 1 イテレーションでやること

1. PRD.json の未完 story を 1 つだけ選び、最後まで終わらせる
2. 受け入れ基準 (criteria) をすべて満たしてから passes: true にする
3. AGENTS.md の「実コマンド」に従って format / lint / test を緑にする
4. コミット単位は story 単位。コミットメッセージに `[story-<id>]` を含める
5. progress.txt に「何を / どう / なぜ」を 5 行以内で追記する
6. 次に持ち越したい設計判断があれば decisions.md に追記する

## 1 story を完了とみなす条件（縦スライス）

`passes: true` を立てる前に、以下がすべて成り立っていること。1 つでも欠ければ
passes は立てず、同イテレーション内で不足分を埋める。

- **feature test が 1 本以上存在する**: `tests/Feature/` 配下に、その story の
  挙動を検証するテストが追加されている
- **テストが HTTP 経由で検証している**: `$this->get(...)` / `$this->post(...)` /
  `$this->patch(...)` / `$this->delete(...)` などで実際のリクエスト〜レスポンスを
  通している（モデルの単体テストや、controller を直接呼ぶテストだけでは不十分）
- **テストが緑**: `docker compose exec app php artisan test` が全件成功
- **format / 静的解析が緑**: `pint --test` と `phpstan analyse` が緑
- **レイヤ横断の変更が同一コミットに含まれている**: route / controller / model /
  migration / blade / FormRequest のうち、その story が必要とするものすべてが
  同じコミット内にある（「次の story で controller を作る」のような横割り完了は禁止）

横割り完了の例（やってはいけない）:

- migration だけ追加して passes: true
- controller のスケルトンだけ追加して passes: true
- blade テンプレートだけ追加して passes: true

縦スライス完了の例（OK）:

- `GET /todos` の story を完了するために、migration / Todo モデル / route /
  TodoController@index / `resources/views/todos/index.blade.php` / feature test
  を **同一コミット** で追加し、テスト緑

## やってはいけないこと

- PROMPT.md / AGENTS.md / ralph.sh の書き換え
- 受け入れ基準を満たさないまま passes: true にすること
- 縦スライス条件（上記）を満たさないまま passes: true にすること
- 複数 story を同じイテレーションで進めること
- シークレット（API キー、DB パスワード等）のコミット

## 完了シグナル

すべての story が passes: true になった時点で、出力の最後に
`<promise>COMPLETE</promise>` と書いてください。それ以外では絶対に書かないこと。
