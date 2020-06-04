PROGS = rev_ll bithack_minmax

all: $(PROGS)

rev_ll: %: %.c
	$(CC) $^ -o $@

test: $(PROGS)
	@for prog in $(PROGS); do \
		echo -n "./$$prog ..."; \
		./$$prog >/dev/null 2>&1 && echo OK || echo FAIL; \
	done

clean:
	rm -f $(PROGS) *.o
