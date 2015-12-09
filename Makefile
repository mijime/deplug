

TARGET=deplug.bash deplug.zsh
COMMON_FILES=$(wildcard src/*.sh)
BASH_FILES=$(wildcard src/bash/*.bash)
ZSH_FILES=$(wildcard src/zsh/*.zsh)
TEST_FILES=$(wildcard tests/*.zsh tests/*.bash)

all: $(TARGET)

deplug.bash: $(COMMON_FILES) $(BASH_FILES)
	cat $^ > $@

deplug.zsh: $(COMMON_FILES) $(ZSH_FILES)
	cat $^ > $@

test: $(TEST_FILES)

tests/*.zsh: deplug.zsh
	zsh -e $@

tests/*.bash: deplug.bash
	bash -e $@
