export PATH := bin:$(PATH)

all: test casts

casts:
	$(foreach file, $(wildcard ./screencasts/*.asc), $(file);)

test:
	@bash -c "shpec"

