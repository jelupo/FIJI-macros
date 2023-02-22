//Speed Pong!
//jelle postma, 2023

//to do: 5 consecutive hits grants enemy weakness (with messages on screen)?

//welcome message
waitForUser("Speed pong", "\nPlay Speed Pong!\nReach high lateral velocities to beat your opponent.\n");

//init game
r = 6; //framerate in ms
min_gray = 20; //background level
clock = 0; //init clock
clock_max = 1e6; //max clock (memory related)
ball_y_vel_max = 4; //ball max speed in y
wall_dampen = 0.01; //wall absorbance in 0-1

//create scene
run("Close All"); newImage("Speed Pong", "8-bit Black", 120, 100, 1);
setLocation(0.2 * screenWidth, 0.2 * screenHeight);
for (i = 0; i < 5; i++) {run("In [+]"); wait(15);}
setColor(min_gray);
floodFill(0, 0);
setTool("rectangle");

//init colors
paddle_color = 220;
ball_color = min_gray;
textcolor = "orange";
setFont("Sanserif", 15);
setColor(textcolor);

//init variables
paddle_height = 30; paddle_width = 5;
ball_x = 0.5 * getWidth; ball_y = 0.5 * getHeight;
ball_width = 2; ball_height = 2;
ball_x_vel = -1; ball_y_vel = 1;
score_l = 0; score_r = 0;
paddle_1_y = 10;
paddle_2_y = 10;
paddle_1_yvel = 0;
paddle_2_yvel = 0;

while (true) { //do this every frame
	
	//reset screen
	Overlay.clear;
	for (i = 0; i < getWidth; i++) {
		for (j = 0; j < getHeight; j++) {
			setPixel(i, j, min_gray); //blacken
		}
	}

	//grab cursor
	getCursorLoc(mouse_x, mouse_y, mouse_z, mouse_flags);
	//grab previous
	paddle_1_yprev = paddle_1_y;
	paddle_2_yprev = paddle_2_y;
	hit = 0;
	score = 0;
	
	//draw left paddle
	if (mouse_y <= 0.5 * getHeight) paddle_1_y = maxOf(10, mouse_y); //enforce wall boundaries
	if (mouse_y > 0.5 * getHeight) paddle_1_y = minOf(getHeight - 10, mouse_y);
	paddle_1_yvel = paddle_1_y - paddle_1_yprev; //max possible speed should be equal to getHeight (== game height == 100)	
	
	for (i = -(0.5 * paddle_height); i < (0.5 * paddle_height); i++) {
		for (j = 0; j < paddle_width; j++) {
			setPixel(j, paddle_1_y + i, paddle_color);
			}
		}
	
	//draw right paddle
	if (ball_y <= 0.5 * getHeight) paddle_2_y = maxOf(10, ball_y); //enforce wall boundaries
	if (ball_y > 0.5 * getHeight) paddle_2_y = minOf(getHeight - 10, ball_y);
	paddle_2_yvel = paddle_2_y - paddle_2_yprev;

	paddle_2_y_real = paddle_2_y; //store actual y position in case it will be flickered away
	
	if(pow(ball_y_vel, 2) > 4) { //at high ball speeds, make paddle unstable (ie. draw it just out of view)
		Overlay.clear;
		if (random > 0.5) {
			paddle_2_y = -paddle_height;
			}
		if (clock%20 < 10) { //flash this message
			message = "OVERLOAD!";
			setFont("Sanserif", 4);
			setColor("cyan");
	    	Overlay.drawString(message, 0.5 * getWidth - 12, 20);
			}
		Overlay.show;
		}
	
	for (i = -(0.5 * paddle_height); i < (0.5 * paddle_height); i++) {
		for (j = -paddle_width; j < paddle_width; j++) {
			setPixel(j + getWidth, paddle_2_y + i, paddle_color);
			}
		}
		
	paddle_2_y = paddle_2_y_real; //restore actual y position in case it was flickered out of view before. pixels have been set (setPixel) so ball can score
	
	//move ball
	if (ball_y + ball_y_vel <= 0 || ball_y + ball_y_vel >= getHeight) {ball_y_vel *= -(1-wall_dampen);} //bounce in y off the top and bottom
	
	if (ball_x + ball_x_vel <= paddle_width -1) { //if ball will be in left paddle range
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) == min_gray) { //if there is no paddle to the left
			ball_x_vel *= -1;
			ball_x = 0.5 * getWidth;
			ball_y = 0.5 * getHeight;
			score_l += 1; //score!
			score = 1;
			if (ball_y_vel > ball_y_vel_max) ball_y_vel = ball_y_vel_max;
			if (ball_y_vel < -ball_y_vel_max) ball_y_vel = -ball_y_vel_max;
			ball_y_vel *= 0.7;
			}	
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) > min_gray) { //if left paddle will be hit
			hit = 1;
			ball_x_vel *= -1; //bounce in x
			ball_y_vel += paddle_1_yvel / (0.05 * getHeight); //transfer some paddle y-velocity to the ball
			}
		}
	
	if (ball_x + ball_x_vel >= getWidth - (paddle_width)) { //if ball will be in right paddle range
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) == min_gray) { //if there is no paddle to the right
			ball_x_vel *= -1;
			ball_x = 0.5 * getWidth;
			ball_y = 0.5 * getHeight;
			score_r += 1; //score!
			score = 1;
			if (ball_y_vel > ball_y_vel_max) ball_y_vel = ball_y_vel_max;
			if (ball_y_vel < -ball_y_vel_max) ball_y_vel = -ball_y_vel_max;
			ball_y_vel *= 0.7;
			}	
		
		if (getPixel((ball_x + ball_x_vel), (ball_y + ball_y_vel)) > min_gray) { //if right paddle will be hit
			hit = 1;
			ball_x_vel *= -1; //bounce in x
			ball_y_vel += paddle_2_yvel / (0.05 * getHeight); //transfer some paddle y-velocity to the ball
			}
		}

	ball_x = ball_x + ball_x_vel; //actually move ball according to new speed
	ball_y = ball_y + ball_y_vel;
	
	//bleed some y velocity and keep velocity in bounds
	if (ball_y_vel > 1) ball_y_vel *= 0.998;
	if (ball_y_vel < -1) ball_y_vel *= 0.998;
	if (ball_y_vel > ball_y_vel_max) ball_y_vel = ball_y_vel_max;
	if (ball_y_vel < -ball_y_vel_max) ball_y_vel = -ball_y_vel_max;
	
	//draw ball
	ball_draw_color = 150 + ((255-150) * (abs(ball_y_vel) / abs(ball_y_vel_max)));
	for (i = -ball_height; i < ball_height; i++) {
		for (j = -ball_width; j < ball_width; j++) {
			setPixel(ball_x + j, ball_y + i, ball_draw_color);
		}
	}
	
	//update display and revert flash damage
	updateDisplay();
	
	//live score display in overlay
	str = d2s(score_r, 0) + " : " + d2s(score_l, 0);
	setFont("Sanserif", 15);
	setColor(textcolor);
    Overlay.drawString(str, (0.5 * getWidth)-(str.length*3), 15);
    Overlay.show;
	
	//end of loop routine
	wait(r);
	if (score == 1) {score = 0; wait(1000);}
	if (clock <= clock_max) {clock++;} else {clock = 0;}
	if (mouse_flags == 16 || mouse_flags == 1) break; //exit upon click
	}

exit;

