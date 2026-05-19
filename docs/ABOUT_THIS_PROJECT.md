# ABOUT_THIS_PROJECT

このリポジトリ自体についての説明（目的・技術スタック・ディレクトリ構成）。
Ralph 運用の手順は [`ABOUT_RALPH.md`](./ABOUT_RALPH.md) を参照。

## このプロジェクト

TODO 管理 Web アプリケーション。Laravel の MVC（Routing / Controller / Eloquent Model / Blade View）
を使ってブラウザから操作できる、いわゆる "rails-new / laravel-new" 直後のような最小プロダクト。

開発手段として Ralph（AI 自律タスク実行ループ）を用いる。実装ファイルは未生成の状態で
リポジトリにあり、`PRD.json` の受け入れ基準を満たすコードを Ralph が継続的に積み上げる。

スコープ:

- ブラウザで `/todos` を開くと一覧が見える
- 作成フォームから Todo を追加できる
- 各 Todo に詳細・編集・削除がある
- 永続化は PostgreSQL（docker compose で起動）
- **すべてのコマンドは Docker Compose コンテナ内で実行**（ホスト側に PHP を入れない）

現在の `PRD.json` の 7 story:

1. プロジェクト基盤（Laravel + PostgreSQL + docker compose、ルートから `/todos` へ）
2. Todo モデル + Laravel マイグレーション
3. 一覧画面: `GET /todos`（Blade で一覧表示、空状態あり）
4. 作成: `GET /todos/create` フォーム + `POST /todos`（バリデーション + フラッシュ通知）
5. 詳細・編集: `GET /todos/{id}` / `GET /todos/{id}/edit` / `PATCH /todos/{id}`
6. 削除: `DELETE /todos/{id}`（一覧の削除ボタン経由、確認あり）
7. 仕上げ: pint / phpunit を 1 コマンド化

## 技術スタック

リポジトリルートの `AGENTS.md` に正本がある。Ralph はこれに沿って実装する。

| レイヤ | 採用 |
| --- | --- |
| 言語 | PHP 8.3 |
| フレームワーク | Laravel 11（MVC: Controller + Eloquent + Blade） |
| ORM | Eloquent（Laravel 同梱） |
| マイグレーション | Laravel Migrations（`php artisan migrate`） |
| ビュー | Blade（`resources/views/` 配下） |
| ルーティング | `routes/web.php`（リソースコントローラ） |
| DB | PostgreSQL 16（docker compose で起動） |
| パッケージ管理 | Composer |
| テスト | PHPUnit（`php artisan test`、feature test 中心） |
| Formatter | Laravel Pint |
| 静的解析 | Larastan / PHPStan |
| 実行環境 | **Docker Compose 必須**（ホスト側に PHP を入れない） |

スタックを変更する場合は `AGENTS.md`（技術スタック・実コマンド・規約）と
`ralph/sprints/todo-api-mvp/PRD.json`（受け入れ基準）を書き換える。

## コンテナ必須の方針

PHP / Composer / Artisan / PHPUnit / Pint を **ホスト側にインストールしない**。
すべて `docker compose exec app ...` 経由で実行する。理由:

- 「macOS で `brew install php` が必要」のような環境依存をなくす
- CI と開発機で同じ PHP バイナリ・拡張を使う
- README の手順を「`docker compose up -d` から始める」1 本に揃える

具体的なコマンド形は `AGENTS.md` の「実コマンド」セクションを参照。

## ディレクトリ構成

```
ralph-todo-sample/
├── README.md                              インデックス（薄い）
├── AGENTS.md                              プロジェクト全体規約の正本（HOW）
├── CLAUDE.md                              @AGENTS.md ブリッジ
├── ralph.sh                               実行ループ本体
├── docs/
│   ├── ABOUT_THIS_PROJECT.md              このファイル（プロジェクト概要）
│   ├── ABOUT_RALPH.md                     このリポジトリで Ralph をどう運用するか
│   └── HOW_RALPH_WORKS.md                 Ralph の仕組みの図解
├── .claude/
│   └── skills/
│       ├── ralph/                         Ralph Skill（仕様は ralph/README.md）
│       │   ├── README.md                  Ralph パターンの説明
│       │   ├── SKILL.md                   Claude が読む規約
│       │   └── templates/                 PRD / PROMPT のひな形
│       └── grill-me/                      初期フェーズ用 Skill（Matt Pocock, MIT）
│           └── SKILL.md
└── ralph/
    └── sprints/
        └── todo-api-mvp/                  既定のスプリント
            ├── PRD.json                   タスク定義（WHAT・MVC Web アプリ）
            ├── PROMPT.md                  Ralph への常駐指示書（ループ手続き）
            ├── progress.txt               Ralph が追記する進捗ログ
            └── decisions.md               世代をまたぐ設計判断
```

`AGENTS.md` はプロジェクト全体に効く正本（技術スタック・規約・実コマンド）。
スプリント固有のループ手続きだけが `ralph/sprints/<sprint>/PROMPT.md`。
`CLAUDE.md` は `@AGENTS.md` 1 行のブリッジ。

## 前提環境

- macOS / Linux
- **Docker / Docker Compose**（必須。PHP はコンテナ内でしか動かさない）
- **ブラウザ**（Chromium / Firefox / Safari いずれか。動作確認用）
- [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude` CLI)
- `gh` CLI（PR / issue 連携を試したい場合）

## 状態

- Ralph 実行前: 実装ファイルなし。`PRD.json` の全 story が `"passes": false`
- Ralph 実行後: `app/Http/Controllers/` `app/Models/` `resources/views/` 等に Laravel 実装、
  `docker-compose.yml`、テストが生成され、全 story が `"passes": true` になり、
  ブラウザから `http://localhost/todos` を開くと一覧 UI が表示される状態が期待値
