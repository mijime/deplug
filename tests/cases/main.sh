caseAll(){
  deplug ${__dplg__options[@]} 'mijime/dotfiles' of:'.bashrc.d/*.sh' use:'.bin/*'
  deplug ${__dplg__options[@]} 'mijime/dat2bar' --post 'go build' --tag 'master' --use 'dat2bar*' --as=mijime/dat2bar
  deplug ${__dplg__options[@]} 'mijime/merje'   post: 'go build' dir: '/tmp/space dir'
  deplug ${__dplg__options[@]} list
  deplug ${__dplg__options[@]} clean --yes
  deplug ${__dplg__options[@]} install
  deplug ${__dplg__options[@]} load
}

__dplg__options=(--verbose)
evalute 'all' caseAll
