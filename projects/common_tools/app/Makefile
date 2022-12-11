CFLAGS = -O3 -march=armv7-a -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard

all: measure-corr measure-level

measure-corr: measure-corr.c
	gcc $(CFLAGS) -o $@ $^

measure-level: measure-level.c
	gcc $(CFLAGS) -o $@ $^ -lm

clean:
	rm -f measure-corr measure-level
