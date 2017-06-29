#! /usr/bin/env python
# encoding: utf-8

import os
toolpath = os.environ['WAFDIR'] + '/../waf-extensions'

top = '.'
out = 'build'

def options(ctx):
    if len(ctx.stack_path) == 1 and ctx.stack_path[0] is None:
        ctx.load('SFFbuildmgr', tooldir=toolpath)
        ctx.load('SFFbuild', tooldir=toolpath)
        #ctx.load('Syn_support', tooldir=toolpath)
        ctx.load('why')
    else:
        pass

def configure(ctx):
    if len(ctx.stack_path) == 1 and ctx.stack_path[0] is None:
        ctx.load('SFFbuildmgr', tooldir=toolpath)
        ctx.load('SFFbuild', tooldir=toolpath)
    ctx.recurse('source_code')
    if len(ctx.stack_path) == 1 and ctx.stack_path[0] is None:
        ctx.SFFUnits.finalize()

def sim_source(ctx):
    ctx.recurse('source_code')

def build(ctx):
    pass
