---
name: ralph-plan
description: Ralph ループに渡すための準備フェーズ用スキル。ユーザーと壁打ちして PRD.json と PROMPT.md を作り、ralph/sprints/<sprint-name>/ に配置する。実装ループそのものは ralph.sh の責務。
---

# ralph-plan Skill

このスキルは **Ralph 実行前の準備フェーズ** を担当します。具体的には:

- ユーザーと壁打ちして、何を作るのかをストーリー単位まで解像する
- 受け入れ基準が「真偽値で判定できる」粒度まで詰める
- 確定した内容を `ralph/sprints/<sprint-name>/PRD.json` と `PROMPT.md` に落とす
- `progress.txt` / `decisions.md` の空ファイルを用意する
- 最後に `./ralph.sh <sprint_dir> [N]` の起動コマンドを提示して人間に渡す

**実装ループ自体（1 イテ 1 ストーリー、コミット、`passes` 更新、完了シグナル）は
このスキルの責務外** です。それは `ralph.sh` が `PROMPT.md` を毎回投げ込むことで成立する、
別のフェーズです。

## 前提

- 対話モードの Claude Code で呼び出される（headless ではない）
- ユーザーに質問できる。質問は **1 度に 1 つだけ**
- リポジトリルートの `AGENTS.md` は読み込み済み（HOW の正本）
- 同梱の `grill-me` skill の手法を借りる:
  - 質問は 1 度に 1 つ
  - 各質問に「私のおすすめはこれ」を添える
  - コードベースを読めば答えられる質問は、ユーザーに聞かずに読みに行く

## このスキルが生成する成果物

```
ralph/sprints/<sprint-name>/
├── PRD.json          ← このスキルが書く（WHAT）
├── PROMPT.md         ← このスキルが書く（ループ手続き）
├── progress.txt      ← 空ファイルを作る（Ralph が追記していく）
└── decisions.md      ← 空ファイルを作る（Ralph が追記していく）
```

ひな形:

- `templates/PRD.example.json`
- `templates/PROMPT.example.md`

## 手順

### Step 1: スプリントの目的を 1〜3 行に圧縮する

ユーザーに「このスプリントで何を作りたいか」を聞く。回答が抽象的なら次に進まず
深掘りする（誰のため・何を解消する・成功とは何か）。

ここで決めるのは **WHAT**（PRD の `context.background`）であり、**HOW**
（技術スタック・コマンド）は `AGENTS.md` に既に書かれているので触らない。

### Step 2: grill-me パターンで意思決定木を潰す

`grill-me` skill と同じ進め方:

- 質問は **1 度に 1 つだけ**
- 「私のおすすめはこれ」を添える（採用 / 却下のコストを下げる）
- コードベースを読めば答えられる質問は、ユーザーに聞かずに読みに行く
- 「この sprint のスコープ外」を意識的に切り出す（PRD の `out_of_scope`）

潰すべき典型的な枝（プロジェクトによって増減する）:

- 認証・認可の有無
- マルチユーザー or 単一ユーザー
- どこまでの CRUD（一覧 / 詳細 / 編集 / 削除 / 検索 / フィルタ）
- 必須項目・最大長などのバリデーション仕様
- 一覧の並び順・ページング
- エラー時 UX（フラッシュ / バナー / リダイレクト先）
- データのライフサイクル（論理削除 / 物理削除 / 期限切れ）

Ralph は **ループ中に質問できない（headless）** ので、ここで残ったあいまいさは
ループ中に世代ごとの解釈ブレとして発現する。ここで潰し切ることが目的。

### Step 3: ストーリーに分解する

Matt Pocock の 3 層を踏襲する:

- **Context**: 背景・制約・スコープ外（PRD の `context`）
- **Stories**: 原子化された作業単位（PRD の `stories[]`）
- **Validation**: 各ストーリーの受け入れ基準（`criteria[]`、真偽値で判定可能）

ストーリー分解の原則:

- **薄い縦スライス**で割る（migration だけ・controller だけ、のような横割りは禁止）
- 受け入れ基準は **テストで真偽が判定できる** ものにする（「UX が良い」「読みやすい」は NG）
- リスクの高い箇所（アーキ・統合点・足場）から先に倒す（fail fast）
- 最初の story は **検証の足場**にする（空テスト・lint・型チェックが全部緑になる状態）。
  Ralph に「目」を与える土台になる

#### 縦スライス自己チェック（criteria を確定する前に必ず実施）

各 story について、以下を自問する。1 つでも NO なら story を作り直す:

