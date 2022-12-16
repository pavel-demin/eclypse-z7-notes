CFLAGS = -O3 -march=armv7-a -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard -D_GNU_SOURCE

all: sdr-receiver-hpsdr setup

sdr-receiver-hpsdr: sdr-receiver-hpsdr.c
	gcc $(CFLAGS) -o $@ $^ -lm -lpthread

setup: setup.c
	gcc $(CFLAGS) -o $@ $^

clean:
	rm -f sdr-receiver-hpsdr setup
