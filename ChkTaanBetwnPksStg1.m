function FileNamelblMLP_PksPost=ChkTaanBetwnPksStg1(FileNamelblMLP_Pks,FileNameTimeStamp,FileNamelblMLP_oneCol,allwTh,allwSamp)
   
    peak_post_new=zeros(length(FileNamelblMLP_Pks),2);
    peak_post=FileNamelblMLP_Pks;
        
    flag_chk=1;
    pchk=1;
    stTemp=peak_post(pchk,:);
    
    FinalStrt=[];
    FinalEnd=[];
    flag_chk=0;
    while pchk<=length(peak_post)-1
        
        enTemp=peak_post(pchk+1,:);
%         loctn=ismember(NewTimeStamp{i_new},stTemp(1):enTemp(1));
%         chk_arr=(ZrFeatVI{i_new}(loctn,1));
        [~,loctnST]=min(abs(FileNameTimeStamp-stTemp(1)));
        [~,loctnEn]=min(abs(FileNameTimeStamp-enTemp(1)));
        chk_lbl=FileNamelblMLP_oneCol(loctnST:loctnEn);
        if isempty(chk_lbl)~=1 && sum(chk_lbl==1)>=length(chk_lbl)*allwTh && sum(chk_lbl==1)>allwSamp %enter if taan
            if flag_chk==0
                StrtPt=stTemp;
            end
            stTemp=peak_post(pchk+1,:);
            flag_chk=1;
            pchk=pchk+1;
            if pchk==length(peak_post)
                FinalStrt=[FinalStrt;StrtPt];
                FinalEnd=[FinalEnd;stTemp];
            end
        elseif isempty(chk_lbl)~=1 && (sum(chk_lbl==1)<length(chk_lbl)*allwTh || sum(chk_lbl==1)<=allwSamp) && flag_chk==1 %previous pair taan
            FinalStrt=[FinalStrt;StrtPt];
            FinalEnd=[FinalEnd;stTemp];
            flag_chk=0;
            stTemp=enTemp;
            pchk=pchk+1;
        elseif isempty(chk_lbl)~=1 && (sum(chk_lbl==1)<length(chk_lbl)*allwTh || sum(chk_lbl==1)<=allwSamp) && flag_chk==0 %&&  sum(chk_lbl)<=length(chk_lbl)*0.3 %for initial non-taan
            pchk=pchk+1;
            stTemp=peak_post(pchk,:);
        end

    end

    peak_post_new1=[];
    [rw,cl]=size(FinalStrt);
    for j_new=1:rw
        peak_post_new1=[peak_post_new1; FinalStrt(j_new,:);FinalEnd(j_new,:)];
     end
            
 
%     peak_post_new1=reshape(peak_post_new,2,size(peak_post_new,1)*size(peak_post_new,2)/2)';
    FileNamelblMLP_PksPost=peak_post_new1;
    clear peak_post chk_arr chk_lbl peak_post_new loctnST loctnEn peak_post_new1;
end