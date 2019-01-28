function outp = AnalyzeFD(in_FD)
% input FD matrix:
% [ z value (nm), approach force value (V), retract force value (V)
%   ... ] 1000 points

% output FD properties:
% [ approach non-contact value (V), retract non-contact value (V)
%   approach non-contact noise level (V), retract non-contact noise level (V)
%   approach maximum force (V), retract maximum force (V)
%   approach minimum force (V), retract minimum force (V)
%   approach contact point (row), retract contact point (row)
%   approach contact slope (V/nm), retract contact slope (V/nm)
%   work of adhesion (V*nm), sqrt of sum of squares of adhesion (V*sqrt(nm)) ]

outp=zeros(6,2);

outp(1,1) = mean(in_FD(1:150,2));
outp(1,2) = mean(in_FD(1:150,3));

outp(2,1) = std(in_FD(1:150,2));
outp(2,2) = std(in_FD(1:150,3));

outp(3,1) = in_FD(end,2);
outp(3,2) = in_FD(end,3);

outp(4,1) = min(in_FD(:,2));
outp(4,2) = min(in_FD(:,3));

% for slope, see at what point value at + 10 nm is higher/equal to previous
sl_test=in_FD(end, 2);
sl_pt=959; %decrement by 20 (another 21 to avoid out-of-bounds error or divide-by-zero error)
while(sl_test>in_FD(sl_pt, 2))
    sl_test=in_FD(sl_pt, 2);
    sl_pt=sl_pt-20;
end
sl_pt=sl_pt+40;
outp(5,1) = sl_pt;
msl=polyfit(in_FD(sl_pt:end, 1), in_FD(sl_pt:end, 2), 1);
outp(6,1) = msl(1); %(in_FD(end,2)-in_FD(sl_pt,2))/(in_FD(end,1)-in_FD(sl_pt,1));

sl_test=in_FD(end, 3);
sl_pt=959; %decrement by 20 (another 21 to avoid out-of-bounds error or divide-by-zero error)
while(sl_test>in_FD(sl_pt, 3))
    sl_test=in_FD(sl_pt, 3);
    sl_pt=sl_pt-20;
end
sl_pt=sl_pt+40;
outp(5,2) = sl_pt;
msl=polyfit(in_FD(sl_pt:end, 1), in_FD(sl_pt:end, 3), 1);
outp(6,2) = msl(1); %(in_FD(end,3)-in_FD(sl_pt,3))/(in_FD(end,1)-in_FD(sl_pt,1));

df=in_FD(:,2)-in_FD(:,3);
dz=in_FD(1,1)-in_FD(2,1);

outp(7,1) = sum(df)*dz;
outp(7,2) = sqrt(sum(df.^2)*dz);

end