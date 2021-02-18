CFLAGS = -O3 -march=armv7-a -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard

all: sdr-transceiver setup

sdr-transceiver: sdr-transceiver.c
	gcc $(CFLAGS) -o $@ $^ -lm -lpthread

setup: setup.c
	gcc $(CFLAGS) -o $@ $^

clean:
	rm -f sdr-transceiver setup
