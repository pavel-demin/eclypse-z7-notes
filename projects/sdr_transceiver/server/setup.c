#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

int main(int argc, char *argv[])
{
  int fd;
  volatile uint32_t *adc_spi, *dac_spi;

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  usleep(100000);

  adc_spi = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x43000000);
  dac_spi = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x44000000);

  *adc_spi = 0x00003C;
  *adc_spi = 0x000803;
  *adc_spi = 0x000800;
  *adc_spi = 0x000502;
  *adc_spi = 0x001421;
  *adc_spi = 0x000501;
  *adc_spi = 0x001431;

  *dac_spi = 0x02B0;
  *dac_spi = 0x1404;

  return EXIT_SUCCESS;
}
