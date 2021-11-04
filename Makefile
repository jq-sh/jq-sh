export PATH := bin:$(PATH)

all: test

test:
	@bash -c "shpec"

