# attendance_management

## 概要

入退室ログCSVから個人別の出勤・退勤時刻テキストファイルを生成します。

## フォルダ構成

```
attendance_management/
├── programs/
│   ├── attendance_management.R        # メインスクリプト
│   └── common.R                       # 共通関数
├── tests/
│   └── test_attendance_management.R   # テストスクリプト
├── input/
│   └── test_YYYYMM/                   # テスト用ダミー入力CSV
└── output/
    └── test_YYYYMM/                   # テスト用期待値ファイル
```

## ファイルのダウンロード

GitHub のページから ZIP ファイルをダウンロードします。  
ダウンロードしたファイルを右クリックして「すべて展開」します。  
「attendance_management-master」フォルダを開くと、同じ名前の「attendance_management-master」フォルダがありますので、それをドキュメントフォルダなどにコピーしてください。

## 事前準備（初回のみ）

以下のパッケージをインストールしてください。  
RStudio 右下の「Packages」タブ →「Install」から実行できます。

- tidyverse
- lubridate
- here

## 使い方

### 通常実行

1. RStudio を起動し、メニューの File > New Project を選択してください。
2. Existing Directory を選択し、Project working directory に「attendance_management-master」フォルダを指定して、Create Project をクリックしてください。
3. RStudio のメニューの File > Open File を選択し、`programs/attendance_management.R` を開いてください。
4. 画面上部の「Source」をクリックすると処理が実行されます。画面左下のコンソールに `>` のみの行が表示されたら処理完了です。
5. Box の所定フォルダに `YYYYMM/` フォルダが作成され、個人別テキストファイルが格納されます。

> **特定の年月を対象にしたい場合**  
> `attendance_management.R` の先頭にある下記の行のコメントを外して年月を指定してください。
>
> ```r
> # target_yyyymm <- "202401"
> ```

### トラブルシューティング

- **ファイルが生成されない** → `//aronas` へのネットワーク接続を確認してください
- **エラーが出る** → パッケージが正しくインストールされているか確認してください
- **パッケージインストール時にコンパイルエラーが出る** → Rtools をインストールしてください（Windows のみ）  
  https://cran.r-project.org/bin/windows/Rtools/rtools45/rtools.html

## テスト

### 実行方法

`tests/test_attendance_management.R` を Source すると、実行日の前月（YYYYMM）を自動で対象とし、実データを使って `programs/attendance_management.R` を実行し、`output/test_YYYYMM/` の期待値と比較して PASS/FAIL を表示します。
