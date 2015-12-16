

TEST_OPTIONS=
TARGET=deplug.bash deplug.zsh
COMMON_FILES=$(wildcard src/*.sh)
BASH_FILES=$(wildcard src/*.bash)
ZSH_FILES=$(wildcard src/*.zsh)
TEST_FILES=$(wildcard tests/*.zsh tests/*.bash)

all: $(TARGET)

deplug.bash: $(COMMON_FILES) $(BASH_FILES)
	cat $^ | grep -v '\[DEBUG\]' | grep -v '^$$' > $@

deplug.zsh: $(COMMON_FILES) $(ZSH_FILES)
	cat $^ | grep -v '\[DEBUG\]' | grep -v '^$$' > $@

test: $(TEST_FILES)

tests/*.zsh: deplug.zsh
	zsh $(TEST_OPTIONS) $@

tests/*.bash: deplug.bash
	bash $(TEST_OPTIONS) $@
