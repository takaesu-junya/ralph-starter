# AGENTS.md

このファイルは、プロジェクト全体の前提・規約を AI エージェント（Claude Code / Codex /
Copilot CLI 等）と人間で共有するための **正本** です。Ralph が毎イテレーション参照します。

CLAUDE.md は Claude Code 用のブリッジで、中身は `@AGENTS.md` の 1 行だけ。
そうすることで「Claude Code は CLAUDE.md を自動で読む」「他エージェントは AGENTS.md を直接読む」
という両立ができる（片方だけのメンテで済む）。

ファイルの役割分担:

- `AGENTS.md`（このファイル）— **HOW**: 技術スタック・規約・実コマンド
- `ralph/sprints/<sprint>/PRD.json` — **WHAT**: 何を作るか・受け入れ基準
- `ralph/sprints/<sprint>/PROMPT.md` — **ループ手続き**: 1 イテ 1 ストーリー、完了シグナル、headless 等

## 実行環境（必須）

**すべての PHP / Composer / Artisan コマンドは Docker Compose コンテナ内で実行する**。
ホスト側に PHP / Composer をインストールする前提を置かない。Ralph も人間も
`docker compose exec app ...` 経由で操作する。

## 技術スタック

- PHP 8.3
- Laravel 11（HTTP / フレームワーク）
- Eloquent（ORM・Laravel 同梱）
- Laravel Migrations（マイグレーション・`php artisan migrate`）
- PostgreSQL 16（docker compose で起動）
- Composer（パッケージ管理）
- PHPUnit（テスト・Laravel 同梱）
- Laravel Pint（フォーマッタ）
- Larastan / PHPStan（静的解析）

別ライブラリを足さなければ進まないと判断した場合は、当該スプリントの
`decisions.md` に理由を書いてから足してください。

## 実コマンド

すべて `docker compose exec app` 経由で実行する。

- コンテナ起動: `docker compose up -d`
- コンテナ停止: `docker compose down`
- 依存追加: `docker compose exec app composer require <package>`
- 依存インストール: `docker compose exec app composer install`
- フォーマット: `docker compose exec app ./vendor/bin/pint`
- フォーマット確認: `docker compose exec app ./vendor/bin/pint --test`
- 静的解析: `docker compose exec app ./vendor/bin/phpstan analyse`
- テスト: `docker compose exec app php artisan test`
- マイグレーション適用: `docker compose exec app php artisan migrate`
- マイグレーション生成: `docker compose exec app php artisan make:migration <name>`
- 任意の Artisan: `docker compose exec app php artisan <command>`

## コーディング規約

- PHP は PSR-12 準拠（Pint のデフォルトプリセットで自動整形）
- クラス名は PascalCase、メソッド名は camelCase、DB カラムは snake_case
- 不要なコメントは書かない。命名で説明できる範囲は命名で済ます

## API 規約

- レスポンスは JSON。日時は ISO 8601 (UTC)
- HTTP ステータスは 201 (Create) / 200 (Read, Update) / 204 (Delete) / 404 / 422 を守る
- バリデーション失敗時は Laravel の FormRequest で 422 を返す

## DB 規約

- 接続情報は Laravel 標準の `.env` 変数（`DB_CONNECTION`, `DB_HOST`, `DB_PORT`,
  `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`）を使う
- `DB_CONNECTION=pgsql`、`DB_HOST` はコンテナ名（例: `postgres`）

## テスト規約

- テストは `php artisan test`（PHPUnit）で実行
- テスト用 DB は本番テーブルと分離する（`.env.testing` で別 DB or SQLite in-memory）
- 各テストで DB をリセット（`RefreshDatabase` トレイトを使う）

## 禁止事項

- `.env` のコミット（`.env.example` だけコミット）
- シークレット（API キー、DB パスワード等）のコミット
- ホスト側に PHP / Composer を直接インストールして実行すること（コンテナ必須）
