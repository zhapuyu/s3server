# Set an output prefix, which is the local directory if not specified
PREFIX?=$(shell pwd)
BUILDTAGS=

.PHONY: clean all fmt vet lint build test install static
.DEFAULT: default

all: clean build fmt lint test vet install

build:
	@echo "+ $@"
	@go build -tags "$(BUILDTAGS) cgo" .

static:
	@echo "+ $@"
	CGO_ENABLED=1 go build -tags "$(BUILDTAGS) cgo static_build" -ldflags "-w -extldflags -static" -o s3server .

server:
	@docker build --rm --force-rm -t r.j3ss.co/s3server .
	@docker run --rm -it -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -p 8080:8080 r.j3ss.co/s3server -bucket s3://hugthief/gifs

fmt:
	@echo "+ $@"
	@gofmt -s -l . | grep -v vendor | tee /dev/stderr

lint:
	@echo "+ $@"
	@golint ./... | grep -v vendor | tee /dev/stderr

test: fmt lint vet
	@echo "+ $@"
	@go test -v -tags "$(BUILDTAGS) cgo" $(shell go list ./... | grep -v vendor)

vet:
	@echo "+ $@"
	@go vet $(shell go list ./... | grep -v vendor)

clean:
	@echo "+ $@"
	@rm -rf s3server

install:
	@echo "+ $@"
	@go install .
