caseAll(){
  deplug ${__dplg__options[@]} clean
  deplug ${__dplg__options[@]} 'mijime/dotfiles' of: '.bashrc.d/*.sh' use: '.bin/*'
  deplug ${__dplg__options[@]} 'mijime/dat2bar'  --post 'go build' --tag 'master' --use 'dat2bar*'
  deplug ${__dplg__options[@]} install
  deplug ${__dplg__options[@]} load
}

export DEPLUG_HOME=${cdir}/tmp
export DEPLUG_BIN=${cdir}/tmp/bin

__dplg__options=(--verbose --debug)
evalute 'all' caseAll
