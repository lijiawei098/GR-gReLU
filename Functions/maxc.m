function Mc = maxc(mag, mbin)
    res = Cal_fmd(mag, mbin,1);
    [~, idx] = max(res.FMD);
    Mc = res.mi(idx);
end