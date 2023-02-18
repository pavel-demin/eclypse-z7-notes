#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#define I2C_SLAVE       0x0703 /* Use this slave address */
#define I2C_SLAVE_FORCE 0x0706 /* Use this slave address, even if it
                                  is already in use by a driver! */

#define ADDR_CLK 0x67

ssize_t i2c_write(int fd, uint16_t addr, uint16_t data)
{
  uint8_t buffer[4];
  buffer[0] = addr >> 8;
  buffer[1] = addr;
  buffer[2] = data >> 8;
  buffer[3] = data;
  return write(fd, buffer, 4);
}

int main(int argc, char *argv[])
{
  int fd, i2c_fd;
  volatile void *cfg;
  volatile uint32_t *adc_spi, *dac_spi;
  volatile uint8_t *dac_cfg;

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  usleep(10000);

  if((i2c_fd = open("/dev/i2c-0", O_RDWR)) >= 0)
  {
    if(ioctl(i2c_fd, I2C_SLAVE_FORCE, ADDR_CLK) >= 0)
    {
      if(i2c_write(i2c_fd, 0x0000, 0x1004) > 0)
      {
        i2c_write(i2c_fd, 0x004F, 0x0208);
        i2c_write(i2c_fd, 0x004E, 0x0000);
        i2c_write(i2c_fd, 0x004C, 0x0188);
        i2c_write(i2c_fd, 0x004B, 0x8008);
        i2c_write(i2c_fd, 0x0049, 0x1000);
        i2c_write(i2c_fd, 0x0048, 0x0005); // /5
        i2c_write(i2c_fd, 0x0044, 0x1000);
        i2c_write(i2c_fd, 0x003F, 0x1000);
        i2c_write(i2c_fd, 0x0039, 0x1000);
        i2c_write(i2c_fd, 0x0032, 0x07C0);
        i2c_write(i2c_fd, 0x0031, 0x001F);
        i2c_write(i2c_fd, 0x0030, 0x180A);
        i2c_write(i2c_fd, 0x002F, 0x0500); // /4
        i2c_write(i2c_fd, 0x001E, 0x0040);
        i2c_write(i2c_fd, 0x001B, 0x0004);
        i2c_write(i2c_fd, 0x0019, 0x0401);
        i2c_write(i2c_fd, 0x0018, 0x8718);
        i2c_write(i2c_fd, 0x0005, 0x0000);
        i2c_write(i2c_fd, 0x0004, 0x0070);
        i2c_write(i2c_fd, 0x0002, 0x0002);
        i2c_write(i2c_fd, 0x0000, 0x1004);
      }
    }
  }

  usleep(10000);

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40001000);
  adc_spi = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40002000);
  dac_spi = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40003000);

  dac_cfg = cfg + 1;

  *adc_spi = 0x00003C;
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
