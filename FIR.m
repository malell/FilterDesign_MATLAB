clc, clear, close all
[song, Fs] = audioread('music.wav');
song = song(:,1);

load('filtersFIR.mat');

g_dB = [-20, -30, -20, -15, 15];

%% Ajustament dels filtres
%Aplicació del guany al filtre (guany en dB convertit a lineal)
Filter1 = Filter1.*db2mag(g_dB(1));
Filter2 = Filter2.*db2mag(g_dB(2));
Filter3 = Filter3.*db2mag(g_dB(3));
Filter4 = Filter4.*db2mag(g_dB(4));
Filter5 = Filter5.*db2mag(g_dB(5));

%% Generació dels tons purs de frecuencies f (test)
f = [125, 500, 1500, 4500, 8500];   %Frecuències
s = 1;                              %Durada del to
t = [0 : 1/Fs : s];

tono = zeros(1, length(t));
for i = 1:length(f)
   tono = cos(f(i)*2*pi*t) + tono;
end
clear i s

L = length(tono);

[tonoF, f_tono] = freqz(tono, 1, L, Fs);
Y = abs(tonoF);

maxV = max(Y);

y_f1 = filter(Filter1, 1, tono);
y_f2 = filter(Filter2, 1, tono);
y_f3 = filter(Filter3, 1, tono);
y_f4 = filter(Filter4, 1, tono);
y_f5 = filter(Filter5, 1, tono);
tono_f = y_f1 + y_f2 + y_f3 + y_f4 + y_f5;

[tonoF_f, f_tono_f] = freqz(tono_f, 1, L, Fs);
X = abs(tonoF_f);

max = max([max(X), maxV]);

figure('Name','Tono puro original i filtrado','NumberTitle','off','Position',[0,380,600,400]);
subplot (2,1,1)
plot(f_tono, Y, 'r')
axis([20 inf 0 max]);
hold on
g = maxV.*ones(1, length(f_tono));
plot(f_tono,g, 'linestyle', '--', 'Color', 'b');
%line([0,Fs/2],[maxV,maxV], 'Color', 'b', 'linestyle','--');
title ('Tonos puros originales');
xlabel ('frequency (Hz)');

subplot(2,1,2)
plot(f_tono_f,X, 'r')
hold on
plot(f_tono,g, 'linestyle', '--', 'Color', 'b');
axis([20 inf 0 max]);
title ('Tonos puros filtrados');
xlabel ('frequency (Hz)');

ax = findall(gcf, 'Type', 'axes');
set(ax(1), 'XScale', 'log');
set(ax(2), 'XScale', 'log');
clear ax;

%% Mostra de la resposta frecuencial amb freqz.m (test)
%Suma dels numeradors de tots els filtres (resposta completa del nostre
%filtre)
Filter = Filter1 + Filter2 + Filter3 + Filter4 + Filter5;

figure('Name','Respuesta frecuencial del ecualizador','NumberTitle','off','Position',[0,0,600,400]);
freqz(Filter, 1, size(Filter,2), Fs);
ax = findall(gcf, 'Type', 'axes');
set(ax(1), 'XScale', 'log');
xlabel(ax(1),'Frequency (Hz)');
xlabel(ax(2),'Frequency (Hz)');
clear ax

%% Obtenció de la sortida del sistema, cançó filtrada en song_f
%Aplicació de cada filtre a la melodia y obtenció del resultat final sumant
%cada una d'elles
y_f1 = filter(Filter1, 1, song);
y_f2 = filter(Filter2, 1, song);
y_f3 = filter(Filter3, 1, song);
y_f4 = filter(Filter4, 1, song);
y_f5 = filter(Filter5, 1, song);
song_f = y_f1 + y_f2 + y_f3 + y_f4 + y_f5;

clear y_f1 y_f2 y_f3 y_f4 y_f5;

%% Resultat final, mostra en audio (test)
soundsc(song_f, Fs);

%% Graficas
L = length(song);

[Y, f] = freqz(song, 1, L, Fs);
[X, ~] = freqz(song_f, 1, L, Fs);

P1 = 10*log(abs(Y));
P2 = 10*log(abs(X));

figure('Name','Señal original y filtrada en dominio frecuencial y temporal','NumberTitle','off','Position',[600,0,600,400]);
subplot (2,2,1)
plot (f, P1, 'b')
axis([20 inf 0 inf]);
title ('Original-Freq');
xlabel ('frequency (Hz)');
ylabel ('magnitude (dBs)');

subplot(2,2,3)
plot (f, P2, 'b')
axis([20 inf 0 inf]);
title ('Filtered-Freq');
xlabel ('frequency (Hz)');
ylabel ('magnitude (dBs)');

ax = findall(gcf, 'Type', 'axes');
set(ax(1), 'XScale', 'log');
set(ax(2), 'XScale', 'log');
clear ax;

tiempo_cancion = size(song,1)/Fs;
t = 0:1/Fs:tiempo_cancion;

subplot(2,2,2)
plot(t(2:end), song, 'b')
title ('Original-Time');
xlabel ('time');
ylabel ('amplitude');

subplot(2,2,4)
plot(t(2:end), song_f, 'b')
title ('Filtered-Time');
xlabel ('time');
ylabel ('amplitude');

