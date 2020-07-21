#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import pyotherside
import locale



def checkPath(path, perm):
    #pyotherside.send('log', "checking path {0}".format(path), os.path.exists(os.path.dirname(path)))
    if os.path.exists(os.path.dirname(path)):
        pyotherside.send('pathExists', True)
    else:
        pyotherside.send('pathExists', False)
        return False
    return True

def checkFile(path, perm):
    pyotherside.send('log',locale.getlocale())
    if checkPath(path, perm):
        pyotherside.send('pathExists', True)
    else:
        pyotherside.send('pathExists', False)
        pyotherside.send('fileExists', False)
        pyotherside.send('readable', False)
        pyotherside.send('writeable', True)
        return False
    if os.access(path, os.F_OK):
        pyotherside.send('fileExists', True)
    else:
        pyotherside.send('fileExists', False)
        pyotherside.send('readable', False)
        pyotherside.send('writeable', True)
        return False
    if os.access(path, os.R_OK):
        pyotherside.send('readable', True)
    else:
        pyotherside.send('readable', False)
        pyotherside.send('writeable', True)
        if ('r' in perm):
            return False
    if os.access(path, os.W_OK):
        pyotherside.send('writeable', True)
    else:
        pyotherside.send('writeable', False)
        if ('w' in perm):
            return False
    return True

def read(path, lastChange):
    if (checkFile(path, "r")):
        #pyotherside.send('log', "File for read checked")
        if (lastChange and os.path.getmtime(path) <= lastChange):
            pyotherside.send('log', os.path.getmtime(path))
            return ""
        with open(path, 'rt') as f:
            read_data = f.read()
            #f.close()
            #pyotherside.send('log', "Content read {0}".format(path))
            return read_data
    else:
        return ""


def write(path, content):
    if (checkFile(path, "w")):
        #pyotherside.send('log', "File for write checked")
        with open(path, 'wt') as f:
            f.write(content)
            f.close()
            pyotherside.send('log', "Content saved to {0}".format(path))


def create(path):
    try:
        if (checkPath(path, 'rw')):
            with open(path, 'w+') as f:
                pyotherside.send('log', "file {0} created.".format(path))
                f.close()
                checkFile(path, "rw")
    except IOError:
        pyotherside.send('ioerror', "File not writeable {0}".format(path))


