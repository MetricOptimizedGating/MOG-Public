![](http://i.imgur.com/QzaoFJj.jpg)
====
MOG is a MATLAB based image reconstruction pipeline for fetal MRI. It was developed at The Hospital for Sick Children in Toronto, Canada. It is licensed for non-commercial use. Two publications have been published on metric optimized gating. If you use MOG in a scientific paper please cite:  1) Jansz MS, Seed M, van Amerom JF, et al. Metric Optimized gating for fetal cardiac MRI. Magn Reson Med 2010;64(5):1304-1314.  2) Roy CW, Seed M, van Amerom JF, et al. Dynamic imaging of the fetal heart using metric optimized gating. Magn Reson Med 2013;70(6):1598-1607.

The Metric Optimization code found here uses two parameter optimization as described in Jansz et al. We have further developed MOG with multiparamter optimization, which will be available on github in the near future. 

For more information on MOG, visit: http://www.sickkids.ca/Research/fetalMRI/MOG/index.html

![](http://i.imgur.com/BgiJxqZ.jpg)
====
![](http://i.imgur.com/1ICo19P.jpg)

![](http://i.imgur.com/OgIxTMS.jpg)
====
To run code: 

    load ('MOG_Test_Data.mat')
    MOG_Tool(Data,Coordinates)

output: metric optimized heart rate.

Structure containing times for each measurement and echos transformed and cropped in the frequency encoding direction.

Structure:

    Data(Rows,Velocity Encodes).Times(Measured Cardiac Phases)
    Data(Rows,Velocity Encodes).KSpace(Columns, Coils, Measured Cardiac Phase)

In Siemens version there are two files read_raw_data.m and write_raw_data.m excluded from this repository but found on Siemens IDEA forum. 

The Metric Optimization code found here uses two parameter optimization as described in Jansz et al. We are further developing MOG with multiparamter optimization which will be available on github eventually. 

![](http://i.imgur.com/kncff3i.jpg)
====
Questions or comments? Contact us by creating a new issue on this page or directly:  Aneta Chmielewski: aneta.chmielewski@sickkids.ca Chris Roy: christopher.roy@sickkids.ca
