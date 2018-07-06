function ids = NFET1(i0, k, kn, vth, l, x, y)

    ut = 0.026;
    
    vds = x;
    vgs = y;

    sub_sat = (vgs < vth) && (vds >= 4*ut);
    sub_off = (vgs < vth) && (vds < 4*ut);
    sat = (vgs > vth) && (vds >= vgs - vth);

    if (sub_sat)
        ids = (i0 * exp(k .* vgs / ut));
    elseif(sub_off)
        ids = (i0 * exp(k .* vgs / ut)) .* (1 - exp(-vds / ut));

    elseif (sat)
        ids = 0.5 * (kn .* (vgs - vth) .^ 2) .* (1 + l * vds);
    else
        ids = (kn .* (vgs - vth) .* vds - ((vds .^ 2)/2)) .* (1 + l * vds);
    end

end