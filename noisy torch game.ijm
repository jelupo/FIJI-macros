//initializing a new game
r = 10; //framerate in ms
min_gray = 20; //background level

run("Close All");
newImage("New", "8-bit Black", 100, 100, 1);
for (i = 0; i < 5; i++) run("In [+]"); wait(50);

setColor(50);
floodFill(0, 0);

//observation with torch
while (true) { //every frame

	getCursorLoc(mouse_x, mouse_y, mouse_z, mouse_flags);
	
	//mouse_x = random * getWidth;
	//mouse_y = random * getHeight;
	
	for (y = 0; y < getHeight; y++) {
		for (x = 0; x < getWidth; x++) {
			dist = sqrt(Math.pow((x - mouse_x),2) + Math.pow((y - mouse_y),2));
			int = min_gray + ((255 - min_gray) - 15 * dist);

			setPixel(x, y, int);
		}
	}
	
	run("Add Noise");
	updateDisplay();
	wait(r);
	
	if (mouse_flags==16||mouse_flags==1) break; //exit upon click

	}

exit;

