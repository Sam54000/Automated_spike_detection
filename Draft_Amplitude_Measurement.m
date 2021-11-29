clearvars -except d DE dat_irrit elec idx_elec labels_BIP
data.fs = 1024;
ch = 96;
DataAnalysis = data.d';
pos = round(DE.pos(DE.chan == ch).*data.fs);
win = 50;
clear window window2 window3 x MOY SD2
[x, ~, ~] = bst_bandpass_hfilter(DataAnalysis(ch,:),1024,6,0);

for i = 1:size(pos,1)
    clear idx
    [~,idx] = max(x(pos(i,1)-win:pos(i,1)+win).*-1);
    idx = idx-30;
    
    window(i,:) = x(pos(i,1)-win:pos(i,1)+win)-mean(x);
end
ThreMin = mean(window(:))-2.*std(window(:));
ThreMax = mean(window(:))+2.*std(window(:));
NumMin = nnz(window<ThreMin);
NumMax = nnz(window>ThreMax);
SumMin = abs(sum(window(window<ThreMin)));
SumMax = abs(sum(window(window>ThreMax)));

if (SumMin > SumMax) && (NumMin > NumMax)
    x = x.*-1;
end

for i = 1:size(pos,1)
    clear idx
    %baseline = mean(x(pos(i,1)+win-10:pos(i,1)+win,ch));
    %recaller les max avec le resample
    window2(i,:) = x(pos(i,1)-win:pos(i,1)+win)-mean(x);
    window3 = resample(window2(i,:),4,1);
    [m(i,1),idx2(i,1)] = max(window3);
    idx2(i,1) = idx2(i,1)-20;
    if idx2(i,1) > 0 && idx2(i,1) < 204
        window2(i,:) = x(pos(i,1)-win-idx2(i,1):pos(i,1)+win-idx2(i,1))-mean(x);
        window4(i,:) = window3(idx2(i,1):idx2(i,1)+200);
    end
end

[m2,idx2] = max(window4,[],2);
test = m2 > 50;


plot(window4','Color',[0 0 0 0.1])

xlim([0 100])
%set(ar,'grid','on')


plot(d(:,86))
hold on
y(DE.con(DE.chan == 86,1)<1,1) = 0;
stem(y)