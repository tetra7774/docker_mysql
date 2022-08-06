# DBの言語設定

## 概要
DB(Mysql)を触っていると、なぜか日本語入力ができなかった。
文字コードの設定が必要なようなので、その設定にあたっての備忘録

## ぶち当たった事象
下記のコードをTerminal上で入力すると、日本語部分だけ表示されない。。
- 入力内容
```
INSERT INTO TASK (user_id, task_id, status, contents, create_date, deadline, memo) VALUES('001', '001', ture, 山へ芝刈, '2022-07-24', '2022-07-24', '午前中に');
```
- 表示
<img width="1608" alt="スクリーンショット 2022-07-31 16 45 48" src="https://user-images.githubusercontent.com/103823940/182015694-9c972185-7088-4200-bcc2-129926b48177.png">

## 課題解決のためのプロセス
既にdocker上でDBを構築してしまっていたので、とりあえずMysql上で言語設定を変更してみることにした。
[このサイト](https://qiita.com/YusukeHigaki/items/2cab311d2a559a543e3a)
を参考に文字コードの確認をしてみた。  
- デフォルトの文字コードを確認
```
show variables like "chara%";
```
- 表示
```
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8mb4                    |
| character_set_connection | utf8mb4                    |
| character_set_database   | utf8mb4                    |
| character_set_filesystem | binary                     |
| character_set_results    | utf8mb4                    |
| character_set_server     | utf8mb4                    |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
```
「utf8mb4」が「utf-8」と何が違うのかわからなかったが、どうやら
[このサイト](https://penpen-dev.com/blog/mysql-utf8-utf8mb4/)
によると「utf8mb4」の方が1〜4バイトの文字が表示できて、「utf-8」は１〜3バイトとの文字が表示できるらしい。(つまり、「utf8mb4」の方が難しい漢字や絵文字などが表示できるとのこと)  
「utf8mb4」でも日本語の表示はできるそうなので、問題は別にあるのかも。  

- コンテナのlocateの確認  
結論の述べると、どうやら原因はコンテナのlocate設定がされていなかったのが原因のよう。  
[このサイト](https://qiita.com/maejima_f/items/4d5432aa471a9deaea7f)
を参照して、コンテナの文字コードを設定した。  
設定前にlocaleコマンド実行を実行した結果 
<img width="515" alt="スクリーンショット 2022-07-31 19 38 54" src="https://user-images.githubusercontent.com/103823940/182022296-82390fe7-47b2-45c5-b339-b79f4b303759.png">  
設定後にlocaleコマンド実行を実行した結果 
<img width="447" alt="スクリーンショット 2022-07-31 19 40 16" src="https://user-images.githubusercontent.com/103823940/182022325-0f38e095-7c66-40c8-bdab-76042e3daa6d.png">  

そもそも、Mysql以前にコンテナ上で日本語が認識されていなかったのかな。。 

## 解決後
無事にmysql上で日本語が扱えた
<img width="619" alt="スクリーンショット 2022-07-31 19 54 00" src="https://user-images.githubusercontent.com/103823940/182022767-b08d6d54-0df8-4680-88d7-82bbfe5318a5.png">  

もし、ベースになるイメージでja_JP.UTF-8のlocaleが用意されていないのであれば、
[このサイト](https://qiita.com/kazuyoshikakihara/items/0cf74c11d273b0064c83)
の後半部分を使って用意する必要がありそう。  
用意されていれば、Dockerfileに「ENV LANG ja_JP.UTF-8」を追加すれば大丈夫なのかな。。  
→今度試してみる。  


以上。
