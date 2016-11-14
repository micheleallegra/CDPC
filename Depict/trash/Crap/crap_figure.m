function varargout=crap_figure(varargin)

%-Condition arguments
%-----------------------------------------------------------------------
if (nargin==0), Action = 'createwin'; else, Action = varargin{1}; end

switch lower(Action)

%=======================================================================

case 'createwin'
% F=crap_figure('CreateWin',Tag,Name,Visible)

if nargin<4 | isempty(varargin{4}), Visible='on'; else, Visible=varargin{4}; end
if nargin<3, Name=''; else, Name = varargin{3}; end
if nargin<2, Tag='';  else, Tag  = varargin{2}; end

WS   = spm('WinScale');                         %-Window scaling factors
FS   = spm('FontSizes');                        %-Scaled font sizes
PF   = spm_platform('fonts');                   %-Font names (for this platform)
Rect = spm('WinSize','Graphics','raw').*WS;     %-Graphics window rectangle
Rect = Rect+[100 50 0 -50];

F      = figure(...
        'Tag',Tag,...
        'Position',Rect,...
        'Resize','off',...
        'Color','w',...
        'ColorMap',gray(64),...
        'DefaultTextColor','k',...
        'DefaultTextInterpreter','none',...
        'DefaultTextFontName',PF.helvetica,...
        'DefaultTextFontSize',FS(10),...
        'DefaultAxesColor','w',...
        'DefaultAxesXColor','k',...
        'DefaultAxesYColor','k',...
        'DefaultAxesZColor','k',...
        'DefaultAxesFontName',PF.helvetica,...
        'DefaultPatchFaceColor','k',...
        'DefaultPatchEdgeColor','k',...
        'DefaultSurfaceEdgeColor','k',...
        'DefaultLineColor','k',...
        'DefaultUicontrolFontName',PF.helvetica,...
        'DefaultUicontrolFontSize',FS(10),...
        'DefaultUicontrolInterruptible','on',...
        'PaperType','A4',...
        'PaperUnits','normalized',...
        'PaperPosition',[.0726 .0644 .854 .870],...
        'InvertHardcopy','off',...
        'Renderer','zbuffer',...
        'Visible','on');

if ~isempty(Name)
        set(F,'Name',sprintf('%s%s',[spm('ver') ' Crap Toolbox'],...
                spm('GetUser',' (%s)')),'NumberTitle','off')
end

%crap_figure('FigContextMenu',F);
set(F,'Visible',Visible)
varargout = {F};



case 'findwin'
%=======================================================================

if nargin<2, F='Graphics1'; else, F=varargin{2}; end

if isempty(F)
        % Leave F empty
elseif ischar(F)
        % Finds Graphics window with 'Tag' string - delete multiples
        Tag=F;
        F = findobj(get(0,'Children'),'Flat','Tag',Tag);
        if length(F) > 1
                % Multiple Graphics windows - close all but most recent
                close(F(2:end))
                F = F(1);
        end
else
        % F is supposed to be a figure number - check it
        if ~any(F==get(0,'Children')), F=[]; end
end
varargout = {F};

case 'getwin'
%=======================================================================

if nargin<2, Tag='Graphics1'; else, Tag=varargin{2}; end

%disp('find wind')
F = crap_figure('FindWin',Tag);

if isempty(F)
        if ischar(Tag)
                switch Tag, case 'Interactive'
                        F = spm('CreateIntWin');
                otherwise
                        F = crap_figure('createwin',Tag,Tag);
                end
        end
else
        set(0,'CurrentFigure',F);
end
varargout = {F};

%disp('created wind')
%F

case 'clear'
%=======================================================================

%-Sort out arguments
%-----------------------------------------------------------------------
if nargin<3, Tags=[]; else, Tags=varargin{3}; end
if nargin<2, F=get(0,'CurrentFigure'); else, F=varargin{2}; end
F = crap_figure('FindWin',F);
if isempty(F), return, end

%-Clear figure
%-----------------------------------------------------------------------
if isempty(Tags)
        %-Clear figure of objects with 'HandleVisibility' 'on'
        %findobj(get(F,'Children'))   deletes all 'things' on the window
        delete(findobj(get(F,'Children'),'flat','HandleVisibility','on'));
        %-Reset figures callback functions
        set(F,'KeyPressFcn','',...
                'WindowButtonDownFcn','',...
                'WindowButtonMotionFcn','',...
                'WindowButtonUpFcn','')
        %-If this is the 'Interactive' window, reset name & UserData
        if strcmp(get(F,'Tag'),'Interactive')
                set(F,'Name','','UserData',[]), end
else
        %-Clear specified objects from figure
        cSHH = get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on')
        if ischar(Tags); Tags=cellstr(Tags); end
        if any(strcmp(Tags(:),'!all'))
                delete(get(F,'Children'))
        else
            for tag = Tags(:)'
                delete(findobj(get(F,'Children'),'flat','Tag',tag{:}));
            end
        end
        set(0,'ShowHiddenHandles',cSHH)
end
set(F,'Pointer','Arrow')




otherwise
%=======================================================================
warning(['Illegal Action string: ',Action])


%=======================================================================
end
                 

