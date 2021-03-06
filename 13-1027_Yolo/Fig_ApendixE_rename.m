clear all; close all;
% Figure filename change + MS Word text box change
cd('C:\Work\13-1027_Yolo\DOC\Figure_Templates\Figures Final\Fig D1-64')
curr_dir = pwd;
% This is the first step; changing filenames.

% file_ext = 'jpg';
file_ext = 'docx';
file_search = ['*A7*.' file_ext];

D = dir(file_search);
WY = 1997:2012;

for j = 1:length(D)
    
    old_filename = D(j).name;
    num_str = regexp(old_filename,'\d+','match');
    
    old_filenum = str2double(num_str{2});
    %     old_filename = sprintf('Fig_A7-%d_%s_WY%d.%s',old_fn,alt_type,WY(j),file_ext);
    
    new_WY_ind = old_filenum - floor((old_filenum-1)/16)*16;
    new_WY = WY(new_WY_ind);
    
    alt_ind = regexp(old_filename,'_');
%     period_ind = regexp(old_filename,'\.');
%     new_alt = old_filename(alt_ind(end)+1:period_ind-1);
    alt_type = old_filename(alt_ind(2)+1:alt_ind(3)-1);
    
    new_filename = sprintf('Fig_E%d_WetA_WY%d_%s.%s',old_filenum-80,new_WY,alt_type,file_ext); 
    %     new_filename = sprintf('Fig_A7-%d_%s_WY%d.%s',new_fn,alt_type,WY(j),file_ext);
    
    if isempty(dir(old_filename))
        break
    end
    movefile(old_filename,new_filename);
    
    fprintf(1,'old: %s\n',old_filename)
    fprintf(1,'new: %s\n\n',new_filename)
    
    
    
    %% Text changing
    
    switch file_ext
        case 'docx'
            
            Word = actxserver('Word.application');
            Word.Visible = 0;
            set(Word,'DisplayAlerts',0);
            Docs = Word.Documents;
            Doc = Docs.Open(fullfile(curr_dir,new_filename));
            selection = Word.Selection;
            
            % change 1
            new_figurenum_docx = sprintf('Figure E%d',old_filenum-80);
            selection.Find.Execute('Figure X-X',0,0,0,0,0,1,1,0,new_figurenum_docx,2,0,0,0,0);
            
            % change 2
            selection.Find.Execute('XXX',0,0,0,0,0,1,1,0,'SJB',2,0,0,0,0);
            
            % change 3
            % new_alt_month = new_alt(1:3);
            % new_alt_day = new_alt(4:end);
            new_figuretitle_docx = sprintf('Wetted Area Comparison for WY %d for %s',new_WY,alt_type);
            selection.Find.Execute('Figure Title',0,0,0,0,0,1,1,0,new_figuretitle_docx,2,0,0,0,0);
            
            % change 4
            selection.Find.Execute('Notes:',0,0,0,0,0,1,1,0,'Notes: TUFLOW model results showing 2D inundation patterns (at time specified) for existing and 4/30 gate closure (left panes), Yolo Bypass inflows (upper right panes), and wetted area for all five gate closures (lower right pane)',2,0,0,0,0);
            
            Doc.Save; Docs.Close;
            invoke(Word,'Quit');
            delete(Word);
            
        otherwise
            continue
    end
    
    
    
    
    
end
