% returns array of structures containing heart rate one and corresponding
% list of heart rate 2
% middle point is included 

function [HRList n] = two_para_search(s1, e1, s2, e2, r)

n = ((e1 - s1) / r + 1) * ((e2 - s2) / r + 1);
HRList = struct([]);

% to avoid searching heart rates below 110 or above 180 bpm
if s1 < 110
    
    s1 = 110;
    e1 = s1 + (n^0.5 - 1) * r;

elseif e1 > 180
    
    e1 = 180;    
    s1 = e1 - (n^0.5 - 1) * r;
    
end

if s2 < 110
    
    s2 = 110;
    e2 = s2 + (n^0.5 - 1) * r;
    
elseif e2 > 180

    e2 = 180;    
    s2 = e2 - (n^0.5 - 1) * r;
    
end

for i=s1:r:e1

    HRList(round((i - s1)/r) + 1).hr1 = i;
    
    %if i == (e1 + s1) / 2
        
        %HRList(round((i - s1)/r) + 1).hr2 = [s2:r:(e2 + s2)/2-r (e2 + s2)/2+r:r:e2];
        
    %else
                
        HRList(round((i - s1)/r) + 1).hr2 = s2:r:e2;
        
    %end

end

