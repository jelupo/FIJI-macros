//Jelle Postma, 2022
//
//This is a weird autodrawer / field explorer alrogithm. Run it in FIJI.
//explored a few combinations of functions here
//this macro moves a selection around (or you take control with the mouse), draws a tail based on its speed,
//generates random targets for the selection to pull towards.
//makes a smaller random range when the measured local mean value is low compared to the max in the picture
//gradually blurs the image over time and goes on forever.

// INIT

newImage("Field Explorer 3000", "RGB black", 1000, 1000, 1);
if (nImages==0) {exit("I need an image");}
w = getWidth(); //image width
h = getHeight(); //image height
f = 0; //initialise a clock
r = 1; //ms of frame wait
pos = newArray((0 * w), (0 * h)); //initialise xy position of circle
tar = newArray((0.5 * w), (0.5 * h)); //initialise xy position of target
ping_1 = 0; //intialise a ping timer
ping_1step = 200; //amount of ticks between pings of ping_1

// MAIN

while (true) {
   
    //make the cursor the target (uncomment next line)
    //getCursorLoc(tar[0], tar[1], z, flags);
    
    //get cursor flags only, ignoring xyz values
    getCursorLoc(bla1, bla2, bla3, flags);
   
	//do things here every frame
	if (ping_1 == ping_1step) {Overlay.clear;} //clears the overlay upon ping_1
	
	tar = changing_target_xy(ping_1); //finds a new target upon ping_1
	circle_chasing_targetxy(tar[0], tar[1], f, pos); //sends a circle after the given target
	ping_1++; if (ping_1 > ping_1step) {ping_1 = 0;} //ping_1 step with reset
	f++; if (f > 100000) {f = 0;} //clock step with reset

    //exit the loop upon mouseclick
    if (flags == 16 || flags == 48) {break}
    wait(r);
    }

exit;

// FUNCTIONS

function changing_target_xy(ping_1) {
	
	newtar = Array.copy(tar);

	if (ping_1 != ping_1step) {return newtar;} //escape the loop immediately if there is no ping
	if (ping_1 == ping_1step) { //if there is a ping, first set up a fully random target
		newtar[0] = (random * w);
		newtar[1] = (random * h);
		}
	
	v = random;
	
	if (v > 0.9 || f < ping_1step) {return newtar;} //0.15 chance to prevent a measurement from happening
	
	else { //acquiring measurement-based new target
		
		//it prefers comparatively darker areas by reducing(factor) the "escape area" to be smaller and around the current location
		//stronger preference if local area very dark (pow function)
		//makes intensity measurement normalized to the global max, since it is generally dark at the start
		
		measurefactor = 2;
		feret = getValue("Feret");
		enl = measurefactor * feret; //make temp selection larger if you are small
		run("Enlarge...", "enlarge=&enl");
		mean = getValue("Mean"); //getting regional mean
		
		//printing green circle of measured range
		col = rgb_to_hex(mean, 100, 0);
		Overlay.addSelection(col, 2);
		
		//getting global max and calculating differences
		run("Select None");
		max = getValue("Max"); //getting global max
		relmean = mean / max; //mean relative to max, factor 0-1
		pref = pow((1-relmean), 3); //preference factor 0-1 ie. how narrow to make the random. only when really dark does it go up
														
		//new random range should be at least 60, up to w, and 60 up to h
		minrange = 60;
		rangex = w - pref * (w-minrange);
		rangey = h - pref * (h-minrange);
		
		//new random coordinates must be around position and not out of bounds
		placex = (random * rangex);	placex = pos[0]+(placex - (0.5*rangex)); if (placex<0) {placex = 0;} if (placex>w) {placex = w;}
		placey = (random * rangey);	placey = pos[1]+(placey - (0.5*rangey)); if (placey<0) {placey = 0;} if (placey>h) {placey = h;}
		
		newtar[0] = placex;
		newtar[1] = placey; 

		//printing labels and red circle
		setFont("SansSerif", 32, "bold"); setColor("red");
		Overlay.drawString(round(rangex), pos[0], pos[1]);
		setFont("SansSerif", 18, "plain");
		Overlay.drawString("RANGE", pos[0] + 5, pos[1] + 30);
		prepx = pos[0]; prepy = pos[1];
		run("Specify...", "width=&rangex height=&rangey x=&prepx y=&prepy oval centered");
		run("Gaussian Blur...", "sigma=1");
		Overlay.addSelection("red", 3);	
		setColor(50,150,50); setFont("SansSerif", 18, "plain");
		Overlay.drawString("SCOPE", pos[0]-70, pos[1] + 30);		
		
		//print to debug
		print("");
		print("measurement decision at f = " + f + ":");
		print("random: " + v);
		print("enl: " + enl);
		print("mean: " + mean);
		print("max : " + max);
		print("relmean: " + relmean);
		print("pref: " + pref);
		print("range: " + rangex);
		print("newx: " + placex); 
		print("newy: " + placey);
	
		return newtar; //giving back the target xy values
		}
	
	}

function circle_chasing_targetxy(tarx, tary, f, pos) { //draws an actual circle, chasing the target xy position
	
	//current-target vectors in x and y
	dx = -pos[0] + tarx; 
	dy = -pos[1] + tary;	
	
	//setting new position in the pos array, with speed factor
	pos[0] = pos[0] + (0.01 * dx); 
	pos[1] = pos[1] + (0.01 * dy); 
	
	//preparing draw values from the pos array
	xdraw = pos[0];
	ydraw = pos[1];

	//expressing the distance to target in 8-bit
	dx = -pos[0] + tarx; dy = -pos[1] + tary;

	vector = sqrt (Math.sqr(dx) + Math.sqr(dy));
	diagmax = sqrt (Math.sqr(w) + Math.sqr(h));
	vectorratio = vector / diagmax;
	vectorbin = 255 * vectorratio;

	//pulsating circle size (either or)
	//s = 40 + 20 * sin (f/10);

	//speed based circle size (either or)
	s = 15 + (60 * vectorratio);
	
	//drawing intensity based on speed
	blue = 10 + 245 * vectorratio;
	setColor(0, 0, blue);
	run("Specify...", "width=&s height=&s x=&xdraw y=&ydraw oval centered");	
	fill();
	
	}

function rgb_to_hex(r, g, b) { //converts rgb values into hexadecimal, eg. for overlay colors

	rhex = toHex(r); if (rhex.length == 1) {rhex = "0" + rhex;}
	ghex = toHex(g); if (ghex.length == 1) {ghex = "0" + ghex;}
	bhex = toHex(b); if (bhex.length == 1) {bhex = "0" + bhex;}
	
	hex = rhex + ghex + bhex;
	
	return hex;
	
	}


