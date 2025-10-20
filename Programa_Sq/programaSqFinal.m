close all
clear all
clc

% Lista de arquivos das 5 estações
filenames = {
    'gabi_sjc_2017H02F.TXT',...  % Estação 1
    'gabi_sjc_2017H09F.TXT',...  % Estação 2
    'gabi_sjc_2017H15F.TXT',...  % Estação 3
    'gabi_sjc_2017H28F.TXT',...  % Estação 4
    'gabi_sjc_2017H30F.TXT'...   % Estação 5
    'josy_sjc_2017H02F.TXT',...  % Estação 1
    'josy_sjc_2017H09F.TXT',...  % Estação 2
    'josy_sjc_2017H15F.TXT',...  % Estação 3
    'josy_sjc_2017H28F.TXT',...  % Estação 4
    'josy_sjc_2017H30F.TXT'...   % Estação 5
    'laura_sjc_2017H02F.TXT',...  % Estação 1
    'laura_sjc_2017H09F.TXT',...  % Estação 2
    'laura_sjc_2017H15F.TXT',...  % Estação 3
    'laura_sjc_2017H28F.TXT',...  % Estação 4
    'laura_sjc_2017H30F.TXT'...   % Estação 5
};


% Inicializando variáveis para armazenar os dados de todas as estações
num_stations = length(filenames);


all_full_foF2 = cell(num_stations, 1);
tempo = 1:288;


