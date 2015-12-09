

TARGET=deplug.bash deplug.zsh
BASE_FILES=$(wildcard src/*.sh)
BASH_FILES=$(wildcard src/bash/*.bash)
ZSH_FILES=$(wildcard src/zsh/*.zsh)

all: $(TARGET)

deplug.bash: $(BASH_FILES) $(BASH_FILES)
	cat $< > $@

deplug.zsh: $(BASH_FILES) $(zsh_FILES)
	cat $< > $@

test: all
	bash tests/base.bash
