PROGS = \
	hello-world \
	taylor-sin

all: $(PROGS)

$(PROGS): %: %.asm
	as $< -o $*.o
	gcc $*.o -o $@
	@echo -e '\e[1;92mCOMPILED: \e[97m' $* '\e[0m'

clean:
	@rm -fv *.o $(PROGS)
