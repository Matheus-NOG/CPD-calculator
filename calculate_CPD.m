%% Compute CPD from multiple actigraphy .txt files using MSFsc values
clear; clc;

%% Read sleep statistics from TXT file

filename = 'example_sleep_statistics.txt'; % Change this to your txt file path

%Insert here the MSFsc in seconds calculated from "calculate_MSFsc_from_txt.m"
MSFsc = 15565;

fid = fopen(filename, 'r');
if fid == -1
    error('Cannot open file: %s', filename);
end

header_line = fgetl(fid);

bed_times = {};
get_up_times = {};

tline = fgetl(fid);
while ischar(tline)
    parts = strsplit(tline, ',');
    if length(parts) >= 4
        bed_times{end+1} = strtrim(parts{3});     % Bed Time
        get_up_times{end+1} = strtrim(parts{4});  % Get Up Time
    end
    tline = fgetl(fid);
end

fclose(fid);

%% Convert time strings to datetime

formatIn = 'HH:mm:ss';

num_bed = datetime(bed_times, 'InputFormat', formatIn);
num_get_up = datetime(get_up_times, 'InputFormat', formatIn);

% Convert datetime to fractional day number (0 to 1)
num_bed_num = hour(num_bed)/24 + minute(num_bed)/(24*60) + second(num_bed)/(24*3600);
num_get_up_num = hour(num_get_up)/24 + minute(num_get_up)/(24*60) + second(num_get_up)/(24*3600);

% Format times as HH:MM strings

formatted_times_bed = cell(size(bed_times));
formatted_times_get_up = cell(size(get_up_times));

for i = 1:length(bed_times)
    h = hour(bed_times(i));
    m = minute(bed_times(i));

    % Handle minute overflow (just in case)
    if m == 60
        m = 0;
        h = h + 1;
    end
    if h == 24
        h = 0;
    end

    formatted_times_bed{i} = sprintf('%02d:%02d', h, m);
end

for i = 1:length(get_up_times)
    h = hour(get_up_times(i));
    m = minute(get_up_times(i));

    if m == 60
        m = 0;
        h = h + 1;
    end
    if h == 24
        h = 0;
    end

    formatted_times_get_up{i} = sprintf('%02d:%02d', h, m);
end


% Calculate mean sleep times

MS_cell = cell(size(formatted_times_bed));

for i = 1:numel(formatted_times_bed)
    A_time = datetime(formatted_times_bed{i}, 'InputFormat', 'HH:mm');
    B_time = datetime(formatted_times_get_up{i}, 'InputFormat', 'HH:mm');
    
    A_hours = hour(A_time) + minute(A_time)/60;
    B_hours = hour(B_time) + minute(B_time)/60;
    
    if B_hours < A_hours
        B_hours = B_hours + 24;  % Adjust for next day
    end
    
    mean_hours = (A_hours + B_hours)/2;
    
    mean_time = hours(mean_hours);
    MS_cell{i} = datestr(mean_time, 'HH:MM');
end

timeCellArray_dt = datetime(MS_cell, 'InputFormat', 'HH:mm');

% Create reference date as datetime object (today's date)
refDate = datetime(year(datetime('today')), month(datetime('today')), day(datetime('today')));

% Convert MSFsc seconds after midnight into datetime on reference date
MS_fsc_dt = refDate + seconds(MSFsc);

% Align all times to the same reference date
timeCellArray_dt_fixed = refDate + timeofday(timeCellArray_dt);

% Compute difference as durations
x_i = MS_fsc_dt - timeCellArray_dt_fixed;

% Handle wrap-around (crossing midnight)
x_i(x_i < -hours(12)) = x_i(x_i < -hours(12)) + days(1);
x_i(x_i > hours(12)) = x_i(x_i > hours(12)) - days(1);

% Convert duration to seconds
x_i = seconds(x_i);



%% Calculate y_i (differences between consecutive mean sleep times)

timeDuration = duration(MS_cell, 'InputFormat', 'hh:mm');
timeDifferences = diff(timeDuration);

y_i_time = -timeDifferences;
y_i = seconds(y_i_time);
y_i = y_i(:);  % convert to column vector
y_i = [0; y_i];


%% Calculate CPD for all days

x_i = x_i(:);  
y_i = y_i(:);  

CPD_i = sqrt(x_i.^2 + y_i.^2);  

N_days = length(CPD_i);

CPD = sum(CPD_i) / N_days;

fprintf('Composite Phase Deviation (CPD) = %.3f seconds\n', CPD);
