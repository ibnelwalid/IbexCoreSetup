export RISCV=${PWD}/lowrisc-toolchain-rv32imcb-20220210-1
export RISCV_GCC=${RISCV}/bin/riscv32-unknown-elf-gcc
export RISCV_OBJCOPY=${RISCV}/bin/riscv32-unknown-elf-objcopy
export SPIKE_PATH=riscv-isa-sim/build

lowrisc_toolchain_setup:
ifeq (,$(wildcard ./lowrisc-toolchain-rv32imcb-20220210-1.tar.xz))
	wget https://github.com/lowRISC/lowrisc-toolchains/releases/download/20220210-1/lowrisc-toolchain-rv32imcb-20220210-1.tar.xz
endif
	tar -xvf lowrisc-toolchain-rv32imcb-20220210-1.tar.xz

build_isa_sim:
	mkdir riscv-isa-sim/build -p
	cd riscv-isa-sim/build; ../configure --prefix=${RISCV}
	cd riscv-isa-sim/build; make -j 16
	cd riscv-isa-sim/build; make install 