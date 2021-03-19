#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sched.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define TCP_PORT 1001

int interrupted = 0;

void signal_handler(int sig)
{
  interrupted = 1;
}

void neoncopy(void *dst, volatile void *src, int cnt)
{
  asm volatile
  (
    "loop_%=:\n"
    "vldm %[src]!, {q0, q1, q2, q3}\n"
    "vstm %[dst]!, {q0, q1, q2, q3}\n"
    "subs %[cnt], %[cnt], #64\n"
    "bgt loop_%="
    : [dst] "+r" (dst), [src] "+r" (src), [cnt] "+r" (cnt)
    :
    : "q0", "q1", "q2", "q3", "cc", "memory"
  );
}

int main ()
{
  int fd, sock_server, sock_client;
  int position, limit, offset;
  volatile uint32_t *slcr, *axi_hp0, *rx_freq, *rx_cntr;
  volatile uint16_t *rx_rate;
  volatile uint8_t *rx_rst;
  volatile void *cfg, *sts, *ram;
  void *buf;
  cpu_set_t mask;
  struct sched_param param;
  struct sockaddr_in addr;
  uint32_t command, size;
  int32_t value;
  int yes = 1;

  memset(&param, 0, sizeof(param));
  param.sched_priority = sched_get_priority_max(SCHED_FIFO);
  sched_setscheduler(0, SCHED_FIFO, &param);

  CPU_ZERO(&mask);
  CPU_SET(1, &mask);
  sched_setaffinity(0, sizeof(cpu_set_t), &mask);

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  slcr = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0xF8000000);
  axi_hp0 = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0xF8008000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40001000);
  ram = mmap(NULL, 128*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x3E000000);
  buf = mmap(NULL, 64*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANONYMOUS, -1, 0);

  /* set HP0 bus width to 64 bits */
  slcr[2] = 0xDF0D;
  slcr[144] = 0;
  axi_hp0[0] &= ~1;
  axi_hp0[5] &= ~1;

  rx_rst = (uint8_t *)(cfg + 0);
  rx_rate = (uint16_t *)(cfg + 4);
  rx_freq = (uint32_t *)(cfg + 8);
  
  rx_cntr = (uint32_t *)(sts + 0);

  if((sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("socket");
    return EXIT_FAILURE;
  }

  setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

  /* setup listening address */
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(TCP_PORT);

  if(bind(sock_server, (struct sockaddr *)&addr, sizeof(addr)) < 0)
  {
    perror("bind");
    return EXIT_FAILURE;
  }

  listen(sock_server, 1024);

  while(!interrupted)
  {
    /* enter reset mode */
    *rx_rst &= ~1;
    usleep(100);
    *rx_rst &= ~2;
    /* set default sample rate */
    *rx_rate = 8;
    /* set default phase increments */
    rx_freq[0] = (uint32_t)floor(10000000 / 100.0e6 * (1<<30) + 0.5);
    rx_freq[1] = (uint32_t)floor(10000000 / 100.0e6 * (1<<30) + 0.5);

    if((sock_client = accept(sock_server, NULL, NULL)) < 0)
    {
      perror("accept");
      return EXIT_FAILURE;
    }

    signal(SIGINT, signal_handler);

    /* enter normal operating mode */
    *rx_rst |= 3;

    limit = 32*1024;

    while(!interrupted)
    {
      if(ioctl(sock_client, FIONREAD, &size) < 0) break;

      if(size >= 4)
      {
        if(recv(sock_client, (char *)&command, 4, MSG_WAITALL) < 0) break;
        value = command & 0xfffffff;
        switch(command >> 28)
        {
          case 0:
            /* set sample rate */
            if(value < 5 || value > 64) continue;
            *rx_rate = value;
          case 1:
            /* set first phase increment */
            if(value < 0 || value > 50000000) continue;
            rx_freq[0] = (uint32_t)floor(value / 100.0e6 * (1<<30) + 0.5);
            break;
          case 2:
            /* set second phase increment */
            if(value < 0 || value > 50000000) continue;
            rx_freq[1] = (uint32_t)floor(value / 100.0e6 * (1<<30) + 0.5);
            break;
        }
      }

      /* read ram writer position */
      position = *rx_cntr;

      /* send 256 kB if ready, otherwise sleep 0.1 ms */
      if((limit > 0 && position > limit) || (limit == 0 && position < 32*1024))
      {
        offset = limit > 0 ? 0 : 256*1024;
        limit = limit > 0 ? 0 : 32*1024;
        neoncopy(buf, ram + offset, 256*1024);
        if(send(sock_client, buf, 256*1024, MSG_NOSIGNAL) < 0) break;
      }
      else
      {
        usleep(100);
      }
    }

    signal(SIGINT, SIG_DFL);
    close(sock_client);
  }

  /* enter reset mode */
  *rx_rst &= ~1;
  usleep(100);
  *rx_rst &= ~2;

  close(sock_server);

  return EXIT_SUCCESS;
}
