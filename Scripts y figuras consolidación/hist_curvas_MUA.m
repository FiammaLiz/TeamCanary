%% Figura consolidacion curvas + histogramas
%Figura con histogramas y curvas de suavizado de los tres estados
%comportamentales, MUA.
%Nota: cantando aun no esta procesado del mismo modo, sujeto a modificacion

%% Carga de datos

%Anchor points utilizados para normalizar
    anchor_points=[57.9333,30.0667,17.2667,222.7000]; %valores en ms
    list_anchors=[anchor_points(1),sum(anchor_points(1:2)),sum(anchor_points(1:3)),sum(anchor_points(1:4))]-anchor_points(1);
    anchor_points_samples=[1737, 903, 510, 6681]; %valores en samples
    
%Onsets en base a los anchor points
    sample_rate=30000;
    new_onset_a=0;
    new_onset_gap=anchor_points_samples(2)*1000/sample_rate;
    new_onset_b=sum(anchor_points_samples(2:3))*1000/sample_rate;
    new_onset_ini=-round(anchor_points(1));
    
%Cantando
    anchors=[1,1738,2640,3158,9839];
    color_lfp= [0.9100 0.4100 0.1700];
    color_mua=[0.6980,0.1333,0.1333];   
    color_darkpurple=[0.4940, 0.1840, 0.5560];
    sr=30000;
    uniformlen=9839;
    load('consolidacion_cantando_mua_lfp.mat');
    fil=2;
    times=(1:uniformlen)./30+new_onset_ini;

%Vigilia
    load datanormalizada-MU-Fiamma.mat
    
%Anestesiado
    % Nota: P0anchorpoints son los anchorpoints transformados a 20 kHz
    load('consolidation_MUA_v3')
    fs=20000;
    t_env=(1E3/fs)*(((P0anchorpoints(4)-P0anchorpoints(5))):1:(length(envall)-(P0anchorpoints(5)-P0anchorpoints(4))-1));    
    
    %% Procesado de datos
    
binsize=5; %histograma
binsize2=1; %curva de suavizado

%Anestesiado

    %Curva de suavizado
    hbcc_m=mean(hbcc); 
    
%Vigilia

    length_totalr=270;
    
    %Curva de suavizado
    cst=[];
    for i=1:length(stretched_spike_train_sil)
    [ss,tt]=ksdensity(stretched_spike_train_sil{1,i}*1000,new_onset_ini:binsize2:length_totalr,'function','pdf','BandWidth',binsize); %hago una curva de suavizado por silaba con los 20 trials
    hold on
    cst=vertcat(cst,ss);
    end
    hold off
    cs=mean(cst); %promedio las curvas de suavizado
    cs_std=std(cst,0,1); %desvio estandard de las curvas de suavizado
    
    %Histograma
    hbc_MU=[];
    for i=1:length(stretched_spike_train_sil)
    hh=histogram(stretched_spike_train_sil{1,i}*1000,new_onset_ini:binsize:length_totalr,'Normalization','pdf');
    hold on
    hbc_MU=vertcat(hbc_MU,hh.Values);
    end
    
    %% Ploteo
    
    f1= figure(1);

%Envolvente de los oscilogramas normalizados
    j(1)=subplot(4,1,1);
    
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
    ylabel('Env. promedio (u.a.)')
    
    %Curva de suavizado con desvio, anestesiado
    j(2)=subplot(4,1,2);
    plot(xi,hbcc_m,'Color',[1 0 0 0.5],'LineWidth',2.5); 
    hold on
    a=bar(new_onset_ini:binsize:length_totalr,sum(hbc,1)/size(hbc,1),'histc');   
    a.FaceColor='none';
    a.EdgeColor='r';
    a.LineWidth=1;
    line(list_anchors'*[1 1],j(2).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    ylabel({'Histograma con';'curva de suavizado'; 'Anestesiado'},'Color','r');
    
    %Curva de suavizado con desvio, vigilia
    j(3)=subplot(4,1,3);
    plot(tt,cs,'Color',[0 0 1 0.5],'LineWidth',2.5); 
    hold on
    line(list_anchors'*[1 1],j(3).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    v=bar(new_onset_ini:binsize:(length_totalr-binsize),sum(hbc_MU,1)/size(hbc_MU,1),'histc'); %histograma
    v.FaceColor='none';
    v.EdgeColor='b';
    v.LineWidth=1;
    hold off
    ylabel({'Histograma con';'curva de suavizado'; 'Vigilia'},'Color','b');
    
%Curva de suavizado con desvio, cantando
    j(4)=subplot(4,1,4);
    plot(times,averages(fil,:),'LineWidth',2,'Color', [0,0.3882,0])
    hold on
    line(list_anchors'*[1 1],j(4).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    %Inserte aqui histograma
    %c=;
    %c.FaceColor='none';
    %c.EdgeColor=[0,0.3882,0];
    %c.LineWidth=1;
    ylabel({'Histograma con';'curva de suavizado'; 'Cantando'},'Color',[0,0.3882,0]);
    hold off
    
    xlabel('Tiempo normalizado(ms)');
    linkaxes(j,'x');
    equispace(f1);
    xlim([new_onset_ini times(end)])
    