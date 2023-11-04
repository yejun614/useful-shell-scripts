# -------------------------------------------------------------
# 초기화하는데 시간이 오래걸리는 명령어들은 shell이 켜질때 마다
# 실행시키는 것 보다 필요할때 초기화하여 이용하는 것이 shell
# 실행시간 단축에 도움이 됩니다.

function nvm() {
    source /usr/local/opt/nvm/nvm.sh --no-use ';' nvm $*
}

function conda_ready() {
    source $HOME/anaconda3/etc/profile.d/conda.sh
    conda activate
}

function pyenv_ready() {
    eval "$(pyenv init -)"
}
# -------------------------------------------------------------
# exa(https://github.com/ogham/exa)라고 하는 프로그램을 사용하면
# ls 명령어를 조금더 예쁘게 볼수 있습니다.
# (아이콘이 꽤 유용한데 제대로 보기 위해서는 Nerd Font를 설치하셔야 합니다)
function lexa() {
    exa --icons --color=always $*
}

function ls() {
  lexa $*
}

function l() {
    lexa -al $*
}

function ll() {
    lexa -aal $*
}

function lm() {
    # 마지막으로 수정한 파일이 제일 아래에 출력 됩니다.
    l -s modified $*
}
# -------------------------------------------------------------
# VIM와 같이 자주사용하는 편집기는 Edit의 앞 글자인 e만 입력해도
# 바로 켜지도록 하면 편리 합니다.
function e() {
    nvim $*
}

# Python3
function py() {
    # Python은 Virtual Environment와 함께 사용하는 경우가 많은데
    # 현제 어떤 인터프리터를 사용중인지 바로바로 확인할 수 있으면
    # 꽤 편리합니다.
    echo "⭐️ Python Interpreter: \e[4m$(which python3)\e[0m"
    python3 $*
}

# lazygit
function lg() {
    # lazygit(https://github.com/jesseduffield/lazygit)은 TUI환경
    # 에서 사용할 수 있는 Git Client 입니다.
    lazygit $*
}

# 일반적으로 rm 명령어는 파일을 삭제할때 사용되는 명령어 입니다.
# 하지만 파일은 한번 삭제되면 복구할 수 없기 때문에 실수로 파일을
# 삭제하는 경우가 종종 있는데요. rm 명령어을 파일을 바로 삭제시키지 않고
# 휴지통으로 보내는 명령어로 변경하였습니다.
# (삭제후에 recovery 명령어를 사용하면 이전에 삭제했던 파일을 원래 위치로
# 되돌려 줍니다)
function rm() {
    # for recovery
    unset RM_ARGS
    declare -Ax RM_ARGS

    if test $# -eq 0
    then
        echo 🙏 No files to delete
    else
        for i in $*
        do
            if test -e $i
            then
                trash_file=$(basename $i)

                if test -e $HOME/.Trash/$trash_file
                then
                    trash_file=$(date)_$trash_file
                fi

                mv $i $HOME/.Trash/$trash_file
                echo 👍 move \"$i\" file to trash! \($trash_file\)

                RM_ARGS[$trash_file]=$i
            else
                echo 🥕 File does not exist \($i\)
            fi
        done
    fi
}

# 위의 rm명령어로 휴지통으로 이동한 파일을 원래 위치로 되돌려 줍니다.
function recovery() {
    if test $#RM_ARGS -eq 0
    then
        echo 🙏 No files to deleted
    else
        for i in ${(k)RM_ARGS}
        do
            trash_file=$i
            file_path=$RM_ARGS[$i]

            if test -e $HOME/.Trash/$trash_file
            then
                if test -e $trash_file
                then
                    trash_file=recovered_(date)_$trash_file
                fi

                mv $HOME/.Trash/$trash_file $file_path
                echo 👍 recovery file to here! \($trash_file\)
            else
                echo 🥕 File does not exist in trash \($trash_file\)
            fi
        done
    fi

    unset RM_ARGS
}

# 현재 Working Directory를 이동합니다.
# (CD_ARGS 환경변수에 이동하기 이전 위치를 기록해 두었다가 back 명령어
# 가 실행되면 CD_ARGS로 되돌아갑니다)
function cd() {
    export CD_ARGS=$(pwd)
    builtin cd $*
}

# 이전 위치로 되돌아 갑니다.
function back() {
    cd $CD_ARGS
}

# 상위 폴더로 계속 올라면서 파일을 찾습니다.
function upfind() {
  current=$PWD
  prev=.

  while test $PWD != "$prev"
  do
    find "$PWD" -maxdepth 1 "$@"
    prev=$PWD
    cd ..
  done
  
  cd $current
}

# 파이썬을 사용하다 보면 Virtual Environment을 사용할 일이 많습니다.
# activate 명령어는 upfind 명령어를 사용하여 상위 폴더에 있는 venv 폴더를
# 찾아 Virtual Environment를 활성화 합니다.
function activate() {
  if [ "$1" != "" ]
  then
    venv=$1
  else
    venv=$(upfind -name "venv" | head -n 1)
  fi
  
  if [ "$venv" != "" ]
  then
    source $venv/bin/activate
    echo ✨ python venv activate \($venv\)
  else
    echo 🙏 no python venv files
  fi
}

# activate 명령어에 실패하더라도 오류 메세지는 띄우지 않습니다.
# Shell을 실행시킬때 자동으로 실행되도록 하면 유용합니다.
function activate_no_errors() {
  venv=$(upfind -name "venv" | head -n 1)
  
  if [ "$venv" != "" ]
  then
    source $venv/bin/activate
    echo ✨ python venv activate \($venv\)
  fi
}
