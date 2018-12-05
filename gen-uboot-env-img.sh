#! /bin/sh
#
# https://github.com/andrewintw
#

# 0x1000 - 0x4 in my uboot
ENV_DATA_SIZE=4092

CFG_DATA_BIN="config.data"
CFG_BASE_BIN="config.base"
CFG_CRC_BIN="config.crc32"
CFG_IMG="config.bin"

env_file="$1"

show_usage () {
	cat <<EOF

Usage: `basename $0` <uboot-env.text>

EOF
}

do_init () {
	rm -rf $CFG_DATA_BIN $CFG_BASE_BIN $CFG_CRC_BIN $CFG_IMG

	if [ "$env_file" = "" ]; then
		show_usage && exit 1
	fi

	if [ ! -f "$env_file" ]; then
		echo "[Error] No such file: $env_file"
		show_usage && exit 1
	fi
}

gen_cfg_data () {
	cat $env_file | sed '/^$/d' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr '\n' '\0' > $CFG_DATA_BIN
}

gen_cfg_base () {
	dd if=/dev/zero of=$CFG_BASE_BIN bs=1 count=$ENV_DATA_SIZE 2>/dev/null

	if [ -f "$CFG_DATA_BIN" ]; then
		dd if=$CFG_DATA_BIN of=$CFG_BASE_BIN bs=1 count=`stat -c %s $CFG_DATA_BIN` conv=notrunc 2>/dev/null
	else
		echo "[Error] No such file: $CFG_DATA_BIN"
		exit 1
	fi
}

gen_cfg_crc () {
	crc32 $CFG_BASE_BIN | sed 's/.\{2\}/& /g' | awk '{for (i=NF;i>=1;i--) printf "%s ", $i;}' | xxd -r -p > $CFG_CRC_BIN
}

gen_cfg_bin () {
	if [ -f "$CFG_CRC_BIN" ] && [ -f "$CFG_BASE_BIN" ]; then
		cat $CFG_CRC_BIN $CFG_BASE_BIN > $CFG_IMG
	else
		echo "[Error] No such file: $CFG_CRC_BIN or $CFG_BASE_BIN"
		exit 1
	fi
}

do_done () {
	if [ -f "$CFG_IMG" ]; then
		hexdump -C $CFG_IMG
	else
		echo "[Error] No such file: $CFG_IMG"
		exit 1
	fi

	rm -rf $CFG_DATA_BIN $CFG_BASE_BIN $CFG_CRC_BIN
}

do_main () {
	do_init && \
	gen_cfg_data && \
	gen_cfg_base && \
	gen_cfg_crc && \
	gen_cfg_bin && \
	do_done
}

do_main

