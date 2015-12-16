deplug --verbose reset
deplug --verbose status || true

deplug --verbose mijime/dat2bar  tag:master post:'notfoundfunc'
deplug --verbose status || true

deplug --verbose mijime/dotfiles post:'true' of:'.bashrc.d/*.sh' --use='.bin/*'
deplug --verbose status || true

deplug --verbose install
deplug --verbose status || true

deplug --verbose upgrade
deplug --verbose status || true
