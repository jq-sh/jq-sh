export PATH := bin:$(PATH)

SCREENCASTS_DIR := screencasts

outputs := $(foreach file, $(wildcard $(SCREENCASTS_DIR)/*.asc), $(patsubst %.asc,%.cast,$(file)))

all: test casts

casts: $(outputs)

$(SCREENCASTS_DIR)/%.cast: $(SCREENCASTS_DIR)/%.asc
	asciinema-rec_script $(patsubst %.cast,%.asc,$@)

casts_upload:
	upload.sh

test:
	shpec

test-docker:
	bash -c "docker build -t jq-sh . && docker run -i --rm jq-sh"
