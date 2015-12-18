deplug reset
deplug list || true

deplug mijime/dat2bar  tag:master post:'notfoundfunc'
deplug list || true

deplug mijime/dotfiles post:'true' of:'.bashrc.d/*.sh' --use='.bin/*'
deplug list || true

deplug install
deplug list || true

deplug update
deplug list || true
