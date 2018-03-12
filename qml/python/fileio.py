#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import pyotherside


def setPath(path):
    global _path
    _path = path

def read():
    if '_path' in globals():
        try:
            with open(_path, 'r') as f:
                read_data = f.read()
                return read_data
        except:
            pyotherside.send('error', "{0} file not readable".format(_path))


def write(content):
    if '_path' in globals():
        try:
            with open(_path, 'w') as f:
                f.write(content)
                pyotherside.send('log', "content saved")
        except:
            pyotherside.send('error', "{0} file not writeable".format(_path))

