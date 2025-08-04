//2025-03 Marije Been, Jelle Postma, General Instrumentation, Radboud Universiteit, Netherlands
//This macro requires a folder of confocal stacks with either 1 or 2 channels and ROI.zip files for each image, outlining some cells at arbitrary Z slices and XY positions, named identically to the corresponding TIFs.
//This macro also requires 2 trained labkit classifiers to detect spots in either channel.
//The macro then goes through all images, and loops through the user-provided ROIs to capture spots in 2 channels. It enlarges each ROI before labkit analysis to enable labkit to see each pixel's surroundings greater than the sigmas it is configured to use.
//Results are reported and saved as CSV.

//ask user which folder to analyze
	waitForUser("Next, select which folder that contains IMAGES.tiff with matching ROIS.zip files to analyze");
	dir = getDir("Which folder to analyze?");

//ask user which labkit classifiers to use for detecting particles in channels 1 and 2
	waitForUser("Next, choose the Labkit classifier to detect spots in channel 1");
	classifier_path_1 = File.openDialog("Labkit classifier for spots in channel 1");
	
	waitForUser("Next, choose the Labkit classifier to detect spots in channel 2");
	classifier_path_2 = File.openDialog("Labkit classifier for spots in channel 2");
	
//initialize
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timestamp_start = d2s(year,0)+"-"+d2s(month,0)+"-"+d2s(dayOfMonth,0)+", "+d2s(hour,0)+"h"+d2s(minute,0)+"m"+d2s(second,0)+"s";
	run("Clear Results");
	
//gather files
	filelist = getFileList(dir);
	
	//make list of tiffs to analyze
		tifflist = newArray;
		for (i = 0; i < filelist.length; i++) {
			if (endsWith(filelist[i], ".tif") || endsWith(filelist[i], ".tiff")) {
				tifflist = Array.concat(tifflist, filelist[i]);
				}
		}
	
	//make list of roi sets to analyze
		ziplist = newArray;
		for (i = 0; i < filelist.length; i++) {
			if (endsWith(filelist[i], ".zip")) {
				ziplist = Array.concat(ziplist, filelist[i]);
				}
		}

	results_dir = dir + "Results";
	File.makeDirectory(results_dir);
	ch1_particles = 0;
	ch2_particles = 0;
	ch1_and_ch2_particles = 0;

