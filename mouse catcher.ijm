

f = 0; //initialize clock
r = 100; //framerate in ms
xypos = newArray(25,25);
mouse = newArray(0,0);
catchable = 0;

run("Close All"); newImage("New", "8-bit Black", 50, 50, 1); //new game
for (i = 0; i < 7; i++) run("In [+]"); wait(10); //scale up to reasonable size

while (true) { //every frame
	
	Color.set("Black");
	fill();
	
	getCursorLoc(mouse[0], mouse[1], z, flags); //register cursor info
	vector = newArray(0,0); //set speed to 0
	
	for (i = 0; i < 2; i++) { //adjust velocity
		if (mouse[i] > xypos[i]) vector[i] = 1;
		if (mouse[i] < xypos[i]) vector[i] = -1;
		}
	
	xypos[0] = xypos[0] + vector[0]; //update positions
	xypos[1] = xypos[1] + vector[1];
	
	if (xypos[0] < 0) xypos[0] = 0; //keep position within image
	if (xypos[1] < 0) xypos[1] = 0; 
	if (xypos[0] > getWidth) xypos[0] = getWidth; 
	if (xypos[1] > getHeight) xypos[1] = getHeight;

	setPixel(xypos[0], xypos[1], 255);
	updateDisplay(); //draw
	
	if (xypos[0] == mouse[0] && xypos[1] == mouse[1]) { //catch player
		print("Caught you at " + xypos[0] + "," + xypos[1]);
		break;
	}

	wait(r); //wait for framerate
	mouseprev = mouse;
	if (flags==16||flags==1) break; //exit upon click
	if (f<10e5) f++; else f=0; //progress clock with reset
	}

exit






