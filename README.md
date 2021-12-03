# attendance_management
## 概要
入退室ログから出勤・退勤時間を出力します。  
## ファイルのダウンロード
Zipファイルをダウンロードします。  
![スクリーンショット 2021-08-02 12 36 37](https://user-images.githubusercontent.com/24307469/127803084-601cfb53-7373-44f2-a211-5857bf86bbf5.png).  
ダウンロードしたファイルを右クリックして「すべて展開」します。  
「attendance_management-master」フォルダを開くと、同じ名前の「attendance_management-master」フォルダがありますので、それをドキュメントフォルダなどにコピーしてください。    
フォルダ構成が下の図のようになればOKです。  
![スクリーンショット 2021-08-02 13 02 34](https://user-images.githubusercontent.com/24307469/127803112-9c8313af-a67c-4379-a473-19d79ff02e83.png)
  
## 事前準備
初回のみ、Rtoolsのインストールが必要です。  
Using Rtools4 on Windows.  
https://cran.r-project.org/bin/windows/Rtools/   
初回のみ、実行前に下記の5パッケージのインストールが必要です。  
R Studio右下の「Packages」からインストールしてください。  
- tidyverse
- xts
- hms  
- here  
- broom
  
![am_package_install_1](https://user-images.githubusercontent.com/24307469/64836427-cee82d80-d624-11e9-9730-380660c90ce2.png)  
  
![am_package_install_2](https://user-images.githubusercontent.com/24307469/64836478-00f98f80-d625-11e9-9080-d5d59af1023d.png)  
### 使用方法
1. R Studioを起動し、メニューのFile > New projectを選択してください。  
1. Existing Directoryを選択し、Project working directoryに先ほど保存した「attendance_management-master」フォルダを指定してCreate Projectをクリックしてください。
1. R StudioのメニューのFile > Open Fileを選択し、「attendance_management.R」を開いてください。  
1. 画面上部中央にある「Source」をクリックすると処理が実行されます。画面左下のコンソールに「>」だけの行が表示されたら処理完了です。
1. 所定の場所のYYYYMMフォルダ（YYYYMMは対象の年月）に、個人別のテキストファイルが作成されていることを確認してください。  