//loop across TIFF files with their associated ZIPs
	for (i = 0; i < tifflist.length; i++) {
		
		//open the current loop's roi-set (zip) and image (tiff)
			roiManager("reset");
			roiManager("Open", dir + ziplist[i]);
			open(dir + tifflist[i]);
			roi_amount = roiManager("count");
			new_original_title = replace(tifflist[i]," ", "_");
			rename(new_original_title); //replacing spaces with underscores to prevent command parsing problems later
		
		//the big analysis:
	
		//if 1 channel only, do particle detection in ROIs and perform statistics
		//if 2 channels, do this for both, and also quantify colocalization between channels in each ROI
			Stack.getDimensions(width, height, channels, slices, frames);
			if (channels == 2) {no_channels = 2;} else {no_channels = 1;}
			
			roi_areas = newArray();
			roi_means = newArray();
		
		//loop across ROIs in the set
			for (r = 0; r < roi_amount; r++) {
		
				//select ROI which goes to the right Z-slice, duplicate it +10 pixel margin (labkit sigma needs 8 px)
					selectWindow(new_original_title);
					roiManager("Select", r);
					Roi.getPosition(channel, slice, frame);
					
					roi_areas[r] = getValue("Area");
					roi_means[r] = getValue("Mean");
					
					run("Enlarge...", "enlarge=10 pixel");
					run("Duplicate...", "title=roi_dupe duplicate channels=1"); //assuming it's the first channel always (in 1 and 2 ch situations)
					run("Select None");
				
				//do labkit on channel 1, obtain particles and get probability map
					run("Calculate Probability Map With Labkit", "segmenter_file=[" + classifier_path_1 + "] use_gpu=false");	
					prob_map_title = getTitle;
					run("Duplicate...", "title=prob_map_dupe duplicate channels=1");
					close(prob_map_title);
		
				//threshold for desired confidence that == particle
					setThreshold(0.7, 1);
					setOption("BlackBackground", true);
					run("Convert to Mask", "background=Dark black");
					
				//clean up and retain thresholded particle stack
					close("roi_dupe");
		
				//recover original ROI (not enlarged) at right position
					Stack.setSlice(slice); //this sets the right slice in the stack (thresholded labkit result)
					roiManager("Select", r);
					Roi.move(10, 10); //correcting ROI position for previously added 10 pixel margin
				
				//delete everything besides the current z-layer and the current actual ROI to prepare for analysis
					run("Make Inverse");
					run("Clear", "stack");
					run("Select None");
					run("Duplicate...", "title=" + new_original_title + "_particle_in_roi_" + r + "_ch1");
					ch1_particles = getTitle();
					
				//obtain statistics
					close("prob_map_dupe");
					run("Set Measurements...", "area centroid shape display redirect=None decimal=3");
					run("Analyze Particles...", "size=10-Infinity pixel display"); //produce results for these particles
					
				//if channel 2 exists, do it again for channel 2 and perform coloc analysis
				if (no_channels == 2) {
					
					//select ROI which goes to the right Z-slice, duplicate it +10 pixel margin (labkit sigma needs 8 px)
						selectWindow(new_original_title);
						run("Select None");
						roiManager("Select", r);
						run("Enlarge...", "enlarge=10 pixel");
						run("Duplicate...", "title=roi_dupe duplicate channels=2"); //assuming it's always the 2nd channel
						run("Select None");
			
					//do labkit on channel 1, obtain particles and get probability map
						run("Calculate Probability Map With Labkit", "segmenter_file=[" + classifier_path_2 + "] use_gpu=false");	
						prob_map_title = getTitle;
						run("Duplicate...", "title=prob_map_dupe duplicate channels=1"); 
						close(prob_map_title);
				
					//threshold for desired confidence that == particle
						setThreshold(0.7, 1);
						setOption("BlackBackground", true);
						run("Convert to Mask", "background=Dark black");
				
					//clean up and retain thresholded particle stack
						close("roi_dupe");
				
					//recover original ROI (not enlarged) at right position
						Stack.setSlice(slice);
						roiManager("Select", r);
						Roi.move(10, 10);
					
					//delete everything besides the current z-layer and the current actual ROI to prepare for analysis
						run("Make Inverse");
						run("Clear", "stack");
						run("Select None");
						run("Duplicate...", "title=" + new_original_title + "_particle_in_roi_" + r + "_ch2");
						ch2_particles = getTitle();
						
					//obtain statistics
						close("prob_map_dupe");
						run("Set Measurements...", "area centroid shape display redirect=None decimal=3");
						run("Analyze Particles...", "size=10-Infinity pixel display"); //produce results for these particles
			
					//COLOCALIZATION: analyze how many red particles are also green using BioVoxxel's binary feature extractor
						run("Binary Feature Extractor", "objects=&ch1_particles selector=&ch2_particles object_overlap=50");
						rename(new_original_title + "_red_particle_also_green_in_roi_" + r + "");
						ch1_and_ch2_particles = getTitle();
						run("Analyze Particles...", "size=10-Infinity pixel display");
						roiManager("Open", dir + ziplist[i]); //because binary feature extractor closes the ROI manager.... for some reason.
						
					} //end of channel 2 + coloc analysis
				
				if (isOpen(ch1_particles)) {close(ch1_particles);}
				if (isOpen(ch2_particles)) {close(ch2_particles);}
				if (isOpen(ch1_and_ch2_particles)) {close(ch1_and_ch2_particles);}
				
				run("Select None");
				
				} //end of ROI loop
			
			if (isOpen(new_original_title)) {close(new_original_title);}
			
			//creating table of ROI results without particle details
				Table.create("ROIs_in_" + new_original_title);
				Table.setColumn("ROI area in um2", roi_areas);
				Table.setColumn("ROI mean gray value", roi_means);
				Table.save(results_dir + File.separator + "ROIs_in_" + new_original_title + "_at_" + timestamp_start + ".csv");
				if (isOpen("ROIs_in_" + new_original_title)) {close("ROIs_in_" + new_original_title);}
			
		} //end of TIFF loop
		
//save results as csv table in new subfolder in the tiff images folder

	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timestamp = d2s(year,0)+"-"+d2s(month,0)+"-"+d2s(dayOfMonth,0)+", "+d2s(hour,0)+"h"+d2s(minute,0)+"m"+d2s(second,0)+"s";
	
	if(isOpen("Results")) {
		
	//saving results table
		no_results = false;
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		selectWindow("Results");
		saveAs("Results", results_dir + File.separator + "All_images_particles_results_at_" + timestamp_start + ".csv");
		if (isOpen("Results")) {close("Results");}
		if (isOpen("ROI Manager")) {close("ROI Manager");}
		} else {no_results = true;}

//reporting back when done
	print("started at " + timestamp_start);
	print("finished at " + timestamp);
	if (no_results == false) {print("results saved in " + results_dir);}
	else {print("no results");}
	
	exit;
	
	
