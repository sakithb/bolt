.PHONY: build run clean

engine_srcs := $(wildcard engine/*.odin)
testbed_srcs := $(wildcard testbed/*.odin)
asset_srcs := $(shell find assets -type f -not -path "assets/shaders/*")
asset_dsts := $(patsubst assets/shaders/%,build/shaders/%.spv,$(shader_srcs))
shader_srcs := $(wildcard assets/shaders/*.vert) $(wildcard assets/shaders/*.frag)
shader_objs := $(patsubst assets/shaders/%,build/shaders/%.spv,$(shader_srcs))

build/shaders/%.spv: assets/shaders/%
	@mkdir -p build/shaders
	@glslc -o $@ $<

build/assets/%: assets/%
	cp -r $< $@

build_assets: $(shader_objs) $(assets)

build_engine: $(engine_src) $(shader_objs)
	# @mkdir -p build
	# @odin build engine -build-mode:dynamic -o:none -out:build/engine -debug
	# @find assets -mindepth 1 -maxdepth 1 ! -name shaders -exec cp -r {} build/ \;

build_testbed: $(testbed_src) $(shader_objs) build_engine
	@mkdir -p build
	@odin build testbed -o:none -out:build/testbed -debug
	@find assets -mindepth 1 -maxdepth 1 ! -name shaders -exec cp -r {} build/ \;

testbed: build_testbed
	@cd build && ./testbed

clean:
	@rm -rf build
