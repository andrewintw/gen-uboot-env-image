# gen-uboot-env-image
a tool to generate a U-Boot environment binary image

## commands

	$ vi env.text

	$ cat env.text | tr '\n' '\0' > config.data

	$ dd if=/dev/zero of=config.base bs=1 count=4092

	$ dd if=config.data of=config.base conv=notrunc bs=1 count=`stat -c %s config.data`

	$ crc32 config.base | sed 's/.\{2\}/& /g' | awk '{for (i=NF;i>=1;i--) printf "%s ", $i;}' | xxd -r -p > config.crc32

	$ cat config.crc32 config.base > config.bin

	$ hexdump -C config.bin


