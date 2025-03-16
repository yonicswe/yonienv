#!/bin/bash

date
for c in clusters/* ; do ./recapture_cluster.sh $c ; done;
