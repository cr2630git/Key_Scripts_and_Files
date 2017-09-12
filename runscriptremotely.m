function runscriptremotely(script)
%Simply calls scripts invoking their remote-running options
%Other than that, scripts are exactly the same as if they were being called
%manually
%Script should be called using its full path to avoid ambiguity


%Assign runremotely (function variable) to runningremotely (variable in
%base workspace)
assignin('base','runningremotely',1); %save to the base workspace
%runningremotely=1; %save to the function workspace

%Load things that need loading
highpcttoload=925;sutoload=3; %925 or 975; 3 or 9
loadreadnycdata=1;loadanalyzenycdata=1;loadorgnarrhws=1;loadavgs=1;loadcfc=1;loadavgsbottomup=0;
loadcalcarealextent=0;
%Save load options to the base workspace
assignin('base','loadreadnycdata',loadreadnycdata);
assignin('base','loadanalyzenycdata',loadanalyzenycdata);
assignin('base','highpcttoload',highpcttoload);
assignin('base','sutoload',sutoload);
assignin('base','loadorgnarrhws',loadorgnarrhws);
assignin('base','loadavgs',loadavgs);
assignin('base','loadcfc',loadcfc);
assignin('base','loadavgsbottomup',loadavgsbottomup);
assignin('base','loadcalcarealextent',loadcalcarealextent);

run(script);
end

