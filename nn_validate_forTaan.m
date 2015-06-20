function [a] = nn_validate_forTaan(nn,temptest,mn,varc)
    x = temptest;
    x = normalize(x,mn,varc);
    a = nn_outputs(nn,x);
    [~,amax] = max(a');
end