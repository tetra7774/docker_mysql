FROM mysql:5.7

#wgetのインストール
RUN apt-get update
RUN apt-get install -y wget

#entrykitのインストール
RUN wget https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz
RUN tar -zxvf entrykit_0.4.0_Linux_x86_64.tgz
RUN rm entrykit_0.4.0_Linux_x86_64.tgz
RUN mv entrykit usr/local/bin
#↓entrykitで主要な実行ファイルのシンボリックファイルを作成してくれる
RUN entrykit --symlink

COPY add-server-id.sh /usr/local/bin/
COPY mysqld.cnf /etc/mysql/mysql.conf.d/
COPY mysql.cnf /etc/mysql/conf.d/
COPY prepare.sh /docker-entrypoint-initdb.d
COPY init-data.sh /usr/local/bin/
COPY sql /sql

# (4) スクリプトとmysqldの実行
ENTRYPOINT [ \
  "prehook", \
    "add-server-id.sh", \
    "--", \
  "docker-entrypoint.sh" \
]

CMD ["mysqld"]