//Jelle Postma, 2022

//this macro should generate lightning that follows your mouse cursor
//run it in FIJI


//run("Close All");
run("Select None");
setTool("rectangle");

newImage("Untitled", "8-bit black", 512, 512, 1);
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);

diagonal = Math.sqrt(Math.sqr(getWidth) + Math.sqr(getHeight));
npoints = 7;
linewidth = 200; //chungal factor
drag = 20; //amount of pixels to move the mouse to trigger a draw
framewait = 100; //amount of ms to wait at the end of each draw


drawing_loop(0,0,npoints); //maybe put the looping part over here, to control live variables
exit;


function drawing_loop(xstart,ystart,points) {

	x1 = xstart;
	y1 = ystart;
	draw = false;
	setColor("white");

	while (true) { //drawing loop, when mouse moves around
	   
	    getCursorLoc(x, y, z, flags);
	    distance = Math.sqrt(Math.sqr(x) + Math.sqr(y));
	    
	    if (draw == true) {
		   
		    //getting the draw possibility space
		    run("Select None");
		    makeLine(1,1,x,y); //initial line from 1,1 to cursor
		    Roi.setStrokeWidth(linewidth); //chungify the line
		    Roi.setStrokeColor("black"); //emblacken the line (cyan = debug, black = final)
		    Roi.getContainedPoints(xpoints, ypoints); //seems to work on chungus line
		    run("Select None");
			
			//make five points within chungus and put their x and y values in ascending order
			pointsx = newArray();
			pointsy = newArray();		
			
			for (i = 0; i < points; i++) { //make the points randomly within the possibility space
				randominlist = round(random * xpoints.length) -1;
				if (xpoints[randominlist] >= 0) {
					pointsx[i] = xpoints[randominlist];} 
					else {pointsx[i] = -xpoints[randominlist];}
				if (ypoints[randominlist] >= 0) {
					pointsy[i] = ypoints[randominlist];} 
					else {pointsy[i] = -ypoints[randominlist];}
				}	
			
			pointsx = Array.sort(pointsx);
			pointsy = Array.sort(pointsy);
			
			for (i = 0; i < points; i++) { //adjust the arrays here so the highest values move closer to mouse	
				
				factorx = minOf(pointsx[i],x) / x;
				factory = minOf(pointsy[i],y) / y;
				
				//print(factorx); //debug
				//print(factory);
				//print(pointsx[i]);
				//print(pointsy[i]);
				
				pointsx[i] = pointsx[i] + (factorx * (x-pointsx[i]));
				pointsy[i] = pointsy[i] + (factory * (y-pointsy[i]));
			
				} //this adjusted each value to be closer to the mouse the closer they were to the mouse.
			
			for (i = 0; i < points; i++) {
				setPixel(pointsx[i],pointsy[i],255);
				}
			
			run("Select None");
			
			makeLine( //making a thin line through 5 points starting at 0
				0,0,	
				pointsx[0], pointsy[0],
				pointsx[1], pointsy[1],
				pointsx[2], pointsy[2],
				pointsx[3], pointsy[3],
				pointsx[4], pointsy[4],
				pointsx[5], pointsy[5],
				pointsx[6], pointsy[6]
				); // big problem here: can't make a segmented line of arbitrary length (Arrays..) because each xy has to be specified

	    	
	    	//draw the line:
	    	Roi.setStrokeColor("black");
	    	Roi.setStrokeWidth(5);
			run("Draw");
	    	run("Select None");	
	    	}	
		
		//for draw upon cursor moves far enough
		//if ((abs(x - x1) > drag)||(abs(y - y1) > drag)) 
		//{draw = true; x1 = x; y1 = y;} 
		//else {draw = false;}
		
		//for draw upon any movement
		if (x1 != x || y1 != y) {draw = true;} 
		else {draw = false;} 
		x1 = x; y1 = y;
	
		//pixel decay
		//using apply global threshold or something? not individual pixels...
				run("Apply LUT");
		setMinAndMax(0, 300);

		
		//exiting macro when user clicks the image
	    if (flags==16) {exit;} 
	   	else {wait(framewait);}
	    }  
	}


exit;
