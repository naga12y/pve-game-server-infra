#!/bin/bash
set -e

# =================================================== #
# VanillaCord のダウンロード                               #
# =================================================== #
echo "VanillaCord をダウンロード中..."
curl -OL https://dev.me1312.net/jenkins/job/VanillaCord/lastSuccessfulBuild/artifact/artifacts/VanillaCord.jar

# =================================================== #
# パッチプログラムの作成                                 #
# =================================================== #
echo "パッチプログラムを作成中..."
VANILLA_JAR=$(ls minecraft_* | sed -e "s/^.\{17\}//" | sed 's/\.[^\.]*$//')
java -jar VanillaCord.jar "$VANILLA_JAR"

# =================================================== #
# パッチの適用 (コンテナを停止せずに適用するため、工夫が必要) #
# =================================================== #
echo "パッチを適用中..."
OUT_JAR=$(ls out/"$VANILLA_JAR"*.jar)
mv "$OUT_JAR" minecraft_server."$VANILLA_JAR".jar

# 元の Vanilla サーバー JAR をバックアップ (念のため)
if [ -f /data/server.jar ]; then
    mv /data/server.jar /data/server.jar.bak
fi

# パッチ適用後の JAR を Vanilla サーバー JAR として配置
mv minecraft_server."$VANILLA_JAR".jar /data/server.jar

# =================================================== #
# データ転送の設定                                     #
# =================================================== #
echo "データ転送の設定..."
sed -i "s/forwarding=bungeecord/forwarding=velocity/" /data/vanillacord.txt

# =================================================== #
# 秘密鍵の設定                                         #
# =================================================== #
echo "秘密鍵を設定中..."
# Velocity の秘密鍵はボリューム経由でマウントされていると仮定
if [ -f /velocity/forwarding.secret ]; then
    SECRET=$(cat /velocity/forwarding.secret)
    sed -i "s/seecret = /seecret = \"$SECRET\"/" /data/vanillacord.txt
else
    echo "警告: Velocity の秘密鍵ファイルが見つかりませんでした。"
fi

# =================================================== #
# Minecraft サーバーの起動                               #
# =================================================== #
echo "Minecraft サーバーを起動中..."
exec java ${JAVA_OPTS} -jar /data/server.jar nogui