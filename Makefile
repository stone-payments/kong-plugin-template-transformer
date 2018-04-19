DEV_ROCKS = "lua-cjson 2.1.0" "kong 0.13.0" "luacov 0.12.0" "busted 2.0.rc12" "luacov-cobertura 0.2-1" "luacheck 0.20.0"

setup:
	cd $(PROJECT)
	@for rock in $(DEV_ROCKS) ; do \
		if luarocks list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock already installed, skipping ; \
		else \
			echo $$rock not found, installing via luarocks... ; \
			luarocks install $$rock; \
		fi \
	done;

check:
	cd $(PROJECT)
	@for rock in $(DEV_ROCKS) ; do \
		if luarocks list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock is installed ; \
		else \
			$(error Couldn't install one rock) ; \
		fi \
	done;

install:
	-@luarocks remove $(PROJECT)
	cd $(PROJECT) && luarocks make

test:
	cd $(PROJECT) && busted spec/ ${ARGS}

coverage:
	cd $(PROJECT) && busted spec/ -c && luacov && luacov-cobertura -o cobertura.xml

package:
	cd $(PROJECT) && luarocks make --pack-binary-rock 

lint:
	cd $(PROJECT) && luacheck -q .
