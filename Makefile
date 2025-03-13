.PHONY: build run clean

GAME_NAME := testbed

asset_srcs := $(shell find assets -type f -not -path "assets/shaders/*")
asset_dsts := $(patsubst assets/%,build/assets/%,$(asset_srcs))
shader_srcs := $(wildcard assets/shaders/*.vert) $(wildcard assets/shaders/*.frag)
shader_objs := $(patsubst assets/shaders/%,build/shaders/%.spv,$(shader_srcs))

build/shaders/%.spv: assets/shaders/%
	@mkdir -p build/shaders
	@glslc -o $@ $<

build/assets/%: assets/%
	cp -r $< $@

build_assets: $(shader_objs) $(assets)

build: build_assets
	@mkdir -p build/

	@odin build $(GAME_NAME) \
		-debug \
		-build-mode:dynamic \
		-out:build/$(GAME_NAME)

	@odin build bolt \
		$(FLAGS) \
		-debug \
		-define:GAME_NAME=$(GAME_NAME) \
		-collection:vendored=vendored \
		-collection:bolt=bolt \
		-out:build/$(GAME_NAME)

run: build
	cd build && ./$(GAME_NAME)

clean:
	@rm -rf build
