import argparse
import sys
import glob
import subprocess
import os
import re

from run_tests import compile_asm_for_self

if __name__ == '__main__':
    compile_asm_for_self(sys.argv[1])
    #file_name =  sys.argv[1]
    ##file_name_cmd = '/home/socetlnx03/RISCVBusiness/' + file_name
    #file_name_cmd = file_name
    ## compile all of the files
    #arch = file_name_cmd.split('/')[-2]
    #short_name = file_name_cmd.split('/')[-1][:-2]
    #output_dir = './sim_out/' + arch + '/' + short_name + '/'
    #output_name = output_dir + short_name + '.elf'

    ## Added 64-bit support
    ## Except for 32 bit rv32ud move.S, which just includes the 64 bit version of move.S
    ## which is weird...
    #if 'move.S' in file_name:
    #    xlen = 'rv64g'
    #    abi = 'lp64'
    #else:
    #    xlen = 'rv64g' if '64' in arch else 'rv32g'
    #    abi = 'lp64' if '64' in arch else 'ilp32'

    #if not os.path.exists(os.path.dirname(output_name)):
    #    os.makedirs(os.path.dirname(output_name))

    #

    #cmd_arr = ['riscv64-unknown-elf-gcc', '-march=' + xlen, '-mabi=' + abi, '-static',
    #            '-mcmodel=medany', '-fvisibility=hidden', '-nostdlib',
    #            '-nostartfiles', '-I./verification/self-tests/env/p',
    #            '-I./verification/self-tests/macros/scalar', '-T./verification/self-tests/env/p/link.ld',
    #            file_name_cmd, '-o', output_name]
    #print (' '.join (cmd_arr))



    #failure = subprocess.call(cmd_arr)
    #if failure:
    #    with open('ret.txt','w') as fptr:
    #        fptr.write(str(-1))
    #    sys.exit()

    #



    ## create an meminit.hex file from the elf file produced above
    #cmd_arr = ['elf2hex', '8', '4096', output_name, '2147483648']
    #hex_file_loc = output_dir + 'meminit.hex'
    #with open(hex_file_loc, 'w') as hex_file:
    #    failure = subprocess.call(cmd_arr, stdout=hex_file)
    #if failure:
    #    with open('ret.txt','w') as fptr:
    #        fptr.write(str(-2))
    #    sys.exit()

    #else:
    #    print (' '.join (cmd_arr))
    #    with open('ret.txt','w') as fptr:
    #        fptr.write(str(0))
    #    sys.exit()