% Loop sobre cada arquivo de estação
for station_idx = 1:num_stations
    filename = filenames{station_idx};

    % Abrir o arquivo para leitura
    fileID = fopen(filename, 'r');
    
    % Verificação se o arquivo foi aberto corretamente
    if fileID == -1
        fprintf('Erro ao abrir o arquivo: %s\n', filename);
        continue;  % Pula para o próximo arquivo
    end
    
    data = textscan(fileID, '%s %s %s %f %f %f', 'HeaderLines', 1, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    fclose(fileID);

    

    % Extract columns from data
    date_str = data{1};    % Date strings
    time_str = data{3};    % Time strings
    foF2 = data{4};        % foF2 data
    hF = data{5};          % h'F data
    hmF2 = data{6};        % hmF2 data
    
    

    % Combine date and time strings into a single datetime array
    datetime_str = strcat(date_str, {' '}, time_str);
    time = datetime(datetime_str, 'InputFormat', 'yyyy.MM.dd HH:mm:ss');

    % Generate a complete time series with 15-minute intervals
    start_time = min(time);
    end_time = max(time);
    full_time = (start_time:minutes(5):end_time)';

    % Convert datetime to serial date numbers for plotting
    full_time_numeric = datenum(full_time);

    % Initialize arrays to store complete data
    full_foF2 = NaN(size(full_time));
    full_hF = NaN(size(full_time));
    full_hmF2 = NaN(size(full_time));

    % Fill the complete data arrays
    [~, ia, ib] = intersect(full_time, time);
    full_foF2(ia) = foF2(ib);
    full_hF(ia) = hF(ib);
    full_hmF2(ia) = hmF2(ib);

    
     % Replace '---' with NaN in the numeric data (as the file has '---' for missing values)
     foF2_final(:,station_idx)= full_foF2;
     hF_final(:,station_idx) = full_hF;
     hmF2_final(:,station_idx) = full_hmF2;
     
     
    
end


[N,M] = size(hmF2_final);

figure(1)
for i = 1:M
    subplot1 = subplot(3,1,1);
    plot(tempo,hF_final(:,i),'k');
    ylabel('h''F (Km)');
%     set(subplot1,'FontSize',24,'LineWidth',2,'XTick', ...
%         [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 96], ...
%         'XTickLabel', {''});
    %xlim([1,96]);
    hold on;

    subplot2 = subplot(3,1,2);
    plot(tempo,foF2_final(:,i),'k');
    ylabel('f0F2 (MHz)');
%     set(subplot2,'FontSize',24,'LineWidth',2,'XTick', ...
%         [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 96], ...
%         'XTickLabel', {''});
    %xlim([1,96]);
    hold on;

    subplot3 = subplot(3,1,3);
    plot(tempo,hmF2_final(:,i),'k');
    ylabel('hmF2 (Km)');
%     set(subplot3,'FontSize',24,'LineWidth',2,'XTick', ...
%         [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 96], ...
%         'XTickLabel', {'','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'});
    %xlim([1,96]);
    hold on;
end

% Calculating means and standard deviations
mediahF = smooth(nanmean(hF_final, 2), 36, 'moving');
desviohF = nanstd(hF_final, 0, 2);
mediaf0F2 = smooth(nanmean(foF2_final, 2), 36, 'moving');
desviof0F2 = nanstd(foF2_final, 0, 2);
mediahmF2 = smooth(nanmean(hmF2_final, 2), 36, 'moving');
desviohmF2 = nanstd(hmF2_final, 0, 2);

%replica

hF_final1=repmat(mediahF,3,1);
foF2_final1=repmat(mediaf0F2,3,1);
hmF2_final1=repmat(mediahmF2,3,1);


% x = (1:length(hF_final1))';  % tempo com base nos índices (1 a 864)
% 
% % h'F
% y_hF = hF_final1;
% mediahF = fnval(csaps(x, y_hF, 0.9), x);  % 0.9 é o parâmetro de suavização
% 
% % foF2
% y_foF2 = foF2_final1;
% mediaf0F2 = fnval(csaps(x, y_foF2, 0.9), x);
% 
% % hmF2
% y_hmF2 = hmF2_final1;
% mediahmF2 = fnval(csaps(x, y_hmF2, 0.9), x);

mediahF = smooth(nanmean(hF_final1, 2), 36, 'moving');

mediaf0F2 = smooth(nanmean(foF2_final1, 2), 36, 'moving');

mediahmF2 = smooth(nanmean(hmF2_final1, 2), 36, 'moving');

mediahF(1:288,:)=[];
mediaf0F2(1:288,:)=[];
mediahmF2(1:288,:)=[];

mediahF(289:end,:)=[];
mediaf0F2(289:end,:)=[];
mediahmF2(289:end,:)=[];




% Save the variables to a .mat file
save('mediasedesvios.mat', 'mediahF', 'desviohF','mediaf0F2', 'desviof0F2', 'mediahmF2', 'desviohmF2');

% Confirm saving process
disp('Variables saved to mediasedesvios.mat successfully.');

grayColor = [0.7, 0.7, 0.7];  % Light gray

figure(1)

subplot1 = subplot(3,1,1);
plot(tempo,mediahF,'LineWidth',3)
hold on;
errorbar(tempo, mediahF, desviohF, 'Color', grayColor);

subplot2 = subplot(3,1,2);
plot(tempo,mediaf0F2,'LineWidth',3)
hold on;
errorbar(tempo, mediaf0F2, desviof0F2, 'Color', grayColor);
ylabel('f0F2 (MHz)');
% set(subplot2,'FontSize',24,'LineWidth',2,'XTick', ...
%     [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 96], ...
%     'XTickLabel', {''});
%xlim([1,96]);

subplot3 = subplot(3,1,3);
plot(tempo,mediahmF2,'LineWidth',3)
hold on;
errorbar(tempo, mediahmF2, desviohmF2, 'Color', grayColor);
ylabel('hmF2 (Km)');
% set(subplot3,'FontSize',24,'LineWidth',2,'XTick', ...
%     [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 65 69 73 77 81 85 89 93 96], ...
%     'XTickLabel', {'','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'});
%xlim([1,96]);


MAEnoitehF = mean(abs(mediahF(253:288,1)));
MAEnoitef0F2 = mean(abs(mediaf0F2(253:288,1)));
MAEnoitehmF2 = mean(abs(mediahmF2(253:288,1)));
%
% Display Results
fprintf('h''F: %.4f\n', MAEnoitehF);
fprintf('f0F2: %.4f\n', MAEnoitef0F2);
fprintf('hmF2: %.4f\n', MAEnoitehmF2);
