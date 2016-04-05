TEST_OPTIONS=
TARGET=sham.bash sham.zsh
COMMON_FILES=$(wildcard src/*.sh)
BASH_FILES=$(wildcard src/*.bash)
ZSH_FILES=$(wildcard src/*.zsh)
TEST_TARGET=$(wildcard test/*/*.sh)

all: $(TARGET)

sham.bash: $(COMMON_FILES) $(BASH_FILES)
	cat $^ | grep -v '\[DEBUG\]' | grep -v '^$$' > $@

sham.zsh: $(COMMON_FILES) $(ZSH_FILES)
	cat $^ | grep -v '\[DEBUG\]' | grep -v '^$$' > $@

test: $(TEST_TARGET)

test/%.sh: $(TARGET)
	test/unitesh.sh $@

docker/%/build: docker/%
	docker build --tag=sham:$* $<

docker/%/test: docker/%/build $(TEST_TARGET) $(TARGET)
	docker run --rm --volume /$$(pwd)://w --workdir //w sham:$* test/unitesh.sh $(TEST_TARGET)

docker: docker/bash-3.0/test docker/bash-4.0/test docker/bash/test docker/zsh/test
