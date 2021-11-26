pos = DE.pos(DE.chan == 86).*data.fs;
for i = 1:size(pos,1)
    c
end

plot(d(:,86))
hold on
y(DE.con(DE.chan == 86,1)<1,1) = 0;
stem(y)