function VPS=find_VPS(Data)
Times=extract_times(Data);
TR=Times(1,2)-Times(1,1);
for loop=2:size(Times,1)
d=Times(loop,1)-Times(loop-1,1);
if d>TR
VPS=loop-1;
break;
end
end
