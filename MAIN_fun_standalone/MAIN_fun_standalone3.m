function [d, DE, discharges, d_decim, envelope, background, envelope_pdf, clustering, labels_BIP, idx_spikes, qEEG, tab] = MAIN_fun_standalone3(data,data_name,saving_folder)

[d,labels_BIP]=ref2bip_v4(double(data.d),data.labels);
[DE, discharges, d_decim, envelope, background, envelope_pdf] = spike_detector_hilbert_v23(d,data.fs);
discharges.MTABS=datenum(0,0,0,0,0,discharges.MP)+data.tabs(1);

%% klastrování
duration=(size(d,1)/data.fs/60);
clustering=clustering_main_fun(discharges,duration);

%% figures
figure(1); clf
cidx=find(clustering.evt_percent>5);
n_line=ceil(length(cidx)/3);

% IED
qEEG=sum(discharges.MW.*(discharges.MV>0)/duration);
[idx1,C]=kmeans(qEEG(:),2,'replicates',10);
[~,cpoz]=max(C);
subplot(n_line+1,3,[1 3])
bar(qEEG);hold on;
set(gca,'XTick',1:length(qEEG),'XTickLabel',labels_BIP); xtickangle(45);
idx_spikes = find(idx1==cpoz);
bar(find(idx1==cpoz),qEEG(idx1==cpoz),'r')
title('total IED rate'); ylabel('IED/min')



% clusters
for i=1:length(cidx)
    subplot(n_line+1,3,3+i)
    cied=clustering.qIED(i,:)/duration;
    bar(cied);hold on; 
    ylim([0 max(qEEG)])
    set(gca,'XTick',1:length(qEEG),'XTickLabel',labels_BIP); xtickangle(45);
    [idx,C]=kmeans(cied(:),2,'replicates',10);
    [~,cpoz]=max(C);
    bar(find(idx==cpoz),cied(idx==cpoz),'r')
    title(['Cluster #' num2str(i) ' - ' num2str(clustering.evt_percent(i),'%.01f') '%'])
end

%% originators
[IEDmax,IEDpoz]=max(clustering.qIED,[],2);
origin=unique(IEDpoz);

origin_weight=[];
for i=1:length(origin)
    origin_weight(i,1)=sum(IEDmax(IEDpoz==origin(i)));
end

figure(1)
subplot(n_line+1,3,[1 3])
plot(origin,origin_weight/duration,'ok','MarkerFaceColor','c');
%set(gca,'XTick',origin,'XTickLabel',labels_BIP(origin)); xtickangle(45); xlim([0 length(qEEG)+1])
%legend('background','irritative zone','origin')


tab=cell(size(clustering.qIED,1)+2,size(clustering.qIED,2)+1);
tab(1,:)=[{'Bip. channels'},labels_BIP(:,1)'];
tab(2,:)=[{'toal IED'},num2cell(qEEG)];
for i=1:size(clustering.qIED,1)
    tab(2+i,:)=[{['cluster #' num2str(i)]},num2cell(clustering.qIED(i,:)/duration)];    
end

% saveas(gcf,[saving_folder '\IED_and_cluster_' data_name], 'fig');
% close figure 1
%% Figures seules

% IED
figure(2)
qEEG=sum(discharges.MW.*(discharges.MV>0)/duration);
[idx1,C]=kmeans(qEEG(:),2,'replicates',10);
[~,cpoz]=max(C);
bar(qEEG);hold on;
set(gca,'XTick',1:length(qEEG),'XTickLabel',labels_BIP); xtickangle(45);
idx_spikes = find(idx1==cpoz);
bar(find(idx1==cpoz),qEEG(idx1==cpoz),'r')
title('total IED rate'); ylabel('IED/min')

%Originator
[IEDmax,IEDpoz]=max(clustering.qIED,[],2);
origin=unique(IEDpoz);
origin_weight=[];
for i=1:length(origin)
    origin_weight(i,1)=sum(IEDmax(IEDpoz==origin(i)));
end
hold on
figure(2)
plot(origin,origin_weight/duration,'ok','MarkerFaceColor','c');
tab=cell(size(clustering.qIED,1)+2,size(clustering.qIED,2)+1);
tab(1,:)=[{'Bip. channels'},labels_BIP(:,1)'];
tab(2,:)=[{'toal IED'},num2cell(qEEG)];
for i=1:size(clustering.qIED,1)
    tab(2+i,:)=[{['cluster #' num2str(i)]},num2cell(clustering.qIED(i,:)/duration)];    
end

 saveas(gcf,[saving_folder '\IED_' data_name], 'fig');
 close figure 2

% Clustering
figure(3)
for i=1:length(cidx)
    subplot(n_line,3,i)
    cied=clustering.qIED(i,:)/duration;
    bar(cied);hold on; 
    ylim([0 max(qEEG)])
    set(gca,'XTick',1:length(qEEG),'XTickLabel',labels_BIP); xtickangle(45);
    [idx,C]=kmeans(cied(:),2,'replicates',10);
    [~,cpoz]=max(C);
    bar(find(idx==cpoz),cied(idx==cpoz),'r')
    title(['Cluster #' num2str(i) ' - ' num2str(clustering.evt_percent(i),'%.01f') '%'])
end

 saveas(gcf,[saving_folder '\Clusters_' data_name], 'fig');
 close figure 3
 writetable(cell2table(tab),'results.csv','Delimiter',';','WriteVariableNames',0);
end

