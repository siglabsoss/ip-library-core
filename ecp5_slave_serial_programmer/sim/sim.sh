#!/bin/bash

rm -f *.log

$ACTIVEHDLBIN/vsimsa -l console.log -do ./sim.do 
