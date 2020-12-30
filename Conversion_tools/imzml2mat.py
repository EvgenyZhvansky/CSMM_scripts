import sys
import time
import os
from tkinter import Tk
from tkinter.filedialog import askopenfilename
import scipy.io as io
from pyimzml.ImzMLParser import ImzMLParser
import numpy as np

def convert_imaging_file_to_mat(imzml_filename, mat_filename):
    p = ImzMLParser(imzml_filename)
    data={}
    amount_of_points_in_image=len(p.intensityLengths)
    data['peaks'] = np.empty((amount_of_points_in_image,), dtype=np.object)
    data['R'] = np.ones(amount_of_points_in_image,dtype=np.int16)
    data['X'] = np.zeros(amount_of_points_in_image,dtype=np.int16)
    data['Y'] = np.zeros(amount_of_points_in_image,dtype=np.int16)
    data['Z'] = np.zeros(amount_of_points_in_image,dtype=np.int16)
    for i, (x,y,z) in enumerate(p.coordinates):
        mzs, intensities = p.getspectrum(i)
        data['X'][i] = x
        data['Y'][i] = y
        data['R'][i] = 1
        data['peaks'][i] = np.vstack((mzs,intensities))

    print(mat_filename)
    io.savemat(mat_filename, {'data': data})
    return


if __name__ == '__main__':
    imzml_found = False
    data = {}
    for rootdir, dirs, files in os.walk(os.getcwd()):
        for file in files:
            if len(file) > 6:
                if ((file[len(file) - 6:len(file)]).lower() == '.imzml'):
                    imzml_found = True
                    imzml_filename=os.path.join(str(rootdir),str(file))
                    newfilename = imzml_filename.rsplit(".", 1)
                    mat_filename = newfilename[0] + ".mat"
                    convert_imaging_file_to_mat(imzml_filename, mat_filename)
                    

    if not imzml_found:
        root = Tk()
        root.withdraw()
        imzml_filename = askopenfilename()
        newfilename = imzml_filename.rsplit(".", 1)
        mat_filename = newfilename[0] + ".mat"
        convert_imaging_file_to_mat(imzml_filename, mat_filename)

    print('done')
    input()
