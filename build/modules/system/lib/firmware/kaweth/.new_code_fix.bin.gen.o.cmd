cmd_firmware/kaweth/new_code_fix.bin.gen.o := /root/toolchains/gclang/bin/clang -Wp,-MD,firmware/kaweth/.new_code_fix.bin.gen.o.d  -nostdinc -isystem /root/toolchains/gclang/lib64/clang/9.0.5/include -I../arch/arm64/include -I./arch/arm64/include/generated/uapi -I./arch/arm64/include/generated  -I../include -I./include -I../arch/arm64/include/uapi -I../include/uapi -I./include/generated/uapi -include ../include/linux/kconfig.h -D__KERNEL__ -Qunused-arguments -mlittle-endian -Qunused-arguments -D__ASSEMBLY__ --target=aarch64-linux-gnu --prefix=/root/toolchains/aarch64-8.0/bin/ --gcc-toolchain=/root/toolchains/aarch64-8.0 -no-integrated-as -Werror=unknown-warning-option -fno-PIE -DCONFIG_AS_LSE=1 -Wa,-gdwarf-2   -c -o firmware/kaweth/new_code_fix.bin.gen.o firmware/kaweth/new_code_fix.bin.gen.S

source_firmware/kaweth/new_code_fix.bin.gen.o := firmware/kaweth/new_code_fix.bin.gen.S

deps_firmware/kaweth/new_code_fix.bin.gen.o := \

firmware/kaweth/new_code_fix.bin.gen.o: $(deps_firmware/kaweth/new_code_fix.bin.gen.o)

$(deps_firmware/kaweth/new_code_fix.bin.gen.o):
