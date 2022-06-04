# docker_mysql
dockerでMaster&SlaveのDBを構築するための備忘録的な

## レポジトリ

レポジトリ名：docker_mysql  
URL:https://github.com/tetra7774/docker_mysql.git

## 構成概要
<img width="588" alt="image" src="https://user-images.githubusercontent.com/103823940/169683615-71079ad8-1088-4444-97ac-a092766cbf00.png">

## Requirement
動作確認した環境  
- macOS Catalina 10.15.7
- Docker 20.10.12
- Mysql 5.7

## Usage(実行コマンドやTipsなど)

###　mysqlでconfファイルに設定する環境変数はこちらのサイトが参考になりそう。
- [基礎MySQL ~その２~ my.cnf (設定ファイル)](https://qiita.com/yoheiW@github/items/bcbcd11e89bfc7d7f3ff)
- [mysql:5.7のリファレンスはこれ(英語しかなかったけど)](https://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html#sysvar_log_bin)

### prepare.shについては下記のサイトが参考になりそう。
- [初心者向けシェルスクリプトの基本コマンドの紹介](https://qiita.com/zayarwinttun/items/0dae4cb66d8f4bd2a337)
- [第14回　MySQLのヘルスチェックをする［応用的な死活監視編］](https://gihyo.jp/dev/serial/01/mysql-road-construction-news/0014)


## Reference
- [Spring BootプロジェクトをDocker上で動かす](https://zenn.dev/nishiharu/articles/7f27b8c580f896)
- 実践コンテナ開発入門(p122~p134)
