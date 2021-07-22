%% Correlacion de curvas de suavizado- MUA
%Calcula las correlaciones de Pearson de las curvas de suavizado de los
%tres estados comportamentales (tres pares) y grafica dos figuras donde se
%realizan corrimientos según el lag que resulte en una mayor correlacion
%(maximo absoluto y local)
%Matlab 2018a

%% Cargo datos y los preparo

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
    
%Vigilia
    load('datanormalizada-MU-Fiamma','stretched_spike_train_sil');
    binsize2=1;
    length_totalr=270;
    
    %Curva de suavizado
    cst=[];
    for i=1:length(stretched_spike_train_sil)
    [ss,tt]=ksdensity(stretched_spike_train_sil{1,i}*1000,new_onset_ini:binsize2:length_totalr,'function','pdf','BandWidth',binsize2); %hago una curva de suavizado por silaba con los 20 trials
    hold on
    cst=vertcat(cst,ss);
    end
    hold off
    cs=mean(cst); %promedio las curvas de suavizado

    clear length_totalr
    clear cst
    clear ss
    
%Anestesiado
    % Nota: P0anchorpoints son los anchorpoints transformados a 20 kHz
    load('consolidation_MUA_v3')
    fs=20000;
    t_env=(1E3/fs)*(((P0anchorpoints(4)-P0anchorpoints(5))):1:(length(envall)-(P0anchorpoints(5)-P0anchorpoints(4))-1));    
    %Curva de suavizado
    hbcc_m=mean(hbcc); 
    
%Cantando
    anchors=[1,1738,2640,3158,9839];
    color_lfp= [0.9100 0.4100 0.1700];
    color_mua=[0.6980,0.1333,0.1333];   
    color_darkpurple=[0.4940, 0.1840, 0.5560];
    uniformlen=9839;
    load('consolidacion_cantando_mua_lfp.mat','allmeans','averages','stdallmeans');
    fil=2; %fila de datos de mua
    times=(1:uniformlen)./30+new_onset_ini;
    clear uniformlen
    
    %Resampleo
    vt=new_onset_ini:binsize2:length_totalr; %vector con tiempos para resamplear
    vq = interp1(times,averages(2,:),vt); %resampleo
    vq(1)=averages(fil,3); %Para eliminar los NaN que siempre aparecen
    vq(end)=averages(fil,length(averages)-3); %Para eliminar los NaN que siempre aparecen
    f1=figure(1); %ploteo ambas trazas para chequear que el resampleo se realizo correctamente
    plot(vt,vq,'o');
    hold on
    plot(times,averages(2,:));
    hold off
    clear binsize2

    %% Calculo de correlaciones

%Correlacion cantando-vigilia

[r_cv,lags_cv] = xcorr(cs,vq,'coeff');
[mx_cv,lcs_cv]=findpeaks(r_cv); %calculo los maximos
lag_mx_cv_min=lags_cv(lcs_cv(1)); %maximo local
lag_mx_cv_max=lags_cv(lcs_cv(2)); %maximo absoluto


%Correlacion cantando-anestesiado
[r_ca,lags_ca] = xcorr(hbcc_m,vq,'coeff');
[mx_ca,lcs_ca]=findpeaks(r_ca); %calculo los maximos
lag_mx_ca=lags_ca(lcs_ca);
lag_mx_ca_min=lags_ca(lcs_ca(2)); %maximo local
lag_mx_ca_max=lags_ca(lcs_ca(3)); %maximo absoluto


%Correlacion anestesiado-vigilia
[r_av,lags_av] = xcorr(cs,hbcc_m,'coeff');
[mx_av,lcs_av]=findpeaks(r_av); %calculo los maximos
lag_mx_av=lags_av(lcs_av);
 
 
%% Ploteo con minimos
    
f2=figure(2);

