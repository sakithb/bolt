.PHONY: build_debug build run clean

GAME_NAME := testbed
MODE = debug

asset_srcs := $(shell find assets -type f)
asset_dsts := $(patsubst assets/%,build/$(MODE)/assets/%,$(asset_srcs))

build/$(MODE)/assets/shaders/%: assets/shaders/%
	@mkdir -p $(@D)
	@glslc -o $@ $<

build/assets/%: assets/%
	cp -r $< $@

build_assets: $(asset_dsts)

build: build_assets
ifeq ($(MODE), debug)
	@mkdir -p build/debug/

	odin build $(GAME_NAME) \
		-debug \
		-collection:bolt=bolt \
		-collection:vendored=vendored \
		-out:build/debug/$(GAME_NAME)
endif

run: build
	cd build/$(MODE) && ./$(GAME_NAME)

clean:
	@rm -rf build
