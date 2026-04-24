pkg load fuzzy-logic-toolkit;
Epi = readfis("bin/octaveepi.fis");
in_put = argv ();

#A1 = in_put{1};
#A2 = in_put{2};
#A3 = in_put{3};
#A4 = in_put{4};
#A5 = in_put{5};
#T = [str2num(A1),str2num(A2),str2num(A3),str2num(A4),str2num(A5)];

A = csvread("temp/fuzzfile.csv");
disp(evalfis(A,Epi));







