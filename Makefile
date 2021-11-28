export PATH := bin:$(PATH)

all: test casts

casts:
	$(foreach file, $(wildcard ./screencasts/*.asc), $(file);)

casts_upload:
	@bash -c "./screencasts/upload.sh"

test:
	@bash -c "shpec"

test-docker:
	@bash -c "docker build -t jq-sh . && docker run -i --rm jq-sh"
