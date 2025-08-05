qemu-system-x86_64 -drive format=raw,file=./bin/boot.bin

# We have to note that, -hda flag instead of -drive will give a warning for not specifying raw format and all
# To avoid that use -drive flag, specify format and file location. DO NOT GIVE SPACES ANYWHERE