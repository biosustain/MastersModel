function [Cexp , Cexpl, time, Vars]=exomets_data_import(spreadsheet,page,t1,t2,biomass_conc,a,b,c)

% Data import stage for Unified ExoMetabolomics pathway
% Andrei Ligema 2019 DTU/CFB
% Inputs:   [spreadsheet,page] spreadsheet paths and page names, from
%           resultsdir.xls
%           [t1,t2] indexes of start and end of used data
%           [biomass_conc] toggle for use of fully derived growth rate or biomass
%           concentration as a substitute
%           [a,b,c] co-ordinates in spreadsheet for experimental data
%           this may be modified as appropriate as long as outputs maintain
%           consistency with standards
% Outputs:  [Cexp] matrix of metabolites over time, rows = time , col =
%           metabolites
%           [Time] Recording time for each index
%           [Vars] Experiment Metadata (time, Viable Cell Density, sample
%           volume)




[num , txt]=xlsread(spreadsheet,page); % import experimental run

if (53+t2-1)>=(size(num,1)+1)  % based on Ivan's standard results sheet, allows t2 to update for sheets that are under-sized, avoiding overrun
    t2=size(num,1)-(53-1);
end

time=num(t1:t2,1); % hours
VCD=(num(t1:t2,2));  % 10^6 cells per ml
Vol=num(t1:t2,16); % ml
OUR=num(t1:t2,12); %mmols per L per hr


Vars(:,1)=time; % packaging for export and further use
Vars(:,2)=VCD;
Vars(:,3)=Vol;



% for glutamine addition, coordinates reference position of glutamine, time
% and volume in standard structures
Datag=num(a(1,1):a(2,1),6);
Addg=num(a(1,1):a(2,1),14); %after sampling
Volumeg=num(a(1,1):a(2,1),16);
GlutC(1)=Datag(1);
for i=2:length(Datag)
    GlutC(i,1)=Datag(i)-sum(Addg(1:i-1))*200/Volumeg(i);
end
GlutC=GlutC; % updated glutamine concentrations after addition calculations

%HPLC - as above, for HPLC glutamine measurements
Datag=num(c(1,1):c(2,1),7);
Addg=num(a(1,1):a(2,1),14); %after sampling
Volumeg=num(a(1,1):a(2,1),16);
GlutC2(1)=Datag(1);
for i=2:length(Datag)
    GlutC2(i,1)=Datag(i)-sum(Addg(1:i-1))*200/Volumeg(i);
end
GlutC2=GlutC2; % updated glutamine concentrations HPLC measurements


% Assigning the columns of Cexp, users may rip this out and replace with
% any method that produces a regular table of metabolites. NaN values are
% acceptable here though empty columns are not reccomended. Cexpl is
% currently generated by reading the text entries of the target sheet but
% may be added independently here.
Cexp(:,1:5)=num(t1:t2,4:8);
Cexp(:,6:14)=num(26+t1:26+t2,2:10);
Cexp(:,15:34)=num(52+t1:52+t2,2:21);

Cexpl(1,1:5)=txt(7,4+1:8+1);
Cexpl(1,6:14)=txt(33,2+1:10+1);
Cexpl(1,15:34)=txt(59,2+1:21+1);

Cexp(:,3)=GlutC(t1:t2,1)';
Cexp(:,20)=GlutC2(t1:t2,1)';
Cexp(:,35)=OUR;
Cexpl(1,35)={'OUR'};


% For experiments where volume measurements are not available use
% biomass_conc = 1 to replace with VCD
if biomass_conc == 0
Vars(:,4)=((Vars(:,2).*360).*10).*(10^-4);
Cexp(:,36)=Vars(:,4);
Cexpl(1,36)={'Biomass'};
else
Vars(:,4)=(Vars(:,2));
Cexp(:,36)=Vars(:,4);
Cexpl(1,36)={'Biomass'};
end

Cexp(:,37:38)=num(t1:t2,9:10);
Cexpl(37:38)=txt(7,10:11);

% validating output
% if size(Cexp,2)==length(Cexpl)
% else
%     error('Inconsistency between number of metabolites and specified list of metabolites.')
% end
% 
% if isnan(Vol)==length(Vol) && biomass_conc==0
%     warning('Volume data is missing but biomass_conc == 0, this may lead to unexpected outcomes')
% elseif isnan(Vol)~=length(Vol) && biomass_conc==1
%     warning('Volume data is available but biomass_conc == 1, it may be preferable to use the more complete biomass calculation')
% end
% 

end
% adapted from Ivan's q calculations code
