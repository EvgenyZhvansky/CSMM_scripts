import sys
import os
import xml.etree.ElementTree as ET
import scipy.io as io
import numpy as np

if __name__ == '__main__':
    regions =[]
    data={}
    files_amount=0
    for rootdir, dirs, files in os.walk(os.getcwd()):
        for file in files:
            if (file == 'peaklist.xml'):
                rd = rootdir
                out_filename = rd.replace(os.getcwd(), "")
                outs=out_filename.split("_R")
                outs=outs[1]
                outs = outs.split("X", 1)
                r=int(outs[0])
                outs = outs[1]
                outs = outs.split("\\", 2)
                if outs[1]=='1':
                    files_amount+=1
    data['peaks']=np.empty((files_amount,), dtype=np.object)
    data['R']=np.zeros(files_amount)
    data['X']=np.zeros(files_amount)
    data['Y']=np.zeros(files_amount)
    file_id=0
    for rootdir, dirs, files in os.walk(os.getcwd()):
        for file in files:
            if (file == 'peaklist.xml'):
                rd = rootdir
                out_filename = rd.replace(os.getcwd(), "")
                #print(out_filename)
                outs=out_filename.split("_R")
                outs=outs[1]
                outs = outs.split("X", 1)
                r=int(outs[0])

                outs = outs[1]
                outs = outs.split("\\", 2)
                if outs[1]=='1':
                    outs = outs[0]
                    outs = outs.split("Y")
                    x = int(outs[0])
                    y = int(outs[1])
                    data['R'][file_id]=r;
                    data['X'][file_id]=x;
                    data['Y'][file_id]=y;

                    tree_local=ET.parse(os.path.join(rootdir, file))
                    root_local = tree_local.getroot()
                    m_el = root_local.find('pk')
                    headers = []
                    if m_el != None:
                        data['peaks'][file_id]=np.zeros((2,len(root_local.findall('pk'))))
                        mz_index=0
                        for child in m_el:
                            headers.append(child.tag)
                        for pk in root_local.findall('pk'):
                            for child in pk:
                                if child.tag == headers[0]:
                                    data['peaks'][file_id][1,mz_index]=float(child.text)
                                elif child.tag == headers[4]:
                                    data['peaks'][file_id][0,mz_index]=float(child.text)
                            mz_index+=1
                    if data['peaks'][i] is None:
                        data['peaks'][i]=np.zeros((2,1))
                        data['peaks'][i][1,0]=0
                        data['peaks'][i][0,0]=700
                    file_id+=1
    outs = out_filename.split("\\")
    out_filename_mat = os.getcwd() + "\\" + outs[1] + "_peaklists.mat"
    print(out_filename_mat)
    io.savemat(out_filename_mat, {'data':data})
    print('done')
    input()
    #sys.exit()
