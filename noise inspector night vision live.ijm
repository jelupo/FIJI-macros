// Jelle Postma

// run this in FIJI
// move the mouse over the blue window to simulate a "night vision" Zoomed-In view of the bigger area in the other image

//init
run("Close All");
world_size = 500;
game_size = 51;

//position of game window (top left corner) relative to world 0,0
xpos = 128; //starting value. make mouse or other user input dependent!
ypos = 145;

//making the world:
//new world with upscaled noise
newImage("world", "8-bit Black", (world_size * 0.1), (world_size * 0.1), 1);

run("Add Noise");
run("Size...", "width=&world_size height=&world_size depth=1 constrain average interpolation=None");

//make world arrays
world_x_array = newArray();
world_y_array = newArray();
world_i_array = newArray();

//register pixels of world
k = 0;
for (i = 0; i < world_size; i++) {
	for (j = 0; j < world_size; j++) {
		world_x_array[k] = i;
		world_y_array[k] = j;
		world_i_array[k] = getPixel(i, j);
		k++;
		}
} 
//close("world");

//preparing the explorer ame:
game_x_array = newArray();
game_y_array = newArray();
game_i_array = newArray();

k = 0;
for (i = 0; i < game_size; i++) {
	for (j = 0; j < game_size; j++) {
		game_x_array = Array.concat(game_x_array, i); //register current position into the arrays to fill them.
		game_y_array = Array.concat(game_y_array, j);
		k++;
		}
}

//actual while loop to live-view the game
//new 100x100 image
newImage("New", "8-bit Black", game_size, game_size, 0);
for (i=0;i<3;i++) {run("In [+]"); wait(50);}
run("royal");

while(true) {
	getCursorLoc(x, y, z, flags);
	xpos = round((x / game_size) * world_size);
	ypos = round((y / game_size) * world_size);	
	
	//go through world and retrieve AND draw values (WORKS BEST IN ACTUAL WHILE LOOP)
	l = 0;
	for (k = 0; k < world_i_array.length; k++) {
		if (world_x_array[k] >= xpos) { 
			if (world_x_array[k] < xpos + getWidth) {
				if (world_y_array[k] >= ypos) {
					if (world_y_array[k] < ypos + getHeight) {
						game_i_array[l] = world_i_array[k]; //go through world reference, add the right pixel to the game
						game_x_array[l] = world_x_array[k] - xpos;
						game_y_array[l] = world_y_array[k] - ypos;
						setPixel(game_x_array[l], game_y_array[l], world_i_array[k]); //draw the pixel here too (setpixel)?
						l++;  
					}
				}
			}
		}
	}
	
	updateDisplay();
	wait(0);
	if (flags==1||flags==16) exit("Exit (user clicked)");

}

//go through world and retrieve values (use modulo?);
updateDisplay();


//DEPRECATED/SCAFFOLDED

//pixel draw loop attempt. go through world and retrieve values (works slowly)
//for (k = 0; k < world_i_array.length; k++) {
//	if (world_x_array[k] >= xpos && world_x_array[k] < xpos + getWidth && world_y_array[k] >= ypos && world_y_array[k] < ypos + getHeight) {
//	game_i_array = Array.concat(game_i_array, world_i_array[k]); //go through world reference, add the right pixel to the game
//	}
//}

//go through world and retrieve values (works faster) nested for loops
//for (k = 0; k < world_i_array.length; k++) {
//	if (world_x_array[k] >= xpos) { 
//		if (world_x_array[k] < xpos + getWidth) {
//			if (world_y_array[k] >= ypos) {
//				if (world_y_array[k] < ypos + getHeight) {
//					game_i_array = Array.concat(game_i_array, world_i_array[k]); //go through world reference, add the right pixel to the game
//				}
//			}
//		}
//	}
//}
//
//draw them
//k = 0;
//for (i = 0; i < getWidth; i++) {
//	for (j = 0; j < getHeight; j++) {
//		setPixel(i,j,game_i_array[k]); //actually draw this pixel too
//		k++;		
//		}
//	}

//go through world and retrieve AND draw values (works.. intermediately? but best in actual final while loop)
//l = 0;
//for (k = 0; k < world_i_array.length; k++) {
//	if (world_x_array[k] >= xpos) { 
//		if (world_x_array[k] < xpos + getWidth) {
//			if (world_y_array[k] >= ypos) {
//				if (world_y_array[k] < ypos + getHeight) {
//					game_i_array[l] = world_i_array[k]; //go through world reference, add the right pixel to the game
//					game_x_array[l] = world_x_array[k] - xpos;
//					game_y_array[l] = world_y_array[k] - ypos;
//					setPixel(game_x_array[l], game_y_array[l], world_i_array[k]); //draw the pixel here too (setpixel)?
//					l++;  
//				}
//			}
//		}
//	}
//}



//get exactly the right intensity from world arrays using MODULO (%)
//picture left and right have influence. picture height should be repeats for grabbing lines like that
//picture top and bottom have incluence. picture width should be repeats for grabbing top and bottoms
//for(i=0; i<getWidth; i++) {
//	for(j=0; j<getHeight; j++) {
//		x = world_i_array[i + (j * world_size)]
//		y = (+ j //offset in y)
//	
//		setPixel(i, j, world_i_array[k]);
//		k++;
//	}
//}









exit;







