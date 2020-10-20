# CSMM_scripts
Concept code for Analytical Chemistry


# Data conversion 
Convert imzML format to .mat file with the imzml2mat.py script from the Conversion_tools folder.
* Python3.5, 3.7 and 3.8 are tested.
* Put the script in the folder containing imzML file or files to convert and run the script.
* numpy, scipy, tkinter and ImzMLParser are required.

There is also xml2mat.py Python script in the Conversion_tools folder, which allows conversion generated .xml files of peaklists from old instruments that don't support the imzML format to .mat file.

# Usage
* Launch CSMM.mat file.
* Load .mat file or press ESC for loading previous file *(this is an option to change some parameters in code and work with previosly selected file for not to select the file again)*.
* and click on any point of the opened Figure 1 iteratively. For exiting the process click the space right to the colorbar.
* set m/z range, m/z bin width, gaussian convolution and storing the data for figures of CSMM to be saved after each click.
