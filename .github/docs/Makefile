# Be friendly to mac users
OS := $(shell uname -s)
ifeq ($(OS),Linux)
    SED := sed
endif
ifeq ($(OS),Darwin)
    SED := gsed
endif

serve build: clean docs
	mkdocs $@

docs:
	mkdir docs
	git clone https://github.com/StatCan/aaw-security-proposal.git docs/architecture
	find ../../ -type f \( -iname \*.md -o -iname \*.jpg -o -iname \*.png \) | sed 's~^\.\./\.\./~~' | \
	grep -v '/charts/' | \
	grep -v '^\(CONTRIBUTING\|SECURITY\|LICENSE\)' | \
	while read line; do \
		mkdir -p docs/$$(dirname $$line); cp ../../$$line docs/$$line; \
	done
	cd docs && ln -s README.md index.md

	# Prepend the DAaaS README
	cd docs && \
		mv README.md old-README.md && \
		wget https://raw.githubusercontent.com/StatCan/daaas/master/README.md && \
		echo >> README.md && \
		cat  old-README.md >> README.md && \
		rm old-README.md

	# Replace external URLs with their content
	find docs -name '*.md' | \
	while read line; do \
		if grep '^@EXTERNAL: ' $$line; then \
			URL=$$(grep '^@EXTERNAL: ' $$line | awk '{print $$2}'); \
			$(SED) -i 's~^@EXTERNAL:.*~~' $$line; \
			curl -sL $$URL >> $$line; \
			URL_BASE=$$(echo $$URL | sed 's~/[^/]*$$~/~'); \
			sed -i "s~\(\[.*\]\)(\./\(.*\))~\1(\2)~g" $$line ; \
			sed -i "s~\(\[.*\]\)(\([^#:]*\))~\1($${URL_BASE}\2)~g" $$line ; \
		fi \
	done


install: requirements.txt
	pip3 install -r requirements.txt

clean:
	rm -rf docs
