function drawBoxplots(nb_contacts,ValSpikesBefore,ValSpikesDuring,ValSpikesAfter,Pstat)
%Pstat = h;

for i = 1:nb_contacts 
    
    y = [ValSpikesBefore{i,1};ValSpikesDuring{i,1};ValSpikesAfter{i,1}];
    g1 = repmat({'Before'},size(ValSpikesBefore{i,1},1),1);
    g2 = repmat({'During'},size(ValSpikesDuring{i,1},1),1);
    g3 = repmat({'After'},size(ValSpikesAfter{i,1},1),1);

    g = [g1; g2; g3];

    subplottight(round(nb_contacts./3),3,i)

    boxplot(y,g)
    f = gcf;
    a = gca;

    for j = 1:3
        f.Children.Children.Children(j).Visible = 'off';
    end

    for j = 4:6
        Xmed(j-3,:) = f.Children.Children.Children(j).XData;
        Ymed(j-3,:) = f.Children.Children.Children(j).YData;
        f.Children.Children.Children(j).Color = 'none';
    end

    for j = 7:9
        Xbox(j-6,:) = f.Children.Children.Children(j).XData;
        Ybox(j-6,:) = f.Children.Children.Children(j).YData;
        f.Children.Children.Children(j).Color = 'none';
    end

    for j = 10:15
        f.Children.Children.Children(j).Color = 'none';
    end

    for j = 16:18
        XlowW(j-15,:) = f.Children.Children.Children(j).XData;
        YlowW(j-15,:) = f.Children.Children.Children(j).YData;
        f.Children.Children.Children(j).Color = 'none';
    end

    for j = 19:21
        XhighW(j-18,:) = f.Children.Children.Children(j).XData;
        YhighW(j-18,:) = f.Children.Children.Children(j).YData;
        f.Children.Children.Children(j).Color = 'none';
    end
    colorMed = [0 0 127/255;127/255 0 0;0 100/255 0];
    colorAll = [0 0 1; 1 0 0;0 127/255 0];
    hold on


    for j = 1:3    
        plot(Xmed(j,:),Ymed(j,:),'Color',colorMed(j,:),'LineWidth',2.5)
        plot(XlowW(j,:),YlowW(j,:),'Color',colorAll(j,:),'LineWidth',2.5)
        plot(XhighW(j,:),YhighW(j,:),'Color',colorAll(j,:),'LineWidth',2.5)
        patch(Xbox(j,:),Ybox(j,:),colorAll(j,:),'EdgeColor','none','FaceAlpha',.5)
        if Pstat(i,1)
            Ymax = max([YhighW(3,2),YhighW(2,2)]);
            pos = Ymax+Ymax/20;
            plot([1,1.9],[pos,pos],'k','LineWidth',1.5);
            text(XhighW(3,1)+XhighW(3,1)/2,pos(1,1)+pos(1,1)/20,'*','FontSize',20)
        end
        
        if Pstat(i,3)
            Ymax = max([YhighW(1,2),YhighW(2,2)]);
            pos = Ymax+Ymax/20;
            plot([2.1,3],[pos,pos],'k','LineWidth',1.5);
            text(2.5,pos+pos/20,'*','FontSize',20)
        end
        
        if Pstat(i,2)
            Ymax = pos(1,1)+pos(1,1)/20;
            pos = Ymax+(20.*Ymax/100);
            plot([XhighW(3,1),XhighW(1,1)],[pos,pos],'k','LineWidth',1.5);
            text(2,pos(1,1)+pos(1,1)/20,'*','FontSize',20)
        end


    end
a.TickLength = [0 0];
a.FontSize = 12;
a.FontWeight = 'bold';

    
end



end