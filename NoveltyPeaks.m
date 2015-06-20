function [NewTimeStamp,LblFeatVI,FileNamelblMLP_Pks]=NoveltyPeaks(FileNameTimeStamp,FileNamelblMLP,FileNamelblMLP_oneCol,Kw,med_len,movav_len,vicin,thresh)


% NewTimeStamp=cell(szdata,1);
% LblFeatVI=cell(szdata,1);
% 
% RptFeat=cell(szdata,1);
% ZrFeatVI=cell(szdata,1);
% 
% FileNamelblMLP_Pks=cell(szdata,1);
% FileNamelblMLP_SimMat=cell(szdata,1);
% FileNamelblMLP_Nov=cell(szdata,1);
% 

    TimeE=FileNameTimeStamp(1):FileNameTimeStamp(end);
    
    locatn_nz=ismember(TimeE,FileNameTimeStamp);
    
%     ER_conc(:,2)=nonzeros(ER_mn(:,2));   %store only the non-zero values (non silences)
%     locatn_nz_ER_mn=ER_mn(:,2)~=0;   %we can get back original tpe from this by audioinfo_tpe(locatn_nz_audioinfo==1) = info_tpe;
    nz_l= locatn_nz~=0;
    FtrInstRpt=zeros(length(TimeE),2);
    FtrInstRpt(nz_l,:)=(FileNamelblMLP);
    FtrZrVI=FtrInstRpt;
    
    LblInstRpt=zeros(length(TimeE),1);
    LblInstRpt(nz_l)=(FileNamelblMLP_oneCol);
            
    for i=2:length(FtrInstRpt)
        if FtrInstRpt(i,1)==0
            FtrInstRpt(i,:)=FtrInstRpt(i-1,:);
        end
    end

    lctn_stillzr=FtrInstRpt(:,2)==0;
    nz_stlzr=find(lctn_stillzr~=0);
    if isempty(nz_stlzr)~=1
        FtrInstRpt(nz_stlzr,2)=FtrInstRpt(nz_stlzr(end),2);
    end
    
    NewTimeStamp=TimeE;
    RptFeat=FtrInstRpt;
    ZrFeatVI=FtrZrVI;
    LblFeatVI=LblInstRpt;
    
    clear LblInstRpt FtrZrVI FtrInstRpt TimeE;


    

    [SimMat,novScr]=SDM_nov(Kw,'Euclidean',RptFeat);
    novScr=novScr/max(novScr);
    peak_feat=peak_pick(NewTimeStamp,novScr,med_len,movav_len,vicin,thresh);
    FileNamelblMLP_SimMat=SimMat;
    
    peak_feat=[min(NewTimeStamp) max(novScr) ;peak_feat; NewTimeStamp(end) max(novScr)];
    
    FileNamelblMLP_Pks=peak_feat;
    FileNamelblMLP_Nov=novScr;
    clear peak_feat;
