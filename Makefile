# Various targets to do things with files in this package,
# like setup, installation, etc.

TARGETS = \
	submodules \
	third_party

THIRD_PARTY = \
	third_party/ranger

all:
	@echo "Available targets: $(TARGETS)"

.PHONY: _submodules
_submodules:
	git submodule update --init --recursive

.PHONY: _third_party
_third_party: _submodules
	@for pkg in $(THIRD_PARTY); do cd $$pkg && sudo make install; done

%:
	@if [[ ! "$@" =~ "$(TARGETS)" ]]; then \
		echo "Unknown target $@ (avail: $(TARGETS))"; exit 1; \
	fi
	@$(MAKE) _$@


