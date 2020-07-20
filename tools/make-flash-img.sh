#!/usr/bin/env bash
set -e
arg_projname=$1
arg_flashimg=$2
idf_lib=$IDF_PATH/libs

if [ -z "$1" -o -z "$2" ]; then
    echo "Combine binary images of bootloader, partitions and app into one binary image."
    echo "Usage: make-flash-img.sh app_name flash_img_file"
    exit 1
fi

echo "Creating "${arg_flashimg}
dd if=/dev/zero bs=1024 count=4096 of=${arg_flashimg}
echo "Copying bootloader: "${idf_lib}/bootloader.bin
dd if=${idf_lib}/bootloader.bin bs=1 seek=$((0x1000)) of=${arg_flashimg} conv=notrunc
echo "Copying partion file: "${idf_lib}/partitions_singleapp.bin
dd if=${idf_lib}/partitions_singleapp.bin bs=1 seek=$((0x8000)) of=${arg_flashimg} conv=notrunc
echo "Copying project binary: "${arg_projname}.bin
dd if=${arg_projname}.bin bs=1 seek=$((0x10000)) of=${arg_flashimg} conv=notrunc

# Just run qemu for normal testing of output
# xtensa-softmmu/qemu-system-xtensa -nographic -machine esp32 -drive file=flash_image.bin,if=mtd,format=raw

# Run qemu paused as gdb server:
# xtensa-softmmu/qemu-system-xtensa -nographic -s -S -machine esp32 -drive file=flash_image.bin,if=mtd,format=raw
# Followed by:
# xtensa-esp32-elf-gdb build/hello-world.elf -ex "target remote :1234" -ex "monitor system_reset" -ex "tb app_main" -ex "c"

