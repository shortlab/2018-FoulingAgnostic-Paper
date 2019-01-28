%% Import and analyze plots from multiple FD files corresponding to a single sample/probe combination
%  Inputs:
folder='D:\Experiment 121\'; % folder should end in '\'
prefix=''; %this comes before FD file number
fd_nums=34:41; %array of numbers of FD files to process
postfix='.txt'; %file extension
outfile=strcat(pwd, '\FD_out.txt');
outfile_n=strcat(pwd, '\FD_filelist.txt');

% FD file properties
% fd_pts=1000; % 1000 approach and retract points - only these curves are imported
fd_cpf=4; % up to 4 FD plots per file are processed, to ensure a unifo rm geometric coverage since each file is at one physical point
fd_minaf=0.005; % minimum applied downward force to accept curve (Volts) (difference between non-contact and highest contact)
fd_maxaf=0.025; % maximum applied downward force to accept curve (Volts)
fd_ncdif=0.0008; % maximum difference between non-contact approach and retract forces to accept curve (Volts) - this filters out 'divergent noise' curves

%% Get set up for loops
% General counters
files_analyzed=0;
curves_analyzed=0;
curves_accepted=0;

% Mean (averaged) value outputs
adh_motion_all=[];
%adh_work_all=[];
%adh_worksq_all=[];
slope_all=[];
noise_all=[];

% Per-file standard deviation outputs
std_motion_all=[];
%std_work_all=[];
%std_worksq_all=[];

fprintf('Analyzing FD data...\n');

fwn = fopen(outfile_n, 'a');

%% Loops
% Loop over files
for(n=fd_nums)
    filename=strcat(folder, prefix, mat2str(n), postfix);
    if(exist(filename, 'file') ~= 2)
        fprintf('\nError: file %s does not exist, continuing on...\n', filename);
        continue;
    end
    fda=ImportFD(filename, fd_pts);
    files_analyzed=files_analyzed+1;
    fprintf(fwn, '%s\r\n', filename);
    fprintf('\nOpening file %s\n', filename);
    if(mod(length(fda),2))
        fprintf('Error: odd number of curves in file %s\n', filename);
    end
    
    adh_motion_file=[]; % initialize empty array for all curves in this file
    %adh_work_file=[];
    %adh_worksq_file=[];
    slope_file=[];
    noise_file=[];
    curves_file=0;
    
    % Loop over FD curves in one file
    for(c=1:2:length(fda)) % every other curve is in (nN) units, which we ignore since they are uncalibrated
        cp=AnalyzeFD(fda{c}); % get salient FD curve properties
        curves_analyzed=curves_analyzed+1;
        dr=abs(cp(1,1)-cp(1,2)); % divergent noise test
        af=(cp(3,1)+cp(3,2))/2-(cp(1,1)+cp(1,2))/2; % applied force test
        if(dr<=fd_ncdif && af>=fd_minaf && af<=fd_maxaf && curves_file<fd_cpf)
            curves_accepted=curves_accepted+1;
            curves_file=curves_file+1;
            adh_motion_file(curves_file)=(cp(4,2)-cp(1,2))/cp(6,2); % (contact min force - non-contact force (V)) / slope (V/nm) = nm deflection due to adhesion
            %adh_work_file(curves_file)=cp(7,1);
            %adh_worksq_file(curves_file)=cp(7,2);
            slope_file(curves_file)=(cp(6,1)+cp(6,2))/2;
            noise_file(curves_file)=(cp(2,1)+cp(2,2))/2;
        end
    end
    
    if(curves_file<4)
        fprintf('* Only %d/%d valid curves in file %s\n', curves_file, length(fda)/2, filename);
    else
        fprintf('Found %d/%d valid curves in file %s\n', curves_file, length(fda)/2, filename);
    end
    
    % Add this file's contribution to sample-probe mean values array
    adh_motion_all=[adh_motion_all adh_motion_file];
    %adh_work_all=[adh_work_all adh_work_file];
    %adh_worksq_all=[adh_worksq_all adh_worksq_file];
    slope_all=[slope_all slope_file];
    noise_all=[noise_all noise_file];
    
    % Record this file's stdev values for assurance
    std_motion_all=[std_motion_all std(adh_motion_file)];
    %std_work_all=[std_work_all std(adh_work_file)];
    %std_worksq_all=[std_worksq_all std(adh_worksq_file)];
end

fprintf(fwn, '\r\n');

fprintf('\nDone processing.\n');
fprintf('Parsed %d files and %d curves, of which %d were accepted for averaging.\n\n', files_analyzed, curves_analyzed, curves_accepted);

%disp('Mean values mean_val=[adhesive force (V), work of adhesion (V*nm), sqrt(sum(delta^2)*dz) (V*sqrt(nm)), slope (V/nm), noise level NC (V)]');
%mean_val=[mean(adh_motion_all) mean(adh_work_all) mean(adh_worksq_all) mean(slope_all) mean(noise_all)];
disp('Mean values mean_val=[adhesive motion (nm), slope (V/nm), noise level NC (V)]');
mean_val=[mean(adh_motion_all) mean(slope_all) mean(noise_all)];
disp(mean_val);

%disp('Stdev values std_val=[adhesive force (V), work of adhesion (V*nm), sqrt(sum(delta^2)*dz) (V*sqrt(nm))]');
%std_val=[std(adh_motion_all) std(adh_work_all) std(adh_worksq_all)];
disp('Stdev values std_val=[adhesive motion (nm)]');
std_val=[std(adh_motion_all)];
disp(std_val);

%disp('Per-file RMS stdev values pf_std_val=[adhesive force (V), work of adhesion (V*nm), sqrt(sum(delta^2)*dz) (V*sqrt(nm))]');
%pf_std_val=[rms(std_motion_all) rms(std_work_all) rms(std_worksq_all)];
disp('Per-file RMS stdev values pf_std_val=[adhesive motion (nm)]');
pf_std_val=[rms(std_motion_all)];
disp(pf_std_val);

dlmwrite(outfile, [mean_val std_val pf_std_val curves_accepted], '-append');
fclose(fwn);