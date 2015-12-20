TEST_OPTIONS=
TARGET=sham.bash sham.zsh
COMMON_FILES=$(wildcard src/*.sh)
BASH_FILES=$(wildcard src/*.bash)
ZSH_FILES=$(wildcard src/*.zsh)
TEST_FILES=$(wildcard tests/*.zsh tests/*.bash)

all: $(TARGET)

sham.bash: $(COMMON_FILES) $(BASH_FILES)
	cat $^ | grep -v '\[DEBUG\]' | grep -v '^$$' > $@

sham.zsh: $(COMMON_FILES) $(ZSH_FILES)
	cat $^ | grep -v '\[DEBUG\]' | grep -v '^$$' > $@

test: $(TEST_FILES)

tests/%.zsh:
	zsh $(TEST_OPTIONS) $@

tests/%.bash:
	bash $(TEST_OPTIONS) $@

docker/%: tests/dockerfiles/%/Dockerfile
	docker build -t $* -f $< .

docker.build/bash_%: docker/bash_%
	docker run --rm --volume /$$(pwd)://wk --workdir //wk --env=TEST_TARGET=$(TEST_TARGET) \
		$* bash $(TEST_OPTIONS) tests/base.bash

tests/docker: docker.build/bash_3.0 docker.build/bash_4.0
