%% MSFsc calculated by Actigraphy
clear all; close all; clc

filename = 'example_sleep_statistics.txt';  % Change to your actual file name

fid = fopen(filename, 'r');
if fid == -1
    error('Cannot open file %s', filename);
end

headerLine = fgetl(fid);

DayOfWeek = {};
Date = {};
BedTime = duration.empty;
GetUpTime = duration.empty;
TimeInBed = duration.empty;
TotalSleepTime = duration.empty;
OnsetLatency = duration.empty;
SleepEfficiency = [];
WASO = duration.empty;
Awakenings = [];

lineNum = 0;
while ~feof(fid)
    tline = fgetl(fid);
    if ischar(tline) && ~isempty(tline)
        lineNum = lineNum + 1;
        parts = strsplit(tline, ',');
        DayOfWeek{lineNum, 1} = parts{1};
        Date{lineNum, 1} = parts{2};
        BedTime(lineNum, 1) = duration(parts{3}, 'InputFormat', 'hh:mm:ss');
        GetUpTime(lineNum, 1) = duration(parts{4}, 'InputFormat', 'hh:mm:ss');
        TimeInBed(lineNum, 1) = duration(parts{5}, 'InputFormat', 'hh:mm:ss');
        TotalSleepTime(lineNum, 1) = duration(parts{6}, 'InputFormat', 'hh:mm:ss');
        OnsetLatency(lineNum, 1) = duration(parts{7}, 'InputFormat', 'hh:mm:ss');
        se = strrep(parts{8}, '%', '');
        SleepEfficiency(lineNum, 1) = str2double(se);
        WASO(lineNum, 1) = duration(parts{9}, 'InputFormat', 'hh:mm:ss');
        Awakenings(lineNum, 1) = str2double(parts{10});
    end
end

fclose(fid);

disp(table(DayOfWeek, BedTime, GetUpTime, TimeInBed, ...
    'VariableNames', {'DayOfWeek', 'BedTime', 'GetUpTime', 'TotalSleepTime'}))

MSF = calculateMSF(DayOfWeek, BedTime, TimeInBed);
fprintf('Midsleep on Free days (MSF): %s\n', char(MSF));
fprintf('MSF in hours: %.2f\n', hours(MSF));

MSFsc = calculateMSFsc(DayOfWeek, BedTime, TimeInBed);
fprintf('Corrected Midsleep on Free Days (MSFsc): %s\n', char(MSFsc));
fprintf('MSFsc in hours: %.2f\n', hours(MSFsc));

MSFsc_seconds = seconds(MSFsc);
fprintf('MSFsc in seconds: %.0f\n', MSFsc_seconds);
