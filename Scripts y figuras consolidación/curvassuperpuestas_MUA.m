%% Figura consolidacion curvas superpuestas
%Figura con curvas de suavizado superpuestas de los tres estados
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
    
    load datanormalizada-MU-Fiamma.mat
    
%Cantando
    anchors=[1,1738,2640,3158,9839];
    color_lfp= [0.9100 0.4100 0.1700];
    color_mua=[0.6980,0.1333,0.1333];   
    color_darkpurple=[0.4940, 0.1840, 0.5560];
    sr=30000;
    fil=2;
    uniformlen=9839;
    load('consolidacion_cantando_mua_lfp.mat');
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

    %% Ploteo
    
    f1= figure(1);

%Envolvente de los oscilogramas normalizados
    j(1)=subplot(2,1,1);
    
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

%Curvas de suavizado superpuestas
    j(2)=subplot(2,1,2);
    yyaxis left
    plot(xi,hbcc_m,'Color','r','LineWidth',2,'LineStyle','-.'); %anestesiado
    ylabel({'Curvas de suavizado'; 'superpuestas'},'Color','k');
    hold on
    plot(tt,cs,'Color','b','LineWidth',2,'LineStyle','-.'); %vigilia
    plot(times,averages(fil,:)/100,'LineWidth',2,'Color', [0,0.3882,0],'LineStyle','-.'); %cantando (divido por 100 para corregir altura)
    yyaxis right
    plot(times,averages(fil,:),'LineWidth',2,'Color','none','LineStyle','-.'); %cantando, para poder plotear el eje correcto
    line(list_anchors'*[1 1],j(2).YLim,'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
    hold off
    
    xlabel('Tiempo normalizado(ms)');
    linkaxes(j,'x');
    equispace(f1);
    xlim([new_onset_ini times(end)])


