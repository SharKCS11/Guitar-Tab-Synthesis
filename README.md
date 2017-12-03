# Guitar Tab Synthesizer

### Introduction:
The goal of this project is to take images of guitar tabs and produce the intended notes. This is done in two stages.
First, a cross-correlation-based character recognition algorithm is applied to the image files to extract numerical information about the position of numbers; then a pitch-shifting
algorithm is used to generate notes from a set of wav files.

From this repository, you can download and run our code, along with test images.

### Instructions to Run:
1. Download the code by either cloning the repository, or getting the prepared zip-file (will be uploaded soon). Make sure you have **MATLAB R2017a or later** installed. 
2. Open MATLAB, and add the entire folder (cloned repository or contents of zip file) to the path.
3. Run "driver.m" and specify the filename of the guitar tab image you want the synthesizer to play. Test images will be located in the
"Test Images/" directory.

Currently, the program will work for ideally cropped images that don't have extra symbols such as rests, slides, hammer-ons, or muted notes.

