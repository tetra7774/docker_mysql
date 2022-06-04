#!/bin/bash -e

# (1) MasterとSlaveを環境変数で制御する
# [-z "環境変数"の場合、環境変数が空の場合Trueを返す]
# 正常終了した場合はexit 0で異常終了の場合はexit 1を書くらしい
if [ ! -z "$MYSQL_MASTER" ]; then
  echo "this container is master"
  exit 0
fi

echo "prepare as slave"

# (2) SlaveからMasterへの疎通確認をする
#  1>&2 は標準出力を標準エラー出力に追記
if [ -z "$MYSQL_MASTER_HOST" ]; then
  echo "mysql_master_host is not specified" 1>&2
  exit 1
fi

# Masterにログインした後、quitコマンドで抜けている(-eを指定するとその後にsql文を入力できる。)
while :
do
  if mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "quit" > /dev/null 2>&1 ; then
    echo "MySQL master is ready!"
    break
  else
    echo "MySQL master is not ready"
  fi
  sleep 3
done

# (3) Masterにレプリケーション用のユーザーと権限の作成
# setコマンド：環境変数の一覧を表示
IP=`hostname -i`
IFS='.'
set -- $IP # 恐らく、$IPを引数として設定している
SOURCE_IP="$1.$2.%.%" #引数、1番目の引数を$1、2番目の引数を$2でアクセスする
#↓MasterにアクセスしてSlaveにアクセスするようのユーザを作成
mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$MYSQL_REPL_USER'@'$SOURCE_IP' IDENTIFIED BY '$MYSQL_REPL_PASSWORD';"
mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPL_USER'@'$SOURCE_IP';"

# (4) Masterのbinlogのポジションを取得
MASTER_STATUS_FILE=/tmp/master-status
mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS\G" > $MASTER_STATUS_FILE
BINLOG_FILE=`cat $MASTER_STATUS_FILE | grep File | xargs | cut -d' ' -f2` #ファイルの一覧からFileと記載のあるディレクトリを出力してその内容をxargeコマンドでcutコマンドに渡している。cutコマンドの-dで渡されたファイルをスペースで区切り、その2項目名を出力する。
BINLOG_POSITION=`cat $MASTER_STATUS_FILE | grep Position | xargs | cut -d' ' -f2`
echo "BINLOG_FILE=$BINLOG_FILE"
echo "BINLOG_POSITION=$BINLOG_POSITION"

# (5) レプリケーションを開始する 
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CHANGE MASTER TO MASTER_HOST='$MYSQL_MASTER_HOST', MASTER_USER='$MYSQL_REPL_USER', MASTER_PASSWORD='$MYSQL_REPL_PASSWORD', MASTER_LOG_FILE='$BINLOG_FILE', MASTER_LOG_POS=$BINLOG_POSITION;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "START SLAVE;"

echo "slave started"
