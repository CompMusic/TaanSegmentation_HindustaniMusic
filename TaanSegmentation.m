function TaanBoundaries=TaanSegmentation(FileName)

load('SturctueOfNNForDunya');

% FileName='HB_Chandrakauns_Melodia.txt';
% display('Step 1');
PitchArray=Melodia2PolyPDA(FileName);

%--feature calculation for the given audio
% display('Step 2');
[FileNameTimeStamp,scaled_features]=FeatureCalculation(PitchArray);

%-----Posteriori calculation for given test audio
% display('Step 3');
addpath('NN');
addpath('util');
FileNamelblMLP = nn_validate_forTaan(nn,scaled_features,mn,varc);

FileNamelblMLP_oneCol=double(FileNamelblMLP(:,1)>0.4); % 0.4->threshold corresponding to f-measure

%--------------------Novelty ans SDM computation
% display('Step 4');
Kw=2;
med_len=5;
movav_len=7;
vicin=5;
thresh=0.1;

[NewTimeStamp,LblFeatVI,FileNamelblMLP_Pks]=NoveltyPeaks(FileNameTimeStamp,FileNamelblMLP,FileNamelblMLP_oneCol,Kw,med_len,movav_len,vicin,thresh);

%---------------------------------Post-Processing----------------------------
% peak_post processed again to confirm the selected boundaries have taan inbetween
% display('Step 5');

allwTh=0.5; %atleast 50% of the labels between 2 peaks must be marked taan
allwSamp=2; %in case of spurious 2 peaks that are v near to each other, the number of taan labels between them should be atleast 2
FileNamelblMLP_PksPost=ChkTaanBetwnPksStg1(FileNamelblMLP_Pks,FileNameTimeStamp,FileNamelblMLP_oneCol,allwTh,allwSamp);

% arrive at labels from grouped peaks stage1
FileNamelblMLP_grpng1=zeros(length(FileNamelblMLP_oneCol),1);
    for j_new1=1:2:length(FileNamelblMLP_PksPost)-1
        [~,nzl1]=min(abs(FileNameTimeStamp-FileNamelblMLP_PksPost(j_new1,1)));
        [~,nzl2]=(min(abs(FileNameTimeStamp-FileNamelblMLP_PksPost(j_new1+1,1))));
        FileNamelblMLP_grpng1(nzl1:nzl2)=1;
    end


% Stage 2 grouping
% display('Step 6');
allowThreshVcl=10;
allowThrshInst=50;
TaanBoundaries=Stage2Grpng(FileNamelblMLP_PksPost,FileNamelblMLP_grpng1,FileNameTimeStamp,NewTimeStamp,LblFeatVI,allowThreshVcl,allowThrshInst);
