---
title: LED blinker
---

## Introduction

For my experiments with the Eclypse Z7 board, I'd like to have the following development environment:

 - recent version of the [Vitis Core Development Kit](https://www.xilinx.com/products/design-tools/vitis.html)
 - recent version of the [Linux kernel](https://www.kernel.org)
 - recent version of the [Debian distribution](https://www.debian.org/releases/bookworm) on the development machine
 - recent version of the [Alpine distribution](https://alpinelinux.org) on the Eclypse Z7 board
 - basic project with all the Eclypse Z7 peripherals connected
 - mostly command-line tools
 - shallow directory structure

Here is how I set it all up.

## Pre-requirements

My development machine has the following installed:

 - [Debian](https://www.debian.org/releases/bookworm) 12 (amd64)

 - [Vitis Core Development Kit](https://www.xilinx.com/products/design-tools/vitis.html) 2023.1

Here are the commands to install all the other required packages:
```bash
apt-get update

apt-get --no-install-recommends install \
  bc binfmt-support bison build-essential ca-certificates curl \
  debootstrap device-tree-compiler dosfstools flex fontconfig git \
  libgtk-3-0 libncurses-dev libssl-dev libtinfo5 parted qemu-user-static \
  squashfs-tools sudo u-boot-tools x11-utils xvfb zerofree zip
```

## Source code

The source code is available at

<https://github.com/pavel-demin/eclypse-z7-notes>

This repository contains the following components:

 - [Makefile](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/Makefile) that builds everything (almost)
 - [cfg](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/cfg) directory with constraints and board definition files
 - [cores](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/cores) directory with IP cores written in Verilog
 - [projects](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/projects) directory with Vivado projects written in Tcl
 - [scripts](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/scripts) directory with
   - Tcl scripts for Vivado and SDK
   - shell script that builds an SD card image

## Syntactic sugar for IP cores

The [projects/led_blinker](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/projects/led_blinker) directory contains one Tcl file [block_design.tcl](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/projects/led_blinker/block_design.tcl) that instantiates, configures and interconnects all the needed IP cores.

By default, the IP core instantiation and configuration commands are quite verbose:
```Tcl
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 ps_0

set_property CONFIG.PCW_IMPORT_BOARD_PRESET cfg/eclypse_z7.xml [get_bd_cells ps_0]

connect_bd_net [get_bd_pins ps_0/FCLK_CLK0] [get_bd_pins ps_0/M_AXI_GP0_ACLK]
```

With the Tcl's flexibility, it's easy to define a less verbose command that looks similar to the module instantiation in Verilog:
```Tcl
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/eclypse_z7.xml
} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
}
```

The `cell` command and other helper commands are defined in the [scripts/project.tcl](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/scripts/project.tcl) script.

## Getting started

Setting up the Vitis and Vivado environment:
```bash
source /opt/Xilinx/Vitis/2023.1/settings64.sh
```

Cloning the source code repository:
```bash
git clone https://github.com/pavel-demin/eclypse-z7-notes
cd eclypse-z7-notes
```

Building `boot.bin`:
```bash
make NAME=led_blinker all
```

## SD card image

Building an SD card image:
```bash
sudo sh scripts/alpine.sh
```

A pre-built SD card image can be downloaded from [this link]({{ site.release_image }}).

To write the image to a micro SD card, copy the contents of the SD card image zip file to a micro SD card.

More details about the SD card image can be found at [this link](/alpine.md).

## Reprogramming FPGA

It's possible to reprogram the FPGA by loading the bitstream file into `/dev/xdevcfg`:
```bash
cat led_blinker.bit > /dev/xdevcfg
```
