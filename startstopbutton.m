function varargout = startstopbutton(fig,obj,varargin)
%STARTSTOPBUTTON       Add a stop/start button to control a timed object 
%
% STARTSTOPBUTTON(FIG,OBJ) adds a start/stop button to figure FIG.  This
% button can be used to start and stop object OBJ. OBJ can be any object
% that supports "start" and "stop" commands.
%
% STARTSTOPBUTTON will also delete OBJ when FIG is closed (i.e., it sets
% FIG's CloseRequestFcn to delete the object)
%
% STARTSTOPBUTTON(FIG,OBJ,'P1','V1','P2','V2', ...) specifies Property-Value
% pairs for configuring properties of the start/stop button.  Any valid
% property of a togglebutton can be specified.
%
% STARTSTOPBUTTON(HBUTTON,OBJ) turns existing uicontrol HBUTTON into a
% start/stop button.
%
% HBUTTON = STARTSTOPBUTTON(...) returns a handle to the start/stop button
%
% Note: This button does not "listen" to determine if your object changes
%   state.  For instance, if you have a finite number of samples
%   acquired after starting, the button will not reset automatically
%   when your object stops running.  Don't despair, since it is easy
%   enough to do on your own!
%
% Example: Add a button to a window that starts and stops a timer. The
% timer simply displays the current date and time in the command window.
%
%      fh = figure;                         % Create a figure
%      t = timer;
%      t.ExecutionMode = 'fixedRate';
%      t.TimerFcn = @(~,~) disp(datestr(now))
%      hButton = startstopbutton(fh,t);      % Add the stopbutton

%   Michelle Hirsch 
%   mhirsch@mathworks.com
%   Copyright 2003-2014 The MathWorks, Inc. 

%Error checking
narginchk(2,inf)

if ~all(isvalid(obj))
    error('Second input argument must be valid data acquisition object')
end;

if ~ishandle(fig)
    error('First input argument must be handle to a figure or a uicontrol');
end;

% Check if user input handle to figure or handle to button
switch get(fig,'Type')
    case 'figure'

        % Create the button
        hButton = uicontrol(fig,'style','togglebutton',varargin{:});
    case 'uicontrol'
        hButton = fig;
        fig = get(hButton,'Parent');
        % In R14, it's possible that fig would return a handle to a panel, not a figure
        if ~strcmp(get(fig,'Type'),'figure')
            fig = get(fig,'Parent');
        end;
end;

%Check current state of the object
val = strcmp(obj.Running,'On');

if val==1       %Already running
    set(hButton,'String','Stop');
    set(hButton,'Value',1)
else
    set(hButton,'String','Start');
    set(hButton,'Value',0)
end;

set(hButton,'Callback',{@localStartStopObject,obj})

% Configure the CloseRequestFcn of the figure
setappdata(fig,'DaqStopButtonObject',obj)
cr = get(fig,'CloseRequestFcn');
cr = ['obj=getappdata(gcf,''DaqStopButtonObject'');stop(obj);delete(obj);' cr];
set(fig,'CloseRequestFcn',cr);

% Return a handle to the button
if nargout
    varargout{1} = hButton;
end;


function localStartStopObject(hButton,action,obj)
% Callback for the start/stop button
val = get(hButton,'Value');
if val==1       %Pushed in
    set(hButton,'String','Stop');
    if all(isvalid(obj))
        start(obj)
    end;
else
    set(hButton,'String','Start');
    if all(isvalid(obj))
        stop(obj)
    end;
end;

