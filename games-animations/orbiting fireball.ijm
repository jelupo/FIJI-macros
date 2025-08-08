//2022 Jelle Postma
//macro presents an orbiting fireball when executed
//can be switched to mouse behavior. click screen to stop
//studying how well you can simulate stuff by get/setpixel

run("Close All"); newImage("New", "8-bit black", 50, 50, 1); run("smart");

for (i = 0; i < 7; i++) {run("In [+]"); wait(20);} //scale up to see pixels

f = 0; //initialize clock
r = 1; //min. framerate in ms
x = 0; xprev = 0;
y = 0; yprev = 0;

pixelsx = newArray();
pixelsy = newArray();
pixelsi = newArray();

while (true) {
	
	getCursorLoc(x, y, z, flags);

	//decay	pixels
	for (h=0; h < getHeight; h++) for (w = 0; w < getWidth; w++) {
		setPixel(w, h, (getPixel(w, h) - 1));
	}
				
		//draw new pixels if mouse moved
		//if (x != xprev || y != yprev) {
			
			//set pixels and intensities to draw
			//pixelsx[0] = x + ((random * 6)-3); //array with x coordinates
			//pixelsy[0] = y + ((random * 6)-3); //array with y coordinates
			//pixelsi[0] = 255; //array with intensities
			
			//draw pixels
			//for (p = 0; p < pixelsx.length; p++) setPixel(pixelsx[p], pixelsy[p], pixelsi[p]);
		//}
	
	//draw new pixels by itself
	pixelsx[0] = (25 + cos(f/120) * 15) + ((random * 6)-3);
	pixelsy[0] = (25 + sin(f/120) * 15) + ((random * 6)-3);
	pixelsi[0] = 255;
	
	pixelsx[1] = (25 + cos(f/120) * 15) + ((random * 6)-3);
	pixelsy[1] = (25 + sin(f/120) * 15) + ((random * 6)-3);
	pixelsi[1] = 255;
	
	for (p = 0; p < pixelsx.length; p++) setPixel(pixelsx[p], pixelsy[p], pixelsi[p]);
	
	//end of frame
	xprev = x; //check mouse movement
	yprev = y;
	updateDisplay();
	
	wait(r); //wait for framerate
	if (flags==16||flags==1) exit; //exit upon click
	if (f<10e5) f++; else f=0; //progress clock with reset

}

exit;










