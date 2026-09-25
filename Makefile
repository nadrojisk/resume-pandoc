IMAGE ?= resume-pandoc:test

.PHONY: build test update-golden
build:
	docker build -t $(IMAGE) .

test: build
	IMAGE=$(IMAGE) tests/run.sh

update-golden: build
	IMAGE=$(IMAGE) tests/run.sh --update-golden
