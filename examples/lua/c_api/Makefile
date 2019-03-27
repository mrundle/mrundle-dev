all: power.so

power.so: power.c
	gcc -Wall -shared -fPIC $< -o $@ /usr/lib/aarch64-linux-gnu/liblua5.1.so

.PHONY: clean
clean:
	@rm -fv power.so
