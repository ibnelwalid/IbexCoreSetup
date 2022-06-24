export RISCV=${PWD}/lowrisc-toolchain-rv32imcb-20220210-1
export RISCV_GCC=${RISCV}/bin/riscv32-unknown-elf-gcc
export RISCV_OBJCOPY=${RISCV}/bin/riscv32-unknown-elf-objcopy
export SPIKE_PATH=${RISCV}/bin
export SIMULATOR=questa
export QUESTA_HOME=/home/yahmed/qsim_builds/V2022.1_1

lowrisc_toolchain_setup:
ifeq (,$(wildcard ./lowrisc-toolchain-rv32imcb-20220210-1.tar.xz))
	wget https://github.com/lowRISC/lowrisc-toolchains/releases/download/20220210-1/lowrisc-toolchain-rv32imcb-20220210-1.tar.xz
endif
	tar -xvf lowrisc-toolchain-rv32imcb-20220210-1.tar.xz

build_isa_sim:
	mkdir riscv-isa-sim/build -p
	cd riscv-isa-sim/build; ../configure --prefix=${RISCV} --enable-commitlog --enable-misaligned
	cd riscv-isa-sim/build; make clean
	cd riscv-isa-sim/build; make -j 16
	cd riscv-isa-sim/build; sudo make install

questasim_uvm:
	cd ibex/dv/uvm/core_ibex; make clean; make ITERATIONS=1 SIMULATOR=${SIMULATOR}