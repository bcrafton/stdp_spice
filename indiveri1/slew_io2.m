function io2 = slew_io2(p00, p10, p01, p20, p11, p02, q00, q10, q01, q20, q11, q02, vo1, vo2)

on = vo1 <= 0.9;
off = vo1 > 0.9;
io2_on = p00 + p10*vo1 + p01*vo2 + p20*vo1.^2 + p11*vo1.*vo2 + p02*vo2.^2;
io2_off = q00 + q10*vo1 + q01*vo2 + q20*vo1.^2 + q11*vo1.*vo2 + q02*vo2.^2;
io2 = io2_on .* on + io2_off .* off;

end
