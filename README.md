# ralph-todo-sample

Ralph Wiggum パターンを最小構成で体験するサンプルリポジトリです。
題材は TODO 管理 API（CRUD 全部 + RDBMS）。リポジトリ自体には実装は入っていません。
`./ralph.sh` を叩くと、AI が PRD.json を読みながら自律的に実装・テスト・コミットまで走ります。

## なにが入っているか

```
ralph-todo-sample/
├── README.md                              この記事
├── AGENTS.md                              プロジェクト全体の規約（カスタマイズ用・空）
├── CLAUDE.md                              Claude Code 用ブリッジ（中身は @AGENTS.md）
├── ralph.sh                               実行ループ（無限ループの本体）
├── .claude/
│   └── skills/
│       ├── ralph/                         Claude Code 用 Skill（Ralph 本体）
│       │   ├── SKILL.md                   Skill 本体（やることの規約）
│       │   └── templates/
│       │       ├── PRD.example.json       PRD のテンプレ
│       │       └── PROMPT.example.md      PROMPT のテンプレ
│       └── grill-me/                      初期フェーズで PRD を詰める Skill (Matt Pocock, MIT)
│           └── SKILL.md
├── ralph/
│   └── sprints/
│       └── todo-api-mvp/                  今回のスプリント
│           ├── AGENTS.md                  スプリント固有の規約（カスタマイズ用・空）
│           ├── CLAUDE.md                  Claude Code 用ブリッジ（中身は @AGENTS.md）
│           ├── PRD.json                   タスク定義（CRUD + RDBMS）
│           ├── PROMPT.md                  Ralph への常駐指示書
│           ├── progress.txt               実行中に Ralph が書き足す進捗ログ
│           └── decisions.md               世代間で持ち越したい設計判断
└── docs/
    └── HOW_RALPH_WORKS.md                 Ralph パターンの概念解説
```

`AGENTS.md` / `CLAUDE.md` は最初は空（コメントだけ）です。読者が自分のプロジェクト規約
（コーディング規約・禁止事項・使ってよいツール 等）を書き足すための入口として用意してあります。
`AGENTS.md` が正本、`CLAUDE.md` は `@AGENTS.md` 1 行のブリッジで、Claude Code はこれ経由で
規約を読み込みます。

実装ファイル（`src/`、`docker-compose.yml`、`pyproject.toml` 等）は **意図的に入っていません**。
Ralph が `PRD.json` を読んで一から作るのが、このサンプルの体験ポイントです。

## 前提

- macOS / Linux
- Docker（PostgreSQL コンテナ起動用）
- [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude` CLI) がインストール済み
- `gh` CLI（PR 自動作成を試したい人向け。なくても動く）
- このリポジトリを Git で初期化して、GitHub に push してあるとフル機能で動く（PR 作成・issue 連携）。ローカル単体でも動作確認は可能

## 全体の流れ

```
[Step 0] grill-me で PRD を詰める  ← 任意。自分で書いた PRD.json に自信があれば飛ばしてよい
              │
              ▼
[Step 1] PRD.json を確定する
              │
              ▼
[Step 2] ./ralph.sh でループを回す  ← ここから先は自律実行
              │
              ▼
[Step 3] 全 story が passes: true → ループ終了
```

## 5 分で動かす

```bash
# 1. 依存ツールがあるか確認
claude --version
docker --version

# 2. (任意) PRD を grill-me で詰める
#    対話モードの Claude Code で次のように依頼する:
#    "/grill-me ralph/sprints/todo-api-mvp/PRD.json の story を 1 つずつ詰めて"
#    → Claude が 1 問ずつ質問してくる。意思決定の枝が解消されたら PRD.json を確定

# 3. Ralph を起動（最大 10 イテレーション）
./ralph.sh ralph/sprints/todo-api-mvp 10
```

ターミナルに Claude の出力が流れ始めます。Ralph は次の順で動きます：

1. `PRD.json` の未完 story を 1 つ選ぶ
2. 実装する
3. テスト / 型チェック / lint を回す
4. コミットする
5. `PRD.json` の該当 story を `"passes": true` に更新する
6. 次のイテレーションへ

全部の story が `passes: true` になると、ループは `<promise>COMPLETE</promise>` を検知して終了します。

## 途中で止めたい

`Ctrl+C` で安全に止まります。`progress.txt` と Git 履歴に進捗が残るので、後から再開できます。

## カスタマイズ

題材を変えたいなら：

1. `ralph/sprints/todo-api-mvp/` をコピーして別ディレクトリを作る
2. `PRD.json` の `stories[]` を書き換える
3. `./ralph.sh ralph/sprints/your-new-sprint 10`

## 参考

- Ralph Wiggum パターン本家: https://ghuntley.com/ralph/
- 解説記事: https://www.aihero.dev/posts/11-tips-for-ai-coding-with-ralph-wiggum
- このサンプルが何をしているかの図解: [`docs/HOW_RALPH_WORKS.md`](docs/HOW_RALPH_WORKS.md)
- grill-me skill 原典: https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
  （Matt Pocock 作・MIT ライセンス。`.claude/skills/grill-me/` にそのまま同梱）
