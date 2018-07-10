addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

reset = loadsig('reset.tr0');

v_vmem = evalsig(reset, 'v_vmem');
v_vo2 = evalsig(reset, 'v_vo2');
i_m12 = evalsig(reset, 'i_m12');

type = fittype( 'NFET(i0, k, kn, l, x, y)', 'independent', {'x', 'y'}, 'dependent', 'ids' );
options = fitoptions(type);
options.MaxFunEvals = 10000;
options.MaxIter = 10000;
options.StartPoint = [1e-10, 0.4, 0.4, 0.01];
options.TolFun = 1e-9;
options.TolX = 1e-9;
options.Robust = 'On';

% [m12_fit, gof, out] = fit([v_vmem, v_vo2], i_m12, type, options);
[m12_fit, gof, out] = fit([v_vmem, v_vo2], i_m12, 'poly55');
disp(gof);
disp(m12_fit);

m12 = m12_fit([v_vmem, v_vo2]);

%plot(v_vmem, m12);
%plot(v_vmem, i_m12);
plot(v_vmem, m12, v_vmem, i_m12);