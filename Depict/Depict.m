function Depict(varargin)

global The_files_to_cluster
global The_mask

global CONNECTEDCUT
global interactive
global vol_begin
global vol_end
global winlen
global NCUT
global SPATIALCUT
global RHO
global NCLUST_MAX

global busy

CONNECTEDCUT=0;
interactive=0;
NCUT=200;
SPATIALCUT=5;
RHO=0;
NCLUST_MAX=10;
vol_begin=1;
vol_end=1;
winlen=12;

busy=0;

The_files_to_cluster=[];
The_mask=[];

global defaults    %%% def. spm parameters
global st



    try
        if numel(defaults)==0
            try
                spm_defaults;
            catch
                try
                    spm('ChMod','FMRI')
                end
            end
        end
        defaults.oldDefaults = defaults;
    end



fg = depict_figure('GetWin','Graphics1');


if isempty(fg), error('Can''t create graphics window'); end
depict_figure('Clear','Graphics1');

set(gcf,'DefaultUicontrolFontSize',spm('FontSizes',get(gcf,'DefaultUicontrolFontSize')));

WS = spm('WinScale');

    st.SPM = spm('FnBanner');

uicontrol(fg,'Style','Text','Position',[25 680 550 75].*WS,'String','DEnsity Peak Image Clustering Toolbox (DEPICT) v0.7',...
    'FontSize',30,'FontWeight','bold','BackgroundColor',[1 1 1],'HorizontalAlignment','Center');


uicontrol(fg,'Style','PushButton','Units','normalized','Position',[.05 .70 .9 .055],'Callback','depict_select;',...
    'String','Select images','FontSize',spm('FontSizes',12));

uicontrol(fg,'Style','PushButton','Units','normalized','Position',[.05 .70-2*0.075 .9 0.055],'Callback','depict_select_parameters;',...
    'String','Select clustering options','FontSize',spm('FontSizes',12));

uicontrol(fg,'Style','PushButton','Units','normalized','Position',[.05 .70-4*0.075 .9 0.055],'Callback','depict_apply;',...
    'String','Apply clustering','FontSize',spm('FontSizes',12));

uicontrol(fg,'Style','PushButton','Units','normalized','Position',[.05 .70-6*0.075 .9 0.055],'Callback','depict_generate_script;',...
    'String','Generate script','FontSize',spm('FontSizes',12));

uicontrol(fg,'Style','PushButton','Units','normalized','Position',[.8 .05 .1 .05],'Callback','depict_exit;',...
    'String',{'Quit'},'FontSize',spm('FontSizes',10));

























