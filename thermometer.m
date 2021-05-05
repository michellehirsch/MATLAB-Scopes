function varargout = thermometer(hAx,Trange,Tinit);
% THERMOMETER      Create a graphical thermometer display 
%
% THERMOMETER makes it easy to include a thermometer display in your
% real-time data acquisition and analysis application.  It takes
% 2 steps to use THERMOMETER.  First, you initialize the thermometer with basic
% information needed for the display (display range and initial temperature).
% After that, all you need to do is pass the current temperature to the thermometer.
%
% This documentation starts with the simplest syntax for the two steps,
% then provides a few more advanced options.
%
% STEP 1: Initialize the thermometer
% hAx = THERMOMETER(Trange) converts the current axes to a graphical
% thermometer display.  If no figures exist, a new one will be created.
% Trange = [Tmin Tmax] specifies the minimum and
% maximum of the temperature scale.  Alternatively, Trange = [Tmin Tincr
% Tmax] specifies the scale increment, too.
% hAx is a required output in this case, as it will be passed to all subsequent 
% calls to THERMOMETER.  Specifically, hAx is the handle to the axis containing 
% the thermometer.
%
% STEP 2: Update the thermometer
% THERMOMETER(hAx, T) updates the thermometer display in axis hAx to the
% specified temperature T. hAx was either passed to THERMOMETER during
% initialization, or was returned from the initialization call.
% 
% THERMOMETER(hAx, Trange) creates a new graphical thermometer display in
% the specified axis, hAx.  Trange is as defined above.
%  
% For users who would like more control over the display, 
% [hAx,hPatch] = THERMOMETER(...)
% returns a handle to the patch object used to represent the thermometer
% value (i.e., the mercury). 
% 
%
% Examples:
%   hAx = thermometer([0 30]);   %Create a thermometer in a new figure. Range is 0 to 30 degrees
%   thermometer(hAx,15);         %Set current temperature to 15 degrees
%
%   % Create figure and axes
%   figure;
%   hAx = axes('Position',[.1 .1 .1 .8]);
%   
%   %Create a thermometer on axes hAx.  Scale goes from 0 to 100 in steps
%   % of 20.  Initial value is 40.
%   [hAx,hPatch] = thermometer(hAx,[0 20 100],40);  
%
%   % Set a new color scheme
%   set(hAx,'Color','y');           % Yellow background
%   set(hPatch,'FaceColor','g')     % Green mercury

% Michelle Hirsch
% mhirsch@mathworks.com
% Copyright 2003 - 2014 The MathWorks, Inc

narginchk(1,3)

msg = nargchk(1,3,nargin);
error(msg)

%If first input argument is Trange
if length(hAx)>1
    if nargout==0
        error(['I really want to give you the axis handle.  ' ...
            'Without it, you won''t be able to update the thermometer. ' ...
            'So, let''s try this again, and call me with one output!'])
    end;
    if nargin==1    %Did not specify initial temperature
        Tinit = hAx(1) + .1*(hAx(end)-hAx(1));   % Default Value
    else
        Tinit = Trange; %Re-define input argument
    end;
    Trange = hAx;
    
    %% Create a figure if none exist
    % Otherwise, use current axes.
    hFigs = findobj(0,'Type','figure');
    if isempty(hFigs)
        hAx = localCreateFig;
    else
        hAx = gca;
    end;
    
    [hAx,hPatch] = thermometer(hAx,Trange,Tinit);
    
    varargout{1} = hAx;
    
else
    if ~strcmp(get(hAx,'Type'),'axes')
        error('With 2 or 3 input arguments, the first argument must be an axis handle');
    end;
    
    if length(Trange)==2 | length(Trange)==3
        if length(Trange)==3
            incr = Trange(2);
            Trange = Trange([1 3]);
        else
            incr=5;
        end;
        
        if nargin==2    %Did not specify initial temperature
            Tinit = Trange(1) + .1*diff(Trange);   % Default Value
        end;
        
        hPatch = localInitAxes(hAx,Trange,incr,Tinit);
    elseif length(Trange)==1
        Tnew = Trange;
        hPatch = localUpdate(hAx,Tnew);   %Trange is now the new temperature
    else
        error('Second input argument must be [Tmin Tmax] or Tnew');
    end;       
    if nargout
        varargout{1} = hAx;
        varargout{2} = hPatch;
    end;
end



function hPatch = localInitAxes(hAx,Trange,incr,Tinit)
%Are there any thermometer patches on this axis already?  If so, delete
%them
therms = findobj(hAx,'Type','patch','Tag','Thermometer');
if ~isempty(therms)
    delete(therms)
end;


set(hAx, ...
    'Color',[.8 .8 .8], ...
    'TickLength', [0.0500 0.1000], ...
    'XLim',[0 1], ...
    'XColor',[.8 .8 .8], ...
    'XLimMode','manual', ...
    'XTick',0, ...
    'YLim',Trange, ...
    'YLimMode','manual', ...
    'YMinorTick','on', ...
    'YTick',Trange(1):incr:Trange(2));

hPatch = patch([0 1 1 0],[0 0 Tinit Tinit],'r','Tag','Thermometer');
alpha(hPatch,.6)

setappdata(hAx,'PatchHandle',hPatch);

function hPatch = localUpdate(hAx,T)
hPatch = getappdata(hAx,'PatchHandle');

%Force within valid temperature range
yl = get(hAx,'YLim');
if T<yl(1)
    T=yl(1);
elseif T>yl(2)
    T=yl(2);
end;

set(hPatch,'YData',[0 0 T T]);


function hAx = localCreateFig
figure('Position',[200 200 75 200], ...
    'Toolbar','none', ...
    'MenuBar','none', ...
    'NumberTitle','off');
hAx = axes('Position',[.3 .1 .4 .8]);