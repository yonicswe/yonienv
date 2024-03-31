#!/bin/bash
func=$1;
path_to_file=$2;
git log -L :${func}:${path_to_file};
