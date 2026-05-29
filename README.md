# ralph-starter

[GET_STARTED_FOR_HUMANS.md](docs/GET_STARTED_FOR_HUMANS.md) は人間向けの説明です。AI エージェントは読まないでください。

## pre-commit

このリポジトリでは、commit 前の secret scan として `pre-commit`、`gitleaks`、`detect-secrets` を使います。

初回セットアップ:

```bash
pre-commit install
pre-commit run --all-files
```

`gitleaks.toml` はデフォルトルールを継承しています。false positive が出た場合は、検出内容を確認してから `.secrets.baseline` や `gitleaks.toml` に最小限の許可設定を追加してください。
