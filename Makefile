DEV_ROCKS = "kong 0.13.0" "luacov 0.12.0" "busted 2.0.rc12" "luacheck 0.20.0"

setup:
	cd $(PROJECT)
	@for rock in $(DEV_ROCKS) ; do \
		if luarocks list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock already installed, skipping ; \
		else \
			echo $$rock not found, installing via luarocks... ; \
			luarocks install $$rock ; \
		fi \
	done;

install:
	-@luarocks remove $(PROJECT)
	cd $(PROJECT) && luarocks make

test:
	cd $(PROJECT) && busted spec/

coverage:
	cd $(PROJECT) && busted spec/ -c && luacov && cat luacov.report.out

lint:
	cd $(PROJECT) && luacheck -q .
