FROM itzg/minecraft-server:latest

# 必要に応じて追加のパッケージをインストール
RUN apt update && apt install -y wget

# 自動実行するシェルスクリプトをコンテナにコピー
COPY ./scripts/entrypoint.sh /entrypoint.sh

# スクリプトに実行権限を与える
RUN chmod +x /entrypoint.sh

# コンテナ起動時のエントリーポイントをシェルスクリプトに変更
ENTRYPOINT ["/entrypoint.sh"]

# (CMD は ENTRYPOINT を上書きするので、通常は不要)
# CMD ["start"]