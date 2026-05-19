# ralph-plan Skill

使い方

```sh
/ralph-plan このリポジトリで TODO アプリの Ralph スプリントを準備して
```

このディレクトリは Claude Code の Skill としての **ralph-plan** 本体です。
Ralph 実行前の **準備フェーズ**（壁打ち + PRD.json / PROMPT.md の生成）を担当します。

実装ループそのもの（1 イテ 1 ストーリーの自律実行）は別フェーズで、リポジトリルートの
`ralph.sh` がやります。このスキルはそこに渡すための入力を整える役割。

> このリポジトリ固有の使い方チュートリアル（どのコマンドを叩くか・どこをコピーするか）は、
> リポジトリの [`docs/ABOUT_RALPH.md`](../../../docs/ABOUT_RALPH.md) を参照。
> 仕組みの図解は [`docs/HOW_RALPH_WORKS.md`](../../../docs/HOW_RALPH_WORKS.md)。

## Ralph Wiggum パターンとは

同じ PROMPT を高頻度ループで AI に投げ、途中状態をファイルに書き残しながら
長尺タスクを完遂させる手法です。発案者は Geoffrey Huntley、命名は
シンプソンズの登場人物 Ralph Wiggum から。

成立条件は次の 3 つ:

1. **タスクの粒度を `passes: true / false` の真偽値で進捗管理する**
   （受け入れ基準を満たしたらフラグを立てる）
2. **常駐指示書を毎ループ読み込ませる**（同じルールを毎回再起動）
3. **完了シグナルをシェルから grep で読む**（AI が `<promise>COMPLETE</promise>`
   を出したらループを抜ける）

Claude Code 固有ではなく、Codex / Gemini CLI / opencode でも同じパターンが成立します。

## 2 つのフェーズ

Ralph パターンの運用は明確に 2 フェーズに分かれます。このスキルが面倒を見るのは前者です。

| フェーズ | 担当 | 役割 |
| --- | --- | --- |
| 準備（壁打ち + 入力生成） | **このスキル** (`ralph-plan`) | ユーザーと対話し PRD.json / PROMPT.md を作る |
| 実装ループ | `ralph.sh` + 同梱 `PROMPT.md` | headless で 1 イテ 1 ストーリーを完遂 |

なぜ分けるのか:

- 準備フェーズは **対話モード**（ユーザーに質問できる）
- 実装フェーズは **headless モード**（質問できない）
- 設計判断を先に潰しておかないと、ループ中に世代ごとの解釈ブレとして発現する

## このディレクトリの構成

```
.claude/skills/ralph-plan/
├── README.md                  このファイル（人間が読む）
├── SKILL.md                   Claude が読む規約（準備フェーズの手順）
└── templates/
    ├── PRD.example.json       新しいスプリントを作るときの PRD ひな形
    └── PROMPT.example.md      PROMPT.md のひな形（ループ手続き）
```

`SKILL.md` は Claude Code が Skill として読み込むファイル、`README.md` は人間が
Skill 全体像を把握するためのファイル、という役割分担です。

## 生成されるスプリントディレクトリ

このスキルが完了すると、次のレイアウトができている:

```
<repo-root>/ralph/sprints/<sprint-name>/
├── PRD.json           タスク定義（passes フラグで進捗管理）
├── PROMPT.md          常駐指示書（ループ手続き）
├── progress.txt       空ファイル（Ralph が追記していく）
└── decisions.md       空ファイル（Ralph が追記していく）
```

そのあとに `./ralph.sh ralph/sprints/<sprint-name> [N]` でループに入る。

## 各ファイルの役割

### PRD.json — 何を作るか

タスク定義。`stories[]` 配列に受け入れ基準を持ったストーリーを並べる。

```json
{
  "title": "...",
  "context": { "background": "...", "constraints": [...] },
  "stories": [
    {
      "id": 1,
      "title": "プロジェクト基盤の用意",
      "criteria": ["...", "..."],
      "passes": false
    }
  ]
}
```

- `passes` は真偽値。Ralph が受け入れ基準をすべて満たしたら `true` に書き換える
- ループの完了条件は「全 story が `passes: true`」
- ひな形: [`templates/PRD.example.json`](templates/PRD.example.json)

### PROMPT.md — ループ手続きの指示書

毎イテレーション、`ralph.sh` がそのままプロンプトに連結する常駐指示書。
**ループ手続き**（1 イテ 1 ストーリー、完了シグナル、headless 等）だけをここに書く。

