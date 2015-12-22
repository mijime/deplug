__sham__options=(--verbose)
sham ${__sham__options[@]} 'mijime/dotfiles' of:'.bashrc.d/*.sh' use:'.bin/*'
sham ${__sham__options[@]} 'mijime/dat2bar' --do 'go build' --at 'master' --use 'dat2bar*' --as=mijime/dat2bar
sham ${__sham__options[@]} 'mijime/merje'   do: 'go build' dir: '/tmp/space dir'
sham ${__sham__options[@]} list
sham ${__sham__options[@]} clean --yes
sham ${__sham__options[@]} install
sham ${__sham__options[@]} load
