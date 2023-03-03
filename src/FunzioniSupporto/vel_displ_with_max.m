%
% La funzione prende in ingresso vehicle_north, t_cut, dT, T_final e restituisce il coefficiente angolare della retta 
% di regressione dei punti di vehicle_north di massimo t.c. t>= t_cut.
% Il coefficiente angolare di tale retta sarà un indice 'qualitativo' della
% velocità di spostamento del veicolo.
% Definizione variabili:
% 
% * vehicle_north : è la traiettoria del cog del veicolo, output della
%                   simualazione;
% * t_cut : istante temporale in cui si presume finire il transitorio del
%           veicolo. In generale valutiamo per ispezione il momento in cui il pitch
%           oscilla attorno ad un punto di equilibrio ( ~30 sec )
% * dT : passo di simulazione;
% * T_final : tempo di fine simulazione
% 

function coeff= vel_displ_with_max(vehicle_north, t_cut,dT,T_final)


Time=[0:dT:T_final]';

X=vehicle_north;
% Derivata discreta
dX=diff(X);
% Esprimo dX come vettore -1,1 e potenzialmente 0 (numericamente poco
% probabile)
sign_dX= sign(dX);

% Vado a memorizzare gli indici dove si ha un cambio del segno della
% derivata
index=[];
for i=1:(length(sign_dX)-1)
    
    % Ad ogni step, controllo il valore in posizione i+1 sia diverso da 0 e 1. Qualora fosse verificato, controllo che 
    % gli elementi in posizione i, i+1 siano diversi --> lo scenario è (i,i+1) == (+1,-1). 
    % Nel caso sia tutto verificato, memorizzo l'indice i.
    % N.B.: (sign_dX(i+1) ~= 0) non è molto elegante tantomeno generale in quanto
    %       funziona nel caso specifico di funzione sinusoidale.
    if ( sign_dX(i) ~= sign_dX(i+1)) && (sign_dX(i+1) ~= 0) && (sign_dX(i+1) ~= 1) 
        index=cat(1,index,i);
    end
    
end

% dX ha dimensione N-1, N dimensione di X. Per prelevare i giusti valori di
% X devo aggiungere 1.
index=index+1;

% Prelevo gli elementi di Time e vehicle_north indicate da index
Time4regr=[];
Trajectory4regr=[];
for i=1:length(index)
    Time4regr=cat(1, Time4regr, Time(index(i)));
    Trajectory4regr=cat(1, Trajectory4regr, X(index(i)));
end

% Prendo solo gli elementi di interesse, ovvero t.c. Time4regr >= t_cut
index=find(Time4regr >= t_cut);
Time4regr_2=Time4regr(index(1):end);
Trajectory4regr_2=Trajectory4regr(index(1):end);

% Fit dei punti
Regr=polyfit(Time4regr_2,Trajectory4regr_2, 1);

% [Regr,S]=polyfit(Time4regr_2,Trajectory4regr_2, 1);
% [Y, delta]=polyval(Regr,Time4regr_2,S);

% Check visivo
% close all;
% figure(5),
% plot(Time, X)
% hold on
% % Punti critici
% scatter(Time4regr,Trajectory4regr,'r')
% % In verde sono i punti critici t.c. Time>= t_cut
% scatter(Time4regr_2,Trajectory4regr_2,'g')
% % Retta di regressione
% plot(Time4regr_2, polyval(Regr,Time4regr_2))
% xlabel('Time [sec]')
% ylabel('[m]')
% title('Fit with points of max')
% %     
coeff=Regr(1);


end


