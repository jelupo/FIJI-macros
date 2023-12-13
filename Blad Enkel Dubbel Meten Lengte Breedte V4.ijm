//Jelle Postma, Romee Groenbos, Radboud University, 2023


//to do: troubleshooten van verkeerde breedtes


//begin met een stack (of 1) van images van al dan niet gevouwen blaadjes

//vragen om de juiste classifier
waitForUser("In the next window, choose which Labkit classifier to use");
path = File.openDialog("Which Labkit classifier to use?");
title = getTitle;

//bestaande resultaten opschonen
print("\\Clear");
run("Clear Results");
roiManager("reset");

//juiste schaal forceren (lijkt niet altijd erin te zitten..)
run("Set Scale...", "distance=0.5682 known=1 pixel=1 unit=micron");

//simpeler maken van de afbeeldingen (de helft kleiner)
run("Enhance Contrast...", "saturated=0 process_all");
run("Grays");
run("Size...", "width=800 height=600 constrain average interpolation=Bicubic");

//schaal registreren (niet meer nodig?)
getPixelSize(unit, pixelWidth, pixelHeight);

//generate probability map with labkit
run("Calculate Probability Map With Labkit", "input=" + title + " segmenter_file=[" + path + "] use_gpu=false");
wait(10);

//schaal weer toepassen
run("Set Scale...", "distance=1 known=&pixelWidth pixel=1 unit=micron");
Stack.getDimensions(width, height, channels, hoeveelheid_blaadjes, frames);

//binary images van alle 3 klassen (stack?)
run("Convert to Mask", "method=Default background=Dark calculate black create");
id_binary_stack = getImageID();

//loop door hoeveelheid blaadjes
breedtes = newArray();
lengtes = newArray();
oppervlaktes = newArray();

for (q = 0; q < hoeveelheid_blaadjes; q++) {
		
		//lengte meten
		selectImage(id_binary_stack);
		Stack.setSlice(q + 1);
		Stack.setChannel(3);
		run("Select None");
		run("Duplicate...", "title=blad_binary");
		run("Invert");
		run("Set Measurements...", "area centroid bounding feret's redirect=None decimal=3");
		run("Analyze Particles...", "size=2000-Infinity display include");
		selectWindow("Results");
		blad_lengte = getResult("Feret", nResults - 1);
		
		//Maak lijn voor blad_breedte
		hoek = - (getResult("FeretAngle", q) - 90);
		midden_x = getResult("X", q);
		midden_y = getResult("Y", q);
		begin_lijn_x = midden_x - (0.5 * blad_lengte);
		einde_lijn_x = midden_x + (0.5 * blad_lengte);
		close("blad_binary");
		
		selectImage(id_binary_stack);
		makeLine(begin_lijn_x/pixelWidth, midden_y/pixelWidth, einde_lijn_x/pixelWidth, midden_y/pixelWidth);
		run("Rotate...", "angle=&hoek");
		
		//breedte dubbel materiaal registreren
		Stack.setChannel(2);
		profiel = getProfile();
		roiManager("add");
		profiel_positief = newArray();
		
		for (i=0; i<lengthOf(profiel); i++) {
			if (profiel[i] > 0) {
				profiel_positief = Array.concat(profiel_positief, i);
				}
			}
			
		breedte_dubbel = (2 * lengthOf(profiel_positief)) * pixelWidth;
		
		//breedte enkel materiaal registreren en totaal berekenen
		Stack.setChannel(1);
		profiel = getProfile();
		profiel_positief = newArray();
		
		for (i=0; i<lengthOf(profiel); i++) {
			if (profiel[i] > 0) {
				profiel_positief = Array.concat(profiel_positief, i);
				}
			}
		
		breedte_enkel = lengthOf(profiel_positief) * pixelWidth;
		blad_breedte = breedte_dubbel + breedte_enkel;
		
		//oppervlakte enkel materiaal registreren
		run("Select None");
		run("Create Selection");
		blad_oppervlak_enkel = getValue("Area");
		
		//oppervlakte dubbel materiaal registreren
		Stack.setChannel(2);
		run("Select None");
		run("Create Selection");
		blad_oppervlak_dubbel = 2 * getValue("Area");
		blad_oppervlak = blad_oppervlak_enkel + blad_oppervlak_dubbel;
		
		//toevoegen van uiteindelijke dimensies van dit blad aan de overkoepelende lijst
		breedtes = Array.concat(breedtes, blad_breedte);
		lengtes = Array.concat(lengtes, blad_lengte);
		oppervlaktes = Array.concat(oppervlaktes, blad_oppervlak);		
		}

//results
print("Breedtes: ");
Array.print(breedtes);
print("Lengtes: ");
Array.print(lengtes);
print("Oppervlaktes: ");
Array.print(oppervlaktes);


















































