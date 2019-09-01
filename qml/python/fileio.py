#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import pyotherside


def checkFile(path, perm):
    if os.path.exists(os.path.dirname(path)):
        pyotherside.send('pathExists', True)
    else:
        pyotherside.send('pathExists', False)
        return False
    if os.access(path, os.F_OK):
        pyotherside.send('fileExists', True)
    else:
        pyotherside.send('fileExists', False)
        return False
    if os.access(path, os.R_OK):
        pyotherside.send('readable', True)
    else:
        pyotherside.send('readable', False)
        if ('r' in perm):
            return False
    if os.access(path, os.W_OK):
        pyotherside.send('writeable', True)
    else:
        pyotherside.send('readable', False)
        if ('w' in perm):
            return False
    return True

def read(path):
    if (checkFile(path, "r")):
        pyotherside.send('log', "File for read checked")
        with open(path, 'rt') as f:
            read_data = f.read()
            #f.close()
            pyotherside.send('log', "Content read {0}".format(path))
            return read_data
    else:
        return ""


def write(path, content):
    if (checkFile(path, "w")):
        pyotherside.send('log', "File for write checked")
        with open(path, 'wt') as f:
            f.write(content)
            f.close()
            pyotherside.send('log', "Content saved to {0}".format(path))


def create(path):
    try:
        with open(path, 'w+') as f:
            pyotherside.send('log', "file {0} created.".format(path))
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', True)
            pyotherside.send('writeable', True)
            pyotherside.send('ioerror', "")
            f.close()
    except IOError:
        pyotherside.send('ioerror', "File not writeable {0}".format(path))
        if not os.path.exists(os.path.dirname(path)):
            pyotherside.send('pathExists', False)
            pyotherside.send('fileExists', False)
            pyotherside.send('ioerror', "Dir does not exist {0}".format(os.path.dirname(path)))
        else:
            pyotherside.send('ioerror', "Destination not writeable {0}".format(os.path.dirname(path)))


