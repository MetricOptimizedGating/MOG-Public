function [minhr1,minhr2,minhr,maxhr,hrs0,patienttype]=determine_patient_type(Data)
if mean(extract_HR_ECG(Data))<600
patienttype='Fetal';
    minhr1 = 145;
    minhr2 = 145;
    minhr  = 110;
    maxhr  = 180;
    hrs0 = struct([]);
    hrs0(1).hr1 = 110;
    hrs0(1).hr2 = [110 130 180];
    hrs0(2).hr1 = 120;
    hrs0(2).hr2 = [120 140 160];
    hrs0(3).hr1 = 130;
    hrs0(3).hr2 = [110 130 150 170];
    hrs0(4).hr1 = 140;
    hrs0(4).hr2 = [120 140 160];
    hrs0(5).hr1 = 150;
    hrs0(5).hr2 = [130 150 170];
    hrs0(6).hr1 = 160;
    hrs0(6).hr2 = [140 160 180 120];
    hrs0(7).hr1 = 170;
    hrs0(7).hr2 = [150 170 130];
    hrs0(8).hr1 = 180;
    hrs0(8).hr2 = [160 180 110];
else
    patienttype='Adult';
    minhr1 = 75;
    minhr2 = 75;
    minhr  = 40;
    maxhr  = 110;
    hrs0 = struct([]);
    hrs0(1).hr1 = 40;
    hrs0(1).hr2 = [40 60 110];
    hrs0(2).hr1 = 50;
    hrs0(2).hr2 = [50 70 90];
    hrs0(3).hr1 = 60;
    hrs0(3).hr2 = [40 60 80 100];
    hrs0(4).hr1 = 70;
    hrs0(4).hr2 = [50 70 90];
    hrs0(5).hr1 = 80;
    hrs0(5).hr2 = [60 80 100];
    hrs0(6).hr1 = 90;
    hrs0(6).hr2 = [70 90 110 50];
    hrs0(7).hr1 = 100;
    hrs0(7).hr2 = [80 100 60];
    hrs0(8).hr1 = 110;
    hrs0(8).hr2 = [90 110 40];
 
end
end