#!/usr/bin/python

#   Copyright 2016 Purdue University
#   
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#   
#       http://www.apache.org/licenses/LICENSE-2.0
#   
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#   Filename:     generate_extension.py
#
#   Created by:   John Skubic
#   Email:        jskubic@purdue.edu
#   Date Created: 04/14/2017
#   Description:  Generates a new custom extension based off of the template
#                 rtype instruction

import argparse
import os
import time

source_dir = "./source_code/"
packages_dir = source_dir + "packages/risc_mgmt/"
risc_mgmt_dir = source_dir + "risc_mgmt/"
extension_dir = risc_mgmt_dir + "extensions/"
source_ext_name = "template"
source_dir = extension_dir + source_ext_name + "/" 

ext_file_list = [packages_dir+source_ext_name+"_pkg.sv", source_dir+source_ext_name+"_decode.sv", 
  source_dir+source_ext_name+"_execute.sv", source_dir+source_ext_name+"_memory.sv"]
waf_script =  extension_dir + "wscript"

''' Checks to make sure all files exist and the directory structure is as expected'''
def dir_check():
  nonexistant = []
  for ext_file in ext_file_list:
    if not os.path.exists(ext_file):
      nonexistant.append(ext_file)
  if not os.path.exists(waf_script):
    nonexistant.append(ext_file)

  for errfile in nonexistant:
    print "Error: The file " + errfile + " does not exist."
  
  if len(nonexistant):
    print "Dircheck failed.  Be sure you are running this script from the top level of RISCV-Business"
    return False
  return True
    

''' Generates the new extension from the source_ext_name template '''
def generate_new_extension(ext_name):
  print "Generating new extension '" + ext_name + "' from '" + source_ext_name + "'"

  # generate new files
  if not os.path.exists(extension_dir + ext_name):
    os.makedirs(extension_dir + ext_name)

  for ext_file in ext_file_list:
    dest_file = ext_file.replace(source_ext_name, ext_name)
    src = open(ext_file, 'r')
    dest = open(dest_file, 'w')
    for line in src:
      #replace name of extension
      line = line.replace(source_ext_name, ext_name)
      line = line.replace(source_ext_name.upper(), ext_name.upper())
      #fill in date
      line = line.replace("<date>", time.strftime("%m/%d/%Y"))
      dest.write(line)
    src.close()
    dest.close() 

  # update waf script
  wfile = open(waf_script, 'r')
  wfile_contents = []
  for line in wfile:
    wfile_contents.append(line)
  wfile.close()

  wfile = open(waf_script, 'w')
  in_recurse_block = False
  for line in wfile_contents:
    if "configure" in line or "sim_source" in line:
      in_recurse_block = True
    if in_recurse_block and line.strip() == "":
      wfile.write("  cnf.recurse(" + ext_name + ")\n")
      in_recurse_block = False
    if ext_name in line: #found this extension in wscript already
      in_recurse_block = False
    wfile.write(line) 
  if in_recurse_block:
    wfile.write("  cnf.recurse(" + ext_name + ")\n")
  wfile.close() 


if __name__ == "__main__":
  description =  "Generates the files and sets up a new custom instruction." 
  description += " This script takes the name of the new extension.  The Template"
  description += " extension (which does nothing) will be used to generate the new"
  description += " extension.  Caution: If an extension with the name you give exists,"
  description += " it will be overwritten."

  parser = argparse.ArgumentParser(description=description)
  parser.add_argument('extension_name', metavar='extension_name', type=str,
                      help='Name of the new extension')
  args = parser.parse_args()
  if dir_check():
    generate_new_extension(args.extension_name)
    print "Extension created successfully"
