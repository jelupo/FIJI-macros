//composed by Jelle Postma, 2022, Radboud University Nijmegen

//getting time info
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

//closing any existing results table
if(isOpen("Results")){close("Results");};

//trimming the image slightly (edge effects..)
t = getTitle(); n=0.95*getWidth();
run("Canvas Size...", "width=&n height=&n position=Center zero");
run("Duplicate...", "title=copy");

//picking up the structures and skeletonizing them
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("Huang"); setOption("BlackBackground", true); run("Convert to Mask"); run("Erode"); run("Skeletonize");

//analyzing the skeletons
run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] late show display"); close("copy"); run("Cascade");

//checking for actual results
if(isOpen("Branch information")){selectWindow("Branch information");}else{exit("Can't find the table of branches");}
e = Table.getColumn("Euclidean distance");
l = Table.getColumn("Branch length");
if(e.length==0||l.length==0){exit("Can't find any branches in table");}
if(!isOpen("Results")){exit("Can't find any Results table");}

//calculating each branch "Tortuosity". Speculative...
//= 1-(distance between ends / its length)
//and adding it to the branches table
tortarray = newArray(e.length);
for(i=0;i<e.length;i++){tortarray[i]=(1-(e[i]/l[i]));}
Table.setColumn("\"Tortuosity\"", tortarray);

//presenting tables
selectWindow("Results");
Table.rename("Results", "Skeleton information of: "+t+" at "+hour+":"+minute+"h"+second+"s:");
setLocation((0.10*screenWidth), (0.10*screenHeight));
selectWindow("Branch information");
Table.rename("Branch information", "Branch information of: "+t+" at "+hour+":"+minute+"h"+second+"s:");
setLocation((0.15*screenWidth), (0.15*screenHeight));

//presenting brief stats in the log
Array.getStatistics(tortarray, min, max, mean, stdDev);
print("Mean and SD of \"Tortuosity\" in "+t+" at "+hour+":"+minute+"h"+second+"s:");
print(mean); print(stdDev); selectWindow("Log");
setLocation((0.20*screenWidth), (0.20*screenHeight));

//end of macro
exit;