%Envolvente de los oscilogramas normalizados
    co(1)=subplot(4,2,1);
    
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
    text(list_anchors(1)-30,co(1).YLim(2)*0.9,sprintf('%.2f',0),'color','k'); %valores númericos de onsets y offsets
    text(list_anchors(2)-20,co(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(2)),'color','k'); %valores númericos de onsets y offsets
    text(list_anchors(3)+2,co(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(3)),'color','k'); %valores númericos de onsets y offsets
    
    hold off
    ylabel('Env. promedio (u.a.)')
    xlim([new_onset_ini length_totalr])

%Correlacion cantando-vigilia
co(2)=subplot(4,2,3);
    yyaxis left
    plot(tt,vq/100,'LineWidth',2,'Color', [0,0.3882,0],'LineStyle','-.')
    hold on
    plot(tt-lag_mx_cv_min,cs,'Color','b','LineWidth',2,'LineStyle','-.');
    ylabel({'Curvas superpuestas'; 'con corrimiento';'Cantando-Vigilia'})
    yyaxis right
    plot(tt,vq,'LineWidth',2.5,'Color', 'none');
    xlim([new_onset_ini length_totalr])
    
co(3)=subplot(4,2,4);  
%correlacion cantando-vigilia
    plot(lags_cv,r_cv,'color',[1 0.5 0]); 
    hold on
    plot(lag_mx_cv_min,mx_cv(1)+0.05,'v','Color','b')
    text(-390,co(3).YLim(2)*0.9,['Lag min=',sprintf('%.2f',lag_mx_cv_min)],'color','k'); %valores númericos de onsets y offsets
    text(-390,co(3).YLim(2)*0.7,['Corr=',sprintf('%.2f',mx_cv(1))],'color','k'); %valores númericos de onsets y offsets
    title('Correlaciones de Pearson')

%Correlacion cantando-anestesiado
co(4)=subplot(4,2,5);
    yyaxis left
    plot(tt,vq/100,'LineWidth',2,'Color', [0,0.3882,0],'LineStyle','-.')
    hold on
    plot(xi-lag_mx_ca_min,hbcc_m,'Color',[1 0 0],'LineWidth',2,'LineStyle','-.'); 
    ylabel({'Curvas superpuestas'; 'con corrimiento';'Cantando-Anestesiado'})
    yyaxis right
    plot(tt,vq,'LineWidth',2.5,'Color', 'none');
    xlim([new_onset_ini length_totalr])
    
co(5)=subplot(4,2,6);
%Correlacion cantando-anestesiado    
    plot(lags_ca,r_ca,'color',[1 0.5 0]); 
    hold on
    plot(lag_mx_ca_min,mx_cv(2),'v','Color','b')
    text(-390,co(5).YLim(2)*0.9,['Lag min=',sprintf('%.2f',lag_mx_ca_min)],'color','k'); %valores númericos de onsets y offsets
    text(-390,co(5).YLim(2)*0.7,['Corr=',sprintf('%.2f',mx_ca(2))],'color','k'); %valores númericos de onsets y offsets

%Correlacion anestesiado-vigilia
 co(6)=subplot(4,2,7);
    plot(tt-lag_mx_av,cs,'Color','b','LineWidth',2,'LineStyle','-.');
    hold on
    plot(xi-lag_mx_av,hbcc_m,'Color',[1 0 0],'LineWidth',2,'LineStyle','-.'); 
    ylabel({'Curvas superpuestas'; 'con corrimiento';'Anestesiado-Vigilia'})
    xlim([new_onset_ini length_totalr])
    
xlabel('Tiempo normalizado(ms)')

co(7)=subplot(4,2,8); 
%correlacion anestesiado-vigilia
    plot(lags_av,r_av,'color',[1 0.5 0]);
    hold on
    plot(lag_mx_av,mx_av+0.05,'v','Color','b')
    text(-390,co(5).YLim(2)*0.9,['Lag min=',sprintf('%.2f',lag_mx_av)],'color','k'); %valores númericos de onsets y offsets
    text(-390,co(5).YLim(2)*0.7,['Corr=',sprintf('%.2f',mx_av)],'color','k'); %valores númericos de onsets y offsets


%% Ploteo con maximos
    
f3=figure(3);

