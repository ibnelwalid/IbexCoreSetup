SHELL = /bin/bash
#export RISCV=${PWD}/lowrisc-toolchain-rv32imcb-20220210-1
#export RISCV_ARCH=riscv32-unknown-elf
#export RISCV_GCC=${PWD}/riscv-crypto/build/riscv32-unknown-elf/bin/riscv64-unknown-elf-gcc
#export RISCV_OBJCOPY= ${PWD}/riscv-crypto/build/riscv32-unknown-elf/bin/riscv64-unknown-elf-objcopy
export ISA=rv32imc_zbkb_zbkc_zbkx_zkne_zknd_zknh
export ABI=ilp32
export RISCV=${PWD}/riscv-gnu-toolchain/rv32imc_zkn
export RISCV_GCC=${RISCV}/bin/riscv32-unknown-elf-gcc
export RISCV_OBJCOPY=${RISCV}/bin/riscv32-unknown-elf-objcopy
export SPIKE_PATH=${RISCV}/bin
export SIMULATOR=questa
export QUESTA_HOME=/home/yahmed/qsim_builds/V2022.1_1
export PRJ_DIR=${PWD}/ibex

lowrisc_toolchain_setup:
ifeq (,$(wildcard ./lowrisc-toolchain-rv32imcb-20220210-1.tar.xz))
	wget https://github.com/lowRISC/lowrisc-toolchains/releases/download/20220210-1/lowrisc-toolchain-rv32imcb-20220210-1.tar.xz
endif
	tar -xvf lowrisc-toolchain-rv32imcb-20220210-1.tar.xz

clone_crypto_gnu_toolchain:
	cd ../ &&\
	git clone https://github.com/riscv/riscv-gnu-toolchain &&\
	cd riscv-gnu-toolchain &&\
	git rm qemu &&\
	git submodule update --init &&\
	cd riscv-gcc &&\
	git remote add k https://github.com/WuSiYu/riscv-gcc &&\
	git fetch k &&\
	git checkout k/riscv-gcc-10.2.0-crypto &&\
	cd ../riscv-binutils &&\
	git remote add k https://github.com/pz9115/riscv-binutils-gdb.git &&\
	git fetch k &&\
	git checkout k/riscv-binutils-2.36-k-ext

crypto_toolchain_setup:
	cd riscv-crypto && source bin/conf.sh && tools/clone.sh

crypto_toolchain_build:
	cd riscv-crypto && source bin/conf.sh && tools/toolchain-conf.sh && tools/toolchain-build.sh
	cd riscv-crypto && source bin/conf.sh && tools/pk-conf.sh && tools/pk-build.sh
	cd riscv-crypto && source bin/conf.sh && tools/spike-conf.sh && tools/spike-build.sh

build_isa_sim:
	mkdir riscv-isa-sim/build -p
	cd riscv-isa-sim/build; ../configure --prefix=${RISCV} --with-isa=${ISA} --enable-commitlog --enable-misaligned
	cd riscv-isa-sim/build; make clean
	cd riscv-isa-sim/build; make -j 16
	cd riscv-isa-sim/build; sudo make install

questasim_uvm:
	cd ibex/dv/uvm/core_ibex; make clean; make SHELL='bash -x' ITERATIONS=1 SIMULATOR=${SIMULATOR}

questasim_uvm_enc_directed:
	cd ibex/dv/uvm/core_ibex; make clean; make ITERATIONS=1 SIMULATOR=${SIMULATOR} TEST=aes_enc_simple

test_basic_direct:
	cd ibex/dv/uvm/core_ibex; make clean; make SHELL='bash -x' ISA=rv32imcb_zkne ITERATIONS=1 SIMULATOR=${SIMULATOR} TEST=aes_enc RISCV_DV_OPTS='--asm_test /home/yahmed/IbexCoreDevEnv/IbexCoreSetup/tests/aes_encryption/aes_enc_0.S --debug debug.log'

