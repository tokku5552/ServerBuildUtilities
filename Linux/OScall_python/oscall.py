#!/usr/bin/python

import subprocess


def res_cmd(cmd):
    return subprocess.Popen(
        cmd, stdout=subprocess.PIPE,
        shell=True).communicate()[0]


if __name__ == '__main__':
   # example
    cmd = ("ls -l | grep .py")
    print(res_cmd(cmd))
