all: bit_printer test

bit_printer: %: %.c
	gcc -std=gnu99 $< -o $@

.PHONY: test
test: test.sh
	./$< bit_printer 2>/dev/null

.PHONY: clean
clean:
	rm -f bit_printer
