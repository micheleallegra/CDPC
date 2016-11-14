global defaults

fg = depict_figure('getWin','Graphics1');
delete(fg)

fg = depict_figure('getWin','SelectPar');
delete(fg)

fg = depict_figure('getWin','SelectFiles');
delete(fg)

fg = depict_figure('getWin','Apply');
delete(fg)

fg = depict_figure('getWin','Script');
delete(fg)


try 
  close(herror1)
  delete(herror1)
end

try
   %depict_figure('Clear','SelectedFiles');
   fg1 = depict_figure('GetWin','SelectedFiles');
   close(fg1);
%  delete(fgFiles)
end

try
  delete(The_files_to_cluster)
end



clear st MAP SPM xSPM CLUSTER displayType group defaults;


try; delete(st.FX); end
try
    spm_defaults = defaults.oldDefaults;
catch
    spm_defaults;
end
%spm_figure('getWin','Graphics');

