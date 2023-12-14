
// Jelle Postma, 2023

// trying to see if I can bypass the imagej macro language's limitation of having only 1d (linear) arrays.
// by storing a 2D-array (2D-matrix) in an 1D-array, by using the width of the 2D-array or matrix.

// an array [1,1,2,2] stores 2 sets of 2 (a linear 2d-array, or linear 2d-matrix)
// an array [1,1,2,2,3,3,] stores 3 sets of 2
// an array [1,1,1,2,2,2,3,3,3] stores 3 sets of 3

// the [3,3] linear 2d-array stores the following structure
// with each position labeled by its X,Y coordinates in the matrix
// and the corresponding set marked set (row) and pos (column) to which X,Y refer:

//        pos 2
// (1,1), (1,2), (1,3) set 1
// (2,1), (2,2), (2,3)
// (3,1), (3,2), (3,3)

// in a linear 2D array, set (X-axis) equals X, and position (Y-axis) equals Y

// need to access array index 2,3 (X, Y) in a linear 2D array of dimensions 3,3 (X, Y)?

// then it's position 6 in the linear representation, because:

// we agreed that X is a set, so it's set 2; for which we need to skip all sets before set X:
// and determine the first component of the value's position in the linear storage array:

//     " (X-position * X-length) "

// we agreed that Y is position in a set, which specifies which linear position at which to read out the pixel value:

//     " + Y-position "

// summing everything up, the position of (x-pos,y-pos) in a linear 2d-matrix is officially: 

// (x-pos * x-length) + y-pos

// or also:

// (set * set-size) + pos

// applying all this in steps:

run("Close All");
print("\\Clear");

// Going to store a 2D-image in one linear array, to then rebuild it in a new window
// for which it needs to retrieve the pixel values again from the linear array

lin_blobs = newArray; //the linear array to store the matrix

//scan vertically and add each line of values to linear_blobs
run("Blobs");
resetMinAndMax;
if(is("Inverting LUT")) {run("Invert LUT");}
original = getImageID;
rename("original");
width = getWidth;
height = getHeight;
for (i = 0; i < height; i++) { //j = x, i = y
	line = newArray;
	for (j = 0; j < width; j++) {
		line[j] = getPixel(j,i);
	}
	lin_blobs = Array.concat(lin_blobs,line);	
}
// now, lin_blobs is a linear array containing all pixels of blobs.gif in sets that have size "width"

//draw vertically, and add each set (x) of linear_blobs in the pos-direction (y)
newImage("reconstructed", "8-Bit black", width, height, 1);
for (pos = 0; pos < height; pos++) {
	for (set = 0; set < width; set++) {
		lin_pos = (pos * width) + set;
		val = lin_blobs[lin_pos];
		setPixel(set, pos, val);
		updateDisplay;
	}
}
run("Tile");

// this works!

// Defining a function to retrieve a value from a linear array at position X,Y:
function val_get(linear_array, width, x, y) {
	return (linear_array[width * x + y]);
}

// using the new function val_get to retrieve pixel value X=10, Y=10 from a linear array with width:
print(val_get(lin_blobs, width, 10, 10));

// Defining a function to set a value in a linear array at position X,Y:
function val_set(linear_array, width, x, y, value) { //returns a new array with the new value set
	linear_pos = width * x + y;
	new_linear_array = linear_array;
	new_linear_array[linear_pos] = value;
	return new_linear_array;
}

// using the new function to set pixel X=10, Y=10 to 65:
val_set(lin_blobs, width, 10, 10, 65);
print(val_get(lin_blobs, width, 10, 10));

// using the new function to set pixel X=10, Y=10 to one more
val_set(lin_blobs, width, 10, 10, val_get(lin_blobs, width, 10, 10) + 1);
print(val_get(lin_blobs, width, 10, 10));

Array.print(lin_blobs);






