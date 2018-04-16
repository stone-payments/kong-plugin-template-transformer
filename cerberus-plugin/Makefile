DEV_ROCKS = "kong 0.13.0" "luacov 0.12.0" "busted 2.0.rc12"
PROJECT = "cerberus-plugin"

setup:
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
	@luarocks make

test:
	busted spec/

coverage:
	busted spec/ -c
	luacov
	cat luacov.report.out