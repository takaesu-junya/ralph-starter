# ABOUT_THIS_PROJECT

このリポジトリ自体についての説明（目的・技術スタック・ディレクトリ構成）。
Ralph パターンの仕様や使い方は [`ABOUT_RALPH.md`](ABOUT_RALPH.md) を参照。

## 目的

Ralph Wiggum パターン（AI に長尺タスクを自律的に回させる手法）を、
誰でも追体験できる最小構成のサンプルとして提供する。

実装ファイル（`src/`、`docker-compose.yml`、`pyproject.toml` など）は
**意図的に入っていない**。`PRD.json` に書かれた受け入れ基準だけを置いておき、
Ralph がそれを満たす最小実装を一から組み立てるところまでを体験できるようにしている。

## 題材

TODO 管理 API（HTTP REST）。

- Create / Read / Update / Delete を全部備える
- 永続化は RDBMS（PostgreSQL）

最初の `PRD.json` は 7 story で構成される:

1. プロジェクト基盤（FastAPI + PostgreSQL + docker compose）
2. Todo モデル + Alembic マイグレーション
3. Create: `POST /todos`
4. Read: `GET /todos` / `GET /todos/{id}`
5. Update: `PATCH /todos/{id}`
6. Delete: `DELETE /todos/{id}`
7. 仕上げ: ruff / pytest を 1 コマンド化

## 想定する技術スタック

`PRD.json` で前提として書かれているスタック。Ralph はこれに沿って実装する。

| レイヤ | 採用 |
| --- | --- |
| 言語 | Python 3.12 |
| HTTP | FastAPI |
| ORM | SQLAlchemy 2.x |
| マイグレーション | Alembic |
| DB | PostgreSQL 16（docker compose で起動） |
| パッケージ管理 | uv |
| テスト | pytest |
| Linter / Formatter | ruff |
| 実行 | Docker Compose |

スタック自体を変えたい場合は `ralph/sprints/todo-api-mvp/PRD.json` の
`context.tech_stack` と `ralph/sprints/todo-api-mvp/PROMPT.md` を書き換える。

## ディレクトリ構成

```
ralph-todo-sample/
├── README.md                              インデックス（薄い）
├── ABOUT_THIS_PROJECT.md                  このファイル
├── ABOUT_RALPH.md                         このリポジトリで Ralph をどう使うか
├── AGENTS.md                              プロジェクト全体規約のカスタマイズ用（空）
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
│           ├── AGENTS.md                  スプリント固有規約のカスタマイズ用（空）
│           ├── CLAUDE.md                  @AGENTS.md ブリッジ
│           ├── PRD.json                   タスク定義（CRUD + RDBMS）
│           ├── PROMPT.md                  Ralph への常駐指示書
│           ├── progress.txt               Ralph が追記する進捗ログ
│           └── decisions.md               世代をまたぐ設計判断
└── docs/
    └── HOW_RALPH_WORKS.md                 仕組みの図解
```

`AGENTS.md` / `CLAUDE.md` は最初は空（コメントだけ）。読者が自分のプロジェクト規約
（コーディング規約・禁止事項・使ってよいツール 等）を書き足すための入口として 2 階層に用意してある。
`AGENTS.md` が正本で、`CLAUDE.md` は `@AGENTS.md` 1 行のブリッジ。

## 前提環境

- macOS / Linux
- Docker（PostgreSQL コンテナ起動用）
- [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude` CLI)
- `gh` CLI（PR / issue 連携を試したい人向け。なくても動く）

GitHub に push してあるとフル機能（PR 自動作成・issue 連携）で動くが、
ローカル単体でも `./ralph.sh` の挙動は確認できる。

## 状態

- Ralph 実行前: 実装ファイルなし。`PRD.json` の全 story が `"passes": false`
- Ralph 実行後: `src/` 配下に実装、`docker-compose.yml`、テストが生成され、
  全 story が `"passes": true` になり、コミット履歴が積まれている状態が期待値
