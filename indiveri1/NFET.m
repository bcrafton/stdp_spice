function ids = NFET(i0, k, kn, vth, l, x, y)

    ut = 0.026;
    ids = zeros(size(x));
    
    for i = 1:length(x)

        vds = x(i);
        vgs = y(i);
        
        sub_sat = (vgs < vth) && (vds >= 4*ut);
        sub_off = (vgs < vth) && (vds < 4*ut);
        sat = (vgs > vth) && (vds >= vgs - vth);

        if (sub_sat)
            ids(i) = (i0 * exp(k .* vgs / ut));
        elseif(sub_off)
            ids(i) = (i0 * exp(k .* vgs / ut)) .* (1 - exp(-vds / ut));
            
        elseif (sat)
            ids(i) = 0.5 * (kn .* (vgs - vth) .^ 2) .* (1 + l * vds);
        else
            ids(i) = (kn .* (vgs - vth) .* vds - ((vds .^ 2)/2)) .* (1 + l * vds);
        end
        
    end

end