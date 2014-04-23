N10 G0 G90 G54 X1.1 Y1.1 Z1.1 G4 P2.4 ;
N20 M106 G83 X1.0 Y1.0 Z-0.25 R0.2 Q0.1 F5.5 (X AND Y NOT REQUIRED, CAN BE PULLED FROM CURRENT POSITION) ;
N30 X-1.0 (Y LOCATION NOT REQUIRED);
N40 Y-1.0 (X LOCATION NOT REQUIRED);
N50 X1.0 ;
N60 X2 Y2.5 G80 ; do one more before deactivting the canned drill cycle.
N70 G0 X3 Y3 Z1; not canned

X-1.5 y3 z7 a1 B2 C3 E7 ; other axes etc. and no line number..
G0 Z0 ; screw up traversal and see if R fixes it.
G81 X3.0 Y3.0 Z-0.52 R0.1 F3.5 (X AND Y NOT REQUIRED, CAN BE PULLED FROM CURRENT POSITION) ;
Y1.5
	; test blank line
G0 X2 ; test behavior of wayward G0 inside a canned sequence
N80 G0 Y2 ; test behavior of line number then wayward G0
G1 Y4 F5.2 ;test behavior of wayward G1 
G80
G83Z-4Q1P0.51
G80
G1 Z2 F1
G89X0Y0Z-2R0.21P1.11 (a space after the digit of any command on the line should cause the cycle output to be spaced between commands); test boring 
X2 
Y2
X0
G80
(G83Z4Q0X5Y6G80i) ; uncomment () to test error termination on Q
(G84) ; uncomment () to test error termination
(G87) ; uncomment () to test error termination
(G88) ; uncomment () to test error termination
G80
