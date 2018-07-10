
addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

inv_slew = loadsig('inv_slew.tr0');

v_vo1 = evalsig(inv_slew, 'v_vo1');
v_vo2 = evalsig(inv_slew, 'v_vo2');
i_vso2 = evalsig(inv_slew, 'i_vso2');


type = fittype( 'slew_io2(p00, p10, p01, p20, p11, p02, q00, q10, q01, q20, q11, q02, vo1, vo2)', 'independent', {'vo1', 'vo2'}, 'dependent', 'ids' );
% options = fitoptions('StartPoint', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'MaxIter', 10000, 'MaxFunEvals', 10000, 'TolFun', 10e-7, 'TolX', 10e-7);
options = fitoptions(type);
options.MaxFunEvals = 10000;
options.MaxIter = 10000;
options.StartPoint = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
options.TolFun = 1e-9;
options.TolX = 1e-9;
options.Robust = 'On';
% [io2_fit, gof, out] = fit([v_vo1, v_vo2], i_vso2, type, 'StartPoint', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'MaxIter', 10000, 'MaxFunEvals', 10000, 'TolFun', 10e-7, 'TolX', 10e-7);
% [io2_fit, gof, out] = fit([v_vo1, v_vo2], i_vso2, type, options);

[io2_fit, gof, out] = fit([v_vo1, v_vo2], i_vso2, 'poly55');

disp(gof);
disp(io2_fit);

io2 = io2_fit([v_vo1, v_vo2]);

plot(v_vo1, io2, v_vo1, i_vso2);