1. **この story 単体で feature test を 1 本書けるか？**
   書けない = レイヤを跨いでいない = 横割りの兆候
2. **criteria の中に「観測不能な状態」が混ざっていないか？**
   - ❌ NG 例: 「テーブルが定義されている」「コントローラが存在する」
     「ルートが登録されている」だけ（=横割り）
   - ✅ OK 例: 「`GET /todos` が空一覧の HTML を 200 で返す」
     「`POST /todos` が title 必須バリデーションを 422 で返し、フォームに戻る」
3. **ユーザーがブラウザで操作した結果として観測できる挙動になっているか？**
   HTTP レスポンス・画面遷移・表示内容・エラー表示・リダイレクト先のいずれかで
   表現されているか
4. **この story を完了するのに必要なレイヤ（route / controller / model /
   migration / blade / feature test）が、その story の範囲内ですべて整うか？**
   「次の story で controller を作る」のように依存が割れていないか

具体例（TODO アプリ）:

| 切り方 | 判定 | 理由 |
| --- | --- | --- |
| 「Todo モデルとマイグレーションを作る」 | ❌ | 観測不能。feature test が書けない |
| 「TodoController を作る」 | ❌ | 観測不能。挙動が定義されていない |
| 「`GET /todos` が空一覧の HTML を 200 で返す」 | ✅ | 必要な migration / model / route / controller / blade / feature test が 1 story 内で揃う |
| 「`POST /todos` で作成し、一覧にリダイレクトされる」 | ✅ | FormRequest / store / redirect / 一覧表示の縦スライス |

### Step 4: PRD.json を書く

`templates/PRD.example.json` をコピーし、Step 1〜3 で確定した内容で書き換える。

```json
{
  "title": "...",
  "context": {
    "background": "...",
    "constraints": ["..."],
    "out_of_scope": ["..."]
  },
  "stories": [
    {
      "id": 1,
      "title": "...",
      "criteria": ["...", "..."],
      "passes": false
    }
  ]
}
```

- すべての `passes` は初期値 `false`
- `id` は 1 から連番。Ralph は id 最小の未完 story を選ぶ
- `criteria[]` は 2〜5 個程度。多すぎたら story を分割する

### Step 5: PROMPT.md を書く

`templates/PROMPT.example.md` をコピーし、**このスプリント固有の手続き**だけを書き換える。

- 技術スタック・実コマンド・コーディング規約は `AGENTS.md` に書かれているので **PROMPT.md に重複させない**
- 「このスプリントの目的」「実行モード（headless）」「1 イテ 1 ストーリー」
  「完了シグナル `<promise>COMPLETE</promise>`」だけを書く

### Step 6: 空の状態ファイルを作る

```
touch ralph/sprints/<sprint-name>/progress.txt
touch ralph/sprints/<sprint-name>/decisions.md
```

Ralph はこれらを **追記のみ** で使う。世代をまたぐコンテキストの引き継ぎ装置。

### Step 7: ユーザーに最終確認して引き渡す

成果物を要約してユーザーに見せる:

- PRD.json の story 一覧（id / title だけ）
- スプリントディレクトリのパス
- 起動コマンド: `./ralph.sh ralph/sprints/<sprint-name> [N]`

「N」の推奨値は story 数 × 2〜3。途中で止まっても再開できるので、控えめでよい。

## このスキルが守るべき不変条件

- **PROMPT.md / AGENTS.md / ralph.sh を勝手に書き換えない**（規約変更が必要なら
  まずユーザーと合意する）
- 質問は 1 度に 1 つ。複数同時に聞かない
- 「ユーザーに聞けばわかる質問」と「コードを読めばわかる質問」を区別する。
  後者は読みに行く
- 受け入れ基準を「真偽値で判定可能」な粒度に保つ。曖昧な criteria は禁止
- 1 story の `criteria[]` が 6 個以上になったら story を分割する
- `out_of_scope` を明示する（やらないことを書く）

## 参考

- Ralph パターン本家解説 (Geoffrey Huntley): https://ghuntley.com/ralph/
- 実践 Tips (aihero.dev): https://www.aihero.dev/posts/11-tips-for-ai-coding-with-ralph-wiggum
- 同梱の `grill-me` skill（Matt Pocock 作・MIT）: `.claude/skills/grill-me/SKILL.md`
- このリポでの運用手順: `docs/ABOUT_RALPH.md`
- 仕組みの図解: `docs/HOW_RALPH_WORKS.md`
