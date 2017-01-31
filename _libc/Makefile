SHELL    = /bin/bash
BDIR     = build
LIB      = $(BDIR)/_libc.a
TEST     = test
SRCS     = $(wildcard src/*.c)
OBJS     = $(patsubst src/%.c,build/%.o,$(SRCS))
LIB_OBJS = $(filter-out build/$(TEST).o,$(OBJS))
CFLAGS   = -I./src/

all: $(BDIR) $(LIB) $(BDIR)/$(TEST)

.PHONY: debug
debug: CFLAGS = -D_LIBC_DEBUG
debug: clean all

$(BDIR)/%.o: src/%.c src/_libc.h
	gcc $(CFLAGS) -c $< -o $@

$(LIB): $(LIB_OBJS)
	ar rcs $@ $^

$(BDIR)/test: $(BDIR)/test.o $(LIB)
	gcc $(CFLAGS) $^ -o $@
	@echo -n "Running tests..." ; \
	out=`$@ 2>&1` && \
		echo -e "\e[92mOK\e[39m" || \
		(echo -e "\e[91mFAILED\e[39m" ; \
		 while read ln; do echo -e "    $$ln"; done <<< "$$out" ; \
		 exit 1)

$(BDIR):
	mkdir -p $@

clean:
	rm -fr *.o $(BDIR)
