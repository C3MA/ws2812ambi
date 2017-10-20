LEDcylinderOutDiameter=20;
LEDcylinderOverlap=25;
materialWidth=2;

boardWidth=26;
boardHeight=2.5;
boardDepth=37;
boardAndPartsHeight=20;
boardHeight=2.5;
boardBottomSpace=0;
// Necessary for fixing
windowBench=25;
windowBenchLength=30;

// CylinderMoving
cylMoveX=boardWidth/2;
cylMoveY=-((LEDcylinderOverlap/2)+materialWidth);
cylMoveZ=LEDcylinderOutDiameter/2;

// Cylinder for the pipe
translate([cylMoveX,cylMoveY,cylMoveZ]) rotate([90,0,0]) difference() {
    cylinder($fn=360, h=LEDcylinderOverlap,d=materialWidth+LEDcylinderOutDiameter+materialWidth, center=true);
    cylinder($fn=360, h=LEDcylinderOverlap,d=LEDcylinderOutDiameter, center=true);    
}
// Connector between round and squared

difference() {
    translate([-materialWidth,-materialWidth,-materialWidth]) cube([boardWidth+(2*materialWidth), materialWidth,boardAndPartsHeight+(2*materialWidth)]);
    translate([cylMoveX,0,cylMoveZ]) rotate([90,0,0]) cylinder($fn=360, h=LEDcylinderOverlap,d=LEDcylinderOutDiameter, center=true);   
}

// Space for the board
difference() {
    translate([-materialWidth,0,-materialWidth])
    cube([boardWidth+(2*materialWidth), boardDepth,boardAndPartsHeight+(2*materialWidth)]);
    cube([boardWidth, boardDepth,boardAndPartsHeight]);
}
// left holder for the board
translate([0,0,boardBottomSpace]) cube([materialWidth, boardDepth,materialWidth]);
translate([0,0,boardBottomSpace+materialWidth+boardHeight]) cube([materialWidth, boardDepth,materialWidth]);
// right holder for the board
translate([boardWidth-materialWidth,0,boardBottomSpace]) cube([materialWidth, boardDepth,materialWidth]);
translate([boardWidth-materialWidth,0,boardBottomSpace+materialWidth+boardHeight]) cube([materialWidth, boardDepth,materialWidth]);

translate([-materialWidth,(boardDepth-windowBenchLength),boardAndPartsHeight+materialWidth]) difference() {
    cube([boardWidth+(materialWidth*2), windowBenchLength,windowBench+materialWidth]); 
    cube([boardWidth+(materialWidth*2), windowBenchLength-materialWidth,windowBench]); 
}