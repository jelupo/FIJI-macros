// INIT

setBatchMode(true);

//initializing values
size = 50; //grid size in number of tiles per side
pixels = 500; //picture scale in pixels per side
textscale = 0.5; //text size compared to grid size

//generating black canvas
run("Close All");
close("Log");
newImage("testimage", "8-bit black", pixels, pixels, 1);

//making numerically ascending arrays for each side (0 to n-1)
xpos=newArray(size); for(i=0;i<size;i++) {xpos[i]=i;} ypos=xpos;

//calculating length of the full series of tiles
length = Math.sqr(size);
width = getWidth();
height = getHeight(); 

//marking pixel positions of the topleft corner of each tile
coord = newArray(size); for(i=0;i<size;i++) {coord[i]=width*(i/size);}

//making rois
if (isOpen("ROI Manager")) {close("ROI Manager");}
roisize = width/size;
for (i=0;i<size;i++) {y=coord[i];
	for (j=0;j<size;j++) {x=coord[j];
		run("Specify...", "width=&roisize height=&roisize x=&x y=&y");
		Roi.setProperty("x", j);
		Roi.setProperty("y", i);
		roiManager("add");
		}
	}

//MAIN

//looping through the ROIs to make random binary
for (i = 0;i<roiManager("count");i++) {
	roiManager("select", i);
	grid_random_binary((Roi.getProperty("x")), (Roi.getProperty("y")));
	}

//doing a mean filter (see function)
mean_filter(2);

//end of macro
setBatchMode(false);
setLocation(150, 150);
exit;

//FUNCTIONS

//making the ROIs random binary, text optional. takes grid coordinates
function grid_random_binary(gridx,gridy) {
	
	Roi.getBounds(roix, roiy, roiwidth, roiheight);
	r = random("gaussian");
	if(r>0){setColor("white");}else{setColor("black");}	fill();
	//if(r<0){setColor("white");b=1;}else{setColor("black");b=0;}
	//setFont("SansSerif", textscale*(pixels/size));
	//drawString(getValue("Max"), roix, roiy+roiheight);
	run("Select None");
	}

//mean filter for regions, uses ROI manager for intermediate image
function mean_filter(factor) {
	
	temparray = newArray(roiManager("count"));
	
	for (i=0;i<roiManager("count");i++) {
		roiManager("select", i);
		enlarge = factor*getValue("Width");
		run("Enlarge...", "enlarge=&enlarge");
		temp = getValue("Mean");
		temparray[i]=round(temp);
		}
		
	for (i=0;i<roiManager("count");i++) {
		roiManager("select", i);
		setColor(temparray[i]);
		roiManager("select", i);
		fill();
		}
	
	run("Select None");	
	}

//Roi.setProperty(key, value)
//Adds the specified key and value pair to the selection properties. 
//Assumes a value of "1" (true) if there is only one argument. 