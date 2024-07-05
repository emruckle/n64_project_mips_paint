#!/bin/bash
cd ../test
~/n64_project/bass/bass/out/bass checkBounds.asm
./chksum64 checkBounds.N64