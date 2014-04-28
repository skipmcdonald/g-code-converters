This repository contains a few helpful perl scripts that modify g-code.  
Files containing g-codes may be used to move robots and other machines in the real world.
Sometimes these machines can be dangerous to life, limb, and property if not instructed correctly.
If machines behave badly after digesting any of these processed file it is not my fault.
Please sanity check the files after processing, doing otherwise is gross negligence on your part.
I am not responsible for the results including any errors put into g-code files by these utilities even if you think they are intentional!      


uncan.pl

This is a perl script to post process g-code from cnc CAM programs that include drill plans. Specifically G83 G80 blocks like those generated in heeks cad.   
The script tries to include formatting similar to the formatting of the input file.  Style includes whether or not spaces are between commands, line numbering and semicolons.   Comments and other whitespace may get moved around by the process.

run the test:

perl uncan.pl -D test.g out.g

and look at the out.g file or try this test to just examine output:

perl uncan.pl -s test.g | pg


modxy.pl

This is a perl script that modifies the x, i, y, and j of a g-code script by moving all x and y coordinates into negative (non-positive actually) space by default and ofsetting i and j by the same amount.  Z is left unchanged for now.



have fun, and remember to be safe.
Noting that happens as a consequence of your use of these utilities is in any way my responsibility upto and including global extinction of the human race done by insane robots.


Skip McDonald
