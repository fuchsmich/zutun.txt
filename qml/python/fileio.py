#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import pyotherside


def read(path):
    try:
        with open(path, 'r') as f:
            read_data = f.read()
            pyotherside.send('log', "Read file {0}".format(path))
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', True)
            pyotherside.send('ioerror', "")
            return read_data
    except IOError:
        pyotherside.send('ioerror', "File not readable {0}".format(path))
        if not os.path.exists(os.path.dirname(path)):
            pyotherside.send('pathExists', False)
            pyotherside.send('fileExists', False)
            pyotherside.send('ioerror', "Dir does not exist {0}".format(os.path.dirname(path)))
        elif not os.path.isfile(path):
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', False)
            pyotherside.send('ioerror', "File does not exist {0}".format(path))
        return ""


def write(path, content):
    try:
        with open(path, 'w') as f:
            f.write(content)
            pyotherside.send('log', "Content saved to {0}".format(path))
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', True)
            pyotherside.send('writeable', True)
            pyotherside.send('ioerror', "")
    except IOError:
        pyotherside.send('ioerror', "File not writeable {0}".format(path))
        if not os.path.exists(os.path.dirname(path)):
            pyotherside.send('pathExists', False)
            pyotherside.send('fileExists', False)
            pyotherside.send('writeable', False)
            pyotherside.send('ioerror', "Dir does not exist {0}".format(os.path.dirname(path)))
        elif not os.path.isfile(path):
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', False)
            pyotherside.send('writeable', False)
            pyotherside.send('ioerror', "File does not exist {0}".format(path))
        else:
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', True)
            pyotherside.send('writeable', False)
            pyotherside.send('ioerror', "File not writeable {0}".format(path))



def create(path):
    try:
        with open(path, 'w+') as f:
            pyotherside.send('log', "file {0} created.".format(path))
            pyotherside.send('pathExists', True)
            pyotherside.send('fileExists', True)
            pyotherside.send('ioerror', "")
    except IOError:
        pyotherside.send('ioerror', "File not writeable {0}".format(path))
        if not os.path.exists(os.path.dirname(path)):
            pyotherside.send('pathExists', False)
            pyotherside.send('fileExists', False)
            pyotherside.send('ioerror', "Dir does not exist {0}".format(os.path.dirname(path)))
        else:
            pyotherside.send('ioerror', "Destination not writeable {0}".format(os.path.dirname(path)))


