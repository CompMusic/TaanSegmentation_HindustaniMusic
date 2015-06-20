function [timestamp_features,scaled_features]=FeatureCalculation(PitchArray)


PitchArray_tpe=zeros(length(PitchArray),2);
PitchArray_tpe(:,1)=PitchArray(:,1);
PitchArray_tpe(:,2)=(1200*log2(PitchArray(:,2)/55));    % pitch in cents

ModifiedPitchArray=zeros(length(PitchArray),2);
ModifiedPitchArray(:,1)=PitchArray(:,1);
ModifiedPitchArray(:,2)=(1200*log2(PitchArray(:,2)/55));    % pitch in cents

%interpolate pitch for small gaps
gapAllw=8;
winobs=20;
for itr=1+winobs:length(PitchArray_tpe)-winobs
    chksmpl_pitch=PitchArray_tpe(itr-winobs:itr+winobs,2);
    intrChksmpl_pitch=chksmpl_pitch;
    
    if sum(isinf(chksmpl_pitch))<=gapAllw && isinf(chksmpl_pitch(1))~=1 && isinf(chksmpl_pitch(end))~=1
        locIn=isinf(chksmpl_pitch);
        NotlocIN=find(~locIn);
        intrChksmpl_pitch(locIn)=interp1(NotlocIN,chksmpl_pitch(NotlocIN),find(locIn),'cubic');
        ModifiedPitchArray(itr-winobs:itr+winobs,2)=intrChksmpl_pitch;
        
    end
end
       

%---------------------------Parameters-------------------------------------
PitchModParam=struct('vib_step',100,'vib_step_hop',50,'fft_size',128,'text_win',10,'text_win_hop',2,'polytym_step',0.01,'er_range',[5 10 1 20]);
                      %in *0.01sec    %round(vib_step/2);             %in *0.5sec     %in *0.5sec     %tpe hop sec
FeatrParam=struct('vib_step',100,'vib_step_hop',50,'fft_size',128,'text_win',10,'text_win_hop',2,'polytym_step',0.01);

feature_wts= [0.2,0.2,0.2]';   %[0.3,0.2,0.2,0.2,0.1]';   0.4,0.1,0.3,0.1,0.1     % equal wts [0.2,0.2,0.2,0.2,0.2]';

%------------------------------------------Pitch Feature-------------------
[ER_mn]=PitchModulationFunction(ModifiedPitchArray,PitchModParam);      % Call to function for Pitch based Feature

ER_conc(:,2)=nonzeros(ER_mn(:,2));   %store only the non-zero values (non silences)
locatn_nz_ER_mn=ER_mn(:,2)~=0;   %we can get back original tpe from this by audioinfo_tpe(locatn_nz_audioinfo==1) = info_tpe;
nz_l= locatn_nz_ER_mn~=0;
ER_mn_time=(ER_mn(nz_l,1));
ER_conc(:,1)=ER_mn_time;


%-------------------EnergyAroundPk_PkFreq_PkAmpl Features----------------------------------
[EnergyAroundPeak,PeakFreqVal,PeakValue]=EnergyAroundPk_PkFreq_PkAmpl(ModifiedPitchArray,FeatrParam);

ER_conc(:,3)=(PeakFreqVal(nz_l));
ER_conc(:,4)=(PeakValue(nz_l));
% ER_conc(:,5)=(EnergyAroundPeak(nz_l,2));

%-------------------------------------Saving the features--------------------
timestamp_features=ER_conc(:,1);
unscaledFeatr=ER_conc(:,2:end);

% Do the normalization of the features
scaled_features=norm_feature(unscaledFeatr,'a');

mult_factr=ones(length(scaled_features),1)*feature_wts';
scaled_features=scaled_features.*mult_factr;

end