test_basic:
	cd ibex/dv/uvm/core_ibex; make clean;python3 /home/yahmed/IbexCoreDevEnv/IbexCoreSetup/ibex/vendor/google_riscv-dv/run.py --o=out/seed-1/instr_gen --steps=gcc_compile --start_seed=1 --test=riscv_bitmanip_balanced_test --testlist=riscv_dv_extension/testlist.yaml --iterations=1 --gcc_opts=-mno-strict-align --custom_target=riscv_dv_extension --mabi=ilp32 --isa=rv32imcb_zkne --asm_test /home/yahmed/IbexCoreDevEnv/IbexCoreSetup/tests/aes_encryption/aes_enc.S --debug debug.log
	cd ibex/dv/uvm/core_ibex; mkdir -p out/rtl_sim
	cd ibex/dv/uvm/core_ibex; ./sim.py --o=out/ --steps=compile --simulator=questa --simulator_yaml=yaml/rtl_simulation.yaml --en_wave '--cmp_opts= +define+IBEX_CFG_RV32M=ibex_pkg::RV32MSingleCycle +define+IBEX_CFG_RV32B=ibex_pkg::RV32BOTEarlGrey +define+IBEX_CFG_RegFile=ibex_pkg::RegFileFF'
	cd ibex/dv/uvm/core_ibex; touch out/rtl_sim/.compile.stamp
	cd ibex/dv/uvm/core_ibex; rm -rf out/seed-1/rtl_sim
	cd ibex/dv/uvm/core_ibex; cp -r out/rtl_sim out/seed-1
	cd ibex/dv/uvm/core_ibex; mkdir out/seed-1/.metadata;touch out/seed-1/.metadata/rtl_sim.compile.stamp
	cd ibex/dv/uvm/core_ibex; echo Running RTL simulation at out/seed-1/rtl_sim/riscv_bitmanip_balanced_test.1/sim.log
	cd ibex/dv/uvm/core_ibex; mkdir -p out/seed-1/rtl_sim/riscv_bitmanip_balanced_test.1
	cd ibex/dv/uvm/core_ibex; ./run_rtl.py --simulator questa --simulator_yaml yaml/rtl_simulation.yaml --en_wave --start-seed 1 '--sim-opts=+signature_addr=8ffffffc  -g/core_ibex_tb_top/RV32E=0 -g/core_ibex_tb_top/BranchTargetALU=1 -g/core_ibex_tb_top/WritebackStage=1 -g/core_ibex_tb_top/ICache=1 -g/core_ibex_tb_top/ICacheECC=1 -g/core_ibex_tb_top/BranchPredictor=0 -g/core_ibex_tb_top/PMPEnable=1 -g/core_ibex_tb_top/PMPGranularity=0 -g/core_ibex_tb_top/PMPNumRegions=16 -g/core_ibex_tb_top/SecureIbex=1 -g/core_ibex_tb_top/ICacheScramble=0' --test-dot-seed riscv_bitmanip_balanced_test.1 --bin-dir out/seed-1/instr_gen/asm_test --rtl-sim-dir out/seed-1/rtl_sim

test_target:
	cd ibex/dv/uvm/core_ibex; make clean;python3 /home/yahmed/IbexCoreDevEnv/IbexCoreSetup/ibex/vendor/google_riscv-dv/run.py --output=out/seed-22684/instr_gen --steps=gen --gen_timeout=1800 --lsf_cmd= --simulator=questa --isa=rv32imcb_zkne --asm_test /home/yahmed/IbexCoreDevEnv/IbexCoreSetup/tests/aes_encryption/aes_enc_0.S --start_seed=22684 --test=riscv_bitmanip_balanced_test --testlist=riscv_dv_extension/testlist.yaml --iterations=1 --csr_yaml=riscv_dv_extension/csr_description.yaml --end_signature_addr=8ffffffc '--sim_opts=+uvm_set_inst_override=riscv_asm_program_gen,ibex_asm_program_gen,uvm_test_top.asm_gen +signature_addr=8ffffffc +pmp_num_regions=16 +pmp_granularity=0 +tvec_alignment=8' --debug debug.log