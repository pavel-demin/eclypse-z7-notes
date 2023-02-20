# 'make' builds everything
# 'make clean' deletes everything except source files and Makefile
#
# You need to set NAME, PART and PROC for your project.
# NAME is the base name for most of the generated files.

NAME = led_blinker
PART = xc7z020clg484-1
PROC = ps7_cortexa9_0

CORES = axi_hub_v1_0 axis_constant_v1_0 axis_fifo_v2_0 axis_lfsr_v1_0 \
  axis_maxabs_finder_v1_0 axis_pps_counter_v1_0 axis_ram_writer_v1_0 \
  axis_spi_v1_0 axis_variable_v1_0 axis_zmod_adc_v1_0 axis_zmod_dac_v1_0 \
  cdce_gpio_v1_0 dac_gpio_v1_0 dsp48_v1_0 port_selector_v1_0 port_slicer_v1_0

VIVADO = vivado -nolog -nojournal -mode batch
XSCT = xsct
RM = rm -rf

UBOOT_TAG = 2021.04
LINUX_TAG = 5.10
DTREE_TAG = xilinx-v2020.2

UBOOT_DIR = tmp/u-boot-$(UBOOT_TAG)
LINUX_DIR = tmp/linux-$(LINUX_TAG)
DTREE_DIR = tmp/device-tree-xlnx-$(DTREE_TAG)

UBOOT_TAR = tmp/u-boot-$(UBOOT_TAG).tar.bz2
LINUX_TAR = tmp/linux-$(LINUX_TAG).tar.xz
DTREE_TAR = tmp/device-tree-xlnx-$(DTREE_TAG).tar.gz

UBOOT_URL = https://ftp.denx.de/pub/u-boot/u-boot-$(UBOOT_TAG).tar.bz2
LINUX_URL = https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$(LINUX_TAG).107.tar.xz
DTREE_URL = https://github.com/Xilinx/device-tree-xlnx/archive/$(DTREE_TAG).tar.gz

RTL8188_TAR = tmp/rtl8188eu-v5.2.2.4.tar.gz
RTL8188_URL = https://github.com/lwfinger/rtl8188eu/archive/v5.2.2.4.tar.gz

RTL8192_TAR = tmp/rtl8192cu-fixes-master.tar.gz
RTL8192_URL = https://github.com/pvaret/rtl8192cu-fixes/archive/master.tar.gz

.PRECIOUS: tmp/cores/% tmp/%.xpr tmp/%.xsa tmp/%.bit tmp/%.fsbl/executable.elf tmp/%.tree/system-top.dts

all: tmp/$(NAME).bit boot.bin uImage devicetree.dtb

cores: $(addprefix tmp/cores/, $(CORES))

xpr: tmp/$(NAME).xpr

bit: tmp/$(NAME).bit

$(UBOOT_TAR):
	mkdir -p $(@D)
	curl -L $(UBOOT_URL) -o $@

$(LINUX_TAR):
	mkdir -p $(@D)
	curl -L $(LINUX_URL) -o $@

$(DTREE_TAR):
	mkdir -p $(@D)
	curl -L $(DTREE_URL) -o $@

$(RTL8188_TAR):
	mkdir -p $(@D)
	curl -L $(RTL8188_URL) -o $@

$(RTL8192_TAR):
	mkdir -p $(@D)
	curl -L $(RTL8192_URL) -o $@

$(UBOOT_DIR): $(UBOOT_TAR)
	mkdir -p $@
	tar -jxf $< --strip-components=1 --directory=$@
	patch -d tmp -p 0 < patches/u-boot-$(UBOOT_TAG).patch
	cp patches/zynq_eclypse_z7_defconfig $@/configs
	cp patches/zynq-eclypse-z7.dts $@/arch/arm/dts

