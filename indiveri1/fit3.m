
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
%%%%%%%%%%%%%%%%%%%%%%
% src_flw, inv_fb

v_vmem = evalsig(inv_fb, 'v_vmem');
v_vo1 = evalsig(inv_fb, 'v_vo1');
i_m7 = evalsig(inv_fb, 'i_m7');

m7_fit = fit(v_vmem, i_m7, 'exp2');
vo1_fit = fit(v_vmem, v_vo1, 'linearinterp');
%%%%%%%%%%%%%%%%%%%%%%
% reset

v_vmem = evalsig(reset, 'v_vmem');
v_vo2 = evalsig(reset, 'v_vo2');
i_m12 = evalsig(reset, 'i_m12');

m12_fit = fit([v_vmem, v_vo2], i_m12, 'poly44');
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
m7s = zeros(steps, 1);
m12s = zeros(steps, 1);
m20s = zeros(steps, 1);

C1 = 500e-15;
C2 = 100e-15;

m7_fit(0)
m7_fit(1)

m12_fit(0, 0)
m12_fit(1, 1)

m20_fit(0)
m20_fit(1)

for i = 1:steps
    
    t = double(i) * dt;
    
    if t > 1e-4
        iin = 1e-8;
    else
        iin = 0;
    end
    
    vo1 = vo1_fit(vmem);
    
    dvdt = (1 / C2) * i_vso2_fit([vo1, vo2]);
    vo2 = vo2 + dvdt * dt;
    vo2 = min(max(vo2, -0.1), 1.0);
        
    dvdt = (1 / C1) * (iin - m20_fit(vmem) + m7_fit(vmem) - m12_fit([vmem, vo2]));
    vmem = vmem + dvdt * dt;
    vmem = min(max(vmem, -0.1), 1.0);
        
    vmems(i) = vmem;
    vo1s(i) = vo1;
    vo2s(i) = vo2;
    iins(i) = iin;
    m7s(i) = m7_fit(vmem);
    m12s(i) = m12_fit([vmem, vo2]);
    m20s(i) = m20_fit(vmem);
end

% disp(m20s');
plot(Ts, vmems);


