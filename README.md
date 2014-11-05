![](http://i.imgur.com/aJv2BDL.jpg)
====
MOG is a MATLAB based image reconstruction pipeline for metric based gating in fetal cardiac MRI. It was developed at The Hospital for Sick Children in Toronto, Canada. It is licensed for non-commercial use. Two publications have been published on metric optimized gating. If you use MOG in a scientific paper please cite:  1) Jansz MS, Seed M, van Amerom JF, et al. Metric Optimized gating for fetal cardiac MRI. Magn Reson Med 2010;64(5):1304-1314.  2) Roy CW, Seed M, van Amerom JF, et al. Dynamic imaging of the fetal heart using metric optimized gating. Magn Reson Med 2013;70(6):1598-1607.

The Metric Optimization code found here initially uses two-parameter optimization as described in Jansz et al. and allows the option to refine the results with the multi-parameter model as described in Roy et al. The multi-parameter model is quite slow especially if the initial start point is far from the optimized heart rate.

For more information on MOG, visit: http://www.sickkids.ca/Research/fetalMRI/MOG/index.html

![](http://i.imgur.com/vuQlqi1.jpg)
====
![](http://i.imgur.com/t3lRDA5.png)

![](http://i.imgur.com/erSgEDP.jpg)
====
To run code: 
    
    Add the MOG-Public directory to your MATLAB path
    Run MOG_Tool.m  
    You will be prompted to select a dataset and region of interest to optimize.
    Test datasets are provided in the folder Test Data


The dataset structure contains times for each measurement and echos transformed and cropped in the frequency encoding direction.

Structure:

    Data(Rows,Velocity Encodes).Times(Measured Cardiac Phases)
    Data(Rows,Velocity Encodes).KSpace(Columns, Coils, Measured Cardiac Phase)

Once two-parameter optimization is complete a plot of two heart rates applied to the two halves of the scan and entropy as a metric of reconstruction quality.  

![](http://i.imgur.com/uCQb0Iz.jpg)

To run the multi-parameter model select refine, once optimization is complete a plot of heart rates from the two-parameter and multi-parameter model is displayed. 

![](http://i.imgur.com/x8IbOBB.jpg)
===

If you are satisfied with the results select patched to save the results.

MOG has been tested on MATLAB versions R2013a and R2012b.

A version of MOG which inputs Siemens raw data header files (*.dat) and outputs optimized header files is available on the IDEA Forum (www.mr-idea.com). This version is the same as found on this repository with the exception of two files read_raw_data.m and write_raw_data.m. The Siemens version works for VB or VD data headers. GRAPPA reconstruction with raw data headers as output does not currently work but is in development. 

To run Matlab executables: 

The MOG executables were compiled with MATLAB 2013a for windows 32 and 64 bit. If you want to run MOG on a windows machine without MATLAB R2013a installed, first install MATLAB Compiler Runtime (MCR) R2013a (8.1) either 32 or 64 bit depending on your windows system (http://www.mathworks.com/products/compiler/mcr/). You will subsequently be able to run MOG_GRIDTool_2_0_64bit_24092014.exe or MOG_GRIDTool_2_0_32bit_24092014.exe and be prompted to select a file input.  

These executable files take Siemens data files for VB or VD MRI systems as input and output. Due to the large header size of Siemens VD data structure over 4 GB of RAM is necessary to process VD files.

![](http://i.imgur.com/SmDExh1.jpg)
====
Questions or comments? Contact us by creating a new issue on this page or directly:  Aneta Chmielewski: aneta.chmielewski@sickkids.ca Chris Roy: christopher.roy@sickkids.ca
