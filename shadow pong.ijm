//shadow pong: predict the path!
//jelle postma, 2023

//to do: 5 consecutive hits grants enemy weakness (with messages on screen)
//to do: paddle y-velocity transfer to ball, ball bleeding y-velocity over time until normal y

//init game
r = 12; //framerate in ms
min_gray = 20; //background level

//create scene
run("Close All"); newImage("New", "8-bit Black", 100, 100, 1);
for (i = 0; i < 5; i++) run("In [+]"); wait(50);
setColor(min_gray);
floodFill(0, 0);

//init colors
paddle_color = 240;
ball_color = min_gray;
textcolor = "orange";
setFont("Sanserif", 15);
setColor(textcolor);

//init variables
paddle_height = 20; paddle_width = 5;
ball_x = 0.5 * getWidth; ball_y = 0.5 * getHeight;
ball_width = 5; ball_height = 5;
ball_x_vel = -1; ball_y_vel = 1;
score_l = 0; score_r = 0;
paddle_2_y = 10;

while (true) { //do this every frame
	
	//reset screen
	for (i = 0; i < getWidth; i++) {
		for (j = 0; j < getHeight; j++) {
			setPixel(i, j, min_gray); //blacken
		}
	}

	//grab cursor
	getCursorLoc(mouse_x, mouse_y, mouse_z, mouse_flags);
	
	//draw left paddle
	if (mouse_y <= 0.5 * getHeight) paddle_1_y = maxOf(10, mouse_y); //enforce wall boundaries
	if (mouse_y > 0.5 * getHeight) paddle_1_y = minOf(getHeight - 10, mouse_y);
	
	for (i = -(0.5 * paddle_height); i < (0.5 * paddle_height); i++) {
		for (j = 0; j < paddle_width; j++) {
			setPixel(j, paddle_1_y + i, paddle_color);
			}
		}
	
	//draw right paddle, could smoothen movement...
	if (ball_y <= 0.5 * getHeight) paddle_2_y = maxOf(10, ball_y); //enforce wall boundaries
	if (ball_y > 0.5 * getHeight) paddle_2_y = minOf(getHeight - 10, ball_y);

	for (i = -(0.5 * paddle_height); i < (0.5 * paddle_height); i++) {
		for (j = -paddle_width; j < paddle_width; j++) {
			setPixel(j + getWidth, paddle_2_y + i, paddle_color);
			}
		}
	
	//move ball
	Overlay.clear; //clear overlay
	
	if (ball_y + ball_y_vel <= 0 || ball_y + ball_y_vel >= getHeight) {ball_y_vel *= -1;} //bounce in y off the top and bottom
	
	if (ball_x + ball_x_vel <= paddle_width -1) { //if ball will be in left paddle range
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) == min_gray) { //if there is no paddle to the left
			ball_x_vel *= -1;
			ball_x = 0.5 * getWidth;
			ball_y = 0.5 * getHeight;
			score_l += 1;
			}	
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) > min_gray) { //if left paddle will be hit
			ball_x_vel *= -1; //bounce in x
			}
		}
	
	if (ball_x + ball_x_vel >= getWidth - (paddle_width)) { //if ball will be in right paddle range
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) == min_gray) { //if there is no paddle to the right
			ball_x_vel *= -1;
			ball_x = 0.5 * getWidth;
			ball_y = 0.5 * getHeight;
			score_r += 1;
			}	
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) > min_gray) { //if right paddle will be hit
			ball_x_vel *= -1; //bounce in x
			hit = 100;
			}
		}
	
	ball_x = ball_x + ball_x_vel; //actually move ball to new speed
	ball_y = ball_y + ball_y_vel;
	
	//prepare ball color
	if (ball_x >= 0.5 * getWidth) {ball_draw_color = ball_color + ((255 - min_gray) - ((1-Math.pow((ball_x / getWidth),5))) * (255 - min_gray));}
	if (ball_x < 0.5 * getWidth) {ball_draw_color = ball_color + ((255 - min_gray) - ((1-Math.pow((ball_x / getWidth),5))) * (255 - min_gray));}

	//draw ball
	for (i = -(0.5*ball_height); i < (0.5*ball_height); i++) {
		for (j = -(0.5*ball_width); j < (0.5*ball_width); j++) {
			setPixel(ball_x + j, ball_y + i, ball_draw_color);
		}
	}
	
	//live score display in overlay
	str = d2s(score_r, 0) + " : " + d2s(score_l, 0);
    Overlay.drawString(str, (0.5 * getWidth)-12, 15);
    Overlay.show;
	
	//end of loop routine
	updateDisplay();
	wait(r);
	if (mouse_flags == 16 || mouse_flags == 1) break; //exit upon click
	}

exit;

