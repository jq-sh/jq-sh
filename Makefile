export PATH := bin:$(PATH)

all: test casts

casts:
	$(foreach file, $(wildcard ./screencasts/*.asc), $(file);)

test:
	@bash -c "shpec"

test-docker:
	@bash -c "docker build -t jqsh . && docker run -i --rm jqsh"
