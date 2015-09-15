function entropy_landscape_GUI(ZI,optimalrates,patientType,matlab_version)

if strcmp(patientType,'Fetal')
xlim([110 180]);
ylim([110 180]);
image(110:180,110:180,flipud(ZI),'CDataMapping','scaled');
set(gca,'YDir','normal')
axis 'square'
elseif strcmp(patientType,'Adult')
xlim([40 110]);
ylim([40 110]);
image(40:110,40:110,flipud(ZI),'CDataMapping','scaled');
set(gca,'YDir','normal')
axis 'square'
end



xlabel('Heart Rate 1','FontSize',12)
ylabel('Heart Rate 2','FontSize',12)
box('on');
hold('all');
colorbar;
if ( verLessThan('matlab','8.4') ) 
cbfreeze
end

% mark actual minimum
hold on;
plot(optimalrates(1,1), optimalrates(1,2), 'w+');
hold on;
title('Reconstrution Quality','FontSize',14)
end