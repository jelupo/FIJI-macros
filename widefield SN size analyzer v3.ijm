// FIJI macro written by Jelle Postma for Gunnar Lapoutre and Angela Zordan, Feb 2023
// works on "Analysis Gallery" output from Fabrice Cordelieres / Etienne Herzog on two- or three-channel widefield images of synaptosomes
// uses the user-annotated output image (the TIF in Analysis_Gallery.zip) to pick only particles that are approved, and then gives their size distribution in all available channels (2 or 3)
//
// this macro requires the plugin "Morphology" by Gabriel Landini which can be added in Help -> Update -> Manage Update Sites
//
// v2 = combined results table is generated
// v2.1 = problem fixed where upon flatten, some overlay elements disappeared
// v3 = made macro functional for 3 channel images too
//
// set desired threshold values (in 16-bit range, choose from 0-65535):
// (CH1 = channel 1, CH2 = channel 2, CH3 = channel 3)
// evaluate results in "CH1_MASK"

//threshold values to be used for picking up objects
ch1_threshold = 1000;
ch2_threshold = 1000;
ch2_threshold = 1000;

//register image properties
title = getTitle();
ID = getImageID();
getPixelSize(unit, pixelWidth, pixelHeight);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
Stack.getDimensions(width, height, channels, slices, frames);
time = d2s(hour, 0) + "h" + d2s(minute, 0) + "m" + d2s(second, 0) + "s";

//calculate image dimensions in number of object positions in x and y
x_dimension = width / 64;
y_dimension = height / 64;
x_array = Array.getSequence(x_dimension);
y_array = Array.getSequence(y_dimension);

//transform x and y arrays into actual positional coordinates (pixel location)
for (i = 0; i < x_dimension; i++) { 
	x_array[i] = 32 + 64 * i;
	}
for (i = 0; i < y_dimension; i++) {
	y_array[i] = 32 + 64 * i;
	}

//generate POINTS_MASK image and populate with all possible object positions
newImage("POINTS_MASK", "8-bit black", width, height, 1);
for (i = 0; i < x_dimension; i++) {
	for (j = 0; j < y_dimension; j++) {
		setPixel(x_array[i],y_array[j],255);
	}
}
run("Convert to Mask");

//go to original image, extract channels for later analysis (CH1, CH2):
selectImage(ID);
run("Select None");
Stack.setChannel(1);
run("Duplicate...", "title=CH1 duplicate channels=1");
run("Remove Overlay");
setMinAndMax(0, 65535);

selectImage(ID);
run("Select None");
Stack.setChannel(2);
run("Duplicate...", "title=CH2 duplicate channels=2");
run("Remove Overlay");
setMinAndMax(0, 65535);

if (channels==3) {
	selectImage(ID);
	run("Select None");
	Stack.setChannel(3);
	run("Duplicate...", "title=CH3 duplicate channels=2");
	run("Remove Overlay");
	setMinAndMax(0, 65535);
}

//select original, remove signal to retain overlay colors only, in all channels
selectImage(ID);
Stack.setChannel(1);
run("Select All");
run("Clear", "slice");
Stack.setChannel(2);
run("Select All");
run("Clear", "slice");
run("Select None");

if (channels==3) {
	Stack.setChannel(3);
	run("Clear", "slice");
	run("Select None");
}

//convert to RGB color to fix unexpected disappearing of some overlay elements (crosses)
run("RGB Color");

//flatten original overlay, split into RGB channels, retain only red channel (crosses)
run("Flatten");
title_flat = getTitle();
run("Split Channels");
close(title_flat + " (green)");
close(title_flat + " (blue)");
selectImage(title_flat + " (red)");
rename("FLAT_RED");

//go through all possible object positions and check for red (=cross) in FLAT_RED. 
//If red, remove the point from POINTS_MASK
//also check whether any signal exists in "CH1". If not, exclude the point for analysis (there is no image object there).
for (i = 0; i < x_dimension; i++) {
	for (j = 0; j < y_dimension; j++) {
		selectImage("FLAT_RED");
			if (getPixel(x_array[i], y_array[j]) > 100) {
			selectImage("POINTS_MASK");
			setPixel(x_array[i], y_array[j], 0);
			}
		selectImage("CH1");
			if (getPixel(x_array[i], y_array[j]) == 0) {
			selectImage("POINTS_MASK");
			setPixel(x_array[i], y_array[j], 0);
			}
	}
}
close("FLAT_RED");

//dilate remaining points in POINTS_MASK to make sure they capture any tiny off-center particles later
selectImage("POINTS_MASK");
run("Dilate");

//threshold all channels to obtain masks
selectImage("CH1");
run("Duplicate...", "title=CH1_MASK");
setThreshold(ch1_threshold, 65535, "raw");
run("Convert to Mask");
selectImage("CH2");
run("Duplicate...", "title=CH2_MASK");
setThreshold(ch2_threshold, 65535, "raw");
run("Convert to Mask");

if (channels==3) {
	selectImage("CH3");
	run("Duplicate...", "title=CH3_MASK");
	setThreshold(ch3_threshold, 65535, "raw");
	run("Convert to Mask");
}

//retain only binary objects that are also found in POINTS_MASK
run("BinaryReconstruct ", "mask=CH1_MASK seed=POINTS_MASK create white");
selectImage("Reconstructed");
run("Set Scale...", "distance=1 known=&pixelWidth unit=&unit");
rename("CH1_MASK_FILTERED");

run("BinaryReconstruct ", "mask=CH2_MASK seed=POINTS_MASK create white");
selectImage("Reconstructed");
run("Set Scale...", "distance=1 known=&pixelWidth unit=&unit");
rename("CH2_MASK_FILTERED");

