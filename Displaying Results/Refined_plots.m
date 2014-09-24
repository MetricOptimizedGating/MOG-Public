
function Refined_plots(handles)
          
if strcmp(handles.patientType,'Fetal')
% xlim([110 180]);
% ylim([110 180]);
axes(handles.axes1);
image(110:180,110:180,flipud(handles.FigureData),'CDataMapping','scaled');
set(gca,'YDir','normal')
axis 'square'
elseif strcmp(handles.patientType,'Adult')
xlim([40 110]);
ylim([40 110]);
image(40:110,40:110,flipud(handles.FigureData),'CDataMapping','scaled');
set(gca,'YDir','normal')
axis 'square'
end
axes(handles.axes2)

xlabel('Heart Rate 1','FontSize',12)
ylabel('Heart Rate 2','FontSize',12)
box('on');
hold('all');
colormap jet; 
colorbar;
cbfreeze


% mark actual minimum
hold on;
plot(handles.axes2,handles.OptimalRates(1,1), handles.OptimalRates(1,2), 'w+');
hold off;

axes(handles.axes3);
plot(handles.axes3,handles.t,handles.Two_HR)
hold on
plot(handles.axes3,handles.t,handles.N_HR,'r')
hold off
xlabel('Time (s)')
ylabel('HR (bpm)')
legend('Original HR Model','Refined HR Model','location','NW')


end