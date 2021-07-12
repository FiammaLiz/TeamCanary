%% Figura general para consolidación
%Cargo los datos correspondientes a cada estado comportamental y ploteo 
%histogramas de cada uno de ellos (SU fásica y tónica en caso de
%anestesiado, SU fásica en cantando, SU y MU en escuchando vigilia)

%% Cargo los datos

binsize=5;

%Posición de los picos
picos_escuchando_s= 44.6; %estimacion a partir de histograma, SU
picos_escuchando_m= [39.6 67.1];%estimacion a partir de histograma,MU
picos_anestesiado_f= [49.55 64.55]; %estimacion a partir de histograma, SU fásicas
picos_anestesiado_t= 69.55; %estimacion a partir de histograma, SU tónicas
picos_cantando=[-24.6,31.2]; %provienen de la estimación que hice con los datos del paper suavizado y binsize 15ms

%Anchor points utilizados para P0
anchor_points_samples=[1737, 903, 510, 6681]; %valores en samples
anchor_points=[57.9333,30.0667,17.2667,222.7000]; %valores en ms
list_anchors=[anchor_points(1),sum(anchor_points(1:2)),sum(anchor_points(1:3)),sum(anchor_points(1:4))]-anchor_points(1);

%Fiamma (escuchando vigilia)
    %Onsets en base a los anchor points
    sample_rate=30000;
    new_onset_a=0;
    new_onset_gap=anchor_points_samples(2)*1000/sample_rate;
    new_onset_b=sum(anchor_points_samples(2:3))*1000/sample_rate;
    new_onset_ini=-anchor_points_samples(1)*1000/sample_rate;

    %SU
    load datanormalizada-SU.mat
    hbc_FiSu=[];
    length_totalr=328;
    %hago histograma de histogramas
    for i=1:length(stretched_spike_train_sil_SU)
    hh=histogram(stretched_spike_train_sil_SU{1,i}*1000,new_onset_ini:binsize:length_totalr,'Normalization','probability');
    hold on
    hbc_FiSu=vertcat(hbc_FiSu,hh.Values);
    end

    %MU
    load datanormalizada-MU.mat
    hbc_FiMu=[];
    %hago histograma de histogramas
    for i=1:length(stretched_spike_train_sil_MU)
    hh=histogram(stretched_spike_train_sil_MU{1,i}*1000,new_onset_ini:binsize:length_totalr,'Normalization','probability');
    hold on
    hbc_FiMu=vertcat(hbc_FiMu,hh.Values);
    end

%Santi (escuchando anestesiado)
    % Para graficar silabas
    % Nota: P0anchorpoints son los anchorpoints transformados a 20 kHz
    load consolidation_5ms_SUf.mat
    fs=20000;
    t_env=(1E3/fs)*(((P0anchorpoints(4)-P0anchorpoints(5))):1:(length(envall)-(P0anchorpoints(5)-P0anchorpoints(4))-1));

%Ceci (cantando)
    color_darkpurple=[0.4940, 0.1840, 0.5560];
    color_darkgreen=[0,0.3882,0];
    load('consolidacion_cantando.mat');
    uniformlen=9839;
    times=((1:uniformlen)-1737)./30;

%% Ploteo

f1= figure(1);

