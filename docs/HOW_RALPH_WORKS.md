# Ralph Wiggum パターンの仕組み

このリポジトリが Ralph をどう動かしているかを 1 ページで説明します。

## 初期フェーズ: grill-me で PRD を詰める（任意・推奨）

ループに入る前に、`PRD.json` の各 story が「ループに任せて安全」と言える粒度まで
解像していることが重要です。Ralph はループ中に質問してこない（headless 実行）ので、
あいまいさを残したまま回すと、世代ごとに別の解釈で実装が振れます。

このリポジトリには [grill-me skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
（Matt Pocock 作・MIT ライセンス）を同梱しています。
対話モードの Claude Code で次のように呼び出すと、PRD 草案を 1 問ずつ詰めてくれます:

```
/grill-me ralph/sprints/my-sprint/PRD.json の story を 1 つずつ詰めて
```

- 1 度に 1 問だけ聞く
- それぞれに「私のおすすめはこれ」を添えてくる
- コードベースを読めば答えられる質問は、こちらに聞かずに読みに行く

意思決定の枝がすべて解消されたら PRD.json を確定し、`./ralph.sh` でループに入ります。
自分で書いた PRD に自信があるなら飛ばして構いません。

## ループフェーズの全体像

```
                    ┌──────────────────────┐
                    │   ralph.sh (loop)    │
                    │   - 最大 N 回ループ   │
                    └──────────┬───────────┘
                               │ 毎イテレーション、合成プロンプトを投げる
                               ▼
   ┌──────────────────────────────────────────────────────────┐
   │ claude CLI (headless)                                    │
   │   入力: PROMPT.md + PRD.json + progress.txt + 直近ログ    │
   │   出力: コード変更 + git commit + PRD.json 更新           │
   └──────────────────────────────────────────────────────────┘
                               │
                               ▼
   ┌──────────────────────────────────────────────────────────┐
   │ Sprint Directory                                         │
   │   PRD.json       受け入れ基準 (passes フラグで進捗管理)    │
   │   PROMPT.md      常駐指示書（毎イテ読み込まれる）          │
   │   progress.txt   Ralph 自身が追記する作業ログ              │
   │   decisions.md   世代をまたぐ設計判断                      │
   └──────────────────────────────────────────────────────────┘
                               │
                               ▼
                  全 story が passes: true になり、
                  出力に <promise>COMPLETE</promise> が現れたら
                  ralph.sh がループを抜けて終了
```

## なぜこれが動くか

3 つの要素の掛け算です。

### 1. PRD.json の `passes` フラグ

ストーリーごとに `passes: false / true` の真偽値を持たせるだけ。
Ralph は毎イテレーションで「`passes: false` のうち id が最小のものを 1 つ」だけ進めるので、
**部分完成状態を安全に保存できる**。途中で止めても再開可能です。

### 2. PROMPT.md の常駐指示書

毎回同じ PROMPT が読み込まれます。「1 イテ 1 ストーリー」「テスト緑にしてからコミット」
「`<promise>COMPLETE</promise>` を未完成で出すな」のようなルールを書いておくと、
Claude は毎回同じルールを再起動し続けます。

### 3. 完了シグナルの grep

`ralph.sh` の終了条件はシンプルに `grep -q '<promise>COMPLETE</promise>'` です。
Claude 側に「全部終わったらこの文字列を出力しろ」と指示することで、
**シェルから AI の主観的な完了判定を読める**ようになります。
Claude Code 固有ではなく、Codex / Gemini CLI / opencode でも同じパターンが成立します。

## 1 イテレーションの流れ

```
[1] PRD.json を見る → 未完 story を 1 つ選ぶ（id=3 とする）
[2] 受け入れ基準 (criteria) を満たす実装をする
[3] pint / phpunit を回す → 緑になる
[4] git commit する
[5] PRD.json の story[3].passes を true にする
[6] progress.txt に「何を / どう / なぜ」を 5 行追記
[7] 終了 → ralph.sh が次イテレーションを起こす
```

これを `passes: false` がなくなるまで繰り返します。
全部終わったら最後の Claude が `<promise>COMPLETE</promise>` を出して、ループを抜けます。

## どこをカスタマイズすればよいか

- **別プロジェクトを動かす**: `ralph/sprints/<new-sprint>/PRD.json` を新しく作る
- **ループ手続きを変える**: `ralph/sprints/<sprint>/PROMPT.md` を書き換える
- **規約・実コマンドを変える**: ルートの `AGENTS.md` を書き換える
- **使えるツールを増やす**: `ralph.sh` の `--allowedTools` リストに追加する
- **ループ回数を増やす**: `./ralph.sh <sprint> 50` のように第 2 引数を増やす

`ralph.sh` 本体（ループ機構）は基本的にいじる必要はありません。

## さらに進んだ使い方

現状の構成は最小です。拡張するなら次のような方向があります:

- GitHub issue を起点に PRD.json を自動生成
- ストーリー完了時に sub-issue を自動 Close
- 全 story 完了時に Pull Request を自動作成
- 別エージェントで PRD 草案を批判・改善（adversarial review）
- 直近イテレーションのコミット差分に対して CodeRabbit などのレビュアーを挟む

最小構成から始めて、必要になった機構だけ足していくのが運用しやすい。
