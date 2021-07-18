# attendance_management
## 概要
入退室ログから出勤・退勤時間を出力します。  
## ファイルのダウンロード
Zipファイルをダウンロードし、復号したファイルを任意の場所に保存してください。
![download](https://user-images.githubusercontent.com/24307469/120434705-c36c0580-c3b7-11eb-92d4-333c2e56fc81.png)
## 事前準備
初回のみ、実行前に下記の3パッケージのインストールが必要です。  
R Studio右下の「Packages」からインストールしてください。  
- tidyverse
- xts
- hms  
- here  
  
![am_package_install_1](https://user-images.githubusercontent.com/24307469/64836427-cee82d80-d624-11e9-9730-380660c90ce2.png)  
  
![am_package_install_2](https://user-images.githubusercontent.com/24307469/64836478-00f98f80-d625-11e9-9080-d5d59af1023d.png)  
### 使用方法
1. R Studioを起動し、メニューのFile > New projectを選択してください。  
1. Existing Directoryを選択し、Project working directoryに先ほど保存した「attendance_management-master」フォルダを指定してCreate Projectをクリックしてください。
1. R StudioのメニューのFile > Open Fileを選択し、「attendance_management.R」を開いてください。  
1. 画面上部中央にある「Source」をクリックすると処理が実行されます。画面左下のコンソールに「>」だけの行が表示されたら処理完了です。
1. \Attendance Management\output\YYYYMM\（YYYYMMは対象の年月）に、個人別のテキストファイルが作成されていることを確認してください。  
