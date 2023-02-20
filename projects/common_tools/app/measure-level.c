#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>

int interrupted = 0;

void signal_handler(int sig)
{
  interrupted = 1;
}

void usage()
{
  fprintf(stderr, "Usage: measure-level freq time\n");
  fprintf(stderr, " freq - frequency expressed in MHz (100, 122.88 or 125),\n");
  fprintf(stderr, " time - measurement time expressed in seconds (from 1 to 30).\n");
}

int main(int argc, char *argv[])
{
  int fd;
  char *end;
  volatile void *cfg, *sts;
  volatile uint32_t *fifo;
  volatile uint8_t *rst;
  volatile uint32_t *cntr;
  double freq;
  long time;
  uint32_t buffer, scale;
  uint16_t level[2];
  uint8_t bits[2];

  if(argc != 3)
  {
    usage();
    return EXIT_FAILURE;
  }

  errno = 0;
  freq = strtod(argv[1], &end);
  if(errno != 0 || end == argv[1] || (freq != 100.0 && freq != 122.88 && freq != 125.0))
  {
    usage();
    return EXIT_FAILURE;
  }

  time = strtol(argv[2], &end, 10);
  if(errno != 0 || end == argv[2] || time < 1 || time > 30)
  {
    usage();
    return EXIT_FAILURE;
  }

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    fprintf(stderr, "Cannot open /dev/mem.\n");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x80000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x80100000);
  fifo = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x80300000);

  rst = (uint8_t *)(cfg + 1);
  cntr = (uint32_t *)(sts + 4);

  *(uint32_t *)(cfg + 4) = (uint32_t)floor(freq * 1.0e6 * time + 0.5) - 1;

  *rst &= ~1;
  *rst |= 1;

  signal(SIGINT, signal_handler);

  while(!interrupted)
  {
    if(*cntr < 1)
    {
      usleep(1000);
      continue;
    }

    buffer = *fifo;

    level[0] = buffer & 0xffff;
    level[1] = (buffer >> 16) & 0xffff;
  }

  *rst &= ~1;

  return EXIT_SUCCESS;
}
