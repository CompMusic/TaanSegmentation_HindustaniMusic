% this matlab code converts Melodia pitch values stored in txt file into
% tpe file with energy column as zero. Also the pitch values in Melodia
% spaced at prev_dur are modified to 0.01 as in the case of PolyPDA
% clc;
% clear all;
% close all;

function [new_tpefile]=Melodia2PolyPDA(FileName)

tpefile=load(FileName);

prev_dur=0.002875;
reqd_dur=0.01;
len=length(tpefile);

time=0.00:0.01:roundn(tpefile(len,1),-2);
new_tpefile=zeros(length(time),2);
new_tpefile(:,1)=time;

for i=2:length(new_tpefile)
  index=round(time(i)/prev_dur)-round(tpefile(1,1)/prev_dur);
  if index>0 && index<len
    new_tpefile(i,2)=tpefile(index,2);
    if tpefile(index,2)<0.0
        new_tpefile(i,2)=0;
    end
  end
end

end