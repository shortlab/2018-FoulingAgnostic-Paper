prefix='ISN AFM/Metal c';
postfix='.txt';

meas=zeros(6,3); %row=curve#, col=[non-contact voltage, minimum voltage, sensitivity slope nm/V]
hold off
%adh_force_all=[];

b=0;

for(i=[4])
    for(b=0:1)
        if(b==0)
            fn=[prefix, num2str(i), postfix];
        else
            fn=[prefix, num2str(i), 'b', postfix];
        end
        data=dlmread(fn, ' ', 1, 0);
        %data(:,1)=data(:,1)*1000; %um to nm
        plot(data(:,1), data(:,2));
        pause
        [x, y]=getpts(); %non-contact, min touching (force), max touching (slope reference)
        sl=(x(3)-x(2))/(y(3)-y(2)); %nm/V
        df=y(1)-y(2); %V
        dx=df*sl; %nm
        disp(dx);
    end
end
