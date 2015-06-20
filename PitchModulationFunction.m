% features calculated using analysis window are further averaged over texture frame
function [ER_mn]=PitchModulationFunction(nwinfo_tpe,PitchModParam)

w=hamming(PitchModParam.vib_step);                                    %% hamming window
polytym_end=(PitchModParam.vib_step-1)/100;  % /100 to convert to sec

ER=zeros(length(nwinfo_tpe),2);
ER(:,1)=nwinfo_tpe(:,1);

for i=(PitchModParam.vib_step/2)+1:PitchModParam.vib_step_hop:length(nwinfo_tpe)-(PitchModParam.vib_step/2)

    nw=nwinfo_tpe(i-(PitchModParam.vib_step/2):i+(PitchModParam.vib_step/2)-1,2);
    if sum(isnan(nw))<=10
        nw_ntnan=nw(~isnan(nw));
        mean_1=ceil(sum(nw_ntnan)/length(nw_ntnan));
        mean_sub=nw-mean_1;

        clear p; clear f;
        p=polyfit(0:PitchModParam.polytym_step:polytym_end,mean_sub',3);      %need to change this if modelling on a smaller length data (90%full window)
        f=polyval(p,0:PitchModParam.polytym_step:polytym_end);

        poly_sub=mean_sub-f';
        poly_sub_win=poly_sub.*w;
          
        clear y;
        y=abs(fft(poly_sub_win,PitchModParam.fft_size));
        len=length(y);
        y_hlf=y(1:len/2);
        p=0:((PitchModParam.fft_size/2)-1);
        h=p*(1/((PitchModParam.fft_size/2)-1))*50;

        ener_num=0;
        ener_den=0;
        for k=1:length(p)
            if h(k)>=PitchModParam.er_range(1) && h(k)<=PitchModParam.er_range(2)
                ener_num=ener_num+(y_hlf(k))^2;
            end
            if h(k)>=PitchModParam.er_range(3) && h(k)<=PitchModParam.er_range(4)
                ener_den=ener_den+(y_hlf(k))^2;
            end

            ER(i,2)=ener_num/ener_den; 
            if isnan(ER(i,2))==1
                ER(i,2)=0;
            end
        end
%         i=i+(PitchModParam.vib_step/2)-1;     %vib_step/2
    else ER(i,2)=0;
    end
    clear nw;
end


ER_new(:,1)=ER(1:PitchModParam.vib_step_hop:end,1);
ER_new(:,2)=ER(1:PitchModParam.vib_step_hop:end,2);
% figure; plot(ER_new(:,1),ER_new(:,2)); title('Pitch Oscillation Measure after analysis frame');

ER_avnew=zeros(length(ER_new),2);
ER_avnew(:,1)=ER_new(:,1);

for i=(PitchModParam.text_win/2)+2:PitchModParam.text_win_hop:length(ER_new)-(PitchModParam.text_win/2)
    part_data=ER_new(i-(PitchModParam.text_win/2):i+(PitchModParam.text_win/2),2);
    if sum(part_data==0)<=round(length(part_data)*0.5)    %*0.5
        ER_avnew(i,2)=mean(part_data(part_data~=0));
    else ER_avnew(i,2)=0;
    end
    clear part_data;
end
ER_mn(:,1)=ER_avnew(1:PitchModParam.text_win_hop:end,1);
ER_mn(:,2)=ER_avnew(1:PitchModParam.text_win_hop:end,2);

end