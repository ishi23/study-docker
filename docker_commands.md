## Dockerとは
- 仮想環境技術
- 基本的にはソフト的にはLinuxカーネルのみを共有する（ハードは当然共有）
- 環境をほぼ丸ごと構築・再現できる

## Docker imageやcontainerの構造
- 複数のイメージレイヤーから成る
- コンテナを作って編集＝新しくレイヤーを追加して、そのレイヤーに書き込み
- レイヤーが共通している場合にスペース節約できるメリット（自分のマシンでも、DockerHubでも）
- 例えばベースがUbuntuイメージで構成されるimageやコンテナは、Ubuntuよりも上書き分のレイヤだけ付け替えることで作ることができる。

## Tips
- image IDやコンテナIDは乱数で補完も効かないため一見扱いにくい。
- しかしタグ付けすることで扱いやすくなる
- また、IDの一部だけの入力でもユニークで特定できれば読み取ってくれる（最初の３文字くらいで十分）。


# docker commands
dockerのコマンドメモ

## dockerのステータス確認
```
# dockerにログイン。DockerHubアカウント
$ docker login

# imagesの確認
$ docker images

# コンテナの確認　(-aオプション無しだとUpのコンテナのみ表示に成るので、基本つける)
$ docker ps -a

## docker ps の出力の意味 ##
# CONTAINER ID: 乱数のコンテナID
# IMAGE: コンテナ元のdocker image
# COMMAND: コンテナに指定したコマンド（指定がなければデフォルトコマンド）
# CREATED: 作成日時
# STATUS: UP(起動中)、Exited、
# PORTS: port number
# NAMES: コンテナ名（指定しない場合は適当な名前がつく）
```

## イメージ・コンテナの取扱い

### コンテナをUpにする
`$ docoker start <container_name_or_id>`
### コンテナをExitedにする
`$ docker stop <container_name_or_id>`
### コンテナを再起動する (stopしてstart。stopしてたらstartと同じ)
`$ docker restart <container_name_or_id> `


### コンテナ削除
Up状態のコンテナは削除できないので、`docker stop <container_name>` しておく必要がある   
### コンテナ指定削除。スペースで繋いで複数指定可能。
`$ docker rm <container_name_or_id>`
### exitedのコンテナを全削除
`$ docker system prune`

### image削除
$ docker rmi <image_name>


### イメージのpull（tag指定無しだとデフォルトでlatest)
`$ docker pull <image:tag>`

### コンテナを立てて実行（run）
`$ docker run <image> <command>`
### 既存のコンテナを実行(exec)
`$ docker exec <container_id> <command>`

## docker run を詳しく（execも大体一緒）
- docker run　は　(pull +) careate + start + exec
- 手元にイメージがあればそこからコンテナを立てる(create)し、なければpullしてくる。
- docker startはコンテナをUPにする。docker execでそのコンテナに入る。
- <command>はbashだとshellに入れる。何も無しだとimageに規定のデフォルトコマンド。
- 既に存在するコンテナに入る場合はdocker runではなくdocker execを使うことに注意。dokcer runだと新たなコンテナが作成されてしまう。

```
# -it コンテナ内に留まる　（コンテナ内でexitで出る）
docker run -it <image> <command>

# --name コンテナ名をつける(中で操作する系のコンテナにはつけよう)
docker run --name <container_name> <image> <command>

# --rm コマンド終了後にコンテナ削除（一時操作系のコンテナ）
docker run --rm <image> <command>

# -d コマンド終了後にdetach（あんま使わないかも）
docker run -d <image> <command>

# -v ホストのフォルダをコンテナにマウントして実行（重要）
$ docker run -v <folder_path_in_host>:<mounted_folder_path_in_container> <image> <command>
# <mounted_folder_path_in_container>は存在しないディレクトリなら勝手に作成される
# ホスト側のrootフォルダをマウントすると、コンテナ内のroot権限で編集できてしまうので注意

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
- `c$ exit`: Exited状態になる
- `c$ detach`: UPのまま。あまり使わなくて良さそう。

## imageを作る


### コンテナからimageを作る(Dockerfileから作れた方が明示的でベスト)
```
# コンテナからimageの作成
$ docker commit <container_name_or_id> <new_image_name>
```

### Dockerfileからimageを作る
- Dockerfileの書き方は別ファイルにメモ   
- build用のフォルダ(build contextと呼ぶ)に、Dockerfileと持ち込みファイルを入れた状態での操作を下に記述。
- この際build contextがdocker daemonに渡されてbuildする.docker daemonはサーバーというイメージ。なので別マシンにも置ける。ただあまり意識しなくても良い。 
```
# カレントディレクトリをbuild contextをしてビルド
$ docker build .

# build contextパスを指定してビルド
$ docker build <build_context>

# -t ビルドしたイメージに名前をつけるオプション（通常つける）
$ docker build -t <image_name> <build_context>

# -f ’Dockerfile'以外の名前のDockerfileを指定、ビルドコンテキスト外のDockerfileを指定(使わない)
$ docker build -f <dockerfile_path> <build_context>
```

### .tarファイルからimageを作る（作るというか復元する）
```
$ docker load < <filename.tar>
```

### Docker imageをExportする

#### DockerHubへのアップロード
- まずDocker Hub内でリポジトリを作る。リポジトリ名はハイフンで繋げるのが慣習。
```
# リポジトリ名とイメージ名を同じにする必要があるので、アップロードするimage名をリボリトリ名に変更する   
$ docker tag <user-name>/<repo-name> # docker image名の変更

# docker hubにupload
$ docker push <image>
```

#### Docker imageをファイルとして保存。転送先で解凍して使用する
- 仕事で使いそう
```
# ファイルとして保存
$ docker save <image ID> > <image_name.tar>

# 解凍する
$ docker load < <filename.tar>
```