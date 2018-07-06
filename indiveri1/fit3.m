
addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

leak = loadsig('leak.tr0');
inv_fb = loadsig('inv_fb.tr0');
reset = loadsig('reset.tr0');
inv_slew = loadsig('inv_slew.tr0');

%%%%%%%%%%%%%%%%%%%%%%
% leak

v_vmem = evalsig(leak, 'v_vmem');
i_m20 = evalsig(leak, 'i_m20');

m20_fit = fit(v_vmem, i_m20, 'exp2');

% x = linspace(0, 1, 100);
% plot(x, m20_fit(x));
% plot(v_vmem, i_m20);

%%%%%%%%%%%%%%%%%%%%%%
% src_flw, inv_fb

v_vmem = evalsig(inv_fb, 'v_vmem');
v_vo1 = evalsig(inv_fb, 'v_vo1');
i_m7 = evalsig(inv_fb, 'i_m7');

m7_fit = fit(v_vmem, i_m7, 'linearinterp');
vo1_fit = fit(v_vmem, v_vo1, 'linearinterp');

% plot(v_vmem, v_vo1);
% g = fittype( 'PWL(p1, b1, m1, p2, b2, m2, b3, m3, x)', 'independent', {'x'}, 'dependent', 'vo1' );
% vo1_fit = fit(v_vmem, v_vo1, g, 'StartPoint', [0.5, 0.95, -0.3, 0.7, -3, 0.7, 0.1, -0.3]);
% disp(vo1_fit);

% x = linspace(0, 1, 100);
% plot(x, vo1_fit(x));

%%%%%%%%%%%%%%%%%%%%%%
% reset

v_vmem = evalsig(reset, 'v_vmem');
v_vo2 = evalsig(reset, 'v_vo2');
i_m12 = evalsig(reset, 'i_m12');

m12_fit = fit([v_vmem, v_vo2], i_m12, 'poly44');

g = fittype( 'NFET(i0, k, kn, vth, l, x, y)', 'independent', {'x', 'y'}, 'dependent', 'ids' );
m12_fit = fit([v_vmem, v_vo2], i_m12, g, 'StartPoint', [1e-10, 0.4, 0.4, 0.3, 0.01]);

% x = linspace(0, 1, 100);
% y = linspace(0.2, 0.2, 100);
% surf(x, y, m12_fit([x, y]));
%%%%%%%%%%%%%%%%%%%%%%
% inv_slew

v_vo1 = evalsig(inv_slew, 'v_vo1');
v_vo2 = evalsig(inv_slew, 'v_vo2');
i_vso2 = evalsig(inv_slew, 'i_vso2');

i_vso2_fit = fit([v_vo1, v_vo2], i_vso2, 'poly44');
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
icmems = zeros(steps, 1);
m7s = zeros(steps, 1);
m12s = zeros(steps, 1);
m20s = zeros(steps, 1);

C1 = 500e-15;
C2 = 100e-15;

% m7_fit(0)
% m7_fit(1)

% m12_fit(0, 0)
% m12_fit(1, 0.6)
% m12_fit(1, 1)

x1s = linspace(1, 1, 100);
x2s = linspace(0, 1, 100);

ys = zeros(100, 1);

for i = 1:100
    ys(i) = NFET1(5e-12, 0.4, 2e-6, 0.325, 0.03, x1s(i), x2s(i));
end
% ys = NFET(5e-12, 0.4, 2e-6, 0.325, 0.03, x1s, x2s);
plot(xs, ys);

for i = 1:steps
    
    t = Ts(i);
    
    if t > 1e-4
        iin = 1e-9;
    else
        iin = 0;
    end
    
    m7s(i) = m7_fit(vmem);
    m12s(i) = NFET1(5e-12, 0.4, 2e-6, 0.325, 0.03, vmem, vo2);
    m20s(i) = m20_fit(vmem);
    
    vo1 = vo1_fit(vmem);
    
    dvdt = (1 / C2) * i_vso2_fit([vo1, vo2]);
    vo2 = vo2 + dvdt * dt;
    vo2 = min(max(vo2, 0.0), 1.0);
    
    %disp(dvdt * dt)
    %disp(vo2);
        
    icmem = (iin - m20_fit(vmem) + m7_fit(vmem) - NFET1(5e-12, 0.4, 2e-6, 0.325, 0.03, vmem, vo2));
    dvdt = (1 / C1) * icmem;
    vmem = vmem + dvdt * dt;
    vmem = min(max(vmem, 0.0), 1.0);
        
    % disp(dvdt * dt);
    % disp(m20_fit(vmem));
    % disp(m7_fit(vmem));
    % disp(m12_fit([vmem, vo2]));
    
    vmems(i) = vmem;
    vo1s(i) = vo1;
    vo2s(i) = vo2;
    iins(i) = iin;
    icmems(i) = icmem;
end

% disp(m20s');
plot(Ts, vmems);

% x = linspace(0, 1, 100);
% plot(x, vo1_fit(x));
