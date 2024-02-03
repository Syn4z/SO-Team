#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <filename.asm>"
  exit 1
fi

filename_with_extension="$1"
filename="${filename_with_extension%.*}"

asm_file="$filename_with_extension"
com_file="$filename.com"
flp_file="$filename.flp"

# Step 1: Compile the assembly code to a .com file
nasm -f bin -o "$com_file" "$asm_file"
if [ $? -ne 0 ]; then
  echo "Compilation failed. Check your assembly code."
  exit 1
fi
echo "Step 1: Compilation completed."

# Step 2: Copy the .com file to a .flp file
nasm -f bin -o "bootloader.com" "bootloader.asm"
nasm -f bin -o "init_bootloader.com" "init_bootloader.asm"
if [ $? -ne 0 ]; then
  echo "Compilation failed. Check your bootloader code."
  exit 1
fi
echo "Step 2: Compilation of boatloader completed."
# cat "bootloader.com" "$com_file" > "$flp_file"

truncate -s 1474560 "$flp_file"
dd if="bootloader.com" of="$flp_file" bs=512 seek=1 conv=notrunc
dd if="$com_file" of="$flp_file" bs=512 seek=3 conv=notrunc

# Step 3: Resize the .flp file to 1.44MB
echo "Step 3: Resized $flp_file to 1.44MB."

# Step 4: Close VirtualBox
VM_NAME="BestOS" 
VBoxManage controlvm "$VM_NAME" poweroff
echo "Virtual Machine $VM_NAME closed."

sleep 3

# Step 5: Change the storage to $flp_file in VirtualBox
VBoxManage storageattach "$VM_NAME" --storagectl "Floppy" --port 0 --device 0 --type fdd --medium "$flp_file"
echo "Step 5: Storage in VirtualBox changed to $flp_file."

# Step 6: Start the Virtual Machine
VBoxManage startvm "$VM_NAME"
echo "Step 6: Virtual Machine $VM_NAME started."

echo "All steps completed successfully."
