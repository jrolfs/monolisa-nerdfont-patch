ARGS ?= -c
OK_TYPES := otf ttf woff woff2
NF_SRC := $(shell find src -type f)
ML_TYPES := $(shell find ./MonoLisa \
						-mindepth 1 \
						-maxdepth 1 \
						-not -empty \
						-type d \
						-exec basename {} \;)

UNKNOWN := $(filter-out $(OK_TYPES),$(ML_TYPES))
$(if $(UNKNOWN),$(error unknown font type in ./MonoLisa: $(UNKNOWN)))

msg = $(call tprint,{a.bold}==>{a.end} {a.b_magenta}$(1){a.end} {a.bold}<=={a.end})

## patch | add nerd fonts to MonoLisa
ifdef DOCKER
.PHONY: patch
patch: $(foreach ml-type,$(ML_TYPES),patch-$(ml-type)-docker)
else
.PHONY: patch
patch: $(addprefix patch-,$(ML_TYPES))
endif

patch-%: ./bin/font-patcher
	$(call msg, Patching MonoLisa $* Files)
	@./bin/patch-monolisa $* $(ARGS)

patch-%-docker: ./bin/font-patcher
	$(call msg, Patching Monolisa $* Files w/Docker)
	@./bin/patch-monolisa-docker $* $(ARGS)

## update-fonts | move fonts and update fc-cache
.PHONY: update-fonts
update-fonts:
	$(call msg,Adding Fonts To System)
	@./bin/update-fonts
	@fc-cache -f -v

## check | check fc-list for MonoLisa
.PHONY: check
check:
	$(call msg,Checking System for Fonts)
	@fc-list | grep "MonoLisa"

## update-src | update nerd fonts source
.PHONY: update-src
update-src:
	$(call msg,Updating Source Files)
	@./bin/update-src

## lint | check shell scripts
.PHONY: lint
lint:
	@shfmt -w -s $(shell shfmt -f bin/)

## clean | remove patched fonts
.PHONY: clean
clean:
	@rm -r patched/*

USAGE = {a.b_green}Update MonoLisa with Nerd Fonts! {a.end}\n\n{a.header}usage{a.end}:\n	make <recipe>\n
-include .task.mk
