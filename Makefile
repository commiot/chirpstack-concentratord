VERSION := $(shell git describe --always |sed -e "s/^v//")

build: build-armv5-release build-armv7hf-release

package: build package-kerlink package-multitech

clean:
	rm -rf dist

build-native-debug:
	docker-compose run --rm chirpstack-concentratord cargo build

build-native-release:
	docker-compose run --rm chirpstack-concentratord cargo build --release

build-armv5-debug:
	docker-compose run -e BINDGEN_EXTRA_CLANG_ARGS="--sysroot=/usr/arm-linux-gnueabi" --rm chirpstack-concentratord cargo build --target armv5te-unknown-linux-gnueabi

build-armv5-release:
	docker-compose run -e BINDGEN_EXTRA_CLANG_ARGS="--sysroot=/usr/arm-linux-gnueabi" --rm chirpstack-concentratord cargo build --target armv5te-unknown-linux-gnueabi --release

build-armv7hf-debug:
	docker-compose run -e BINDGEN_EXTRA_CLANG_ARGS="--sysroot=/usr/arm-linux-gnueabihf" --rm chirpstack-concentratord cargo build --target arm-unknown-linux-gnueabihf

build-armv7hf-release:
	docker-compose run -e BINDGEN_EXTRA_CLANG_ARGS="--sysroot=/usr/arm-linux-gnueabihf" --rm chirpstack-concentratord cargo build --target arm-unknown-linux-gnueabihf --release

package-multitech: package-multitech-conduit

package-kerlink: package-kerlink-ifemtocell

package-multitech-conduit:
	mkdir -p dist/multitech/conduit
	rm -f packaging/vendor/multitech/conduit/*.ipk
	docker-compose run --rm chirpstack-concentratord bash -c 'cd packaging/vendor/multitech/conduit && ./package.sh ${VERSION}'
	cp packaging/vendor/multitech/conduit/*.ipk dist/multitech/conduit

package-kerlink-ifemtocell:
	mkdir -p dist/kerlink/ifemtocell
	docker-compose run --rm chirpstack-concentratord bash -c 'cd packaging/vendor/kerlink/ifemtocell && ./package.sh ${VERSION}'
	cp packaging/vendor/kerlink/ifemtocell/*.ipk dist/kerlink/ifemtocell

test:
	docker-compose run --rm chirpstack-concentratord cargo test
