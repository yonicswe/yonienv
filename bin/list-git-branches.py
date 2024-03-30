#!/usr/bin/python

import subprocess
import sys

def git(*args):
    return subprocess.check_output(['/usr/bin/git'] + list(args)).strip()

try:
    branches = git('branch').split('\n')

except subprocess.CalledProcessError:
    sys.exit(1)

longest = len(max(branches, key=len))

for branch in branches:
    active = '*' if branch[0] == '*' else ''
    branch = branch.lstrip(' *')
    try:
        desc = git('config', 'branch.'+branch+'.description')

    except subprocess.CalledProcessError:
        print '{:2}{}'.format(active, branch)
    else:
        print '{:2}{:{}}  {}'.format(active, branch, longest, desc)
