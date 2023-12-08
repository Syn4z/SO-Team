#!/bin/bash

binary_file="$1"
bootloader="$2"
mini_bootloader="$3"

# Check if the binary file exists
nasm -f bin $binary_file -o main.bin
nasm -f bin $mini_bootloader -o mini_bootloader.bin
nasm -f bin $bootloader -o bootloader.bin

# Create an empty floppy disk image (1.44MB size)
floppy_image="floppy.img"
truncate -s 1474560 mini_bootloader.bin
mv mini_bootloader.bin $floppy_image

dd if="bootloader.bin" of="$floppy_image" bs=512 seek=1 conv=notrunc
dd if="main.bin" of="$floppy_image" bs=512 seek=3 conv=notrunc

echo "Binary file '$binary_file' successfully added to floppy image '$floppy_image'."