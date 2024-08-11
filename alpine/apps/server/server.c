#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>

#define DIR "/sys/bus/iio/devices/iio:device0/"

const char *directory = "/media/mmcblk0p1/apps";
const char *forbidden = "HTTP/1.0 403 Forbidden\n\n";
const char *redirect = "HTTP/1.0 302 Found\nLocation: /\n\n";
const char *okheader = "HTTP/1.0 200 OK\n\n";

void detach(char *path)
{
  int pid = fork();
  if(pid != 0) return;
  close(STDIN_FILENO);
  close(STDOUT_FILENO);
  close(STDERR_FILENO);
  execlp(path, path, NULL);
  exit(0);
}

float read_value(char *name)
{
  FILE *fp;
  char buffer[64];

  if((fp = fopen(name, "r")) == NULL)
  {
    printf("Cannot open %s.\n", name);
    exit(1);
  }

  fgets(buffer, sizeof(buffer), fp);
  fclose(fp);

  return atof(buffer);
}

int main()
{
  FILE *fp;
  int i, j;
  float off, raw, scl;
  struct stat sb;
  size_t size;
  char buffer[256];
  char path[284];

  if(fgets(buffer, 256, stdin) == NULL)
  {
    fwrite(forbidden, 24, 1, stdout);
    return 1;
  }

  if(buffer[4] != '/')
  {
    fwrite(forbidden, 24, 1, stdout);
    return 1;
  }

  if(strncmp(buffer, "GET ", 4) && strncmp(buffer, "get ", 4))
  {
    fwrite(forbidden, 24, 1, stdout);
    return 1;
  }

  for(i = 5; i < 255; ++i)
  {
    if(buffer[i] == ' ')
    {
      buffer[i] = 0;
      break;
    }
  }

  for(j = 5; j < i - 1; ++j)
  {
    if(buffer[j] == '.' && buffer[j + 1] == '.')
    {
      fwrite(forbidden, 24, 1, stdout);
      return 1;
    }
  }

  if(i == 10 && strncmp(buffer + 5, "temp0", 5) == 0)
  {
    fwrite(okheader, 17, 1, stdout);
    off = read_value(DIR "in_temp0_offset");
    raw = read_value(DIR "in_temp0_raw");
    scl = read_value(DIR "in_temp0_scale");
    printf("%.1f\n", (off + raw) * scl / 1000);
    return 0;
  }

  memcpy(path, directory, 21);
  memcpy(path + 21, buffer + 4, i - 3);

  if(stat(path, &sb) < 0)
  {
    fwrite(redirect, 32, 1, stdout);
    return 1;
  }

  if(S_ISDIR(sb.st_mode))
  {
    memcpy(path + 21 + i - 4, "/start.sh", 10);
    detach(path);
    memcpy(path + 21 + i - 4, "/index.html", 12);
  }

  fp = fopen(path, "r");

  if(fp == NULL)
  {
    fwrite(redirect, 32, 1, stdout);
    return 1;
  }

  fwrite(okheader, 17, 1, stdout);

  while((size = fread(buffer, 1, 256, fp)) > 0)
  {
    if(!fwrite(buffer, size, 1, stdout)) break;
  }

  return 0;
}
