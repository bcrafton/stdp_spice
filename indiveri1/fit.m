
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
polyvaln(m7_fit, [1.0, 0.5]);

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

v_vmem = evalsig(x, 'v_vmem');
v_vo1 = evalsig(x, 'v_vo1');

vo1_fit = polyfitn(v_vmem, v_vo1, 2);

%%%%%%%%%%%%%%%%%%%%%%

dt = 1e-7;
T = 1e-3;
steps = uint32(T / dt);

vmem = 0;
vo1 = 0;
vo2 = 0;

Ts = linspace(0, T, steps);
vmems = zeros(steps, 1);
vo1s = zeros(steps, 1);
vo2s = zeros(steps, 1);
iins = zeros(steps, 1);
m7s = zeros(steps, 1);
m12s = zeros(steps, 1);
m20s = zeros(steps, 1);

C1 = 500e-15;
C2 = 100e-15;

for i = 1:steps
    
    t = double(i) * dt;
    
    if t > 1e-4
        iin = 1e-9;
    else
        iin = 0;
    end
    
    vo1 = polyvaln(vo1_fit, vmem);
    
    % dvdt = (1 / C1) * (iin - polyvaln(m20_fit, vmem) + (-1 * polyvaln(m7_fit, [vmem, vo1])) - polyvaln(m12_fit, [vmem, vo2]));
    dvdt = (1 / C1) * (iin - polyvaln(m20_fit, vmem) + (-1 * polyvaln(m7_fit, [vmem, vo1])) - polyvaln(m12_fit, [vmem, vo2]));
    vmem = vmem + dvdt * dt;
    vmem = min(max(vmem, -0.1), 0.6);
        
    dvdt = (1 / C2) * polyvaln(c1_fit, [vo1, vo2]);
    vo2 = vo2 + dvdt * dt;
    vo2 = min(max(vo2, -0.5), 1.0);
    
    vmems(i) = vmem;
    vo1s(i) = vo1;
    vo2s(i) = vo2;
    iins(i) = iin;
    m7s(i) = (-1 * polyvaln(m7_fit, [vmem, vo1]));
    m12s(i) = polyvaln(m12_fit, [vmem, vo2]);
    m20s(i) = polyvaln(m20_fit, vmem);
end

disp(m20s');
plot(Ts, m7s, Ts, m12s, Ts, m20s);


