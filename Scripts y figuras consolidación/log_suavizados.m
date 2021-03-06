%% Figura consolidacion logaritmo de curvas
%Cuantificacion. Figura con el logaritmo de las curvas de suavizado de los tres estados
%comportamentales, MUA.
%Nota: cantando aun no esta procesado del mismo modo, sujeto a modificacion

%% Carga de datos

%Anchor points utilizados para normalizar
anchor_points=[57.9333,30.0667,17.2667,222.7000]; %valores en ms
list_anchors=[anchor_points(1),sum(anchor_points(1:2)),sum(anchor_points(1:3)),sum(anchor_points(1:4))]-anchor_points(1);

%Vigilia
    %Anchor points utilizados para P0
    anchor_points_samples=[1737, 903, 510, 6681]; %valores en samples
    
    %Onsets en base a los anchor points
    sample_rate=30000;
    new_onset_a=0;
    new_onset_gap=anchor_points_samples(2)*1000/sample_rate;
    new_onset_b=sum(anchor_points_samples(2:3))*1000/sample_rate;
    new_onset_ini=-anchor_points_samples(1)*1000/sample_rate;
    
    load datanormalizada-MU.mat
    
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

%Anestesiado
    % Nota: P0anchorpoints son los anchorpoints transformados a 20 kHz
    load('consolidation_MUA')
    fs=20000;
    t_env=(1E3/fs)*(((P0anchorpoints(4)-P0anchorpoints(5))):1:(length(envall)-(P0anchorpoints(5)-P0anchorpoints(4))-1));    
    
   %% Procesado de datos
    
binsize=5;

%Anestesiado 
    hbcc_m=mean(hbcc);
    hbcc_log=log(hbcc_m);
    
%Vigilia
    length_totalr=328;
    cst=[];
    for i=1:length(stretched_spike_train_sil)
    [ss,tt]=ksdensity(stretched_spike_train_sil{1,i}*1000,new_onset_ini:binsize:length_totalr,'function','pdf','BandWidth',binsize); %hago una curva de suavizado por silaba con los 20 trials
    hold on
    cst=vertcat(cst,ss);
    end
    hold off
    cs=mean(cst); %promedio las curvas de suavizado
    cs_log=log(cs);
    
%Cantando
    averages_log=log(averages(fil,:));
    
    %% Ploteo
    
    f1= figure(1);

%Envolvente de los oscilogramas normalizados
    j(1)=subplot(4,1,1);
    
    %Envolvente de s?labas en anestesiado
    plot(t_env,mean(envall,1),'black','LineWidth',1.5)
    X=[t_env fliplr(t_env)];
    Y=[(mean(envall,1)-std(envall,0,1)) fliplr((mean(envall,1)+std(envall,0,1)))];
    patch(X,Y,1/255*[197,180,227],'EdgeColor','none');hold on;
    alpha .5
    hold on
    
    %Envolvente de s?labas en cantando
    plot(times,allmeans,'Color',color_darkpurple,'LineWidth',3)
    plot(times,allmeans+stdallmeans,'Color',color_darkpurple,'LineWidth',2,'LineStyle','--')
    plot(times,allmeans-stdallmeans,'Color',color_darkpurple,'LineWidth',2,'LineStyle','--')
    line(list_anchors'*[1 1],[0 1],'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    text(list_anchors(1)-30,j(1).YLim(2)*0.9,sprintf('%.2f',0),'color','k'); %valores n?mericos de onsets y offsets
    text(list_anchors(2)-20,j(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(2)),'color','k'); %valores n?mericos de onsets y offsets
    text(list_anchors(3)+2,j(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(3)),'color','k'); %valores n?mericos de onsets y offsets
    
    hold off
    ylim([0 1])
    ylabel('Env. promedio (u.a.)')

    %Curva de suavizado, logaritmica, cantando
    j(2)=subplot(4,1,2);
    plot(times,averages_log,'LineWidth',2,'Color', [0,0.3882,0])
    hold on
    line(list_anchors'*[1 1],j(2).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    ylabel({'Logaritmo de'; 'curva de suavizado'; 'Cantando'},'Color',[0,0.3882,0]);
    hold off
    
    %Curva de suavizado, logaritmica, anestesiado
    j(3)=subplot(4,1,3);
    plot(xi,hbcc_log,'Color','r','LineWidth',1); 
    ylim([-9 -4])
    hold on
    line(list_anchors'*[1 1],j(3).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    ylabel({'Logaritmo de'; 'curva de suavizado'; 'Anestesiado'},'Color','r');
    
    %Curva de suavizado, logaritmica, vigilia
    j(4)=subplot(4,1,4);
    plot(tt,cs_log,'Color','b','LineWidth',1); 
    ylim([-8 -5])
    hold on
    line(list_anchors'*[1 1],j(4).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    hold off
    ylabel({'Logaritmo de'; 'curva de suavizado'; 'Vigilia'},'Color','b');
   
    xlabel('Tiempo normalizado(ms)');
    linkaxes(j,'x');
    equispace(f1);
    xlim([new_onset_ini times(end)])
