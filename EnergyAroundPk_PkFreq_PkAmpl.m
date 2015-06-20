% features calculated using analysis window are further averaged over texture frame
function [EnergyAroundPeak_mn,PeakFreqVal_mn,PeakValue_mn]=EnergyAroundPk_PkFreq_PkAmpl(nwinfo_tpe,FeatrParam)

w=hamming(FeatrParam.vib_step);                                    %% hamming window
polytym_end=(FeatrParam.vib_step-1)/100;  % /100 to convert to sec

EnergyAroundPeak=zeros(length(nwinfo_tpe),2);
EnergyAroundPeak(:,1)=nwinfo_tpe(:,1);

% EnergyAroundPeak_timestamp=nwinfo_tpe(:,1);
PeakValue=zeros(length(nwinfo_tpe),1);
PeakFreqVal=zeros(length(nwinfo_tpe),1);

p=0:((FeatrParam.fft_size/2)-1);
h=p*(1/((FeatrParam.fft_size/2)-1))*50;
for i_new=(FeatrParam.vib_step/2)+1:FeatrParam.vib_step_hop:length(nwinfo_tpe)-(FeatrParam.vib_step/2)
    
    nw=nwinfo_tpe(i_new-(FeatrParam.vib_step/2):i_new+(FeatrParam.vib_step/2)-1,2);
    if sum(isinf(nw))==0
        nw_ntnan=nw(~isnan(nw));
        mean_1=ceil(sum(nw_ntnan)/length(nw_ntnan));
        mean_sub=nw-mean_1;
        
        clear p; clear f;
        p=polyfit(0:FeatrParam.polytym_step:polytym_end,mean_sub',3);      %need to change this if modelling on a smaller length data (90%full window)
        f=polyval(p,0:FeatrParam.polytym_step:polytym_end);
        
        poly_sub=mean_sub-f';
        poly_sub_win=poly_sub.*w;
        
        clear y;
        y=abs(fft(poly_sub_win,FeatrParam.fft_size));
        len=length(y);
        y_hlf=y(1:len/2);
        [val,loctn]=max(y_hlf);
        if loctn==len/2
            EnergyAroundPeak(i_new,2)=sum(y_hlf(loctn-2:loctn).^2);
        elseif loctn==1
            EnergyAroundPeak(i_new,2)=sum(y_hlf(loctn:loctn+2).^2);
        elseif loctn==(len/2)-1
            EnergyAroundPeak(i_new,2)=sum(y_hlf(loctn-2:loctn+1).^2);
        elseif loctn==2
            EnergyAroundPeak(i_new,2)=sum(y_hlf(loctn-1:loctn+2).^2);
        else
            EnergyAroundPeak(i_new,2)=sum(y_hlf(loctn-2:loctn+2).^2);
        end
        PeakValue(i_new)=y_hlf(loctn);
        PeakFreqVal(i_new)=h(loctn);

    end
    clear nw;
end

EnergyAroundPeak_new(:,1)=EnergyAroundPeak(1:FeatrParam.vib_step_hop:end,1);
% pitchstack_newtime=EnergyAroundPeak_timestamp(1:PitchModParam.vib_step_hop:end);
EnergyAroundPeak_new(:,2)=EnergyAroundPeak(1:FeatrParam.vib_step_hop:end,2);
PeakValue_new=PeakValue(1:FeatrParam.vib_step_hop:end);
PeakFreqVal_new=PeakFreqVal(1:FeatrParam.vib_step_hop:end);

EAP_avnew=zeros(length(EnergyAroundPeak_new),2);
PV_avnew=zeros(length(EnergyAroundPeak_new),1);
PFV_avnew=zeros(length(EnergyAroundPeak_new),1);
EAP_avnew(:,1)=EnergyAroundPeak_new(:,1);

for i=(FeatrParam.text_win/2)+2:FeatrParam.text_win_hop:length(EAP_avnew)-(FeatrParam.text_win/2)
    part_data=EnergyAroundPeak_new(i-(FeatrParam.text_win/2):i+(FeatrParam.text_win/2),2);
    part_data_pv=PeakValue_new(i-(FeatrParam.text_win/2):i+(FeatrParam.text_win/2));
    part_data_pfv=PeakFreqVal_new(i-(FeatrParam.text_win/2):i+(FeatrParam.text_win/2));
    
    if sum(part_data==0)<=round(length(part_data)*0.5)    %*0.5
        EAP_avnew(i,2)=mean(part_data(part_data~=0));
        PV_avnew(i)=mean(part_data_pv(part_data_pv~=0));
        PFV_avnew(i)=mean(part_data_pfv(part_data_pfv~=0));
    else EAP_avnew(i,2)=0;
    end
    clear part_data part_data_pv part_data_pfv;
end
EnergyAroundPeak_mn(:,1)=EAP_avnew(1:FeatrParam.text_win_hop:end,1);
EnergyAroundPeak_mn(:,2)=EAP_avnew(1:FeatrParam.text_win_hop:end,2);
PeakValue_mn=PV_avnew(1:FeatrParam.text_win_hop:end);
PeakFreqVal_mn=PFV_avnew(1:FeatrParam.text_win_hop:end);

% EnergyAroundPeak_mn(:,1)=EnergyAroundPeak_new(1:FeatrParam.text_win_hop:end,1);
% EnergyAroundPeak_mn(:,2)=zeros(length(EnergyAroundPeak_new(1:FeatrParam.text_win_hop:end,1)),1);
% PeakValue_mn=zeros(length(EnergyAroundPeak_new(1:FeatrParam.text_win_hop:end,1)),1);
% PeakFreqVal_mn=zeros(length(EnergyAroundPeak_new(1:FeatrParam.text_win_hop:end,1)),1);
% k=0;
% for i_new1=(FeatrParam.text_win/2)+2:FeatrParam.text_win_hop:length(EnergyAroundPeak_new)-(FeatrParam.text_win/2)
%     part_data=EnergyAroundPeak_new(i_new1-(FeatrParam.text_win/2):i_new1+(FeatrParam.text_win/2),2);
%     part_data_pv=PeakValue_new(i_new1-(FeatrParam.text_win/2):i_new1+(FeatrParam.text_win/2));
%     part_data_pfv=PeakFreqVal_new(i_new1-(FeatrParam.text_win/2):i_new1+(FeatrParam.text_win/2));
%     k=k+1;
%     if sum(part_data==0)<=round(length(part_data)*0.5)
%         EnergyAroundPeak_mn(k,2)=mean(part_data(part_data~=0));
%         PeakValue_mn(k)=mean(part_data_pv(part_data_pv~=0));
%         PeakFreqVal_mn(k)=mean(part_data_pfv(part_data_pfv~=0));
%     else EnergyAroundPeak_mn(k,2)=0;
%     end
%     clear part_data;
% end

end