技術スタック・コーディング規約・実コマンドのような **プロジェクト恒久ファクト** は
ここではなく、リポジトリルートの `AGENTS.md` に書く。Claude Code は `CLAUDE.md`
（→ `@AGENTS.md`）経由で自動的に読み込むので、PROMPT.md に重複させる必要はない。

PROMPT.md に書くべき内容:

- このスプリントの目的（1〜3 行）
- 1 イテレーションの手順
- やってはいけないこと（ループ運用に関するもの）
- 完了シグナル（`<promise>COMPLETE</promise>`）の出し方
- headless 実行モードの注意

AGENTS.md に書くべき内容（プロジェクト全体）:

- 技術スタック（言語、フレームワーク、DB 等）
- 実コマンド（test, lint, format, build）
- コーディング規約
- API / DB 等の規約
- 禁止事項（シークレットのコミット等）

ひな形: [`templates/PROMPT.example.md`](templates/PROMPT.example.md)

### progress.txt — 作業ログ（ループ中に Ralph が書く）

Ralph が各イテレーションで「何を / どう / なぜ」を 5 行以内で追記していくファイル。
次イテレーションの自分が読む前提で書く。上書き禁止・追記のみ。

このスキルは **空ファイルを用意するだけ**。中身は Ralph が書く。

### decisions.md — 設計判断ログ（ループ中に Ralph が書く）

世代をまたいで持ち越したい判断・トレードオフ・禁忌事項を Ralph がここに残す。

- 採用した方式と却下した代替案
- 一度試して失敗した方法（次の自分が同じ罠を踏まないように）
- 後続 story に影響する規約

このスキルは **空ファイルを用意するだけ**。中身は Ralph が書く。

## grill-me との関係

同梱の [`grill-me` skill](../grill-me/SKILL.md)（Matt Pocock 作・MIT ライセンス）は
「対話で意思決定木を 1 問ずつ潰す」という汎用パターンです。`ralph-plan` はその
パターンを Ralph 専用にラップしたもの:

| | `grill-me` | `ralph-plan` |
| --- | --- | --- |
| 範囲 | 任意の plan / design | Ralph スプリントの準備 |
| 出力 | 合意された理解（暗黙） | `PRD.json` / `PROMPT.md` / 空の状態ファイル |
| ハンドオフ先 | 自由 | `./ralph.sh` |

`ralph-plan` が内部で `grill-me` 流の手続きを採用しているので、
利用者が直接 `grill-me` を呼ぶ必要はない。ただし PRD 確定後にもう一段
詰めたい場合や、Ralph と無関係な設計検討では `grill-me` を直接使ってよい。

## 責務分離（このスキル / ralph.sh / PROMPT.md / AGENTS.md）

| 責務 | 担当 |
| --- | --- |
| ユーザーと壁打ち、入力ファイル生成 | **このスキル** (`ralph-plan`) |
| ループ・終了判定・合成プロンプト生成 | `ralph.sh` |
| AI への指示（1 イテ 1 ストーリー、完了シグナル、headless 等） | `PROMPT.md` |
| 何を作るか・進捗管理 | `PRD.json` |
| 技術スタック・規約・実コマンド | `AGENTS.md`（リポジトリルート） |
| 副作用（PR 作成、issue 連携、外部通知 等） | `PROMPT.md` 経由で AI に `gh` 等を叩かせる |

## ループ完了の判定（参考）

`ralph.sh` の終了条件はシンプルに:

```bash
grep -q '<promise>COMPLETE</promise>'
```

AI 側に「全部終わったらこの文字列を出力しろ」と指示することで、シェルから
AI の主観的な完了判定を読めるようにしている。同じパターンは Codex / Gemini CLI /
opencode でも使える。

## やってはいけないこと（このスキルとして）

- `ralph.sh` / `AGENTS.md` を勝手に書き換える（規約変更が必要ならまずユーザーと合意する）
- 複数質問を一度に投げる（1 度に 1 つ）
- ユーザーに聞かずに勝手に PRD を確定する
- 受け入れ基準を曖昧なまま残す（「UX が良い」「読みやすい」のような真偽判定不能なもの）

## 参考

- 本家解説 (Geoffrey Huntley): https://ghuntley.com/ralph/
- 実践 Tips (aihero.dev): https://www.aihero.dev/posts/11-tips-for-ai-coding-with-ralph-wiggum
- 歴史 (humanlayer): https://www.humanlayer.dev/blog/brief-history-of-ralph
- Matt Pocock の skills 集: https://github.com/mattpocock/skills
- 命名の話 (VentureBeat): https://venturebeat.com/technology/how-ralph-wiggum-went-from-the-simpsons-to-the-biggest-name-in-ai-right-now/
