# IbexCoreSetup
Setup for my ibex core development environment
## Steps to setup on Ubuntu 20.04 LTS docker image:
Docker Image: https://hub.docker.com/layers/ubuntu/library/ubuntu/20.04/images/sha256-b2339eee806d44d6a8adc0a790f824fb71f03366dd754d400316ae5a7e3ece3e?context=explore
```
docker pull ubuntu:20.04
docker run -it ubuntu:20.04 bash
apt-get update
apt-get install ca-certificates curl gnupg lsb-release
apt-get install git gawk texinfo bison flex python expect ninja-build pkg-config libglib2.0-dev vim make g++ device-tree-compiler
mkdir IbexCoreCryptoExtensionWorkDir
cd IbexCoreCryptoExtensionWorkDir
git clone https://github.com/ibnelwalid/IbexCoreSetup
```

## Use the High-level Makefile
### Build a Scalar cryptography compatible GNU Toolchain
```
make clone_crypto_gnu_toolchain
make crypto_toolchain_setup
make questasim_uvm
```
Notes:
- Reference: https://plctlab.github.io/k-ext/how-to-build-scalar-cryptography-gnu-toolchain.html
- Note: The official toolchain for riscv offered by lowrisc doesn't have support for Crypto Extension assembly instructions, so we use the riscv-crypto repo to build the custom toolchain
- Reference: https://github.com/ibnelwalid/riscv-crypto/blob/master/tools/README.md
- I had to clone riscv-crypto because they had some issues using wrong submodules url, so I fixed this in my fork
### riscv-crypto is very bad in terms of build now I'm trying https://plctlab.github.io/k-ext/how-to-build-scalar-cryptography-gnu-toolchain.html
Follow steps in the link, and use the following commands
```
./configure --prefix=/home/yahmed/IbexCoreDevEnv/IbexCoreSetup/riscv-gnu-toolchain/rv32imc_zkn --with-arch=rv32imc_zbkb_zbkc_zbkx_zkne_zknd_zknh --with-abi=ilp32 --with-multilib-generator=rv64imc_zbkb_zbkc_zbkx_zkne_zknd_zknh-ilp32--
```
- add --enable-commitlog to the Makefile in target build-spike like this
```
stamps/build-spike: $(SPIKE_SRCDIR) $(SPIKE_SRC_GIT)
        rm -rf $@ $(notdir $@)
        mkdir $(notdir $@)
        cd $(notdir $@) && $</configure \
                --prefix=$(INSTALL_DIR) \
                --enable-commitlog
        $(MAKE) -C $(notdir $@)
        $(MAKE) -C $(notdir $@) install
        mkdir -p $(dir $@)
        date > $@
```
