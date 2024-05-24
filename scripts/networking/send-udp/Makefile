all: send-udp

send-udp: %: %.c
	$(CC) $< -o $@

.PHONY: clean
clean:
	rm send-udp
