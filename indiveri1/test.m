addpath('../HspiceToolbox/');
addpath('../PolyfitnTools/');
colordef none;

leak = loadsig('leak.tr0');
inv_fb = loadsig('inv_fb.tr0');
reset = loadsig('reset.tr0');
inv_slew = loadsig('inv_slew.tr0');

%%%%%%%%%%%%%%%%%%%%%%
% reset

v_vmem = evalsig(reset, 'v_vmem');
v_vo2 = evalsig(reset, 'v_vo2');
i_m12 = evalsig(reset, 'i_m12');
        
m12_fit = fit([v_vmem, v_vo2], i_m12, 'poly44');

%%%%%%%%%%%%%%%%%%%%%%

% disp(i_m12);
m12_fit(0, 0);
m12_fit(1, 1);

x = [0.81;0.91;0.13;0.91;0.63;0.098;0.28;0.55;...
    0.96;0.96;0.16;0.97;0.96];
y = [0.17;0.12;0.16;0.0035;0.37;0.082;0.34;0.56;...
    0.15;-0.046;0.17;-0.091;-0.071];

ft = fittype( 'piecewiseLine( x, a, b, c, d, k )' );
f = fit( x, y, ft, 'StartPoint', [1, 0, 1, 0, 0.5] );
% plot( f, x, y );

%%%%%%%%%%%%%%%%%%%%%%

% g = fittype( @(a, b, c, d, x, y) a*x.^2+b*x+c*exp(-(y-d).^2 ), 'independent', {'x', 'y'}, 'dependent', 'z' );
% g = fittype( @(c1, c2, d1, d2, x, y) c1 * exp(c2 * x) + d1 * exp(d2 * y), 'independent', {'x', 'y'}, 'dependent', 'z' );
% g = fittype( @(k, i0, ut, vth, x, y) (i0 * exp(k .* y / ut)) + (k .* (y - vth) .* x - x.^2) + (k .* (y - vth) .^ 2), 'independent', {'x', 'y'}, 'dependent', 'z' );

g = fittype( 'NFET(i0, k, kn, vth, l, x, y)', 'independent', {'x', 'y'}, 'dependent', 'ids' );
m12_fit = fit([v_vmem, v_vo2], i_m12, g, 'StartPoint', [1e-10, 0.4, 0.4, 0.3, 0.01]);
% m12_fit = fit([v_vmem, v_vo2], i_m12, 'poly44');

err = zeros(size(i_m12));
for i = 1:length(i_m12)
    diff = i_m12(i) - m12_fit([v_vmem(i), v_vo2(i)]); 
    err(i) = diff;
end

disp(m12_fit)
disp(sum(abs(err)) / length(i_m12))
% disp(sum(abs(err)) / sum(abs(i_m12)) / length(i_m12))
% disp(min(i_m12));

m12_fit(0, 0)
i_m12(1)

