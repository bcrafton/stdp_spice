
addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

x = loadsig('indiveri.tr0');

lssig(x)

v_vmem = evalsig(x, 'v_vmem');
v_vin = evalsig(x, 'v_vin');
v_vo1 = evalsig(x, 'v_vo1');
i_m7 = evalsig(x, 'i_m7');

%%%%%%%%%%%%%%%%%%%%%%
% vvo1

vo1_fit = polyfitn([v_vmem, v_vin], v_vo1, 2);
polyvaln(vo1_fit, [0.6, 0.35]);

%%%%%%%%%%%%%%%%%%%%%%
% im7

m7_fit = polyfitn([v_vmem, v_vin], i_m7, 2);
polyvaln(m7_fit, [0.6, 0.35]);

%%%%%%%%%%%%%%%%%%%%%%
% ic1

v_vo1 = evalsig(x, 'v_vo1');
v_vo2 = evalsig(x, 'v_vo2');
i_c1 = evalsig(x, 'i_c1');

c1_fit = polyfitn([v_vo1, v_vo2], i_c1, 2);
polyvaln(c1_fit, [0.3, 0.4]);
polyvaln(c1_fit, [0.9, 0.0]);

%%%%%%%%%%%%%%%%%%%%%%
% im20

v_vmem = evalsig(x, 'v_vmem');
i_m20 = evalsig(x, 'i_m20');

m20_fit = polyfitn(v_vmem, i_m20, 2);
polyvaln(m20_fit, 0.1);
polyvaln(m20_fit, 0.6);

%%%%%%%%%%%%%%%%%%%%%%
% im12

v_vmem = evalsig(x, 'v_vmem');
v_vo2 = evalsig(x, 'v_vo2');
i_m12 = evalsig(x, 'i_m12');

m12_fit = polyfitn([v_vmem, v_vo2], i_m12, 2);
polyvaln(m12_fit, [0.5, 0.5]);

%%%%%%%%%%%%%%%%%%%%%%

dt = 1e-6;
T = 1e-2;
steps = T / dt;

vmem = 0;
vo1 = 0;
vo2 = 0;

for i = 1:steps
    
    t = i * dt;
    iin = (t > 1e-3) * 1e-9;
    
    dvdt = iin - polyvaln(m20_fit, vmem) + polyvaln(m7_fit, [vmem, vo1]) - polyvaln(m12_fit, [vmem, vo2]);
    vmem = vmem + dvdt * dt;
    
    dvdt = polyvaln(c1_fit, [vo1, vo2]);
    vo2 = vo2 + dvdt * dt;
    
end





