DEV_ROCKS = "https://raw.githubusercontent.com/openresty/lua-cjson/2.1.0.8/lua-cjson-2.1.0.6-1.rockspec" "kong 2.6.0" "luacov 0.12.0" "busted 2.0.0-1" "luacov-cobertura 0.2-1" "luacheck 0.20.0" "lua-resty-template 1.9-1" "--server=http://luarocks.org/dev luaffi scm-1"
PROJECT_FOLDER = template-transformer
LUA_PROJECT = kong-plugin-template-transformer

setup:
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

dev-install:
	-@luarocks remove $(LUA_PROJECT) --local
	luarocks make --local

dev-package:
	luarocks make --pack-binary-rock

dev-restart:
	make install-dev
	kong restart
	make clear-logs
	make test-route
	make logs

dev-service:
	curl -i -X POST \
	--url http://localhost:8001/services/ \
	--data 'name=dummy' \
	--data 'url=http://mockbin.org'

dev-route:
	curl -i -X POST \
	--url http://localhost:8001/services/dummy/routes \
	--data 'paths[]=/dummy'

add-route-plugin:
	curl -i -X POST \
	--url http://localhost:8001/services/dummy/plugins/ \
	-d @plugin_schema.json

dev-global-plugin:
	curl -X POST http://localhost:8001/plugins/ \
	--header "Content-Type: application/json" \
	-d @plugin_schema.json

dev-route-plugin:
	make create-service
	make create-route
	make add-route-plugin

