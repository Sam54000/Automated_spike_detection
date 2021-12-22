function drawBoxplots(nb_contacts,ValSpikesBefore,ValSpikesDuring,ValSpikesAfter)


for i = 1:nb_contacts 
    
    x = [ValSpikesBefore{i,1};ValSpikesDuring{i,1};ValSpikesAfter{i,1}];
    g1 = repmat({'Before'},size(ValSpikesBefore{i,1},1),1);
    g2 = repmat({'During'},size(ValSpikesDuring{i,1},1),1);
    g3 = repmat({'After'},size(ValSpikesAfter{i,1},1),1);
    g = [g1; g2; g3];   
    subplot(round(nb_contacts./3),3,i)
    
    boxplot(x,g)
    f = gcf;

for i = 4:3:21
    f.Children.Children.Children(i).LineWidth = 2;
    f.Children.Children.Children(i).Color = [0,0,1];
end

for i = 5:3:21
    f.Children.Children.Children(i).LineWidth = 2;
    f.Children.Children.Children(i).Color = [1,0,0];
end

for i = 6:3:21
    f.Children.Children.Children(i).LineWidth = 2;
    f.Children.Children.Children(i).Color = [0,168/255,0];
end



for i = 1:7
    mVAL = q(i,1)+(w2(i)).*(q(i,3)-q(i,1)); %w2 is negative
    if mVAL < 0
        mVAL = 0;
    end
    MVAL = q(i,3)+abs(w1(i)).*(q(i,3)-q(i,1));
    f.Children.Children.Children(i+3*7).YData = [mVAL mVAL];
    f.Children.Children.Children(i+4*7).YData = [MVAL MVAL];
    f.Children.Children.Children(i+5*7).YData = [q(i,1) mVAL];
    f.Children.Children.Children(i+6*7).YData = [q(i,3) MVAL];
end


ax = gca;
ax.TickLength = [0 0];
ax.YGrid = 'on';
ax.FontSize = 12;
ax.FontWeight = 'bold';


    boxplot(x,g)
    ylim([0 max(x)])
    


end