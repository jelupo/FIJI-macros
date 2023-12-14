//move mouse across the image


r = 0; //framerate in ms
clock = 0; //init clock


//create scene
run("Close All"); newImage("New", "8-bit Black", 100, 100, 1);
run("smart");
for (i = 0; i < 4; i++) {run("In [+]"); wait(10);}

//init variables
x_locs = newArray(); 
y_locs = newArray(); 
ints = newArray(); 
ages = newArray();
wobble = 0.5; //wobble chance 0-1

while (true) { //do this every frame
	
	//reset screen
	for (i = 0; i < getWidth; i++) {
		for (j = 0; j < getHeight; j++) {
			setPixel(i, j, 0); //blacken
		}
	}

	//grab cursor
	getCursorLoc(mouse_x, mouse_y, mouse_z, mouse_flags);
	
	//override cursor because why not
	//mouse_x = 50 - (sin(clock/113) * sin(clock/50) * cos(clock/100)) * 30; //simple circle
	//mouse_y = 80 - sin(clock/200) * 10;
	//mouse_y = 50 - cos(clock/100) * 30;
	//mouse_x = 50 + (sin(clock/102) * sin(clock/216) * cos(clock/12)) * 40; //convoluted pattern
	//mouse_y = 50 - (cos(clock/107) * cos(clock/31) * sin(clock/7)) * 40;
	
	//create things
	x_locs = Array.concat(x_locs, mouse_x + ((random * 3) - 1.5));
	y_locs = Array.concat(y_locs, mouse_y + ((random * 3) - 1.5));
	ints = Array.concat(ints, (10 + (random * 100)));
	ages = Array.concat(ages, 0);
	
	//age and animate things
	for (i=0; i<x_locs.length; i++) { //go through all objects
		ages[i] = ages[i] + 0.5;
		ints[i] = ints[i] - 0.3;{
		
		if (random > 1-wobble) { //sometimes adjust their x location
			if (random > 0.5) {
				x_locs[i] += 0.5;
				} else {x_locs[i] -= 0.5;}
			}
		if (random > 1-wobble) { //sometimes adjust their y location
			if (random > 0.5) {
				y_locs[i] += 0.5;
				} else {y_locs[i] -= 0.5;}
			}
		
		p_dim = 1 + random;
		for (k=-p_dim; k<p_dim; k++) { //draw squares on them
			for (l=-p_dim; l<p_dim; l++) {
				setPixel(x_locs[i]+k, y_locs[i]+l, (getPixel(x_locs[i]+k,y_locs[i]+l) + ints[i]));
				}
			}
		}
	}
	
	for (i=0; i<x_locs.length; i++) { //clean up old and dead items
		if (ages[i] >= 500 || ints[i] <= 0) {
			x_locs = Array.deleteIndex(x_locs, i);
			y_locs = Array.deleteIndex(y_locs, i);
			ints = Array.deleteIndex(ints, i);
			ages = Array.deleteIndex(ages, i);
			}
		y_locs[i] = y_locs[i]-0.3; //move all items up
		}

	//end of loop routine
	updateDisplay();
	wait(r);
	if (mouse_flags == 16 || mouse_flags == 1) exit;
	if (clock <= 1e8) {clock++;} else {clock = 0;}
	}

exit;

