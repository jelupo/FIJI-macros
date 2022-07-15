
// this macro shows live mouse coordinates in a constantly refreshing overlay
// having LMB pressed down causes getCursorLoc(flags) to be 16, so that is used to escape the macro
// shift key pressed down causes flags to be 1, which is also used as a backup escape button

if (nImages==0){exit("No images found");}

setBatchMode(true);
setFont("Sanserif", 24);
setColor("yellow");

str = newArray(2);

while (true) {
	
	Overlay.clear;
	getCursorLoc(x, y, z, flags);
	
	xstr="x: "+x; str[0]=lengthOf(xstr);
	ystr="y: "+y; str[1]=lengthOf(ystr);
	
	Array.getStatistics(str, min, max, mean, stdDev);
	strmax = d2s(max, 0);
	
	if ((getHeight()-y)<62){y-=67;}
	if ((getWidth()-x)<(15*strmax)){x-=(17*strmax);}
	
	Overlay.drawString(xstr, x+10, y+20); 
	Overlay.drawString(ystr, x+12, y+48);
	Overlay.show;
	wait(10);
	
	if (flags==16||flags==1) {break}
	 
	}

Overlay.clear;
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Last run's coordinates at "+hour+":"+minute+"h"+second+"s:");

print(xstr);
print(ystr+"\n");

exit
