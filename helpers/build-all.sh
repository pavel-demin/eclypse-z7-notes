source /opt/Xilinx/2025.2/Vitis/settings64.sh

JOBS=`nproc 2> /dev/null || echo 1`

make NAME=led_blinker all

PRJS="sdr_receiver_hpsdr sdr_receiver_wide sdr_transceiver"

printf "%s\n" $PRJS | xargs -n 1 -P $JOBS -I {} make NAME={} bit

sudo sh scripts/alpine.sh
