function drawBoxplots(nb_contacts,ValSpikesBefore,ValSpikesDuring,ValSpikesAfter,Pstat,electrodes)
%Pstat = h;
colorMed = [0 0 127/255;127/255 0 0;0 100/255 0];
colorAll = [0 0 1; 1 0 0;0 127/255 0];
    for i = 1:nb_contacts 
        
        clear f a
        y = [ValSpikesBefore{i,1};ValSpikesDuring{i,1};ValSpikesAfter{i,1}];
        g1 = repmat({'Before'},size(ValSpikesBefore{i,1},1),1);
        g2 = repmat({'During'},size(ValSpikesDuring{i,1},1),1);
        g3 = repmat({'After'},size(ValSpikesAfter{i,1},1),1);

        g = [g1; g2; g3];
        
        x1 = repmat(1,size(ValSpikesBefore{i,1},1),1);
        x2 = repmat(2,size(ValSpikesDuring{i,1},1),1);
        x3 = repmat(3,size(ValSpikesAfter{i,1},1),1);

        x = [x1; x2; x3];
        if nb_contacts == 1
            f(i) = figure;
        elseif nb_contacts == 2
            f(i) = subplot(1,2,i);
        elseif nb_contacts == 3
            f(i) = subplot(1,3,i);
        else
            f(i) = subplot(ceil(nb_contacts./3),3,i);
        end
        scatter(x(x==1),y(x==1),5,'MarkerFaceColor',colorAll(3,:),'MarkerEdgeColor','none','MarkerFaceAlpha',0.2,'jitter','on');
        hold on
        scatter(x(x==2),y(x==2),5,'MarkerFaceColor',colorAll(2,:),'MarkerEdgeColor','none','MarkerFaceAlpha',0.2,'jitter','on');
        scatter(x(x==3),y(x==3),5,'MarkerFaceColor',colorAll(1,:),'MarkerEdgeColor','none','MarkerFaceAlpha',0.2,'jitter','on');
        
        minAll=min(y);
        maxAll=max(y);
        
        numBefore = nnz(x==1);
        numDuring = nnz(x==2);
        numAfter = nnz(x==3);
        
        boxplot(y,x,'Label',{'','',''});
        a = gca;
        
        if i == 1
            ylabel('Amplitude (µV)');
        end
        for j = 1:3 %Outliers
            a.Children(1).Children(j).Visible = 'off';
        end

        for j = 4:6 %Median plot
            Xmed(j-3,:) = a.Children(1).Children(j).XData;
            Ymed(j-3,:) = a.Children(1).Children(j).YData;
            a.Children(1).Children(j).Color = 'k';
            a.Children(1).Children(j).LineWidth = 1.5;
        end

        for j = 7:9 %Boxes
            Xbox(j-6,:) = a.Children(1).Children(j).XData;
            Ybox(j-6,:) = a.Children(1).Children(j).YData;
            a.Children(1).Children(j).Color = 'k';
            a.Children(1).Children(j).LineWidth = 1.5;
        end

        for j = 10:15 %Lower and Higher Dajacent Value
            a.Children(1).Children(j).Color = 'none';
        end

        for j = 16:18  %Lower whisker
            XlowW(j-15,:) = a.Children(1).Children(j).XData;
            YlowW(j-15,:) = a.Children(1).Children(j).YData;
            a.Children(1).Children(j).Color = 'k';
            a.Children(1).Children(j).LineStyle = '-';
            a.Children(1).Children(j).LineWidth = 1.5;
        end

        for j = 19:21 %Upper whisker
            XhighW(j-18,:) = a.Children(1).Children(j).XData;
            YhighW(j-18,:) = a.Children(1).Children(j).YData;
            a.Children(1).Children(j).Color = 'k';
            a.Children(1).Children(j).LineStyle = '-';
            a.Children(1).Children(j).LineWidth = 1.5;
        end

        for j = 1:3   %Plot shapes
%             plot(Xmed(j,:),Ymed(j,:),'Color',colorMed(j,:),'LineWidth',2.5)
%             plot(XlowW(j,:),YlowW(j,:),'Color',colorAll(j,:),'LineWidth',2.5)
%             plot(XhighW(j,:),YhighW(j,:),'Color',colorAll(j,:),'LineWidth',2.5)
%             patch(Xbox(j,:),Ybox(j,:),colorAll(j,:),'EdgeColor','none','FaceAlpha',.5)
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
                Ymax = max(YhighW(:,2));
                pos = Ymax+(30.*Ymax/100);
                plot([XhighW(3,1),XhighW(1,1)],[pos,pos],'k','LineWidth',1.5);
                text(2,pos(1,1)+pos(1,1)/20,'*','FontSize',20)
            end
        end
       myLabels = { 'Before','During','After';...
                     num2str(numBefore),num2str(numDuring),num2str(numAfter)};
        for j = 1:length(myLabels)
            text(j, a.YLim(1), sprintf('%s\n%s\n%s', myLabels{:,j}), ...
                'horizontalalignment', 'center', 'verticalalignment', 'top','FontSize',11);    
        end

    title(electrodes{i})
    a.Box = 'off';
    a.TickLength = [0 0];
    a.FontSize = 11;
    %a.FontWeight = 'bold';
    

    end
    
    f = gcf;    
    set(f,'Units','normalized','Position',[0.3542 0.2139 0.55 0.75])
%     for i = 1:nb_contacts
%         pos = f.Children(i).Position;
%         set(f.Children(i),'Units','normalized','Position',[pos(1,1) pos(1,2) 0.2090 0.1893])
%     end


end