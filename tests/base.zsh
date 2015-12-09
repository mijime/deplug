#!/usr/bin/zsh -e

evalute(){
  echo $1
  shift

  time "$@"
}

caseAll(){
  deplug ${__dplg__options[@]} clean
  deplug ${__dplg__options[@]} 'mijime/dotfiles' --post 'source .bashrc.d/*.sh' --of '.bashrc.d/*.sh' --use '.bin/*'
  deplug ${__dplg__options[@]} 'mijime/dat2bar'  --post 'go build' --tag 'master' --use 'dat2bar*'
  deplug ${__dplg__options[@]} install
  deplug ${__dplg__options[@]} load
}

__dplg__options=(--verbose --debug)

source ${0%/*}/../deplug.zsh

evalute 'clean install load' caseAll