if (channels==3) {
	run("BinaryReconstruct ", "mask=CH3_MASK seed=POINTS_MASK create white");
	selectImage("Reconstructed");
	run("Set Scale...", "distance=1 known=&pixelWidth unit=&unit");
	rename("CH3_MASK_FILTERED");
}

//organising images
selectImage("CH1");
rename("CH1 - " + title);
run("Enhance Contrast...", "saturated=0.01");
selectImage("CH2");
rename("CH2 - " + title);
run("Enhance Contrast...", "saturated=0.01");

if (channels==3) {
	selectImage("CH3");
	rename("CH3 - " + title);
	run("Enhance Contrast...", "saturated=0.01");
}

run("Tile");

//obtain statistics of remaining binary objects
run("Set Measurements...", "area centroid redirect=None decimal=4");

selectImage("CH1_MASK_FILTERED");
run("Analyze Particles...", "  show=Overlay display include");
IJ.renameResults("CH1_SIZE_TABLE");
if (isOpen("CH1_SIZE_TABLE")) {
ch1 = Table.getColumn("X");
ch1_length = lengthOf(ch1);
} else {ch1_length = 0;}

selectImage("CH2_MASK_FILTERED");
run("Analyze Particles...", "  show=Overlay display include");
IJ.renameResults("CH2_SIZE_TABLE");
if (isOpen("CH2_SIZE_TABLE")) {
ch2 = Table.getColumn("X");
ch2_length = lengthOf(ch2);
} else {ch2_length = 0;}

if (channels==3) {
	selectImage("CH3_MASK_FILTERED");
	run("Analyze Particles...", "  show=Overlay display include");
	IJ.renameResults("CH3_SIZE_TABLE");
	if (isOpen("CH3_SIZE_TABLE")) {
	ch3 = Table.getColumn("X");
	ch3_length = lengthOf(ch3);
	} else {ch3_length = 0;}
} else {ch3_length = 0;}

//do sorting:
run("Set Measurements...", "area centroid redirect=None decimal=4");
selectImage("POINTS_MASK");
run("Analyze Particles...", "  show=Overlay display include");
IJ.renameResults("POINTS_TABLE");
points_X = Table.getColumn("X");
points_Y = Table.getColumn("Y");
length = lengthOf(points_X);
points_indices = Array.getSequence(length);

for (i = 0; i < length; i++) {
	points_indices[i]++;
}

run("BinaryReconstruct ", "mask=POINTS_MASK seed=CH1_MASK_FILTERED create white");
if (isOpen("Reconstructed")) {
selectImage("Reconstructed");
rename("CH1_POINTS");
run("Analyze Particles...", "  show=Overlay display include");
IJ.renameResults("CH1_POINTS_TABLE"); 
}

run("BinaryReconstruct ", "mask=POINTS_MASK seed=CH2_MASK_FILTERED create white");
if (isOpen("Reconstructed")) {
selectImage("Reconstructed");
rename("CH2_POINTS");
run("Analyze Particles...", "  show=Overlay display include");
IJ.renameResults("CH2_POINTS_TABLE");
}

if (channels==3) {
	run("BinaryReconstruct ", "mask=POINTS_MASK seed=CH3_MASK_FILTERED create white");
	if (isOpen("Reconstructed")) {
	selectImage("Reconstructed");
	rename("CH3_POINTS");
	run("Analyze Particles...", "  show=Overlay display include");
	IJ.renameResults("CH3_POINTS_TABLE"); 
	}
}

//create combined results table
Table.create("COMBINED_RESULTS");
Table.setColumn("Index", points_indices);
Table.setColumn("X position (px)", points_X);
Table.setColumn("Y position (px)", points_Y);
Table.setColumn("Ch1 size");
Table.setColumn("Ch2 size");
if(channels==3) { Table.setColumn("Ch3 size"); }

if (ch1_length > 0) {
	
	for (i = 0; i < length; i++) {

	X = Table.getString("X", i, "POINTS_TABLE");
	Y = Table.getString("Y", i, "POINTS_TABLE");
	
		for (j = 0; j < ch1_length; j++) {
			selectWindow("CH1_POINTS_TABLE");
			if ((X == Table.getString("X", j)) && (Y == Table.getString("Y", j))) {
				size = Table.getString("Area", j, "CH1_SIZE_TABLE");
				Table.set("Ch1 size", i, size, "COMBINED_RESULTS");
				}
		}
	}
}

if (ch2_length > 0) {
		
	for (i = 0; i < length; i++) {

	X = Table.getString("X", i, "POINTS_TABLE");
	Y = Table.getString("Y", i, "POINTS_TABLE");
	
		for (j = 0; j < ch2_length; j++) {
			selectWindow("CH2_POINTS_TABLE");
			if ((X == Table.getString("X", j)) && (Y == Table.getString("Y", j))) {
				size = Table.getString("Area", j, "CH2_SIZE_TABLE");
				Table.set("Ch2 size", i, size, "COMBINED_RESULTS");
				}
		}
	}
}


if ((channels==3) && (ch3_length > 0)) {
	
	for (i = 0; i < length; i++) {

	X = Table.getString("X", i, "POINTS_TABLE");
	Y = Table.getString("Y", i, "POINTS_TABLE");
	
		for (j = 0; j < ch3_length; j++) {
			selectWindow("CH3_POINTS_TABLE");
			if ((X == Table.getString("X", j)) && (Y == Table.getString("Y", j))) {
				size = Table.getString("Area", j, "CH3_SIZE_TABLE");
				Table.set("Ch3 size", i, size, "COMBINED_RESULTS");
				}
		}
	}
}

//finishing up
print("Macro done!");
selectWindow("Log");
exit;