$(LINUX_DIR): $(LINUX_TAR) $(RTL8188_TAR) $(RTL8192_TAR)
	mkdir -p $@
	tar -Jxf $< --strip-components=1 --directory=$@
	mkdir -p $@/drivers/net/wireless/realtek/rtl8188eu
	mkdir -p $@/drivers/net/wireless/realtek/rtl8192cu
	tar -zxf $(RTL8188_TAR) --strip-components=1 --directory=$@/drivers/net/wireless/realtek/rtl8188eu
	tar -zxf $(RTL8192_TAR) --strip-components=1 --directory=$@/drivers/net/wireless/realtek/rtl8192cu
	patch -d tmp -p 0 < patches/linux-$(LINUX_TAG).patch
	cp patches/zynq_ocm.c $@/arch/arm/mach-zynq
	cp patches/cma.c $@/drivers/char
	cp patches/xilinx_devcfg.c $@/drivers/char
	cp patches/xilinx_zynq_defconfig $@/arch/arm/configs

$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

uImage: $(LINUX_DIR)
	make -C $< mrproper
	make -C $< ARCH=arm xilinx_zynq_defconfig
	make -C $< ARCH=arm -j $(shell nproc 2> /dev/null || echo 1) \
	  CROSS_COMPILE=arm-linux-gnueabihf- UIMAGE_LOADADDR=0x8000 \
	  uImage modules
	cp $</arch/arm/boot/uImage $@

$(UBOOT_DIR)/u-boot.bin: $(UBOOT_DIR)
	mkdir -p $(@D)
	make -C $< mrproper
	make -C $< ARCH=arm zynq_eclypse_z7_defconfig
	make -C $< ARCH=arm -j $(shell nproc 2> /dev/null || echo 1) \
	  CROSS_COMPILE=arm-linux-gnueabihf- all

boot.bin: tmp/$(NAME).fsbl/executable.elf $(UBOOT_DIR)/u-boot.bin
	echo "img:{[bootloader] tmp/$(NAME).fsbl/executable.elf [load=0x4000000,startup=0x4000000] $(UBOOT_DIR)/u-boot.bin}" > tmp/boot.bif
	bootgen -image tmp/boot.bif -w -o i $@

devicetree.dtb: uImage tmp/$(NAME).tree/system-top.dts
	$(LINUX_DIR)/scripts/dtc/dtc -I dts -O dtb -o devicetree.dtb \
	  -i tmp/$(NAME).tree tmp/$(NAME).tree/system-top.dts

tmp/cores/%: cores/%/core_config.tcl cores/%/*.v
	mkdir -p $(@D)
	$(VIVADO) -source scripts/core.tcl -tclargs $* $(PART)

tmp/%.xpr: projects/% $(addprefix tmp/cores/, $(CORES))
	mkdir -p $(@D)
	$(VIVADO) -source scripts/project.tcl -tclargs $* $(PART)

tmp/%.xsa: tmp/%.xpr
	mkdir -p $(@D)
	$(VIVADO) -source scripts/hwdef.tcl -tclargs $*

tmp/%.bit: tmp/%.xpr
	mkdir -p $(@D)
	$(VIVADO) -source scripts/bitstream.tcl -tclargs $*

tmp/%.fsbl/executable.elf: tmp/%.xsa
	mkdir -p $(@D)
	$(XSCT) scripts/fsbl.tcl $* $(PROC)

tmp/%.tree/system-top.dts: tmp/%.xsa $(DTREE_DIR)
	mkdir -p $(@D)
	$(XSCT) scripts/devicetree.tcl $* $(PROC) $(DTREE_DIR)
	sed -i 's|#include|/include/|' $@
	patch -d $(@D) < patches/devicetree.patch

clean:
	$(RM) uImage boot.bin devicetree.dtb tmp
	$(RM) .Xil usage_statistics_webtalk.html usage_statistics_webtalk.xml
	$(RM) vivado*.jou vivado*.log
	$(RM) webtalk*.jou webtalk*.log
