# ABOUT_THIS_PROJECT

このリポジトリ自体についての説明（目的・技術スタック・ディレクトリ構成）。
Ralph パターンの仕様や使い方は [`ABOUT_RALPH.md`](ABOUT_RALPH.md) を参照。

## 目的

Ralph Wiggum パターン（AI に長尺タスクを自律的に回させる手法）を、
誰でも追体験できる最小構成のサンプルとして提供する。

実装ファイル（`app/`、`docker-compose.yml`、`composer.json` など）は
**意図的に入っていない**。`PRD.json` に書かれた受け入れ基準だけを置いておき、
Ralph がそれを満たす最小実装を一から組み立てるところまでを体験できるようにしている。

## 題材

TODO 管理 API（HTTP REST）。

- Create / Read / Update / Delete を全部備える
- 永続化は RDBMS（PostgreSQL）
- **すべてのコマンドは Docker Compose コンテナ内で実行**（ホスト側に PHP を入れない）

最初の `PRD.json` は 7 story で構成される:

1. プロジェクト基盤（Laravel + PostgreSQL + docker compose）
2. Todo モデル + Laravel マイグレーション
3. Create: `POST /todos`
4. Read: `GET /todos` / `GET /todos/{id}`
5. Update: `PATCH /todos/{id}`
6. Delete: `DELETE /todos/{id}`
7. 仕上げ: pint / phpunit を 1 コマンド化

## 想定する技術スタック

リポジトリルートの `AGENTS.md` に正本がある。Ralph はこれに沿って実装する。

| レイヤ | 採用 |
| --- | --- |
| 言語 | PHP 8.3 |
| フレームワーク | Laravel 11 |
| ORM | Eloquent（Laravel 同梱） |
| マイグレーション | Laravel Migrations（`php artisan migrate`） |
| DB | PostgreSQL 16（docker compose で起動） |
| パッケージ管理 | Composer |
| テスト | PHPUnit（`php artisan test`） |
| Formatter | Laravel Pint |
| 静的解析 | Larastan / PHPStan |
| 実行環境 | **Docker Compose 必須**（ホスト側に PHP を入れない） |

スタック自体を変えたい場合は `AGENTS.md`（技術スタック・実コマンド・規約）と
`ralph/sprints/todo-api-mvp/PRD.json`（受け入れ基準）を書き換える。

## コンテナ必須の方針

このプロジェクトでは PHP / Composer / Artisan / PHPUnit / Pint を **ホスト側に
インストールしない**。すべて `docker compose exec app ...` 経由で実行する。
理由:

- 「macOS で `brew install php` が必要」のような環境依存をなくす
- CI と開発機で同じ PHP バイナリ・拡張を使う
- README の手順を「`docker compose up -d` から始める」1 本に揃える

具体的なコマンド形は `AGENTS.md` の「実コマンド」セクションを参照。

## ディレクトリ構成

```
ralph-todo-sample/
├── README.md                              インデックス（薄い）
├── ABOUT_THIS_PROJECT.md                  このファイル
├── ABOUT_RALPH.md                         このリポジトリで Ralph をどう使うか
├── AGENTS.md                              プロジェクト全体規約の正本（HOW）
├── CLAUDE.md                              @AGENTS.md ブリッジ
├── ralph.sh                               実行ループ本体
├── .claude/
│   └── skills/
│       ├── ralph/                         Ralph Skill（仕様は ralph/README.md）
│       │   ├── README.md                  Ralph パターンの説明
│       │   ├── SKILL.md                   Claude が読む規約
│       │   └── templates/                 PRD / PROMPT のひな形
│       └── grill-me/                      初期フェーズ用 Skill（Matt Pocock, MIT）
│           └── SKILL.md
├── ralph/
│   └── sprints/
│       └── todo-api-mvp/                  本リポジトリ既定のスプリント
│           ├── PRD.json                   タスク定義（WHAT・CRUD + RDBMS）
│           ├── PROMPT.md                  Ralph への常駐指示書（ループ手続き）
│           ├── progress.txt               Ralph が追記する進捗ログ
│           └── decisions.md               世代をまたぐ設計判断
└── docs/
    └── HOW_RALPH_WORKS.md                 仕組みの図解
```

`AGENTS.md` はプロジェクト全体に効く正本（技術スタック・規約・実コマンド）。
スプリント固有のループ手続きだけが `ralph/sprints/<sprint>/PROMPT.md`。
`CLAUDE.md` は `@AGENTS.md` 1 行のブリッジ。

## 前提環境

- macOS / Linux
- **Docker / Docker Compose**（必須。PHP はコンテナ内でしか動かさない）
- [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude` CLI)
- `gh` CLI（PR / issue 連携を試したい人向け。なくても動く）

GitHub に push してあるとフル機能（PR 自動作成・issue 連携）で動くが、
ローカル単体でも `./ralph.sh` の挙動は確認できる。

## 状態

- Ralph 実行前: 実装ファイルなし。`PRD.json` の全 story が `"passes": false`
- Ralph 実行後: `app/` 配下に Laravel 実装、`docker-compose.yml`、テストが生成され、
  全 story が `"passes": true` になり、コミット履歴が積まれている状態が期待値
