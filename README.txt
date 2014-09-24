README - September 22, 2014

To run code: 

load ('MOG_Test_Data.mat')

MOG_Tool(Data,Coordinates)

output: metric optimized heart rate.

Structure containing times for each measurement and echos transformed and cropped in the frequency encoding direction.

Structure:

Data(Rows,Phase Encodes).Times(Measured Cardiac Phases)
Data(Rows,Phase Encodes).KSpace(Columns, Coils, Frames)


In Siemens version there are two files read_raw_data.m and write_raw_data.m excluded from this repository.
