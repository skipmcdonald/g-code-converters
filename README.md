This is a perl script to post process g-code from cnc CAM programs that include drill plans. Specifically G83 G80 blocks like those generated in heeks cad.   
The script tries to include formatting similar to the formatting of the input file.  Style includes whether or not spaces are between commands, line numbering and semicolons.   Comments and other whitespace may get moved around by the process.

run the test:

perl uncan.pl -D test.g out.g

and look at the out.g file or try this test to just examine output:

perl uncan.pl -s test.g | pg

have fun.

Skip McDonald
