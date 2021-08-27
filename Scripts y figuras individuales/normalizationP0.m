%% Normalizado de sonido y spiketimes,P0
%Script para realizar el normalizado de las instancias de disparo segun
%anchor points definidos para las silabas
% Matlab 2018a

%% Datos para normalizar

a=2; %estímulo (si hay BOS1 y BOS2)
anchor_points=[1737, 903, 510, 6681]; %anchor points para P0
max_ini_length=anchor_points(1);
max_note_a_length=anchor_points(2);
max_gap_length=anchor_points(3);       
max_note_b_length=anchor_points(4); 

new_onset_a=0;
new_onset_gap=anchor_points(2)/sample_rate;
new_onset_b=sum(anchor_points(2:3))/sample_rate;
new_onset_ini=-anchor_points(1)/sample_rate;

%% Deteccion de onsets y offsets

%Delimito frase
 silaba= 'P0(M)'; %poner identidad de sílaba que me va a interesar
 n=1; %identificador del estimulo (BOS/CON/REV)
 g=1; %si la frase aparece mas de una vez, el numero de aparicion
 
 %Para extraer el momento temporal de la silaba en BOS
 find_sil= strfind(tg(n).tier{1,1}.Label,silaba); %encuentra los indices donde esta la silaba de interes
 frase_position_logical = ~cellfun(@isempty,find_sil); %paso a array logico para poder indexar
 frase_position_init=tg(n).tier{1,1}.T1(frase_position_logical); %encuentro el valor de tiempo inicial de la frase en esos indices
 frase_position_end=tg(n).tier{1,1}.T2(frase_position_logical);  %y el final de la frase
 sound=audio_stim{n}(t_audio_stim{n}>=(frase_position_init(g))& t_audio_stim{n}<=frase_position_end(g));
 times= t_audio_stim{n}(t_audio_stim{n}>=(frase_position_init(g))& t_audio_stim{n}<=frase_position_end(g));
 clear find_sil
 clear frase_position_logical
 
%Detecto inicios y finales de sílaba
params.fs=sample_rate;
params.birdname='BF';
params=def_params(params);
[gtes]=find_gte(sound,params);
onsets=times(gtes.gtes1);
offsets=times(gtes.gtes2);

clear gtes
clear params

%Testeo para ver si me detecto bien los inicios de las silabas

ax(1)=subplot(1,1,1);
plot(times,sound);
hold on
for j=1:length(onsets)
line(onsets(j)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',5,'Color',[0.8 0.8 0]);
line(offsets(j)*[1 1],ax(1).YLim,'LineStyle','-','MarkerSize',5,'Color',[0.1 0.1 0]);
end
clear j

%Separo las distintas instancias
onset_a=onsets(1:2:end);
onset_b=onsets(2:2:end);
offset_a=offsets(1:2:end);
offset_b=offsets(2:2:end);
syll_ini=[onset_a(1)+new_onset_ini offset_b(2:end-1)];

clear onsets
clear offsets

%% Normalizado de oscilogramas

onset_a_samples=round(onset_a*sample_rate);
offset_a_samples=round(offset_a*sample_rate);
onset_b_samples=round(onset_b*sample_rate);
offset_b_samples=round(offset_b*sample_rate);
syll_ini_samples=round(syll_ini*sample_rate);

length_note_a=offset_a_samples-onset_a_samples;
length_gap=onset_b_samples-offset_a_samples;
length_note_b=offset_b_samples-onset_b_samples;
length_ini=onset_a_samples-syll_ini_samples;

for t=1:length(onset_a)    
sound_a(t)={audio_stim{a}(onset_a_samples(t):offset_a_samples(t))};
sound_b(t)={audio_stim{a}(onset_b_samples(t):offset_b_samples(t))};
sound_gap(t)={audio_stim{a}(offset_a_samples(t):onset_b_samples(t))};
end  
clear t

for g=1:length(onset_a)
stretched_notes_a{g}=interp1(1:size(sound_a{g},2),sound_a{g},linspace(1,size(sound_a{g},2),max_note_a_length))';
stretched_gap{g}=interp1(1:size(sound_gap{g},2),sound_gap{g},linspace(1,size(sound_gap{g},2),max_gap_length))';
stretched_notes_b{g}=interp1(1:size(sound_b{g},2),sound_b{g},linspace(1,size(sound_b{g},2),max_note_b_length))';
end

for g=1:length(onset_a)
stretched_syllabes(:,g)= [stretched_notes_a{g}; stretched_gap{g}; stretched_notes_b{g}];
end

clear g
clear stretched_notes_a
clear stretched_gap
clear stretched_notes_b

for t=1:length(onset_a)  
    plot(stretched_syllabes(:,t))
    hold on 
    pause
end

clear onset_a_samples
clear onset_b_samples
clear offset_a_samples
clear offset_b_samples
clear syll_ini_samples
clear sound_a
clear sound_b
clear sound_gap


%% Normalizado de temporalidad de spikes

stretched_spike_train_sil={};

for h=1:length(onset_a)
stretched_spike_train=[];
spikes_stim_all=cell2mat(spike_stim(a).trial);
spike_train=spikes_stim_all((spikes_stim_all>=syll_ini(h))&(spikes_stim_all<=offset_b(h)));
spike_train_reset=spike_train;

for spike = 1:length(spike_train_reset)
    spike_timestamp = spike_train_reset(spike);
    
    if spike_timestamp >= syll_ini(h) && spike_timestamp < onset_a(h) 
        stretched_spike_timestamp = (spike_timestamp-syll_ini(h)) * max_ini_length/length_ini(h) + new_onset_ini;
    
    elseif spike_timestamp >= onset_a(h) && spike_timestamp < offset_a(h)
        
        stretched_spike_timestamp = (spike_timestamp-onset_a(h)) * max_note_a_length/length_note_a(h) + new_onset_a;
            
    elseif spike_timestamp >= offset_a(h) && spike_timestamp < onset_b(h)
        
        stretched_spike_timestamp = (spike_timestamp-offset_a(h)) * max_gap_length/length_gap(h) + new_onset_gap;

    elseif spike_timestamp >= onset_b(h) && spike_timestamp < offset_b(h)
        
        stretched_spike_timestamp = (spike_timestamp-onset_b(h)) * max_note_b_length/length_note_b(h) + new_onset_b; 
    
    end
   
    stretched_spike_train(spike)= stretched_spike_timestamp*1000; %paso a ms por comodidad
    
end
 
   stretched_spike_train_sil(h)={stretched_spike_train};
   
end

clear stretched_spike_train
clear stretched_spike_timestamp
clear spike_train
clear spike_train_reset 
clear spike_timestamp
clear spike

%%  Agrupado de histogramas

%Para ir agrupando los histogramas:
hbc=[];
binsize=5;
length_totalr=272;
for i=1:length(stretched_spike_train_sil)
 hh=histogram(stretched_spike_train_sil{1,i},new_onset_ini*1000:binsize:length_totalr,'Normalization','probability');
 hold on
 pause
 hbc=vertcat(hbc,hh.Values);
end

clear hh
clear i
clear binsize

%% Agrupado de curvas de suavizado

cs=[];
binsize=1;
for i=1:length(stretched_spike_train_sil)
 [hh,tt]=ksdensity(stretched_spike_train_sil{1,i},new_onset_ini*1000:binsize:length_totalr,'function','pdf','BandWidth',binsize,'Numpoints',length_totalr);
 hold on
 cs=vertcat(cs,hh);
 plot(tt,cs(i,:))
end

cs_m=mean(cs);
plot(tt,cs_m);

clear cs
clear binsize