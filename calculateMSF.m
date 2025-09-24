function MSF = calculateMSF(DayOfWeek, BedTime, TotalSleepTime)
    % Input:
    %   DayOfWeek: cell array of day names (e.g., 'Saturday', 'Sunday', etc.)
    %   BedTime: duration array of sleep onset times (bed time)
    %   TotalSleepTime: duration array of total sleep times
    
    weekendIdx = strcmpi(DayOfWeek, 'Saturday') | strcmpi(DayOfWeek, 'Sunday');
    
    if ~any(weekendIdx)
        error('No weekend data found.');
    end
    
    BT = BedTime(weekendIdx);
    TST = TotalSleepTime(weekendIdx);
    
    BT_hours = hours(BT);
    TST_hours = hours(TST);
    
    BT_adj = BT_hours;
    idx_before_midnight = BT_hours >= 12;
    BT_adj(idx_before_midnight) = BT_adj(idx_before_midnight) - 24;
    
    % Calculate MSF = adjusted BedTime + half Total Sleep Time
    MSF_hours = BT_adj + TST_hours/2;
    
    % Wrap MSF_hours into [0,24) range using mod
    MSF_hours = mod(MSF_hours, 24);
    
    % Convert back to duration
    MSF_durations = hours(MSF_hours);
    
    % Average MSF (mean of all weekend days)
    MSF = mean(MSF_durations);
end

