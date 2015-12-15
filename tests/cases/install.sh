deplug reset
deplug mijime/dat2bar  tag:master post:'notfoundfunc'
deplug mijime/dotfiles post:'true' of:'.bashrc.d/*.sh' --use='.bin/*'
deplug install --verbose
deplug upgrade --verbose
