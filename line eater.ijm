//composed by Jelle Postma, Nijmegen, 2022

//macro aims to generate a line profile from a single 8-bit grayscale skeleton (any values >1) on black
//by eating the line starting from the leftmost end,
//and building a memory of the line while it's eating.
//then it measures that sequence in the original and lists everything.

//it depends on having 1 skeleton line in the picture


print("Working...");
selectWindow("Log");
setLocation(0.05 * screenWidth, 0.05 * screenHeight);

setBatchMode(true);

name = getTitle; 
run("Duplicate...", "title=temp_copy");
setBatchMode("show");

run("Manual Threshold...", "min=1 max=255"); //threshold, make binary
setOption("BlackBackground", false); run("Convert to Mask"); 
run("Create Selection"); 

//store roi-contained points X,Y in arrays
Roi.getContainedPoints(xpoints, ypoints);
run("Select None");
series = newArray(); //for use in plot

//prepare two X,Y arrays for filling with ordered XYs
xordered = newArray(); yordered = xordered;

//preparing edge coordinates
edgex = newArray(); edgey = edgex;

//go through all of the points and find the two with only one neighbour (the edges)
for (i = 0; i < xpoints.length; i++) {
	series[i] = i;
	makePoint(xpoints[i], ypoints[i]); //select a point in the line-area
	run("Enlarge...", "enlarge=1"); //make 3x3
	if (getValue("Mean") < 70) { //if this is an end of the line the 3x3 has 2 and not 3 pixels white		
		if (edgex.length == 0) { //the current coordinates are the first found end
			edgex[0] = xpoints[i];
			edgey[0] = ypoints[i];
		}
		else { //the current coordinates are the second found end
			edgex[1] = xpoints[i];
			edgey[1] = ypoints[i];
			break; //stop the loop when both ends were found
		}
	}
}

run("Select None");

//put the topleftmost end of line as the first entry in the final line coordinates array
if (edgex[0] == edgex[1]) {xordered[0] = edgex[0]; yordered[0] = Array.findMinima(edgey, 0);} //if points are above eachother, choose the highest one
if (edgey[0] == edgey[1]) {yordered[0] = edgey[0]; xordered[0] = Array.findMinima(edgex, 0);} //if points are on the same horizontal, choose the left one
if (edgex[0] < edgex[1]) {xordered[0] = edgex[0]; yordered[0] = edgey[0];} //if first detected edge is left of the second, select the first
else {xordered[0] = edgex[1]; yordered[0] = edgey[1];} //otherwise select the second

//do 3x3 searching around the starting pixel, looking for the next white pixel
//using getpixel vs. current getpixel comparisons (+1/-1 nested for loops)
//if found, grab those coordinates as target for the next iteration

for (i = 0; i < xpoints.length; i++) {
	for (j = -1; j < 2; j++) { 
		for (k = -1; k < 2; k++) {	
			if (getPixel(xordered[i] + j, yordered[i] + k) > 0) { //if a white pixel is found, use the current grid position j,k for:			
				if (j == 0 && k == 0) { //if the white pixel is the current one, make it black
					setPixel(xordered[i], yordered[i], 0);
				}			
				else { //or it was the actual next pixel, so make it the next target
					xordered[i+1] = xordered[i] + j; 
					yordered[i+1] = yordered[i] + k;
				}
			}
		}
	} 
} 

//all of the line's pixel coordinates were registered in order

close("temp_copy");
selectWindow(name);
intensities = newArray();

for (i = 0; i < xordered.length; i++) { //measuring each pixel in order	
	intensities[i] = getPixel(xordered[i],yordered[i]);
}

//presenting results
Table.create("Line profile of: " + name);
Table.setColumn("X", xordered);
Table.setColumn("Y", yordered);
Table.setColumn("Intensity", intensities);

Plot.create("Line profile of: " + name, "position (px)", "intensity", series, intensities);
Plot.setLimits(0, series.length, 0, 255);
Plot.setStyle(0, "red,none,2.0,Line");

setBatchMode(false);

print("Done!");
selectWindow("Log");

exit;




















