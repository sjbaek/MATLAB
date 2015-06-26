clear all; close all
% only when debugging
cd('C:\Work\13-1027_Yolo\LT model\TUFLOW\Time_Series_plot')

path_PO = 'PO_files';
PO = dir([path_PO '\*.csv']);

path_OBS = 'OBS_data';
OBS = dir([path_OBS '\*.mat']);

%% Read Model Run length file (hardwired)
% [fn,pn] = uigetfile('*.cfg', 'Pick a configuration file ...');
% 
fidc = fopen('Model_Run_length.txt');
% 
% C_cfg = textscan(fidc,'%s','delimiter',sprintf('\n'));
Output = textscan(fidc,'%f%f%s%f%s','delimiter','\t','headerlines',1);
modelYear = Output{1};
startHr   = Output{2};
endHr     = Output{4};
startDate = Output{3};
endDate   = Output{5};
% 
fclose(fidc);
%%

% cd(path_PO)
% flt_path = pwd;
% 
% s = regexp(pwd,'\','split');
% model_year = str2double(s{end-2});

%%
% modelYear = 1997:2012;

%% plot setup
% Figure template
fig_text.source = 'TUFLOW model output: Fremont modeled and observed data';
fig_text.proj_title='Yolo Bypass Fish Passage';
fig_text.proj_number='13-1027';
fig_text.created_by = 'SB';
% fig_text.description = ['Water surface profiles ' char(8212) ' 2' char(8211) 'year'];
fig_text.description = 'Fremont Stage';
fig_text.fig_number = num2str(2);

%% subplot positions
subplots = zeros(3,4);
fig_height = 0.23;
for k = 1:3
    subplots(k,1:4) = [0.15 0.13+(fig_height+0.05)*(k-1) 0.75 fig_height];
end
% [hf_1,h_axes1]=cbec_fig_11x17('portrait',fig_text);
[hf_1,h_axes1]=cbec_fig_11x17('portrait',fig_text,subplots);

%% TS: OBS data

for j = 1:length(OBS)   % read MAT files for OBS data
    load([path_OBS '\' OBS(j).name])
end

%{
variable names
freH_time, freH_data : hourly
freQ_time, freQ_data : daily
vonQ_time, vonQ_data : daily
yby_time, yby_data   : hourly
%}

%% TS: PO files (model results)
% line_color = ...
%     {'b','r','g','c','k','m','b','r','g','c','k','m','b','r','g','c','k','m'};
line_color = {'b','r','g','b','b','r','r','g','c','c','g','c','k','k','k','m'};

min_value_old = 0;
max_value_old = 0;

%% year category
dry_yr  = [2001 2002 2007 2008 2009];
norm_yr = [2000 2003 2004 2005 2010 2012];
wet_yr  = [1997:1999 2006 2011];

leg_dry  = {'2001';'2002';'2007';'2008';'2009'};
leg_norm = {'2000';'2003';'2004';'2005';'2010';'2012'};
leg_wet  = {'1997';'1999';'2006';'2011'};
%% Modeled data
h_scatter = zeros(length(modelYear),1);
for j = 1:length(modelYear)
    
    fname_PO = PO(j).name;
    fidPO = fopen(fullfile(path_PO,fname_PO));
    readfmt = ['%*s%f' repmat('%*f',1,23) '%f%*f%f%*f%*f%f'];
    PO_Model_data = textscan(fidPO,readfmt,'delimiter',',','headerlines',2);
    fclose(fidPO);
    
    TS_PO_hr = PO_Model_data{1};
    TS_PO = TS_PO_hr(TS_PO_hr>=startHr(j) & TS_PO_hr<=endHr(j));
    
    % --------- plot data
    Data_FreWSE_w = PO_Model_data{2}(TS_PO_hr>=startHr(j) & TS_PO_hr<=endHr(j));
    Data_FreWSE_e = PO_Model_data{3}(TS_PO_hr>=startHr(j) & TS_PO_hr<=endHr(j));
    Data_FreQ = PO_Model_data{4}(TS_PO_hr>=startHr(j) & TS_PO_hr<=endHr(j));
    
        
    % in real time (datenum)
    dTS_PO = TS_PO - TS_PO(1);   % time(hour) differences from the 1st entry
    TS_PO_time = addtodate(datenum([1996 10 2 0 0 0]),TS_PO(1),'hour') + dTS_PO./24;
    
    if ~isempty(intersect(modelYear(j),dry_yr))
        curr_axis = h_axes1(1);
    elseif ~isempty(intersect(modelYear(j),norm_yr))
        curr_axis = h_axes1(2);
    else
        curr_axis = h_axes1(3);
    end
    
    %% make two dataset same in length and time scale
        
    %% interpolate OBS data in hourly
    freH_time_plot = freH_time(freH_time>=TS_PO_time(1) & freH_time<TS_PO_time(end));
    freH_data_plot = freH_data(freH_time>=TS_PO_time(1) & freH_time<TS_PO_time(end));
    
    
    %% Remove flatlined WSE (simulated): usually the minimum values in Modeled TS.
    
    ind_flat = Data_FreWSE_w~=min(Data_FreWSE_w);
    
    newT = TS_PO_time(ind_flat);
    newD = Data_FreWSE_w(ind_flat);
    
    %% 
    [C,ia,ib] = intersect(freH_time,newT);
    h_scatter(j) = scatter(curr_axis,freH_data(ia),newD(ib),5,line_color{j},'filled');
    hold(curr_axis,'on')
    grid(curr_axis,'on')
    
    if ~isempty(intersect(modelYear(j),dry_yr))
        if isempty(newD)
            dry_yr(dry_yr == modelYear(j)) = NaN;
        end
    elseif ~isempty(intersect(modelYear(j),norm_yr))
        if isempty(newD)
            norm_yr(norm_yr == modelYear(j)) = NaN;
        end
    else
        if isempty(newD)
            wet_yr(wet_yr == modelYear(j)) = NaN;
        end
    end
    
    
        
end
    % -----------------
    %% Scatter plot
    
xlabel(h_axes1(3),'Observed Stage (ft)','fontsize',8) % bottom figure

legend(h_axes1(1),num2str(dry_yr(~isnan(dry_yr))'),'location','northwest')
legend(h_axes1(2),num2str(norm_yr(~isnan(norm_yr))'),'location','northwest')
legend(h_axes1(3),num2str(wet_yr(~isnan(wet_yr))'),'location','northwest')

x_lim = get(h_axes1(3),'xlim');
y_lim = get(h_axes1(3),'ylim');
end_point = max(x_lim(2),y_lim(2));



for k = 1:3  % number of subplots
    curr_axis = h_axes1(k);
    set(curr_axis,'xlim',[0 end_point]);
    set(curr_axis,'ylim',[0 end_point]);
    plot(curr_axis,[0 end_point],[0 end_point],'k')
    set(curr_axis,'fontsize',8)
    ylabel(curr_axis,'Modeled Stage (ft)','fontsize',8)
    
    plot(curr_axis,[0 32.8],[32.8 32.8],'color',[.8 .8 .8])
    plot(curr_axis,[32.8 32.8],[0 32.8],'color',[.8 .8 .8])
    set(gcf,'CurrentAxes',h_axes1(k))
    text(15,34,'weir crest elevation')
    text(33.5,15,'weir crest elevation','rotation',270,'horizontalalignment','center')
end

title(h_axes1(1),'Dry years')
title(h_axes1(2),'Normal years')
title(h_axes1(3),'Wet years')

print(hf_1,'-dpdf','Fremont_Stage')




