#!/bin/bash
# Pull Docker image as a singularity
path=$1
singularity pull -F $path docker://pennsive/neuror