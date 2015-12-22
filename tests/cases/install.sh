sham reset
sham list || true

sham mijime/dat2bar  at:master do:'notfoundfunc'
sham list || true

sham mijime/dotfiles do:'true' of:'.bashrc.d/*.sh' --use='.bin/*'
sham list || true

sham install
sham list || true

sham update
sham list || true
