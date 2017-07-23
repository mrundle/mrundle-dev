PROG=program
OBJS=library.o
PREREQS=gcov lcov konqueror
SHELL=/bin/bash
COV_DIR=cov
GCOV_CFLAGS=-fprofile-arcs -ftest-coverage
CFLAGS+=$(GCOV_CFLAGS)

# great resource:
# https://wiki.documentfoundation.org/Development/Lcov#Run_initial.2Fbaseline_lcov

all: prereqs program test open_cov

prereqs:
	@for prereq in $(PREREQS); do \
		if ! `hash $$prereq >/dev/null 2>&1`; then \
			echo "Couldn't find $$prereq (please install)"; \
			exit 1; \
		fi \
	done

program: $(PROG).c $(OBJS)
	gcc $(CFLAGS) $^ -o $@

%.o: %.c %.h
	gcc $(CFLAGS) -c $< -o $@

$(COV_DIR):
	mkdir -p $@

.PHONY: test
test: $(PROG) $(COV_DIR)
	# get baseline
	lcov --no-external --capture --initial --base-directory `pwd` --directory . \
	    --output-file $(COV_DIR)/lcov.init
	# run the program
	./$(PROG)
	# collect coverage data
	lcov --no-external --capture --base-directory `pwd` --directory . \
	    --output-file $(COV_DIR)/lcov.result
	# combine tracefiles
	lcov --add-tracefile $(COV_DIR)/lcov.init \
		 --add-tracefile $(COV_DIR)/lcov.result \
		 --output-file $(COV_DIR)/lcov.final
	# generate html
	genhtml --legend --title "Testing lcov" \
		--output-directory=$(COV_DIR) $(COV_DIR)/lcov.final
	@echo -e "\n\e[1;92m-- OK --\e[0;39m"

.PHONY: open_cov
open_cov: $(COV_DIR)/index.html
	@while true; do \
		echo -en "\e[1;93m\nOpen the coverage report in Konqueror?\e[0;49m " ; \
		read -p "(y/n) " yn ; \
		case $$yn in \
			[Yy]* ) /usr/bin/konqueror $<; break;; \
			[Nn]* ) exit 0;; \
			* ) echo "Please anser yes or no.";; \
		esac ; \
	done \

clean:
	rm -rf $(PROG) *.o *.gcno *.gcda $(COV_DIR)