%Envolvente de los oscilogramas normalizados
    co(1)=subplot(4,2,1);
    
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
    text(list_anchors(1)-30,co(1).YLim(2)*0.9,sprintf('%.2f',0),'color','k'); %valores númericos de onsets y offsets
    text(list_anchors(2)-20,co(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(2)),'color','k'); %valores númericos de onsets y offsets
    text(list_anchors(3)+2,co(1).YLim(2)*0.9,sprintf('%.2f',list_anchors(3)),'color','k'); %valores númericos de onsets y offsets
    
    hold off
    ylabel('Env. promedio (u.a.)')
    xlim([new_onset_ini length_totalr])
    
%Cantando-vigilia
co(2)=subplot(4,2,3);
    yyaxis left
    plot(tt,vq/100,'LineWidth',2,'Color', [0,0.3882,0],'LineStyle','-.')
    hold on
    plot(tt-lag_mx_cv_max,cs,'Color','b','LineWidth',2,'LineStyle','-.');
    ylabel({'Curvas superpuestas'; 'con corrimiento';'Cantando-Vigilia'})
    yyaxis right
    plot(tt,vq,'LineWidth',2.5,'Color', 'none');
    xlim([new_onset_ini length_totalr])
    
co(3)=subplot(4,2,4);
    %correlacion cantando-vigilia
    plot(lags_cv,r_cv); 
    hold on
    plot(lag_mx_cv_max,mx_cv(2)+0.05,'v','Color','b') %marca del pico
    text(-390,co(3).YLim(2)*0.9,['Lag max=',sprintf('%.2f',lag_mx_cv_max)],'color','k'); %valores númericos de onsets y offsets
    text(-390,co(3).YLim(2)*0.7,['Corr=',sprintf('%.2f',mx_cv(2))],'color','k'); %valores númericos de onsets y offsets
    title('Correlaciones de Pearson')

%Cantando-anestesiado
co(4)=subplot(4,2,5);
    yyaxis left
    plot(tt,vq/100,'LineWidth',2,'Color', [0,0.3882,0],'LineStyle','-.')
    hold on
    plot(xi-lag_mx_ca_max,hbcc_m,'Color',[1 0 0],'LineWidth',2,'LineStyle','-.'); 
    ylabel({'Curvas superpuestas'; 'con corrimiento';'Cantando-Anestesiado'})
    yyaxis right
    plot(tt,vq,'LineWidth',2.5,'Color', 'none');
    xlim([new_onset_ini length_totalr])
    
co(5)=subplot(4,2,6);   
    %correlacion cantando-anestesiado
    plot(lags_ca,r_ca); 
    hold on
    plot(lag_mx_ca_max,mx_ca(3)+0.04,'v','Color','b') %marca del pico
    text(-390,co(5).YLim(2)*0.9,['Lag max=',sprintf('%.2f',lag_mx_ca_max)],'color','k'); %valores númericos de onsets y offsets
    text(-390,co(5).YLim(2)*0.7,['Corr=',sprintf('%.2f',mx_ca(3))],'color','k'); %valores númericos de onsets y offsets
    
%Anestesiado-vigilia
 co(6)=subplot(4,2,7);
    plot(tt-lag_mx_av,cs,'Color','b','LineWidth',2,'LineStyle','-.');
    hold on
    plot(xi-lag_mx_av,hbcc_m,'Color',[1 0 0],'LineWidth',2,'LineStyle','-.'); 
    ylabel({'Curvas superpuestas'; 'con corrimiento';'Anestesiado-Vigilia'})
    xlim([new_onset_ini length_totalr])
    
xlabel('Tiempo normalizado(ms)')

co(7)=subplot(4,2,8);  
    %correlacion anestesiado-vigilia
    plot(lags_av,r_av); 
    hold on
    plot(lag_mx_av,mx_av+0.05,'v','Color','b') %marca del pico
    text(-390,co(5).YLim(2)*0.9,['Lag=',sprintf('%.2f',lag_mx_av)],'color','k'); %valores númericos de onsets y offsets
    text(-390,co(5).YLim(2)*0.7,['Corr=',sprintf('%.2f',mx_av)],'color','k'); %valores númericos de onsets y offsets


