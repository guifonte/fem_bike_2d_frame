%% Program: frame2d_lab
%
%   @DESCRIPTION Analysis of 2d frame structures. See the documentation of
%   the input and output files in the document framelab_inputfile.pdf. @
%
%   @AUTHOR Guilherme N. Fontebasso @
%   
%   @REFERENCE truss2d by Fabiano F. Bargos, Marco L. Bittencourt. @
%
%   @CREATED June/2019 @
%
%   @REVISED 1. @                
%
%
%% Clean memory and close windows
clear all
%close all
clc

%% Loading the problem params
[node_list, elem_list] = frame2d_reader('bike');

Q = 2; % Safety factor for the nominal loads
S = 1.5; % Safety factor for the von Mises equivalent stress

% Cargas considerando o fator de segurança
node_list.setSafetyFactor(Q);
elem_list.setSafetyFactor(S);

%Tensão de escoamento considerando o fator de segurança
%Para o problema proposto, todas as tensões de escoamento são iguais
sigma_esc = elem_list.elems(1).elem.sigma_esc;

%% Fiding the equivalent stress values for all elements for 120mm < h < 360mm
h_min = 0.120; %m
h_max = 0.360; %m
dh = 0.001; %m
num_h = ((h_max-h_min)/dh)+1;
h_vec = linspace(h_min, h_max, num_h); %m
h_vec_mm = h_vec*1000; %mm

stress_h = zeros(elem_list.num_elems,num_h);

% Calcula as tensões equivalentes para os valores de h determinados
for h_count = 1 : num_h
    new_x = 0.500 - h_vec(h_count)*0.250/sqrt(0.250^2+0.400^2);
    new_y = h_vec(h_count)*0.400/sqrt(0.250^2+0.400^2);
    node_list.updateNode(7, new_x, new_y);
    
    elem_list.updateElementsByNodeNum(7);
    
    [q, s, fr] = frame2d_solver(node_list, elem_list);
    stress_h(:,h_count) = s;  
end

% Encontra tensão média por h
avg_stress_h = zeros(1,num_h);
for i = 1 : num_h
    avg_stress_h(i) = sum(stress_h(:,i))/elem_list.num_elems;
end 

% Cria legenda para o gráfico tensão por h
h_leg = strings(elem_list.num_elems,1);
for i = 1 : elem_list.num_elems
    h_leg(i) = strcat("e^{[",num2str(i),"]}");
end
h_leg = [h_leg; "\sigma_{esc}"];
h_leg = [h_leg; "\sigma_{avg}"];
esc_vec = ones(1,length(h_vec_mm))*sigma_esc;

% Plot do gráfico de tensão por h
figure();
hold on;
plot(h_vec_mm,stress_h,'LineWidth',2);
plot(h_vec_mm,esc_vec,'--','LineWidth',2.5);
plot(h_vec_mm,avg_stress_h,'--','LineWidth',2);
xlabel('h [mm]','FontSize',14); 
ylabel('\sigma_{eq} [N/m^2]','FontSize',14);
title('Tensão equivalente em cada elemento para diferentes valores de h','FontSize',14);
grid on;
legend(h_leg,'FontSize',14);
xlim([h_min*1000 h_max*1000])
hold off;

% Encontra o h para a menor tensão equivalente média
[min_avg_stress, min_avg_stress_index] = min(avg_stress_h);
min_avg_stress_h = h_vec(min_avg_stress_index);

fprintf(1, 'A menor média das tensão equivalente ocorre quando h = %.2f m\n',min_avg_stress_h);

%Atualizando a posição do nó 7 e os elementos afetados para o h escolhido
new_x = 0.500 - min_avg_stress_h*0.250/sqrt(0.250^2+0.400^2);
new_y = min_avg_stress_h*0.400/sqrt(0.250^2+0.400^2);
node_list.updateNode(7, new_x, new_y);
elem_list.updateElementsByNodeNum(7);
[q_h, s_h, fr_h] = frame2d_solver(node_list, elem_list);

plotFrame(elem_list, node_list, 1);
plotStressBarGraph(elem_list);

%% Encontrando os valores de d1, d2 e d3 para o valor de h escolhido
%entre 0.012m e 0.027m

d_min = 0.012; %diâmetro mínimo
d_max = 0.027; %diâmetro máximo
dd = 0.0005; %m
num_d = ((d_max-d_min)/dd)+1;
d_vec = linspace(d_min, d_max, num_d);

weights_all = zeros(num_d,num_d,num_d);
weights_valid = zeros(num_d,num_d,num_d);
valid = zeros(num_d,num_d,num_d);
stress_d = zeros(num_d,num_d,num_d,elem_list.num_elems);

% Varia d1, d2 e d3, e verifica onde se tem o menor peso, considerando
% tensões abaixo da de escoamento.

for i1 = 1 : num_d
    elem_list.updateExtDiameterOfGroup(1, d_vec(i1))
    for i2 = 1 : num_d
        elem_list.updateExtDiameterOfGroup(2, d_vec(i2)) 
        for i3 = 1 : num_d
            elem_list.updateExtDiameterOfGroup(3, d_vec(i3)) 
                       
            [q, s, fr] = frame2d_solver(node_list, elem_list);
            stress_d(i1,i2,i3,:) = s;       
            
            %Vê se as tensões não passam a de escoamento, e salva o peso se
            %não ultrapassarem
            temp_weight = 0;
            isValid = 1;
            for i = 1 : elem_list.num_elems
                temp_weight = temp_weight + elem_list.getElemWeight(i);
                if s(i) > sigma_esc
                    isValid = 0;
                end
            end
            weights_all(i1,i2,i3) = temp_weight;
            if isValid == 1
                weights_valid(i1,i2,i3) = temp_weight;
                valid(i1,i2,i3) = 1;
            end
        end     
    end
end

% Obtém os índices do menor peso válido
min_ind = find(weights_valid==min(nonzeros(weights_valid)));
[d1_ind,d2_ind,d3_ind] = ind2sub(size(weights_valid), min_ind);
fprintf(1, 'O menor peso possível do quadro é %.5f g\n',weights_valid(d1_ind,d2_ind,d3_ind)*1000);
fprintf(1, 'Ele ocorre quando d1 = %.1f mm, d2 = %.1f mm  e d3 = %.1f mm\n',d_vec(d1_ind)*1000,d_vec(d2_ind)*1000,d_vec(d3_ind)*1000);

% Modifica os elementos para os diâmetros otimizados e plota
elem_list.updateExtDiameterOfGroup(1, d_vec(d1_ind))
elem_list.updateExtDiameterOfGroup(2, d_vec(d2_ind))
elem_list.updateExtDiameterOfGroup(3, d_vec(d3_ind))

[q_d, s_d, fr_d] = frame2d_solver(node_list, elem_list);

plotFrame(elem_list, node_list, 10);
plotStressBarGraph(elem_list);

% Open App
frame2d_lab_app(elem_list, node_list, d_vec(d1_ind)*1000, d_vec(d2_ind)*1000, d_vec(d3_ind)*1000, 10, dd*1000 , d_min*1000, d_max*1000, min_avg_stress_h*1000);