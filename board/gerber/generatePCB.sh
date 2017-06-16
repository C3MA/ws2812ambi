#!/bin/bash
# Needs the tool pcb2gcode
# Was documented at: http://marcuswolschon.blogspot.de/2013/02/milling-pcbs-using-gerber2gcode.html

MILLSPEED=600
MILLFEED=200
PROJECT=ESP01
pcb2gcode --front ESP01-F.Cu.gbr --back ESP01-B.Cu.gbr --metric --zsafe 5 --zchange 10 --zwork -0.01 --offset 0.02 --mill-feed $MILLFEED --mill-speed $MILLSPEED --drill ESP01.drl --zdrill -2.5 --drill-feed $MILLFEED --drill-speed $MILLSPEED --basename $PROJECT
