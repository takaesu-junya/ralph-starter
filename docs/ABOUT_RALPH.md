# ABOUT_RALPH

このリポジトリで Ralph（自律タスク実行ループ）を運用するための手順書。
Ralph パターンそのものの仕様や、Skill の中身は
[`.claude/skills/ralph-plan/README.md`](../.claude/skills/ralph-plan/README.md) に委ねている。
仕組みの図解は [`HOW_RALPH_WORKS.md`](./HOW_RALPH_WORKS.md)。

ここでは「このリポジトリのファイルを使って、どの順で何をすればよいか」だけを書く。

## 全体の流れ

```
[Step 1] /ralph-plan で壁打ち → PRD.json / PROMPT.md を生成
              │
              ▼
[Step 2] ./ralph.sh でループを回す  ← ここから先は自律実行
              │
              ▼
[Step 3] 全 story が passes: true になりループ終了
```

## Step 1: ralph-plan で PRD.json を作る

対話モードの Claude Code で `ralph-plan` skill を呼び出す。スキルは
ユーザーに 1 問ずつ尋問しながら、最終的に `ralph/sprints/<sprint-name>/` に
次の 4 ファイルを置く:

- `PRD.json` — 受け入れ基準つきタスク定義
- `PROMPT.md` — ループ手続き（スプリント固有）
- `progress.txt` — 空（Ralph が追記する）
- `decisions.md` — 空（Ralph が追記する）

呼び出し方:

```
/ralph-plan このリポジトリで <作りたいもの> の Ralph スプリントを準備して
```

スキルの中身（手順・不変条件）は
[`.claude/skills/ralph-plan/SKILL.md`](../.claude/skills/ralph-plan/SKILL.md) を参照。

> Ralph はループ中に質問できない（headless 実行）ので、ここで意思決定木を潰し切る
> 必要がある。スキルは内部で `grill-me`（Matt Pocock 作・MIT、`.claude/skills/grill-me/`
> に同梱）と同じ「1 問ずつ＋おすすめ提示」の手法を使う。Ralph と無関係な設計検討で
> grill-me を直接呼びたい場合は `/grill-me ...` でも使える。

## Step 2: Ralph を起動する

```bash
# 依存ツール確認
claude --version
docker --version

# Ralph を起動（最大 10 イテレーション）
./ralph.sh ralph/sprints/my-sprint 10
```

ターミナルに Claude の出力が流れ始める。1 イテレーションごとに次が走る:

1. `PRD.json` の未完 story を 1 つ選ぶ（id 最小）
2. 受け入れ基準を満たす実装をする
3. テスト / 型チェック / lint を緑にする
4. `git commit` する
5. `PRD.json` の該当 story を `"passes": true` に更新する
6. `progress.txt` / `decisions.md` に作業ログ・設計判断を追記する
7. 次イテレーションへ

全 story が `passes: true` になると、最後の Claude が
`<promise>COMPLETE</promise>` を出力し、`ralph.sh` がそれを検知してループを抜ける。

## 途中で止めたい

`Ctrl+C` で安全に停止する。`progress.txt` と Git 履歴に進捗が残っているので、
同じコマンドを再実行すれば続きから走る。

## モニタリング

別ターミナルで進捗を眺めるなら:

```bash
tail -f ralph/sprints/my-sprint/progress.txt
tail -f ralph/sprints/my-sprint/ralph-output.log
jq '.stories[] | {id, title, passes}' ralph/sprints/my-sprint/PRD.json
```

## 手動でひな形をコピーしたい場合

`/ralph-plan` を使わず、自分でひな形からスプリントを作りたい場合:

```bash
mkdir -p ralph/sprints/my-sprint
cp .claude/skills/ralph-plan/templates/PRD.example.json    ralph/sprints/my-sprint/PRD.json
cp .claude/skills/ralph-plan/templates/PROMPT.example.md   ralph/sprints/my-sprint/PROMPT.md
touch ralph/sprints/my-sprint/progress.txt
touch ralph/sprints/my-sprint/decisions.md
# あとは PRD.json の title / stories[] を自分のプロジェクト向けに書き換える
```

## このリポジトリ固有のカスタマイズポイント

- **規約を足したい**: ルートの `AGENTS.md` にプロジェクト規約を書く（命名、禁止事項、
  コーディングルール、技術スタック、実コマンド 等）。Claude Code は `CLAUDE.md` 経由で
  `AGENTS.md` を自動で読み込む。スプリント固有の手続き（このスプリントだけの段取り）は
  `ralph/sprints/<sprint>/PROMPT.md` に書く
- **使えるツールを増やしたい**: `ralph.sh` の `--allowedTools` リストに追加する
- **ループ回数を増やしたい**: `./ralph.sh <sprint_dir> 50` のように第 2 引数を増やす
- **別プロジェクトを動かしたい**: 上記「Step 1」のディレクトリコピー方式

## トラブルシュート

- **同じエラーが続く**: `decisions.md` を Ralph が書き残しているはずなので、そこから
  どこで詰まっているかを読む。必要なら `PROMPT.md` のローカルルールを足す
- **`<promise>COMPLETE</promise>` が出たのに未完了**: `PRD.json` を確認。`passes: true`
  が誤って付いている story がないか、Git 履歴で差し戻す
- **Claude が質問してくる**: PROMPT.md の `## 実行モード` セクションが headless を
  指示している。指示が効いていない場合は PROMPT.md の冒頭付近に再掲する
