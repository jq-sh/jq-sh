export PATH := bin:$(PATH)

all: test casts

casts:
	$(foreach file, $(wildcard ./screencasts/*.asc), $(file);)

test:
	@bash -c "shpec"

docker_test:
	@bash -c "docker build -t jqsh . && docker run -i --rm jqsh"
