#! /usr/bin/env python
# encoding: utf-8

import os
toolpath = os.environ['WAFDIR'] + '/../waf-extensions'

top = '.'
out = 'build'

def options(ctx):
    ctx.load('SoC_build_mgr', tooldir=toolpath)
    ctx.load('Incisive', tooldir=toolpath)
    ctx.load('Syn_support', tooldir=toolpath)
    ctx.load('why')

def configure(ctx):
    ctx.load('SoC_build_mgr', tooldir=toolpath)
    ctx.load('Incisive', tooldir=toolpath)
    ctx.load('Syn_support', tooldir=toolpath)
    ctx.recurse('source_code')

def build(ctx):
    pass
