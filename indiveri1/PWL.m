function vo1 = PWL(p1, b1, m1, p2, b2, m2, b3, m3, x)

vo1 = zeros(size(x));

for i = 1:length(x)
    if x(i) < p1
        vo1(i) = b1 + m1 * x(i);
    elseif x(i) < p2 
        vo1(1) = b2 + m2 * x(i);
    else
        vo1(i) = b3 + m3 * x(i);
    end
end
end