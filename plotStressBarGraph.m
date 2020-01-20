function plotStressBarGraph(elem_list)
    num_elems = elem_list.num_elems;
    figure();
    hold on;
    x = linspace(1,num_elems,num_elems);
    sigma_esc_y = zeros(1,num_elems);
    sigma_eq_y = zeros(1,num_elems);
    for i = 1 : num_elems
        sigma_esc_y(i) = elem_list.getElemSigmaEsc(i);
        sigma_eq_y(i) = elem_list.getElemSigmaEq(i);
    end
    w1 = 1;
    w2 = 0.5;
    bar(x,sigma_esc_y,w1,'FaceColor',[0.2 0.2 0.5])
    bar(x,sigma_eq_y,w2,'FaceColor',[0 0.7 0.7])
    grid on
    ylabel('\sigma_{eq} [N/m^2]','FontSize',14);
    legend({'\sigma_{esc}','Elementos'},'FontSize',14)
    title('Tensão equivalente de cada elemento','FontSize',14);
    xlim([1-w1/2 num_elems+w1/2])
    ylim([0 max([max(sigma_eq_y) max(sigma_esc_y)])*1.1])
    hold off;
end

