function [Data_Properties,user_input] = selectROI(Data_Properties)
temp =  reconstruct_optimal_images(Data_Properties,[mean(extract_HR_ECG(Data_Properties.Data))*0.9 mean(extract_HR_ECG(Data_Properties.Data))*0.9]);
boundary_condition=[];
while isempty(boundary_condition)
    if strcmp(Data_Properties.DataType{1},'CINE')
        [Data_Properties.yDimensions,Data_Properties.xDimensions,user_input]=Select_ROI_CINE(temp,Data_Properties.Protocol);
    else
        [Data_Properties.yDimensions,Data_Properties.xDimensions,user_input]=Select_ROI_PC(temp,Data_Properties.Protocol);
    end
    
    if strcmp(user_input,'skip')
        boundary_condition=1;
    else
        %%% Make Sure ROI is within image boundaries
        if  min(Data_Properties.yDimensions)<1 || min(Data_Properties.xDimensions)<1 || max(Data_Properties.yDimensions)>size(temp,1) || max(Data_Properties.xDimensions)>size(Data_Properties.Data(1).KSpace,1)
            questdlg('ROI exceeds image boundary, please choose again','Reselect ROI','OK', 'OK');
            boundary_condition=[];
        else
            boundary_condition=1;
        end
    end
end
end
