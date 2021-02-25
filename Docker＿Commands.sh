# docker



#########################
##### docker状況確認 #####
#########################

# dockerにログイン
docker login
# imagesの確認
docker images
# コンテナの確認　(-a無しだとUpのコンテナのみ表示)
docker ps -a

##############################
##### イメージ・コンテナ管理 #####
##############################

# Up状態にする
docoker start <container_name_or_id>
# Exited状態にする
docker stop <container_name_or_id>
# Up状態のコンテナを再起動する (stopしてstart)
docker restart <container_name_or_id>
# 

###### コンテナ削除 #######

# Upは削除できないので、docker stop <container_name> しておく必要がある
# rm: コンテナの削除 スペースで繋げば複数可
docker rm <container_name_or_id>
# system prune: exitedのコンテナを全削除
docker system prune

####### image削除 ########
docker rmi <image_name>


# イメージのpull
docker pull <image:tag>

# pullだけする
docker pull 

docker run <image> <command>


###################################
####### docker run (exec) #########
###################################

# docker run　は　(pull +) careate + start + exec
# docker exec は 既存する Up のコンテナに入る操作。
# <command>はbashだとshellに入れる。何も無しだとimageに規定のデフォルトコマンド

# -it コンテナ内に留まる　（コンテナ内でexitで出る）
docker run -it <image> <command>
# --name コンテナ名をつける
docker run --name <container_name> <image> <command>
# --rm コマンド終了後にコンテナ削除
docker run --rm <image> <command>
# -d コマンド終了後にdetach 
docker run -d <image> <command>

# -v ホストのフォルダをコンテナにマウントして実行
docker run -v <folder_path_in_host>:<mounted_folder_path_in_container> <image> <command>
# <mounted_folder_path_in_container>は存在しないディレクトリなら勝手に作成される
# ホスト側のrootフォルダをマウントすると、コンテナ内    のroot権限で触れてしまう問題

# -u ホスト側の権限でコンテナ内に入る
docker run -it -u $(id -u):$(id -g) -v <folder_path_in_host>:<mounted_folder_path_in_container> <image> <command>
# -v でroot権限に触れてしまう問題の回避をするためにユーザー権限で入る
# 'id -u' はUser ID, 'id -g' はユーザーグループを表示するLinuxコマンド
# ＄(idーu)や$(id-g)でLinuxコマンド出力の代入になる

# -p ホストportとコンテナportを繋ぐ(publishする)
docker run -it -p <host_port>:<container_port> <image> <command>

# --cpus CPUの論理コア数を指定：枯渇を防ぐ
# --memory メモリ上限を指定：枯渇を防ぐ
docker run -it cpus 4 --memory 2g <image> <command>


########################
###### imageを作る ######
########################


###### コンテナからimageを作る ######
docker commit <container_name_or_id> <image_name>
# docker hubにuploadする場合はimage名をリボリトリ名にする必要がある
docker tag <image_name> <new_image_name:tag_name>
# docker hubにupload
docker push <image>


##### Dockerfileからimageを作る #####
# Dockerfileの書き方は別ファイルにメモ
# build contextとはbuildに指定するフォルダのこと

# カレントディレクトリから'Dockerfile'を探してビルド
docker build .
# フォルダパスを指定してその中の'Dockerfile'を探してビルド
docker build <build_context>
# -t ビルドしたイメージに名前をつけるオプション（通常つける）
docker build -t <image_name> <build_context>
# -f ’Dockerfile'以外の名前のDockerfileを指定、ビルドコンテキスト外のDockerfileを指定
docker build -f <dockerfile_path> <build_context>


##### .tarファイルからimageを作る #####
docker load < <filename.tar>


########################
###### imageを保存 ######
########################

##### docker hubにpush #####
docker


##### ファイルとして保存 #####
docker save <image ID> > <image_name.tar>
# docker load < <file_name.tar>でimageに戻せる

