# RISCVBusiness
Design documents and project information for the RISC-V Business project can be found here:

https://wiki.itap.purdue.edu/display/RISC/RISCV-Business

RISCVBusiness uses the waf build system.  The following repository contains the source for waf:

https://github.com/mattaw/SoCFoundationFlow

Add the following lines of code to your .cshrc file to initialize waf:

    setenv SFF_ADMIN < path to the "admin" dir in the checkouted out waf repository>

    source $SFF_ADMIN/setup_env.tcsh

Refer to the LICENSE file for licensing information.
