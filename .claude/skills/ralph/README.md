# Ralph Skill

このディレクトリは Claude Code の Skill としての Ralph 本体です。
ここを読めば「Ralph パターンとは何か」「Skill としてどう構成されているか」
「実運用ファイル（PRD.json / PROMPT.md 等）にどんな約束ごとがあるか」が分かります。

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

## このディレクトリの構成

```
.claude/skills/ralph/
├── README.md                  このファイル（人間が読む）
├── SKILL.md                   Claude が読む規約
└── templates/
    ├── PRD.example.json       新しいスプリントを作るときの PRD ひな形
    └── PROMPT.example.md      PROMPT.md のひな形
```

`SKILL.md` は Claude Code が Skill として読み込むファイル、`README.md` は人間が
Skill 全体像を把握するためのファイル、という役割分担です。

## スプリントディレクトリの構造

このスキルが前提とするレイアウト:

```
<repo-root>/
├── ralph.sh                       実行ループ（ループ・終了判定・合成だけ）
└── ralph/
    └── sprints/
        └── <sprint-name>/
            ├── PRD.json           タスク定義（passes フラグで進捗管理）
            ├── PROMPT.md          常駐指示書（AI 指示の唯一の出所）
            ├── progress.txt       AI が追記する作業ログ
            └── decisions.md       世代をまたぐ設計判断
```

起動コマンド:

```bash
./ralph.sh <sprint_dir> [max_iterations]
# 例
./ralph.sh ralph/sprints/my-sprint 10
```

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

### progress.txt — 作業ログ

AI が各イテレーションで「何を / どう / なぜ」を 5 行以内で追記していくファイル。
次イテレーションの AI が読む前提で書く。上書き禁止・追記のみ。

### decisions.md — 設計判断ログ

世代をまたいで持ち越したい判断・トレードオフ・禁忌事項を AI がここに残す。

- 採用した方式と却下した代替案
- 一度試して失敗した方法（次の自分が同じ罠を踏まないように）
- 後続 story に影響する規約

## ralph.sh の責務分離

`ralph.sh` は意図的に薄く保たれている:

| 責務 | 担当 |
| --- | --- |
| ループ・終了判定・合成プロンプト生成 | `ralph.sh` |
| AI への指示（1 イテ 1 ストーリー、完了シグナル、headless 等） | `PROMPT.md` |
| 何を作るか・進捗管理 | `PRD.json` |
| 副作用（PR 作成、issue 連携、外部通知 等） | `PROMPT.md` 経由で AI に `gh` 等を叩かせる |

`ralph.sh` に AI 指示を混ぜると、再利用しにくくなり、`PROMPT.md` だけ差し替えれば
別プロジェクトで動くという利点が失われます。

## ループ完了の判定

`ralph.sh` の終了条件はシンプルに:

```bash
grep -q '<promise>COMPLETE</promise>'
```

AI 側に「全部終わったらこの文字列を出力しろ」と指示することで、シェルから
AI の主観的な完了判定を読めるようにしている。同じパターンは Codex / Gemini CLI /
opencode でも使える。

## 初期フェーズとの組み合わせ（grill-me）

ループに入る前に、`PRD.json` の各 story が「ループに任せて安全」な粒度に
解像していることが重要です。Ralph はループ中に質問できない（headless）ので、
あいまいさは事前に潰しておく必要があります。

このリポジトリには [grill-me skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
（Matt Pocock 作・MIT ライセンス）を同梱しており、`PRD.json` 確定前に
対話モードの Claude Code で呼び出して使えるようにしてあります。

## やってはいけないこと（スキル共通）

- `ralph.sh` / `SKILL.md` / `PROMPT.md` をタスクと無関係に書き換える
- 1 イテレーションで複数 story を進める
- 受け入れ基準を満たさないまま `passes: true` に書き換える
- `<promise>COMPLETE</promise>` を未完成のまま出力する
- `progress.txt` / `decisions.md` を上書き・削除する（追記のみ）

## 参考

- 本家解説 (Geoffrey Huntley): https://ghuntley.com/ralph/
- 実践 Tips (aihero.dev): https://www.aihero.dev/posts/11-tips-for-ai-coding-with-ralph-wiggum
- 歴史 (humanlayer): https://www.humanlayer.dev/blog/brief-history-of-ralph
- 命名の話 (VentureBeat): https://venturebeat.com/technology/how-ralph-wiggum-went-from-the-simpsons-to-the-biggest-name-in-ai-right-now/