%Envolvente de los oscilogramas normalizados
    j(1)=subplot(6,1,1);
    
    %Envolvente de sílabas en anestesiado
    plot(t_env,mean(envall,1),'black','LineWidth',1.5)
    X=[t_env fliplr(t_env)];
    Y=[(mean(envall,1)-std(envall,0,1)) fliplr((mean(envall,1)+std(envall,0,1)))];
    patch(X,Y,1/255*[197,180,227],'EdgeColor','none');hold on;
    alpha .5
    hold on
    
    %Envolvente de sílabas en cantando
    plot(times,allmeans,'Color',color_darkpurple,'LineWidth',3)
    plot(times,allmeans+stdallmeans,'Color',color_darkpurple,'LineWidth',2,'LineStyle','--')
    plot(times,allmeans-stdallmeans,'Color',color_darkpurple,'LineWidth',2,'LineStyle','--')
    line(list_anchors'*[1 1],[0 1],'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    text(list_anchors(1)-30,j(1).YLim(2)*0.9,sprintf('%.2f',0),'color','k'); %valores númericos de onsets y offsets
    text(list_anchors(2)-20,j(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(2)),'color','k'); %valores númericos de onsets y offsets
    text(list_anchors(3)+2,j(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(3)),'color','k'); %valores númericos de onsets y offsets
    
    hold off
    ylim([0 1])
    ylabel('Env. promedio (u.a.)')

%Histograma datos cantando
    j(2)=subplot(6,1,2);
    bighist=histogram('BinEdges',-100:5:400,'BinCounts',sum(allhists,1)/size(allhists,1)); %histograma
    bighist.FaceColor=color_darkgreen;
    bighist.EdgeColor=color_darkgreen;
    line(list_anchors'*[1 1],[0 j(2).YLim(2)],'color',[0.5 0.5 0.5 0.5]); %lineas que delimitan los onsets y offsets
    %grafico los picos
    line([picos_cantando(1) picos_cantando(1)],[0 j(2).YLim(2)],'color',color_darkgreen); 
    line([picos_cantando(2) picos_cantando(2)],[0 j(2).YLim(2)],'color',color_darkgreen);
    text(picos_cantando(1)+2,j(2).YLim(2)*0.9,sprintf('%.2f',picos_cantando(1)),'color',color_darkgreen);
    text(picos_cantando(2)+2,j(2).YLim(2)*0.9,sprintf('%.2f',picos_cantando(2)),'color',color_darkgreen);
    xlim([-57.9,270.07])
    box('off')

%Histograma datos anestesiado, SU fásicas
j(3)=subplot(6,1,3);
y=bar(t_env(1):binsize:(t_env(end)-binsize),sum(hbc,1)/size(hbc,1),'histc'); %histograma
y.FaceColor=[1 0 0]; 
%Grafico los picos y sus valores
line([picos_anestesiado_f(1) picos_anestesiado_f(1)],[0 j(3).YLim(2)],'color',[1 0 0]);
line([picos_anestesiado_f(2) picos_anestesiado_f(2)],[0 j(3).YLim(2)],'color',[1 0 0]);
text(picos_anestesiado_f(1)+2,j(3).YLim(2)*0.9,sprintf('%.2f',picos_anestesiado_f(1)),'color',[1 0 0]);
text(picos_anestesiado_f(2)+2,j(3).YLim(2)*0.9,sprintf('%.2f',picos_anestesiado_f(2)),'color',[1 0 0]);
ylabel('Prob. de disparo (SUf)')

%Histograma de datos anestesiado, SU tónicas
j(4)=subplot(6,1,4); 
load consolidation_5ms_SUt.mat
u=bar(t_env(1):binsize:(t_env(end)-binsize),sum(hbc,1)/size(hbc,1),'histc');
u.FaceColor=[1 0.2 0.1];
%Grafico los picos y sus valores
line([picos_anestesiado_t picos_anestesiado_t],[0 j(4).YLim(2)],'color',[1 0.2 0.1]);
text(picos_anestesiado_t,j(4).YLim(2)*0.9,sprintf('%.2f',69.55),'color',[1 0.2 0.1]);
ylabel('Prob. de disparo (SUt)')

%Histograma de datos escuchando vigilia, SU
j(5)=subplot(6,1,5);
g=bar(new_onset_ini:binsize:(length_totalr*1000-binsize),sum(hbc_FiSu,1)/size(hbc_FiSu,1),'histc'); %histograma
g.FaceColor=[0.1 0.25 0.75];
%Grafico los picos y sus valores
line([picos_escuchando_s picos_escuchando_s],[0 j(5).YLim(2)],'color',[0.1 0.25 0.75]);
text(picos_escuchando_s+2,j(5).YLim(2)*0.9,sprintf('%.2f',picos_escuchando_s),'color',[0.1 0.25 0.75]);
ylabel('Prob. de disparo (SUf)')

%Histograma de histogramas de Fi-MU
j(6)=subplot(6,1,6);
b=bar(new_onset_ini:binsize:(length_totalr*1000-binsize),sum(hbc_FiMu,1)/size(hbc_FiMu,1),'histc'); %histograma
b.FaceColor=[0.2 0.5 0.8];
%Grafico los picos y sus valores
line(list_anchors'*[1 1],[0 j(6).YLim(2)],'color',[0.5 0.5 0.5 0.5]);
line([picos_escuchando_m(1) picos_escuchando_m(1)],[0 j(6).YLim(2)],'color',[0.2 0.5 0.8]);
line([picos_escuchando_m(2) picos_escuchando_m(2)],[0 j(6).YLim(2)],'color',[0.2 0.5 0.8]);
text(picos_escuchando_m(1)-2,j(6).YLim(2)*0.9,sprintf('%.2f',picos_escuchando_m(1)),'color',[0.2 0.5 0.8]);
text(picos_escuchando_m(2)-2,j(6).YLim(2)*0.9,sprintf('%.2f',picos_escuchando_m(2)),'color',[0.2 0.5 0.8]);
ylabel('Prob. de disparo (MU)')

xlabel('Tiempo normalizado (ms)')
linkaxes(j,'x');
equispace(f1);
xlim([-57.9 272.1]);
