# ABOUT_RALPH

このリポジトリで Ralph（自律タスク実行ループ）を運用するための手順書。
Ralph パターンそのものの仕様や、Skill の中身は
[`.claude/skills/ralph/README.md`](../.claude/skills/ralph/README.md) に委ねている。
仕組みの図解は [`HOW_RALPH_WORKS.md`](./HOW_RALPH_WORKS.md)。

ここでは「このリポジトリのファイルを使って、どの順で何をすればよいか」だけを書く。

## 全体の流れ

```
[Step 0] grill-me で PRD を詰める   ← 任意。PRD に自信があれば飛ばしてよい
              │
              ▼
[Step 1] PRD.json を確定する
              │
              ▼
[Step 2] ./ralph.sh でループを回す  ← ここから先は自律実行
              │
              ▼
[Step 3] 全 story が passes: true になりループ終了
```

## Step 0（任意）: grill-me で PRD を詰める

Ralph はループ中に質問してこない（headless 実行）ので、`PRD.json` に
あいまいさが残っていると世代ごとに別解釈で実装が振れる。確信が持てない story が
ある場合は、対話モードの Claude Code で grill-me skill を呼んで詰める。

```
/grill-me ralph/sprints/my-sprint/PRD.json の story を 1 つずつ詰めて
```

- 1 度に 1 問だけ聞いてくる
- 各質問に「私のおすすめはこれ」を添えてくる
- コードベースを読めば答えられる質問は、こちらに聞かずに読みに行く

意思決定の枝が解消されたら `PRD.json` を保存して Step 1 へ。

> grill-me skill は Matt Pocock 作・MIT ライセンスで `.claude/skills/grill-me/` に
> そのまま同梱している。原典: https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md

## Step 1: PRD.json を確定する

このリポジトリは「Ralph パターンの汎用スターター」として配布している。
何を作るかは利用者ごとに違うので、`ralph/sprints/` 配下に既定のスプリントは置いていない。
ひな形は [`.claude/skills/ralph/templates/`](../.claude/skills/ralph/templates/) にある:

- `PRD.example.json` — タスク定義の雛形
- `PROMPT.example.md` — 常駐指示書の雛形

自分の sprint ディレクトリを作って、ひな形をコピーするところから始める:

```bash
mkdir -p ralph/sprints/my-sprint
cp .claude/skills/ralph/templates/PRD.example.json    ralph/sprints/my-sprint/PRD.json
cp .claude/skills/ralph/templates/PROMPT.example.md   ralph/sprints/my-sprint/PROMPT.md
# あとは PRD.json の title / stories[] を自分のプロジェクト向けに書き換える
```

PRD のスキーマや `passes` フラグの扱いは
[`.claude/skills/ralph/README.md`](../.claude/skills/ralph/README.md) を参照。
PRD 草案に不安があれば、Step 0 の grill-me で詰めてから Step 2 へ進む。

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