dev-test-route:
	curl --request GET \
	--url http://localhost:8000/dummy?affiliation_key=26170920420d411f91e7333634cc2a5a \
	--header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJUUUY0c2p5RUJfRUthV0VfSkxEZExHMVlKYXVnNklTV0tQbEdEeG9qNzhjIn0.eyJqdGkiOiIzNWQ2MGJiYS1hNTI0LTQ5NjUtOGZjMi03NDdlZTM5Y2RhNTAiLCJleHAiOjE2MzczMzQzNzAsIm5iZiI6MCwiaWF0IjoxNjM3MzMzNDcwLCJpc3MiOiJodHRwczovL2xvZ2luLnNhbmRib3guc3RvbmUuY29tLmJyL2F1dGgvcmVhbG1zL3N0b25lX2FjY291bnQiLCJzdWIiOiJkODc1NTVmOC02ZDBhLTRjMjAtOWRmOS1kMTg5ODU3ZDBiZWMiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJhYmNfd2ViQG9wZW5iYW5rLnN0b25lLmNvbS5iciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjMwYThjMTZiLTg2MjItNDJiMi05MDcyLTE1MjZiOWM1OGFiNSIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiaHR0cHM6Ly9zYW5kYm94LmNvbnRhLnN0b25lLmNvbS5iciIsImh0dHA6Ly9sb2NhbGhvc3Q6MzAwMCIsImh0dHBzOi8vc2FuZGJveC1kYXNoYm9hcmQub3BlbmJhbmsuc3RvbmUuY29tLmJyIiwiaHR0cHM6Ly9zYW5kYm94Lm9wZW5iYW5rLnN0b25lLmNvbS5iciJdLCJzY29wZSI6ImVudGl0eTpsZWdhbF93cml0ZSBlbnRpdHk6bG9hbjpjcmVhdGUgaW52ZXN0bWVudDpzcGFjZTpyZWFkIHN0b3JlOnByb2R1Y3Q6d3JpdGUgY2FyZDpyZWFkIGludmVzdG1lbnQ6cmVhZCBzdG9yZTpwcm9kdWN0OnJlYWQgcmVjZWl2YWJsZTp3cml0ZSBlbnRpdHk6cmVhZCBwcmluY2lwYWw6Y29uc2VudCBzdG9yZTpwYXltZW50c2VydmljZTpyZWFkIHBpeDplbnRyeSBjcmVkaXQ6Ym9ycm93ZXI6KiBpbnZlc3RtZW50OnNwYWNlOmRlcG9zaXQgc3RvbmVfc3ViamVjdF9pZCBlbnRpdHk6bG9hbjphY2NlcHQgcGF5bWVudGFjY291bnQ6KiBpbnZlc3RtZW50OnNwYWNlOndyaXRlIGV4cGVuZDp0cmFuc2ZlcnM6ZXh0ZXJuYWwgc2FsYXJ5OnBvcnRhYmlsaXR5IGV4cGVuZDpwYXlyb2xscyBwaXg6ZW50cnlfY2xhaW0gcGl4OnBheW1lbnRfaW52b2ljZSBpbnZlc3RtZW50OnNwYWNlOmRlbGV0ZSBlbnRpdHk6d3JpdGUgcGF5bWVudGFjY291bnQ6cGF5bWVudGxpbmtzOndyaXRlIGV4cGVuZDpib2xldG9pc3N1YW5jZSBleHBlbmQ6cGF5bWVudHMgZW1haWwgaW52ZXN0bWVudDp3cml0ZSBzdG9uZV9hY2NvdW50cyByZWNlaXZhYmxlOnJlYWQgZXhwZW5kOnJlYWQgcHJvZmlsZSBleHBlbmQ6dHJhbnNmZXJzOmludGVybmFsIHBpeDpwYXltZW50IHN0b3JlOnBheW1lbnRzZXJ2aWNlOndyaXRlIHN0b3JlOndyaXRlIHBheW1lbnRhY2NvdW50OnBheW1lbnRsaW5rczpyZWFkIGV4cGVuZDpwYXltZW50bGlua3MgY2FyZDp3cml0ZSBpbnZlc3RtZW50OnNwYWNlOndpdGhkcmF3YWwgZXhwZW5kOnBpeF9wYXltZW50IHN0b3JlOnJlYWQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwic3RvbmVfc3ViamVjdF9pZCI6InVzZXI6MjQwMTdjMTMtMWY5ZC00NGU0LWI0YWYtMDA3ZjY5NWNlY2UzIiwibmFtZSI6IkJyeWFuIE1hcnRpbnMgLSBRQSBQb3J0YWwgU3RvbmUiLCJzdG9uZV9hY2NvdW50cyI6ImVuYWJsZWQiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJicnlhbm5vZ0BnbWFpbC5jb20iLCJnaXZlbl9uYW1lIjoiQnJ5YW4iLCJsb2NhbGUiOiJwdC1CUiIsImZhbWlseV9uYW1lIjoiTWFydGlucyAtIFFBIFBvcnRhbCBTdG9uZSIsImVtYWlsIjoiYnJ5YW5ub2dAZ21haWwuY29tIn0.c5SK-hGmErLILWurExmZqv4iJhQyaHC4lKnkC5eJGNAtUn8So5XW-lC4VukequHGA3Yq-7Xnr7uiUAHp1t2Z3c7TLKna8TJJy8aqx2MLzTkE500nqoh6a-W13Z0f_fp003JFFzpxHNmGbEMYsf0ImHmJ11gVfqHuDjwOVMlv9BlcwUn-Zc2-oKMOUcSQ35s0xwSvkGfJRcYt-6U1H-AVBgi5HEMFxIapmbhm5t7nhA8pFIFchtGpXJrqCW2TLNMFphzO56vRXWQoeKnOnPOqEn5zGUIFGodeXWmtcxuWmK8k5W8Gq5Wi7ryLvaOYJwh3SOIZO4-r9Z_mLnguWk0nuQ'

run-kong:
	kong migrations bootstrap
	kong start --vv

clear-logs:
	> /usr/local/kong/logs/error.log

logs:
	cat /usr/local/kong/logs/error.log

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

access:
	docker exec -ti $(LUA_PROJECT)_kong_1 /bin/sh
