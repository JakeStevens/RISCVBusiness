#! /usr/bin/env python
# encoding: utf-8

import os
toolpath = os.environ['WAFDIR'] + '/../waf-extensions'

top = '.'
out = 'build'

def options(ctx):
    ctx.load('SFFbuildmgr', tooldir=toolpath)
    ctx.load('SFFincisive', tooldir=toolpath)
    #ctx.load('Syn_support', tooldir=toolpath)
    ctx.load('why')

def configure(ctx):
    ctx.load('SFFbuildmgr', tooldir=toolpath)
    ctx.load('SFFincisive', tooldir=toolpath)
    #ctx.load('Syn_support', tooldir=toolpath)
    ctx.recurse('source_code')
    ctx.SFFUnits.finalize()

def build(ctx):
    pass
