![](http://i.imgur.com/aJv2BDL.jpg)
====
MOG is a MATLAB based image reconstruction pipeline for metric based gating in fetal cardiac MRI. It was developed at The Hospital for Sick Children in Toronto, Canada. It is licensed for non-commercial use. Two publications have been published on metric optimized gating. If you use MOG in a scientific paper please cite:  1) [Jansz MS, Seed M, van Amerom JF, et al. Metric Optimized gating for fetal cardiac MRI. Magn Reson Med 2010;64(5):1304-1314.](http://onlinelibrary.wiley.com/doi/10.1002/mrm.22542/abstract;jsessionid=85B077FC76AB3F7A796D422002BB9CC6.f02t01?deniedAccessCustomisedMessage=&userIsAuthenticated=false)  2) [Roy CW, Seed M, van Amerom JF, et al. Dynamic imaging of the fetal heart using metric optimized gating. Magn Reson Med 2013;70(6):1598-1607.](http://onlinelibrary.wiley.com/doi/10.1002/mrm.24614/abstract?deniedAccessCustomisedMessage=&userIsAuthenticated=false)

The Metric Optimization code found here initially uses two-parameter optimization as described in Jansz et al. and allows the option to refine the results with the multi-parameter model as described in Roy et al. The multi-parameter model is quite slow especially if the initial start point is far from the optimized heart rate.

For more information on MOG, visit: http://www.sickkids.ca/Research/fetalMRI/MOG/index.html

![](http://i.imgur.com/vuQlqi1.jpg)
====
![](http://i.imgur.com/t3lRDA5.png)

![](http://i.imgur.com/erSgEDP.jpg)
====
Image Acquisition:

An artificial gating trace is used for the fetal waveform, for most fetuses an R-R interval of 545 ms corresponding to a heart rate of 110 beats per minute will ensure that every heartbeat is oversampled. Siemens IDEA command tool can be used to define the R-R interval. 

Cine SSFP and PC image sequence parameters for 1.5 T are provided below. For PC vessel flow quantification, a minimum of 8 voxels over the area and a temporal resolution of 50 ms is used.

![](http://i.imgur.com/xjx9KZA.png)

A full description of fetal cardiovascular MRI is found in [Seed M, Macgowan CK. Fetal cardiovascular MRI. Magnetom FLASH. 2014;2:66-72](http://www.healthcare.siemens.com/siemens_hwem-hwem_ssxa_websites-context-root/wcm/idc/groups/public/@global/@imaging/@mri/documents/download/mdaz/mdmz/~edisp/mri_57_seed-01390790.pdf), in www.siemens.com/magnetom-world.

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

To run the multi-parameter model select refine, once optimization is complete a plot of heart rates from the two-parameter and multi-parameter model is displayed. The muli-parameter model is available for anatomical scanning only. 

![](http://i.imgur.com/x8IbOBB.jpg)
===

If you are satisfied with the results select patched to save the results.

MOG has been tested on MATLAB versions R2014b, R2013a and R2012b.

A version of MOG which inputs Siemens raw data header files (*.dat) and outputs optimized header files is available on the IDEA Forum (www.mr-idea.com). This version is the same as found on this repository with the exception of two files read_raw_data.m and write_raw_data.m. The Siemens version works for VB, VD and VE data headers for PC and CINE FULL/GRAPPA/MSENSE scans. The ROI selection tool has not been updated for MSENSE, you may find that some of your MSENSE files are aliased in the visualization but they will patch and reconstruct correctly.

 Due to the large header size of Siemens VD/VE data structure over 4 GB of RAM is necessary to process VD/VE files.

![](http://i.imgur.com/SmDExh1.jpg)
====
Questions or comments? Contact us by creating a new issue on this page or directly: Chris Macgowan: christopher.macgowan@sickkids.ca
.ca
