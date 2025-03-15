.PHONY: build_debug build run clean

GAME_NAME := testbed

# asset_srcs := $(shell find assets -type f -not -path "assets/shaders/*")
# asset_dsts := $(patsubst assets/%,build/assets/%,$(asset_srcs))

shader_srcs := $(wildcard assets/shaders/*.vert) $(wildcard assets/shaders/*.frag)
shader_objs_rls := $(patsubst assets/shaders/%,build/release/shaders/%.spv,$(shader_srcs))
shader_objs_dbg := $(patsubst assets/shaders/%,build/debug/shaders/%.spv,$(shader_srcs))

build/release/shaders/%.spv: assets/shaders/%
build/debug/shaders/%.spv: assets/shaders/%
	@mkdir -p $(@D)
	@glslc -o $@ $<

# build/release/assets/%: assets/%
# build/debug/assets/%: assets/%
# 	cp -r $< $@

# build_assets: $(shader_objs) $(assets)

build_assets_rls: $(shader_objs)
build_assets_dbg: $(shader_objs_dbg)

build_release: build_assets_rls
	@mkdir -p build/release/

	@odin build $(GAME_NAME) \
		-vet \
		-o:speed \
		-build-mode:dynamic \
		-out:build/release/$(GAME_NAME)

	@odin build bolt \
		$(FLAGS) \
		-vet \
		-o:speed \
		-warnings-as-errors \
		-define:GAME_NAME=$(GAME_NAME) \
		-collection:vendored=vendored \
		-collection:bolt=bolt \
		-out:build/release/$(GAME_NAME)

build: build_assets_dbg
	@mkdir -p build/debug/

	@odin build $(GAME_NAME) \
		-debug \
		-build-mode:dynamic \
		-out:build/debug/$(GAME_NAME)

	@odin build bolt \
		$(FLAGS) \
		-debug \
		-define:GAME_NAME=$(GAME_NAME) \
		-collection:vendored=vendored \
		-collection:bolt=bolt \
		-out:build/debug/$(GAME_NAME)

run_release: build_release
	cd build/release && ./$(GAME_NAME)

run: build
	cd build/debug && ./$(GAME_NAME)

clean:
	@rm -rf build
