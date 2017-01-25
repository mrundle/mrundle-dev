PROG=test

all: $(PROG)

%.o: %.c %.h
	gcc -c $< -o $@

%.o: %.c
	gcc -c $< -o $@

$(PROG): test.o _libc.o
	gcc $^ -o $@

clean:
	rm *.o $(PROG)
