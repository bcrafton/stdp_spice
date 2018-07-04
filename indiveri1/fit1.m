
addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

x = loadsig('indiveri.tr0');

lssig(x)

% outputs, dependent
v_vspk = evalsig(x, 'v_vspk');
i_vso2 = evalsig(x, 'i_vso2');
i_vsmem = evalsig(x, 'i_vsmem');

% inputs, independent
i_is1 = evalsig(x, 'i_is1');
v_vsmem = evalsig(x, 'v_vmem');
v_vso1 = evalsig(x, 'v_vo1');

%%%%%%%%%%%%%%%%%%%%%%

% i_vsmem_fit = polyfitn([v_vsmem, v_vso1, i_is1], i_vsmem, 10);
i_vsmem_fit = fit([v_vsmem, v_vso1, i_is1], i_vsmem, 'linearinterp');
% i_vso2_fit = polyfitn([v_vsmem, v_vso1, i_is1], i_vso2, 10);
i_vso2_fit = fit([v_vsmem, v_vso1, i_is1], i_vso2, 'linearinterp');

%%%%%%%%%%%%%%%%%%%%%%

dt = 1e-6;
T = 1e-3;
steps = uint32(T / dt);

Ts = linspace(0, T, steps);
vmems = zeros(steps, 1);
vo2s = zeros(steps, 1);
iins = zeros(steps, 1);

C1 = 500e-15;
C2 = 100e-15;

vmem = 0;
vo2 = 0;

dvdt = (1 / C1) * (polyvaln(i_vsmem_fit, [1, 1, 0]));
disp(dvdt);

for i = 1:steps
    
    t = double(i) * dt;
    
    if t > 1e-4
        iin = 1e-9;
    else
        iin = 0;
    end
    
    % dvdt = (1 / C1) * (polyvaln(i_vsmem_fit, [vmem, vo2, iin]));
    dvdt = (1 / C1) * (i_vsmem_fit([vmem, vo2, iin]));
    vmem = vmem + dvdt * dt;
    vmem = min(max(vmem, -0.1), 1);

    % dvdt = (1 / C2) * (polyvaln(i_vso2_fit, [vmem, vo2, iin]));
    dvdt = (1 / C2) * (i_vso2_fit([vmem, vo2, iin]));
    vo2 = vo2 + dvdt * dt;
    vo2 = min(max(vo2, -0.1), 1.0);
    
    % disp(dvdt);
    
    vmems(i) = vmem;
    vo2s(i) = vo2;
    iins(i) = iin;
end

%disp(vmems');
%plot(Ts, vmems);
