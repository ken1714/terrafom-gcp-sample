# TerraformでGCPサンプル
## 1. 動作環境

- OS: Windows 11


## 2. Terraformのインストール

1. [公式サイト](https://developer.hashicorp.com/terraform/install)にアクセスし、バイナリをダウンロードして実行。
   - `386`のもので良い
2. 解凍した`terraform.exe`を、PATHの通っているフォルダ(`C:\Windows`など)に配置
3. コマンドプロンプトでTerraformのバージョンを確認できれば完了
   ```bash
   $ terraform --version
   Terraform v1.7.0
   on windows_386
   ```


## 3. Google Cloud CLIのインストール

[公式ドキュメントの「gcloud CLI をインストールする」](https://cloud.google.com/sdk/docs/install?hl=ja)の手順に従う。インストール後、コマンドプロンプトでバージョンを確認できれば完了。

```bash
$ gcloud --version
Google Cloud SDK 460.0.0
bq 2.0.101
core 2024.01.12
gcloud-crc32c 1.0.0
gsutil 5.27
```

あらかじめGoogle Cloudでプロジェクトを作成しておき、以下のコマンドを実行。Google Cloud CLI上からアカウントへのログイン、プロジェクトへのチェックアウトを実行できる。

```bash
$ gcloud init
```

また、Terraformのコマンドを実行する前に以下のコマンドを実行する必要がある。

```bash
$ gcloud auth login
$ gcloud auth application-default login
```
