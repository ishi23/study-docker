
イメージレイヤー
Docker imageeはイメージレイヤーで構成されている
コンテナを作って編集＝新しくレイヤーを追加して、そのレイヤーに書き込み
レイヤーが共通している場合にスペース節約できる
例えばベースがUbuntuというイメージで構成される複数のimageやコンテナはUbuntuよりも上の層だけ付け替えることで作ることができる。
このため容量削減が可能。


# docker commands
dockerのコマンドメモ

## dockerのステータス確認

### dockerにログイン
`$ docker login`
### imagesの確認
`$ docker images`
### コンテナの確認　(-a無しだとUpのコンテナのみ表示)
`$ docker ps -a`
CONTAINER ID: 乱数のコンテナID
IMAGE: コンテナ元のdocker image
COMMAND: コンテナに指定したコマンド（指定がなければデフォルトコマンド）
CREATED: 作成日時
STATUS: UP(起動中)、Exited、
PORTS: port number
NAMES: コンテナ名（指定しない場合は適当な名前がつく）

## イメージ・コンテナ管理

### Up状態にする
`$ docoker start <container_name_or_id>`
### Exited状態にする
`$ docker stop <container_name_or_id>`
### Up状態のコンテナを再起動する (stopしてstart)
`$ docker restart <container_name_or_id> `
####### この際、CONTAINER IDの一部でもユニークであればちゃんと読み取って動いてくれる。全てのコンテナID指定に言える。###########

### コンテナ指定削除
Upは削除できないので、docker stop <container_name> しておく必要がある   
rm: コンテナの削除 スペースで繋げば複数可
`$ docker rm <container_name_or_id>`
### exitedのコンテナを全削除
`$ docker system prune`

### image削除
docker rmi <image_name>


### イメージのpull
`$ docker pull <image:tag>`

### pullだけする
`$ docker pull`

### RUN
`$ docker run <image> <command>`


## docker run (exec)
docker run　は　(pull +) careate + start + exec
手元にイメージがあればそこからコンテナを立てる(create)し、なければpullしてくる。
docker startはコンテナをUPにする。docker exec は 既存する Up のコンテナに入る。   
<command>はbashだとshellに入れる。何も無しだとimageに規定のデフォルトコマンド。
既に存在するコンテナに入る場合はdocker runではなくdocker execを使うことに注意。
dokcer runだと新たなコンテナが作成されてしまう。

```
### -it コンテナ内に留まる　（コンテナ内でexitで出る）
docker run -it <image> <command>
# --name コンテナ名をつける
docker run --name <container_name> <image> <command>
# --rm コマンド終了後にコンテナ削除
docker run --rm <image> <command>
# -d コマンド終了後にdetach 
docker run -d <image> <command>

# -v ホストのフォルダをコンテナにマウントして実行
$ docker run -v <folder_path_in_host>:<mounted_folder_path_in_container> <image> <command>
# <mounted_folder_path_in_container>は存在しないディレクトリなら勝手に作成される
# ホスト側のrootフォルダをマウントすると、コンテナ内    のroot権限で触れてしまう問題

# -u ホスト側の権限でコンテナ内に入る
$ docker run -it -u $(id -u):$(id -g) -v <folder_path_in_host>:<mounted_folder_path_in_container> <image> <command>
# -v でroot権限に触れてしまう問題の回避をするためにユーザー権限で入る
# 'id -u' はUser ID, 'id -g' はユーザーグループを表示するLinuxコマンド
# ＄(idーu)や$(id-g)でLinuxコマンド出力の代入になる

# -p ホストportとコンテナportを繋ぐ(publishする)
$ docker run -it -p <host_port>:<container_port> <image> <command>

# --cpus CPUの論理コア数を指定：枯渇を防ぐ
# --memory メモリ上限を指定：枯渇を防ぐ
$ docker run -it cpus 4 --memory 2g <image> <command>
```

## コンテナから出る
exit
Exited状態になる
detach
UPのまま。あまり使わなくて良さそう。

## imageを作る
Docker Hubのリポジトリを作る
リポジトリ名はハイフンで繋げる
リポジトリ名とイメージ名を同じにする必要がある。
docker tag <user-name>/<repo-name> # docker image名の変更
そのリポジトリ

### コンテナからimageを作る
```
$ docker commit <container_name_or_id> <image_name>
# docker hubにuploadする場合はimage名をリボリトリ名にする必要がある
$ docker tag <image_name> <new_image_name:tag_name>
# docker hubにupload
$ docker push <image>
```

### Dockerfileからimageを作る
Dockerfileの書き方は別ファイルにメモ   
build用のフォルダにDockerfileと持ち込みファイルを用意した状態での操作を下に記述する。
build contextとはbuildに指定するフォルダのこと。build contextをdocker daemonの渡してbuildする.
docker daemonはサーバーというイメージ。なので別マシンにも置ける。ただあまり意識しなくても良い。 
```
# カレントディレクトリから'Dockerfile'を探してビルド
$ docker build .
# フォルダパスを指定してその中の'Dockerfile'を探してビルド
$ docker build <build_context>
# -t ビルドしたイメージに名前をつけるオプション（通常つける）
$ docker build -t <image_name> <build_context>
# -f ’Dockerfile'以外の名前のDockerfileを指定、ビルドコンテキスト外のDockerfileを指定
$ docker build -f <dockerfile_path> <build_context>
```

### .tarファイルからimageを作る
`$ docker load < <filename.tar>`


## imageを保存

### docker hubにpush
`$ docker   `


### ファイルとして保存
`$ docker save <image ID> > <image_name.tar>`   
docker load < <file_name.tar>でimageに戻せる

