%% Ploteo de histograma- escuchando Vigilia- MUA
%Figura con histograma ponderado de la actividad neuronal al escuchar
%silabas P0 durante la vigilia
%Matlab 2018a

%% Cargo datos y los proceso

load('datanormalizada-MU-Fiamma')

    %Curva de suavizado
    cst=[];
    for i=1:length(stretched_spike_train_sil)
    [ss,tt]=ksdensity(stretched_spike_train_sil{1,i},new_onset_ini*1000:binsize2:length_totalr,'function','pdf','BandWidth',binsize2); %hago una curva de suavizado por silaba con los 20 trials
    hold on
    cst=vertcat(cst,ss);
    end
    hold off
    cs=mean(cst); %promedio las curvas de suavizado
    cs_std=std(cst,0,1); %desvio estandard de las curvas de suavizado
    
    %Histograma
    hbc_MU=[];
    for i=1:length(stretched_spike_train_sil)
    hh=histogram(stretched_spike_train_sil{1,i},new_onset_ini*1000:binsizer:length_totalr,'Normalization','pdf');
    hold on
    hbc_MU=vertcat(hbc_MU,hh.Values);
    end
    
duration_syllabe= (1:length(stretched_syllabes))*1000/sample_rate; %para el plot de la onda de sonido de las silabas

%% Ploteo

f1= figure(2); 

