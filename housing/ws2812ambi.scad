LEDcylinderOutDiameter=20;
LEDcylinderOverlap=25;
materialWidth=2;

boardWidth=26;
boardHeight=2.5;
boardDepth=37;
boardAndPartsHeight=18;

translate([LEDcylinderOutDiameter/2+materialWidth,-(LEDcylinderOverlap/2), LEDcylinderOutDiameter/2]) rotate([90,0,0]) difference() {
    cylinder($fn=360, h=LEDcylinderOverlap,d=materialWidth+LEDcylinderOutDiameter+materialWidth, center=true);
    cylinder($fn=360, h=LEDcylinderOverlap,d=LEDcylinderOutDiameter, center=true);    
}

cube([boardWidth-(2*materialWidth), boardDepth,boardAndPartsHeight]);