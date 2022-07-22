//this macro works on the active image (last selected image)
//it allows you to draw a line, preview the length stamp, and release the mouse to stamp it.
//it generates a copy (RGB) of the image when stamping, so you can add more by running the macro again
//or close the latest image to go one step back if you made a mistake
//it uses the image's scaled units (eg. nanometers) if available, otherwise it uses pixels
//the text avoids being cut off by the edge of the image

//some global parameters you can change
linecolor = "#fffc8b";
textcolor = "orange";
linewidth = 8;

//macro starts here
if (nImages==0){exit("No images found!");}
run("Enhance Contrast...", "saturated=0");
waitForUser("Click and drag to start a line, release to stamp it. \nPress OK to begin.");

//initializing pixel size and text size
getVoxelSize(w, h, d, unit);
setFont("Sanserif", 24);
setColor(textcolor);

//activate the line tool
setTool(4);

//waiting for user to start the line
while (true) {
	
	getCursorLoc(x, y, z, flags);
	if (flags==16) {break}
	wait(10);
	}	

//previewing the length stamp and waiting for mouse release
while (true) {
	
	getCursorLoc(x, y, z, flags);
	xstr=d2s(getValue("Length"),0); 
	xstr+=" "+unit;
	str=lengthOf(xstr);
	if ((getHeight()-y)<30) {y-=30;}
	if ((getWidth()-x)<(15*str)) {x-=(15*str);}
	Overlay.clear;
	Overlay.drawString(xstr, x+10, y+20);
	Overlay.show;
	getCursorLoc(x, y, z, flags);
	if (flags==32||flags==0) {break}
	wait(10);
	}

//stamping the actual information
Overlay.setStrokeWidth(linewidth);
Overlay.addSelection(linecolor);
run("Select None");
Overlay.hide;

//generating a new RGB-image, adding the stamp
Overlay.flatten;

//exiting macro
exit
