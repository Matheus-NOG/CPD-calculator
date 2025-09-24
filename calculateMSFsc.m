function MSFsc = calculateMSFsc(DayOfWeek, BedTime, TotalSleepTime)
    weekendIdx = strcmpi(DayOfWeek, 'Saturday') | strcmpi(DayOfWeek, 'Sunday');
    weekdayIdx = strcmpi(DayOfWeek, 'Monday') | strcmpi(DayOfWeek, 'Tuesday') | ...
                 strcmpi(DayOfWeek, 'Wednesday') | strcmpi(DayOfWeek, 'Thursday') | ...
                 strcmpi(DayOfWeek, 'Friday');

    if ~any(weekendIdx) || ~any(weekdayIdx)
        error('Insufficient data: both weekend and weekday entries are required.');
    end

    BT = BedTime(weekendIdx);
    TST = TotalSleepTime(weekendIdx);
    BT_hours = hours(BT);
    TST_hours = hours(TST);

    BT_adj = BT_hours;
    idx_before_midnight = BT_hours >= 12;
    BT_adj(idx_before_midnight) = BT_adj(idx_before_midnight) - 24;

    % Compute midsleep times and average
    MSF_all = BT_adj + TST_hours / 2;
    MSF_all = mod(MSF_all, 24);
    MSF = mean(MSF_all);  % in hours

    % Compute sleep durations
    SDURweekend = mean(hours(TotalSleepTime(weekendIdx)));
    SDURweekday = mean(hours(TotalSleepTime(weekdayIdx)));
    SDURweekly = (SDURweekday * 5 + SDURweekend * 2) / 7;

    % Compute MSFsc
    if SDURweekend > SDURweekday
        MSFsc_hours = MSF - (SDURweekend - SDURweekly)/2;
    else
        MSFsc_hours = MSF;
    end

    MSFsc_hours = mod(MSFsc_hours, 24);

    % Return as duration
    MSFsc = hours(MSFsc_hours);
end
