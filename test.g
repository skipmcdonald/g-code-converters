N10 G0 G90 G54 X1.1 Y1.1 Z1.1 ;
N20 M106 G83 X1.0 Y1.0 Z-0.25 R0.2 Q0.1 F5.5 (X AND Y NOT REQUIRED, CAN BE PULLED FROM CURRENT POSITION) ;
N30 X-1.0 (Y LOCATION NOT REQUIRED);
N40 Y-1.0 (X LOCATION NOT REQUIRED);
N50 X1.0 ;
N60 X2 Y2.5 G80 ; do one more before deactivting the canned drill cycle.
N70 G0 X3 Y3 Z1; not canned
X-1.5 y3 z7 a1 B2 C3 E7 ; other axes etc. and no line number..