%Oscilogramas normalizados
n(1)=subplot(4,1,1);
plot(duration_syllabe,mean_envelopes,'b','LineWidth',3)
X=[duration_syllabe fliplr(duration_syllabe)];
Y=[(mean_envelopes-std_envelopes) fliplr(mean_envelopes+std_envelopes)];
patch(X,Y,1/255*[0,200,227],'EdgeColor','none');hold on;
alpha .5
hold on
list_anchors=([anchor_points(1),sum(anchor_points(1:2)),sum(anchor_points(1:3)),sum(anchor_points(1:4))]-anchor_points(1))*1000/sample_rate;
%lineas con anchor points y sus valores
line(list_anchors'*[1 1],[n(1).YLim(1) 0.4],'color',[0.5 0.5 0.5 0.5]);
text(list_anchors(1)-30,n(1).YLim(2)*0.85,sprintf('%.2f',0),'color','k');
text(list_anchors(2)-20,n(1).YLim(2)*0.85,sprintf('%.2f',list_anchors(2)),'color','k');
text(list_anchors(3)+2,n(1).YLim(2)*0.85,sprintf('%.2f',list_anchors(3)),'color','k');
ylabel 'Env. promedio(u.a.)'

%Histograma ponderado + curva de suavizado
n(2)=subplot(4,1,2);
plot(tt,cs,'Color',[0 0 1 0.5],'LineWidth',2.5); %curva de suavizado
hold on
line(list_anchors'*[1 1],[0 0.007],'color',[0.5 0.5 0.5 0.5]); %lineas grises para delimitar onsets y offsets 
v=bar(new_onset_ini*1000:binsizer:(length_totalr-binsizer),sum(hbc_MU,1)/size(hbc_MU,1),'histc'); %histograma
v.FaceColor='none';
v.EdgeColor='b';
v.LineWidth=1;
%Etiquetas de picos
line([42.1 42.1],[0 0.007],'LineWidth',1,'LineStyle','-.','color','k');
line([67.1 67.1],[0 0.007],'LineWidth',1,'LineStyle','-.','color','k');
text(2,n(2).YLim(2)*0.8,sprintf('%.2f',42.1));
text(75.6,n(2).YLim(2)*0.8,sprintf('%.2f',67.1));
hold off
ylabel({'Probabilidad de'; 'disparo'});
 

%Raster de cada silaba

n(3)=subplot(4,1,3:4);

         for h=1:length(stretched_spike_train_sil_RoNe1)  
  line(stretched_spike_train_sil_RoNe1{1,h}'*[1 1],[-0.4 0.4] + h,'LineStyle','-','MarkerSize',4,'Color',colorp{1}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         hold on
         for j=1:length(stretched_spike_train_sil_RoNe2)  
  line(stretched_spike_train_sil_RoNe2{1,j}'*[1 1],[-0.4 0.4] + h + j,'LineStyle','-','MarkerSize',4,'Color',colorp{2}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for k=1:length(stretched_spike_train_sil_RoNe3)  
  line(stretched_spike_train_sil_RoNe3{1,k}'*[1 1],[-0.4 0.4] + h +j +k,'LineStyle','-','MarkerSize',4,'Color',colorp{3}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for l=1:length(stretched_spike_train_sil_RoNe4)  
  line(stretched_spike_train_sil_RoNe4{1,l}'*[1 1],[-0.4 0.4] + h +j +k + l,'LineStyle','-','MarkerSize',4,'Color',colorp{4}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for m=1:length(stretched_spike_train_sil_RoNe5)  
  line(stretched_spike_train_sil_RoNe5{1,m}'*[1 1],[-0.4 0.4] + h +j +k + l + m,'LineStyle','-','MarkerSize',4,'Color',colorp{5}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for f=1:length(stretched_spike_train_sil_RoNe6)  
  line(stretched_spike_train_sil_RoNe6{1,f}'*[1 1],[-0.4 0.4] + h +j +k + l + m +f,'LineStyle','-','MarkerSize',4,'Color',colorp{6}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for o=1:length(stretched_spike_train_sil_RoNe7)  
  line(stretched_spike_train_sil_RoNe7{1,o}'*[1 1],[-0.4 0.4] + h +j +k + l + m +f + o,'LineStyle','-','MarkerSize',4,'Color',colorp{7}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for a1=1:length(stretched_spike_train_sil_RoNe8)  
  line(stretched_spike_train_sil_RoNe8{1,a1}'*[1 1],[-0.4 0.4] + h +j +k + l + m +f + o +a1,'LineStyle','-','MarkerSize',4,'Color',colorp{8}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         line([new_onset_ini*1000 new_onset_b*1000+anchor_points(4)*1000/sample_rate],[0.6 0.6] + h +j +k + l + m +f + o +a1 ,'LineStyle','-','MarkerSize',4,'Color','k'); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial   
         for c1=1:length(stretched_spike_train_sil_VeNe1)  
  line(stretched_spike_train_sil_VeNe1{1,c1}'*[1 1],[-0.4 0.4] + h +j +k + l + m +f + o +a1 +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{10}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for d1=1:length(stretched_spike_train_sil_VeNe2)  
  line(stretched_spike_train_sil_VeNe2{1,d1}'*[1 1],[-0.4 0.4] +d1 + h +j +k + l + m +f + o +a1 +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{11}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for e1=1:length(stretched_spike_train_sil_VeNe3)  
  line(stretched_spike_train_sil_VeNe3{1,e1}'*[1 1],[-0.4 0.4] +e1 +d1 + h +j +k + l + m +f + o +a1 +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{12}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for f1=1:length(stretched_spike_train_sil_VeNe4)  
  line(stretched_spike_train_sil_VeNe4{1,f1}'*[1 1],[-0.4 0.4] +f1 +e1 +d1 + h +j +k + l + m +f + o +a1 +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{13}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for h1=1:length(stretched_spike_train_sil_VeNe5)  
  line(stretched_spike_train_sil_VeNe5{1,h1}'*[1 1],[-0.4 0.4] + h1 +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{14}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for i1=1:length(stretched_spike_train_sil_VeNe6)  
  line(stretched_spike_train_sil_VeNe6{1,i1}'*[1 1],[-0.4 0.4] + i1+ h1 +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{15}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for j1=1:length(stretched_spike_train_sil_VeNe7)  
  line(stretched_spike_train_sil_VeNe7{1,j1}'*[1 1],[-0.4 0.4] +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{16}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
 line([new_onset_ini*1000 new_onset_b*1000+anchor_points(4)*1000/sample_rate],[0.6 0.6]  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1 +c1,'LineStyle','-','MarkerSize',4,'Color','k'); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial   
         for h2=1:length(stretched_spike_train_sil_VioAzu1)  
  line(stretched_spike_train_sil_VioAzu1{1,h2}'*[1 1],[-0.4 0.4]  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1 + h2,'LineStyle','-','MarkerSize',4,'Color',colorp{19}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for j2=1:length(stretched_spike_train_sil_VioAzu2)  
  line(stretched_spike_train_sil_VioAzu2{1,j2}'*[1 1],[-0.4 0.4] + h2 + j2 +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{20}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for k2=1:length(stretched_spike_train_sil_VioAzu3)  
  line(stretched_spike_train_sil_VioAzu3{1,k2}'*[1 1],[-0.4 0.4] + h2 +j2 +k2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1 + +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{21}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for l2=1:length(stretched_spike_train_sil_VioAzu4)  
  line(stretched_spike_train_sil_VioAzu4{1,l2}'*[1 1],[-0.4 0.4] + h2 +j2 +k2 + l2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{22}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for m2=1:length(stretched_spike_train_sil_VioAzu5)  
  line(stretched_spike_train_sil_VioAzu5{1,m2}'*[1 1],[-0.4 0.4] + h2 + j2 +k2 + l2 + m2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{23}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for f2=1:length(stretched_spike_train_sil_VioAzu6)  
  line(stretched_spike_train_sil_VioAzu6{1,f2}'*[1 1],[-0.4 0.4] + h2 +j2 +k2 + l2 + m2 +f2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{24}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for o2=1:length(stretched_spike_train_sil_VioAzu7)  
  line(stretched_spike_train_sil_VioAzu7{1,o2}'*[1 1],[-0.4 0.4] + h2 +j2 + k2 + l2 + m2 + f2 + o2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{25}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for p2=1:length(stretched_spike_train_sil_VioAzu8)  
  line(stretched_spike_train_sil_VioAzu8{1,p2}'*[1 1],[-0.4 0.4] + h2 + j2 + k2 + l2 + m2 +f2 + o2 + p2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{10}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for q2=1:length(stretched_spike_train_sil_VioAzu9)  
  line(stretched_spike_train_sil_VioAzu9{1,q2}'*[1 1],[-0.4 0.4] + h2 + j2 + k2 + l2 + m2 +f2 + o2 + p2 + q2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{11}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for r2=1:length(stretched_spike_train_sil_VioAzu10)  
  line(stretched_spike_train_sil_VioAzu10{1,r2}'*[1 1],[-0.4 0.4] + h2 +j2 +k2 + l2 + m2 +f2 + o2 + p2 +q2 +r2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{12}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for u2=1:length(stretched_spike_train_sil_VioAzu11)  
  line(stretched_spike_train_sil_VioAzu11{1,u2}'*[1 1],[-0.4 0.4] + h2 +j2 +k2 + l2 + m2 + f2 + o2 + p2 + q2 + r2 + u2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{13}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         for v2=1:length(stretched_spike_train_sil_VioAzu12)  
  line(stretched_spike_train_sil_VioAzu12{1,v2}'*[1 1],[-0.4 0.4] + h2 + j2 + k2 + l2 + m2 +f2 + o2 + p2 + q2 + r2 + u2 + v2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{14}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for w2=1:length(stretched_spike_train_sil_VioAzu13)  
  line(stretched_spike_train_sil_VioAzu13{1,w2}'*[1 1],[-0.4 0.4] + h2 + j2 + k2 + l2 + m2 + f2 + o2 + p2 + q2 + r2 + u2 + v2 + w2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{15}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for x2=1:length(stretched_spike_train_sil_VioAzu14)  
  line(stretched_spike_train_sil_VioAzu14{1,x2}'*[1 1],[-0.4 0.4] + h2 + j2 + k2 + l2 + m2 + f2 + o2 + p2 + q2 +r2 + u2 + v2 + w2 + x2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{16}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end 
         for z2=1:length(stretched_spike_train_sil_VioAzu15)  
  line(stretched_spike_train_sil_VioAzu15{1,z2}'*[1 1],[-0.4 0.4] + h2 +j2 + k2 + l2 + m2 + f2 + o2 + p2 + q2 + r2 + u2 + v2 + w2 + x2 + z2  +j1 + i1+ h1   +f1 +e1 +d1 + h +j +k + l + m +f + o +a1  +c1,'LineStyle','-','MarkerSize',4,'Color',colorp{17}); %extrae las instancias de disparo y hace lineas azules, apilándolas por cada trial 
         end
         
ylim([0 length(stretched_spike_train_sil)+0.5])
ylabel '# de silaba' 
xlabel 'tiempo normalizado (ms)'

linkaxes(n,'x');
hold off

xlim([new_onset_ini*1000 length_totalr])