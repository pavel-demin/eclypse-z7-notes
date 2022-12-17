---
layout: page
title: SDR transceiver
permalink: /sdr-transceiver/
---

Introduction
-----

This is a port of the SDR transceiver application for the Red Pitaya board to the Eclypse Z7 board.

The SDR transceiver application for the Red Pitaya board is described at [this link](http://pavel-demin.github.io/red-pitaya-notes/sdr-transceiver-122-88).

All programs and libraries that work with the SDR transceiver application for the Red Pitaya board should also work with this port.

This application requires Zmod Digitizer and Zmod AWG to be connected to the Eclypse Z7 board as follows:

 - Zmod Digitizer is connected to ZMOD A connector
 - Zmod AWG is connected to ZMOD B connector

Hardware
-----

The SDR transceiver consists of two SDR receivers and of two SDR transmitters.

The implementation of the SDR receivers is quite straightforward:

 - An antenna is connected to one of the inputs of the Zmod Digitizer module.
 - The on-board ADC (122.88 MS/s sampling frequency, 14-bit resolution) digitizes the RF signal from the antenna.
 - The data coming from the ADC is processed by a in-phase/quadrature (I/Q) digital down-converter (DDC) running on the FPGA.

The SDR transmitters consist of the similar blocks but arranged in an opposite order:

 - The I/Q data is processed by a digital up-converter (DUC) running on the FPGA.
 - The on-board DAC (122.88 MS/s sampling frequency, 14-bit resolution) outputs RF signal.
 - An antenna is connected to one of the outputs of the Zmod AWG module.

The tunable frequency range covers from 0 Hz to 122.88 MHz.

The I/Q data rate is configurable and five settings are available: 24, 48, 96, 192, 384, 768 and 1536 kSPS.

The basic blocks of the digital down-converters (DDC) and of the digital up-converters (DUC) are shown on the following diagram:

![SDR transceiver]({{ "/img/sdr-transceiver.png" | prepend: site.baseurl }})

The [projects/sdr_transceiver](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/projects/sdr_transceiver) directory contains four Tcl files: [block_design.tcl](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/projects/sdr_transceiver/block_design.tcl), [trx.tcl](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/projects/sdr_transceiver/trx.tcl), [rx.tcl](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/projects/sdr_transceiver/rx.tcl), [tx.tcl](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/projects/sdr_transceiver/tx.tcl). The code in these files instantiates, configures and interconnects all the needed IP cores.

Software
-----

The [projects/sdr_transceiver/server](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/projects/sdr_transceiver/server) directory contains the source code of the TCP server ([sdr-transceiver.c](https://github.com/pavel-demin/eclypse-z7-notes/blob/master/projects/sdr_transceiver/server/sdr-transceiver.c)) that receives control commands and transmits/receives the I/Q data streams (up to 2 x 32 bit x 1536 kSPS = 91.6 Mbit/s) to/from the SDR programs.

The [projects/sdr_transceiver/gnuradio](https://github.com/pavel-demin/eclypse-z7-notes/tree/master/projects/sdr_transceiver/gnuradio) directory contains an example of a flow graph configuration for [GNU Radio Companion](https://wiki.gnuradio.org/index.php/GNURadioCompanion).

Getting started with GNU Radio
-----

 - Connect an antenna to the CH1 connector of the Zmod Digitizer module.
 - Download [SD card image zip file]({{ site.release-image }}) (more details about the SD card image can be found at [this link]({{ "/alpine/" | prepend: site.baseurl }})).
 - Copy the contents of the SD card image zip file to a micro SD card.
 - Optionally, to start the application automatically at boot time, copy its `start.sh` file from `apps/sdr_transceiver` to the topmost directory on the SD card.
 - Install the micro SD card in the Eclypse Z7 board and connect the power.
 - Install [GNU Radio](http://gnuradio.org):
{% highlight bash %}
sudo apt-get install gnuradio
{% endhighlight %}
 - Clone the source code repository:
{% highlight bash %}
git clone https://github.com/pavel-demin/eclypse-z7-notes
{% endhighlight %}
 - Run [GNU Radio Companion](http://gnuradio.org/redmine/projects/gnuradio/wiki/GNURadioCompanion) and open FM receiver flow graph:
{% highlight bash %}
cd eclypse-z7-notes/projects/sdr_transceiver/gnuradio
export GRC_BLOCKS_PATH=.
gnuradio-companion fm.grc
{% endhighlight %}

Getting started with SDR# and HDSDR
-----

 - Connect an antenna to the CH1 connector of the Zmod Digitizer module.
 - Download [SD card image zip file]({{ site.release-image }}) (more details about the SD card image can be found at [this link]({{ "/alpine/" | prepend: site.baseurl }})).
 - Copy the contents of the SD card image zip file to a micro SD card.
 - Optionally, to start the application automatically at boot time, copy its `start.sh` file from `apps/sdr_transceiver` to the topmost directory on the SD card.
 - Install the micro SD card in the Eclypse Z7 board and connect the power.
 - Download and install [SDR#](https://www.dropbox.com/sh/5fy49wae6xwxa8a/AAAdAcU238cppWziK4xPRIADa/sdr/sdrsharp_v1.0.0.1361_with_plugins.zip?dl=1) or [HDSDR](http://www.hdsdr.de/).
 - Download and install [Microsoft Visual C++ Redistributable for Visual Studio 2019](https://visualstudio.microsoft.com/downloads/#microsoft-visual-c-redistributable-for-visual-studio-2019).
 - Download [ExtIO plug-in](https://www.dropbox.com/sh/5fy49wae6xwxa8a/AAA6mFLQaCF-wT2fhACJHotra/sdr/ExtIO_RedPitaya_122_88.dll?dl=1) for SDR# and HDSDR.
 - Copy `ExtIO_RedPitaya_122_88.dll` into the SDR# or HDSDR installation directory.
 - Start SDR# or HDSDR.
 - Select Red Pitaya SDR TRX from the Source list in SDR# or from the Options [F7] &rarr; Select Input menu in HDSDR.
 - Press Configure icon in SDR# or press ExtIO button in HDSDR, then type in the IP address of the Eclypse Z7 board and close the configuration window.
 - Press Play icon in SDR# or press Start [F2] button in HDSDR.

Building from source
-----

The structure of the source code and of the development chain is described at [this link]({{ "/led-blinker/" | prepend: site.baseurl }}).

Setting up the Vitis and Vivado environment:
{% highlight bash %}
source /opt/Xilinx/Vitis/2020.2/settings64.sh
{% endhighlight %}

Cloning the source code repository:
{% highlight bash %}
git clone https://github.com/pavel-demin/eclypse-z7-notes
cd eclypse-z7-notes
{% endhighlight %}

Building `sdr_transceiver.bit`:
{% highlight bash %}
make NAME=sdr_transceiver bit
{% endhighlight %}

Building SD card image zip file:
{% highlight bash %}
source helpers/build-all.sh
{% endhighlight %}
