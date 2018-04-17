DEV_ROCKS = "kong 0.13.0" "luacov 0.12.0" "busted 2.0.rc12"

setup:
	cd $(PROJECT)
	@for rock in $(DEV_ROCKS) ; do \
		if luarocks list --porcelain $$rock | grep -q "installed" ; then \
			echo $$rock already installed, skipping ; \
		else \
			echo $$rock not found, installing via luarocks... ; \
			if luarocks install $$rock | grep -q "error" ; then \
				 $(error There was an error installing rock ) \
			fi \
		fi \
	done;

install:
	-@luarocks remove $(PROJECT)
	cd $(PROJECT) && luarocks make

test:
	cd $(PROJECT) && busted spec/

coverage:
	cd $(PROJECT) && busted spec/ -c && luacov && cat luacov.report.out

package:
	cd $(PROJECT) && luarocks make --pack-binary-rock 