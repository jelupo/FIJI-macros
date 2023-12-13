//Moss Structures And Cells V4
//2023 Jelle Postma, Romee Groenbos, Radboud University, Netherlands

//input: a stack of TIFF pictures of different FOVs of moss leaves, at 40X mag brightfield
//does: labkit detection of cells and their superstructures, quantification of their amounts
//output: amounts of cells in each stack image, and their respective amounts of sub-cells

//to-do: more parameters of each structure (area, length, circumference, circularity etc.) can be easily added upon request
//to-do: Save individual cell PNGs too? Remove asking for disk locations at the start of macro?

name = getTitle();
ID_main = getImageID();

//ask user for input:
waitForUser("In the next window, choose which Labkit classifier file to use for structures");
path_structures_classifier = File.openDialog("Which Labkit classifier to use?");
waitForUser("In the next window, choose which Labkit classifier file to use for hyaline cells and pores (in structures)");
path_cells_classifier = File.openDialog("Which Labkit classifier to use?");
waitForUser("In the next window, choose a folder to save the resulting images");
path_save = getDirectory("In which directory to save all the output images?");

//preparing to start working on the stack:
getDimensions(width, height, channels, slices, frames);

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
timestamp = d2s(year,0)+"-"+d2s(month,0)+"-"+d2s(dayOfMonth,0)+", "+d2s(hour,0)+"h"+d2s(minute,0)+"m"+d2s(second,0)+"s";
print(""); print("Macro run at " + timestamp);
print("Result images saved in: ");
print(path_save); print("");

//working on the stack:
for (k = 0; k < slices; k++) {

	selectImage(ID_main);
	Stack.setSlice(k+1);
	run("Duplicate...", "use");
	
	ID_slice = getImageID;
	subname = getTitle;

	run("Calculate Probability Map With Labkit", "segmenter_file=[" + path_structures_classifier + "] use_gpu=false");
	run("Duplicate...", "duplicate channels=1");
	ID_prob = getImageID;
	name_prob = getTitle;
	
	setThreshold(0.5, 1);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	
	run("Set Measurements...", "area bounding shape feret's redirect=None decimal=3");
	
	roiManager("reset");
	run("Analyze Particles...", "size=10-Infinity show=Outlines display exclude clear include add");
	
	//We have a tabel with each cel and its area (in um2) feret (longest diameter), minferet (shortest diameter) + a list of objects (ROI manager)
	structures_no = roiManager("count");
	
	//Here we can calculate the area, smallest and widest diameter etc. 
	// For now we took it out because the pictures are not good enough and we want to train the classifier better (also for the pores)
	
	//selectWindow("Results");
	//cells_area = newArray();
	//cells_minferet = newArray();
	//cells_feret = newArray();
	
	//cells_area = Table.getColumn("Area");
	//cells_minferet = Table.getColumn("MinFeret");
	//cells_feret = Table.getColumn("Feret");
	
	if (structures_no == 0) {exit("no cells!");}
	
	close("Results");
	
	cells_no = newArray();
	
	//saving a PNG outlining detected structures
	selectImage(ID_prob);
	roiManager("Show All with labels");
	roiManager("XOR");
	Roi.setStrokeWidth(5); Roi.setStrokeColor("Red");
	run("Flatten");
	saveAs("PNG", path_save + getTitle + ".png");
	close();
	
	//analyzing each structure for cells:
	for (i = 0; i < structures_no; i++) { 
		
		selectImage(ID_slice);
		roiManager("select", i);
		run("Duplicate...", i);
		run("Make Inverse");
		setBackgroundColor(0, 0, 0);
		run("Clear", "slice");
		run("Select None");

		run("Calculate Probability Map With Labkit", "segmenter_file=[" + path_cells_classifier + "] use_gpu=false");
		
		run("Duplicate...", "duplicate channels=2");
		run("Gaussian Blur...", "sigma=2");
		setThreshold(0.95, 1);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		
		run("Analyze Particles...", "size=10-Infinity show=Outlines display exclude clear include");
		
		cells_no = Array.concat(cells_no,nResults);
		close("Results");

	}
	
	//Here the data is printed of the amount of structures and the amount of cells per structure
	//this is labeled for which image in the stack the data comes from
	print("Structures in image: " + subname + ":");
	print(structures_no);
	print("Cells in each structure:");
	Array.print(cells_no); //cells_no = pores en hyaline cells (at the moment)
	print(""); //whitespace

}

//tidying up:
run("Close All");
if(isOpen("Log")) {selectWindow("Log");}
