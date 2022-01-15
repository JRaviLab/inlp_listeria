#!/bin/bash
module load edirect
AccNum=$1

efetch -db protein -format ipg -id "$AccNum" | sed -n 2p

