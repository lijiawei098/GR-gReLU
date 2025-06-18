 function [res] = Cal_fmd(mag,mbin,flag)
 % Compute frequency–magnitude distribution (FMD) and complementary cumulative frequency–magnitude distribution (CCFMD)
 %  
 % mag：magnitude
 % mbin：magnitude bin
    if ~exist('flag', 'var')
      flag = 0; 
    end
    if flag == 1
        mincr = [-10:mbin:max(round(mag/mbin)*mbin)];
    else
        mincr = [min(round(mag/mbin)*mbin):mbin:max(round(mag/mbin)*mbin)];
    end
    nbm = length(mincr); 
    cumnbmag = zeros(nbm,1); 
    nbmag = zeros(nbm,1); 
    
    for n = 1:nbm
        cumnbmag(n,1) = length(find(mag > mincr(n)-mbin/2));
    end
    
    cumnbmagtmp = [cumnbmag;0];
    nbmag = abs(diff(cumnbmagtmp)); 
	    
    res.CCFMD  = cumnbmag'; % CCFMD
    res.FMD = nbmag';       % FMD
    res.mi = mincr;         % Magnitude

end