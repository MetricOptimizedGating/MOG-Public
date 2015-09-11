function versionCheck
localVersion='2.6';
localVersionDate='September 10, 2015';
% Check when version what last checked
LastCheck=textread('VersionCheck.txt','%s', 'delimiter','/');
LastCheckMonth=str2num(cell2mat(LastCheck(2)));
LastCheckYear = str2num(cell2mat(LastCheck(3)));
LastCheck2=strsplit(char(LastCheck(1)),':');
LastCheckDay = str2num(cell2mat(LastCheck2(2)));
% Get current date and time
CurrentDate=clock;
CurrentYear=CurrentDate(1);
CurrentMonth=CurrentDate(2);
CurrentDay=CurrentDate(3);
% if version check has not been performed in 30 days run
DaysSinceLastCheck = (CurrentDay-LastCheckDay)+(CurrentMonth-LastCheckMonth)*31+ (CurrentYear-LastCheckYear)*365;
if (DaysSinceLastCheck>=30)
urlVersion=urlread('https://raw.githubusercontent.com/MetricOptimizedGating/MOG-Public/master/Version.txt');
endVersion=regexp(urlVersion,'\n');
remoteVersion=urlVersion(1:endVersion-1);
if(localVersion==remoteVersion)
else
waitfor(msgbox(sprintf('A new version of MOG is availabe on Github, you are running version %s the latest version is  %s', localVersion,remoteVersion),'Version Check'));
end
VersionCheckWrite =sprintf(' Last version check: %s/%s/%s;\n Current Version: %s;\n Release Date: %s;',num2str(CurrentDate(3)),num2str(CurrentDate(2)),num2str(CurrentDate(1)),localVersion,localVersionDate);
fidVer=fopen('VersionCheck.txt','w+');
fwrite(fidVer, VersionCheckWrite,'char');
fclose(fidVer);
end
end
