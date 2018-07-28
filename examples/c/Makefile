PROGS = rev_ll

all: $(PROGS)

rev_ll: %: %.c
	$(CC) $^ -o $@

clean:
	rm -f $(PROGS) *.o
