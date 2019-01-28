function output_fd = ImportFD(filename, numpts)
% Imports FD file from ezAFM software as cell array of FD curves
% input: filename = string of full path to file
%        numpts = integer number of points in approach and retract curves
%            that will be accepted
% output: output_fd = cell array where each item is a numpts-by-3 matrix
%           where first column is distance (nm), second is approach force
%           (V), third is retract force (V)

numpts=1000; % FD curves must have this many points to be accepted

fid=fopen(filename);

% approach: search for 'Approach' by repeated calling of textscan(fid, '%s', 1)
% then test that 1000 points are logged by textscan(fid, '%s', 3), there
% are two #FF... lines and 3rd line will have number of points
% then import next 1000 points by textscan(fid, '%f %f', 1000)
% then 'Retract' line, 2 #FF... lines and 1 line should show 1000 points
% then import next 1000 points by textscan(fid, '%f %f', 1000)
% continue to search for 'Approach'

temp_fd=zeros(numpts,3); %z (nm), approach force (V), retract force (V)
output_fd=cell(1); %this will get expanded over time
read_fds=0;

% find the next 'Approach'
while(~feof(fid))
   tline=fgetl(fid); 
   if(strcmp(tline, 'Approach'))
       fgetl(fid);% this line contains #something
       fgetl(fid);% this line contains #something
       tline=fgetl(fid);% this line contains number of points like 1000
       np=sscanf(tline, '%d'); %get integer number of points
       if(np==numpts) %save this data
           for(n=1:np)
               tline=fgetl(fid);
               vs=sscanf(tline, '%f %f');
               temp_fd(n,1:2)=vs(:);
           end
           tline=fgetl(fid);% see if retract immediately follows approach, then they are assumed to be associated
           if(strcmp(tline, 'Retract'))
               fgetl(fid);% this line contains #something
               fgetl(fid);% this line contains #something
               tline=fgetl(fid);% this line contains number of points like 1000
               np=sscanf(tline, '%d'); %get integer number of points
               if(np==numpts) %save this data
                   for(n=np:-1:1)
                       tline=fgetl(fid);
                       vs=sscanf(tline, '%f %f');
                       temp_fd(n,3)=vs(2);
                   end
                   read_fds=read_fds+1;
                   output_fd{read_fds}=temp_fd;
               end
           end
       end
   end
end

fclose(fid);
end