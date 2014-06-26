function Landscape=Metric_Landscape(Optimization)
warning off; %#ok<*WNOFF>
Interpolated_Landscape = TriScatteredInterp(Optimization.hr1s',Optimization.hr2s',double(Optimization.metrix'));
[XI,YI] = meshgrid(1:71,1:71);
Landscape=Interpolated_Landscape(XI,YI);
end
