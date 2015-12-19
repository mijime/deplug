sham reset
sham list || true

sham mijime/dat2bar  tag:master post:'notfoundfunc'
sham list || true

sham mijime/dotfiles post:'true' of:'.bashrc.d/*.sh' --use='.bin/*'
sham list || true

sham install
sham list || true

sham update
sham list || true
