#!/bin/python3



from sys import argv

from prettytable import PrettyTable

from subprocess import check_output

import os

import sys



def format_table(table):

    table.field_names = ["branch", "description"]

    table.align["branch"] = "l"

    table.align["description"] = "l"



def show_branches(prefix):

    table = PrettyTable()

    format_table(table)

    G = "\033[0;32;40m" # GREEN

    N = "\033[0m" # Reset



    try:

        branches = check_output(['git', 'branch']).decode('utf')

    except:

        sys.exit(1)



    for branch in branches.splitlines():

        if prefix not in branch:

            continue



        curr_branch = '*' in branch

        branch_name = branch.strip() if not curr_branch else branch.strip().split(' ')[1]

        try:

            output = check_output(['git', 'config', f'branch.{branch_name}.description']).decode('utf')

            desc = os.linesep.join([s for s in output.splitlines() if s])

        except:

            desc = '---'

        if curr_branch:

            table.add_row([G+branch_name, desc+N])

        else:

            table.add_row([N+branch_name+N, desc+N])



    # Done

    print(table)



if __name__ == '__main__':

    prefix = argv[1] if len(argv) > 1 else ''

    show_branches(prefix)
