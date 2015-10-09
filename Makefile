# This helper Makefile assumes GNU Make and supports those target:
# check       : Makes sure the document is tidied
# tidy        : Tidied the document, in place
# install_tidy: installs tidy (the modern, HTML5 version) on a standard UNIX
#               environment. This requires CMake and git in the PATH.

support_dir ?= $(CURDIR)/.support
tidy ?= $(shell which tidy 2>/dev/null)
ifeq (,$(tidy))
tidy := $(support_dir)/bin/tidy
endif
cmake ?= cmake

.PHONY: check
check: install_tidy
	$(tidy) -quiet -config tidyconf.txt index.html | sed -f fixup.sed | diff -q index.html -

.PHONY: tidy
tidy: install_tidy
	$(tidy) -quiet -config tidyconf.txt -modify index.html || true
	sed -i.old -f fixup.sed index.html && rm -f index.html.old

.PHONY: install_tidy
install_tidy: $(tidy)
$(tidy):
	if [ ! -d tidy-html5 ]; then \
	  mkdir -p tidy-html5; \
	  git clone -q --depth 10 https://github.com/htacg/tidy-html5.git tidy-html5; \
	fi
	cd tidy-html5/build/cmake && \
	  $(cmake) ../.. -DCMAKE_INSTALL_PREFIX=$(support_dir) -DCMAKE_BUILD_TYPE=Release && \
	  make && make install
