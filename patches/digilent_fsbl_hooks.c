#include <string.h>

#include "xqspips.h"
#include "xemacps.h"

u32 SetMacAddress()
{
  XQspiPs Qspi;
  XQspiPs_Config *QspiConfig;
  XEmacPs Emac;
  XEmacPs_Config *EmacConfig;
  u32 Status;
  u8 Buffer[12];

  memset(Buffer, 0, 12);

  Buffer[0] = 0x4B;
  Buffer[3] = 0x20;

  QspiConfig = XQspiPs_LookupConfig(XPAR_XQSPIPS_0_DEVICE_ID);
  if(QspiConfig == NULL) return XST_FAILURE;

  Status = XQspiPs_CfgInitialize(&Qspi, QspiConfig, QspiConfig->BaseAddress);
  if(Status != XST_SUCCESS) return XST_FAILURE;

  Status = XQspiPs_PolledTransfer(&Qspi, Buffer, Buffer, 12);
  if(Status != XST_SUCCESS) return XST_FAILURE;

  EmacConfig = XEmacPs_LookupConfig(XPAR_PS7_ETHERNET_0_DEVICE_ID);
  if(EmacConfig == NULL) return XST_FAILURE;

  Status = XEmacPs_CfgInitialize(&Emac, EmacConfig, EmacConfig->BaseAddress);
  if(Status != XST_SUCCESS) return XST_FAILURE;

  Status = XEmacPs_SetMacAddress(&Emac, Buffer + 5, 1);
  if(Status != XST_SUCCESS) return XST_FAILURE;

  return Status;
}
