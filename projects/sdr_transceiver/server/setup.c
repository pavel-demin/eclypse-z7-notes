#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
  int fd;
  volatile void *cfg;
  volatile uint32_t *adc_spi, *dac_spi;
  volatile uint16_t *adc_cfg;
  volatile uint8_t *dac_cfg;

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  adc_spi = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40001000);
  dac_spi = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40002000);

  adc_cfg = cfg + 0;
  dac_cfg = cfg + 2;

  *adc_cfg = 0;
  *adc_cfg = 0x255;
  usleep(20000);
  *adc_cfg = 0;

  *adc_spi = 0x000803;
  *adc_spi = 0x000800;
  *adc_spi = 0x000502;
  *adc_spi = 0x001421;
  *adc_spi = 0x000501;
  *adc_spi = 0x001431;

  *dac_cfg = 0;
  *dac_cfg = 8;
  *dac_cfg = 1;

  *dac_spi = 0x02B0;
  *dac_spi = 0x1404;

  return EXIT_SUCCESS;
}
