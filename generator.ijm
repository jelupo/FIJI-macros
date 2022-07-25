// a simple random pattern generator, run in FIJI

// functions

function generate(a,b,c,d) {
	
	if (a <= 0 || b < 0) {
		exit;
		}
		
	newImage("noise", "8-bit black", d, d, 1);
	
	for (i = 0; i < a; i++) {
		run("Add Noise");
		run("Gaussian Blur...", "sigma=2");
		}

	for (i = 0; i < b; i++) {
		run("Duplicate...", " ");
		run("Add Noise");
		run("Gaussian Blur...", "sigma=1");
		}

	run("Images to Stack", "name=substack title=noise");
	
	for (i = 1; i <= nSlices; i++) {
    	setSlice(i);
		run("Bandpass Filter...", "filter_large=40 filter_small=3 suppress=None tolerance=5 autoscale saturate");
		run("Kuwahara Filter", "sampling=9 slice");
		run("Mean...", "radius=1");
		run("Gaussian Blur...", "sigma=2");		
		}

	run("Z Project...", "projection=[Sum Slices]");
	run("16-bit");
	run(c);
	run("Enhance Contrast", "saturated=0");
	rename(-getImageID());
	close("substack");
	
	return (-getImageID());
	}

function messup(image) {
	
	selectWindow(image);
	run("Morphological Filters", "operation=Gradient element=Square radius=12");
	run("Maximum...", "radius=2");
	rename("current_" + -getImageID());
	}

function make_multiple(n,o,p,q) {
	
	for (i = 0; i < n; i++) {
		messup(generate(o,p,"ICA",q));
		setBatchMode("show");
		run("Enhance Contrast", "saturated=0");
		}
	}

function present_final(type) {
	
	if (type == "tile") {
		run("Tile");
		}
	
	if (type == "stack") {
		run("Images to Stack", "name=stack title=current");
		w = 0.5 * getWidth();
		h = 0.5 * getHeight();
		l = nSlices;
		run("Set... ", "zoom=200 x=&w y=&h");
		//run("Animation Options...", "speed=1 first=1 last=&l start");
		}
	}
	
// main
	
setBatchMode(true);
	
	run("Close All");
	make_multiple(2,50,100,500);  // #outputs, rounds1, rounds2, size

setBatchMode(false);
