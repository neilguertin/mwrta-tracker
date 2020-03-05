function logger
url = 'http://vc.mwrta.com/api/FR/text';
datetimefmt = 'yyyy-MM-dd''T''HH:mm:ss';
datefmt = 'yyyy-MM-dd';

numerrors = 0;

firstDay = datetime('today');

% Initialize variables. If log is already started, use it. Otherwise empty.
fname = fullfile('logs',sprintf('mwrta_%s.log',string(firstDay,datefmt)));
if isfile(fname)
    [logDateTimes, dataDateTimes, routes, vehicles, lats, lons] = readlog(fname);
else
    logDateTimes = datetime.empty;
    dataDateTimes = datetime.empty;
    routes = string.empty;
    vehicles = string.empty;
    lats = [];
    lons = [];
end

lastTimes = containers.Map;
while true
    try
    
    % at the end of the day, make and save table, and reset local variables
    curDay = datetime('today');
    if curDay ~= firstDay
        % save data as table
        T = table(logDateTimes',dataDateTimes',categorical(routes'),categorical(vehicles'),lats',lons','VariableNames',{'DateTime','DataDateTime','Route','Vehicle','Lat','Lon'});
        fname = sprintf('mwrta_%s.mat',string(firstDay,datefmt));
        save(fullfile('logs',fname),'T');

        % reset variables
        logDateTimes = datetime.empty;
        dataDateTimes = datetime.empty;
        routes = string.empty;
        vehicles = string.empty;
        lats = [];
        lons = [];
        
        % switch to tomorrow
        firstDay = curDay;
    end
    
    while true
        try
            allRows = webread(url);
            break
        catch e
            if strcmp(e.identifier,'MATLAB:webservices:Timeout')
                fprintf("Lost connection at %s\n",datetime);
                pause(30)
            else
                return
            end
        end
    end
    
    % TODO: check if I can use ID field
    % TODO: check if I can use ScheduleDelta field
    for i = 1:numel(allRows)

        % get data fields
        row = allRows(i);
        logDateTime = datetime('now','Format',datetimefmt);
        dataDateTime = datetime(row.DateTime,'InputFormat',datetimefmt,'Format',datetimefmt);
        route = getShortRouteName(row.Route);
        vehicle = row.VehiclePlate;
        lat = row.Lat;
        lon = row.Long;

        % skip this row if we've seen it before
        if lastTimes.isKey(vehicle) && lastTimes(vehicle) == dataDateTime
            continue
        end
        lastTimes(vehicle) = dataDateTime;
        
        % as a backup, always print to log file
        curDay = datetime('today');
        fname = sprintf('mwrta_%s.log',string(curDay,datefmt));
        fid = fopen(fullfile('logs',fname),'a');
        fprintf(fid,'%s %s %5s %3s %2.5f %2.5f\n',logDateTime,dataDateTime,route,vehicle,lat,lon);
        fclose(fid);

        % as an extra backup/debugging step, print to command window
        %disp(string(logDateTime) + " " + string(rowDateTime) + " " + pad(string(route),5) + " " + pad(string(vehicle),3) + " " + string(lat) + " " + string(lon))

        % save data from this row to be put in table later
        %#ok<*AGROW> runs once per second, speed does not matter
        % colon index is to force column vector
        logDateTimes(end+1,:) = logDateTime;  
        dataDateTimes(end+1,:) = dataDateTime;
        routes(end+1,:) = route;
        vehicles(end+1,:) = vehicle;
        lats(end+1,:) = lat;
        lons(end+1,:) = lon;
    end
    pause(1)
    catch e
        % TODO: sometimes errors because one json entry is a 0x0 double,
        % so the value returned from webread is a cell array of structs
        % instead of a struct array.
        fprintf("Error at %s\n",datetime)
        text = webread(url,weboptions('ContentType','text'));
        display(e)
        numerrors = numerrors+1;
        fname = sprintf("error%d.mat",numerrors);
        save(fname)
    end
end
end

function shortName = getShortRouteName(longName)
switch(longName)
    case 'Natick Commuter Shuttle'
        shortName = 'NCS';
    case 'Mass Bay Riverside Shuttle'
        shortName = 'MBRS';
    case 'Mass Bay Campus to Campus Shuttle'
        shortName = 'MBCCS';
    case 'MathWorks Express Shuttle'
        shortName = 'MWEX';
    case 'Mass Bay Cushing Parking Shuttle'
        shortName = 'MBCPS';
    case 'CSBSCS'
        shortName = 'BSCS';
    case 'CSFCS'
        shortName = 'FCS';
    otherwise
        shortName = longName;
end
end