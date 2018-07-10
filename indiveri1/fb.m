addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

inv_fb = loadsig('inv_fb.tr0');

v_vmem = evalsig(inv_fb, 'v_vmem');
v_vo1 = evalsig(inv_fb, 'v_vo1');
i_m7 = evalsig(inv_fb, 'i_m7');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vo1_fit = fit(v_vmem, v_vo1, 'poly5');
%disp(gof);
%vo1 = vo1_fit(v_vmem);
%plot(v_vmem, vo1, v_vmem, v_vo1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%options = fitoptions('poly5');
%options.Robust = 'On';
%m7_fit = fit(v_vmem, i_m7, 'poly5', options);

%options = fitoptions('gauss2');
%options.Robust = 'On';
%options.MaxIter = 1000;
%options.MaxFunEvals = 1000;
%m7_fit = fit(v_vmem, i_m7, 'gauss2');

m7_fit = fit(v_vmem, i_m7, 'cubicspline');

disp(gof);
m7 = m7_fit(v_vmem);
plot(v_vmem, m7);
%plot(v_vmem, m7, v_vmem, i_m7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%