DEV_ROCKS = "lua-cjson 2.1.0.10-1" "kong 3.0.2" "luacov 0.12.0" "busted 2.0.0-1" "luacov-cobertura 0.2-1" "luacheck 0.20.0" "lua-resty-template 1.9-1"
PROJECT_FOLDER = template-transformer
LUA_PROJECT = kong-plugin-template-transformer
VERSION = $(shell cat version.txt)

rockspec:
	if [ ! -f $(LUA_PROJECT)-$(VERSION)-1.rockspec ]; then \
		mv -f *.rockspec $(LUA_PROJECT)-$(VERSION)-1.rockspec; \
	fi
	find . -name "*.rockspec" ! -name "${LUA_PROJECT}-${VERSION}-1.rockspec" -exec rm -f {} +
	sed -i "s/version = \"[0-9]*\.[0-9]*\.[0-9]*-1\"/version = \"$(VERSION)-1\"/" "$(LUA_PROJECT)-$(VERSION)-1.rockspec"
	sed -i -E "s/^( *)tag = \"v[0-9]+\.[0-9]+\.[0-9]+\"/\1tag = \"v$(VERSION)\"/" "$(LUA_PROJECT)-$(VERSION)-1.rockspec"

setup: rockspec
	@for rock in $(DEV_ROCKS) ; do \
		if luarocks list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock already installed, skipping ; \
		else \
			echo $$rock not found, installing via luarocks... ; \
			luarocks install $$rock; \
		fi \
	done;

check:
	cd $(PROJECT_FOLDER)
	@for rock in $(DEV_ROCKS) ; do \
		if luarocks list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock is installed ; \
		else \
			echo $$rock is not installed ; \
		fi \
	done;

install:
	-@luarocks remove $(LUA_PROJECT)
	luarocks make

test:
	cd $(PROJECT_FOLDER) && busted spec/ ${ARGS}

coverage:
	cd $(PROJECT_FOLDER) && busted spec/ -c ${ARGS} && luacov && luacov-cobertura -o cobertura.xml

package:
	luarocks make --pack-binary-rock

lint:
	cd $(PROJECT_FOLDER) && luacheck -q .
