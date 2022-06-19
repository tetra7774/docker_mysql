# docker_mysql
dockerでMaster&SlaveのDBを構築するための備忘録的な

## レポジトリ

レポジトリ名：docker_mysql  
URL:https://github.com/tetra7774/docker_mysql.git

## 構成概要
<img width="615" alt="スクリーンショット 2022-06-18 15 11 05" src="https://user-images.githubusercontent.com/103823940/174425414-dc6fcaef-9f58-45f9-888f-4a1821e9abac.png">

## Requirement
動作確認した環境  
- macOS Catalina 10.15.7
- Docker 20.10.12
- Mysql 5.7

## Usage(実行コマンドやTipsなど)
#### 下準備
1. クラスタを作っておく。  
参考→[dind (自分用のGit)](https://github.com/tetra7774/dind)  
2. todo-mysql.ymlをクラスタ構成のMasterに置いておく。  
※todo-mysql.ymlはStackの設定ファイル
2. DockerfileをBuildしておき、DockerhubにPushしとく。
### 実行コマンド  
1. NWを作っておく。現時点では必要性はないが、今回構築するDBの他に別なStackと通信するかも用。  
```docker container exec -it manager docker network create --driver=overlay --attachable ch01```
2. managerコンテナに向けてtodo-mysql.ymlをtodo_mysqlスタックとしてデプロイ  
```docker container exec -it manager docker stack deploy -c /stack/todo-mysql.yml todo_mysql```  
※Stackで作成されるService名は、Stack名_設定したService名  
3. 次にDBにデータをセットしていく。まずはDB(Master)にデータを投入するので、クラスタ構成で言うManagerにDB(Master)をどのコンテナに作成したかを聞きにいく。コマンドは下記の通り。  
```docker container exec -it manager docker service ps todo_mysql_master --no-trunc```  
※--no-truncオプション：デフォルトだと表示される項目が省略されるが、このオプションを指定するとフルの長さで表示される。
4. 「3.」でDB(master)が起動しているノードが分かるので目的のコンテナに多段でアクセスする。  
```docker container exec -it ノードID docker container exec -it タスクID bash```  
ノード：ノード（node） とは、swarm （クラスタ）に参加している Docker Engine のこと。ホスト(Docker)とほぼ同じかな。今回はたまたまdindで構築しているだけなのでノード≠コンテナであることに注意。
5. 「4.」でDB(Master)にアクセスしたのでinit-data.shを実行してテーブルとデータを作成。  
```init-data.sh```
6. テーブルの確認
```mysql -u gihyo -pgihyo tododb```
```SELECT * FROM todo LIMIT 1\G```
※LIMITオプション：レコード何行分表示するか
※\G：SQL文の末尾に\Gを付けると縦に表示されてちょっと見やすくなる(;の代わりに入力)  
DB(Slave)もmaster-Slave構成なので同様の方法でテーブルを確認できる。



### mysqlでconfファイルに設定する環境変数はこちらのサイトが参考になりそう。
- [基礎MySQL ~その２~ my.cnf (設定ファイル)](https://qiita.com/yoheiW@github/items/bcbcd11e89bfc7d7f3ff)
- [mysql:5.7のリファレンスはこれ(英語しかなかったけど)](https://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html#sysvar_log_bin)

### prepare.shについては下記のサイトが参考になりそう。
- [初心者向けシェルスクリプトの基本コマンドの紹介](https://qiita.com/zayarwinttun/items/0dae4cb66d8f4bd2a337)
- [第14回　MySQLのヘルスチェックをする［応用的な死活監視編］](https://gihyo.jp/dev/serial/01/mysql-road-construction-news/0014)


## Reference
- [Spring BootプロジェクトをDocker上で動かす](https://zenn.dev/nishiharu/articles/7f27b8c580f896)
- 実践コンテナ開発入門(p122~p134)
