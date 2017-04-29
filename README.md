# RISCVBusiness
Design documents and project information for the RISC-V Business project can be found here:

[RISCV-Business Documentation](https://wiki.itap.purdue.edu/display/RISC/RISCV-Business)

# Getting Started

## Generating RISC-V tool-chain

Refer to the following link for instructions on installing the RISC-V software tools:

[RISC-V Software Installation](https://riscv.org/software-tools/)

Execute the following commands to download the correct version of the RISC-V tools:

~~~
git clone https://github.com/riscv/riscv-tools.git
git checkout 4635ab67966c763a84f7217bc2c20b65dcabc7ec
git submodule update --init --recursive
~~~

Change the line to build the riscv-gnu-toolchain tools to:

~~~
build_project riscv-gnu-toolchain --prefix=$RISCV --with-xlen="$with_xlen" --with-arch=RV32IM
~~~

Then run after setting the environment variable "RISCV" to your install location:

~~~
./build.sh
~~~

## Installing the build environment

RISCVBusiness uses SoCFoundationFlow, built off of the waf build system.  The following repository contains the source for waf:

[SoCFoundationFlow](https://github.com/mattaw/SoCFoundationFlow)

Refer to SoCFoundationFlow for installation instructions.

## Verifying your setup

Run the following command to run the regression test on RISCV-Business.  All tests should pass:

~~~
./run_test.py
~~~

Refer to the LICENSE file for licensing information.
