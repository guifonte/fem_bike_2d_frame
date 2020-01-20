function plotFrame(elem_list, node_list, scale_factor)
    maxHe = elem_list.getMaxAbsHe();
    minX = node_list.getMinX();
    minY = node_list.getMinY();
    maxX = node_list.getMaxX();
    maxY = node_list.getMaxY();
    
    figure('Color',[0 0 0]);
    
    %% Mesh and boundary conditions
    subplot1 = subplot(2,1,1, ...
        'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
        'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
        'Xlim', [minX - .5 * maxHe, maxX + .5 * maxHe], ...
        'Ylim', [minY - .5 * maxHe, maxY + .5 * maxHe], ...
        'Color',[0 0 0]);

    % Create labels (X e Y)
    xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
    ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

    % Create title
    title('Frame','FontSize',17, 'Color',[1 1 1]);
    box on;

    hold all;

    % plots original mesh
    plotOriginalMesh(elem_list);

    % plots nodes of the undeformed mesh
    plotNodesOriginalMesh(node_list);


    %% Plots loads
    load_coords = node_list.getLoadCoords();
    FFe = .25 * (load_coords(:,1) .* maxHe ./ abs(max(load_coords(:,1))));
    load_coords(:,1) = FFe;
    
    for i = 1 : length(load_coords(:,1))
        if load_coords(i,4) == 1
            quiver(load_coords(i,2)-load_coords(i,1), load_coords(i,3), load_coords(i,1), 0,...
                'MaxHeadSize', 3,'LineWidth', 1, 'Color',[1 0 0], 'AutoScaleFactor',1);
        elseif load_coords(i,4) == 2
            quiver(load_coords(i,2), load_coords(i,3)-load_coords(i,1), 0, load_coords(i,1),...
                'MaxHeadSize', 3,'LineWidth', 1, 'Color',[1 0 0], 'AutoScaleFactor',1);
        end
    end

    %% Plots bcs  
    BCDOFs_coords = node_list.getBCDOFsCoords();
    for i = 1 : size(BCDOFs_coords,1)
        if BCDOFs_coords(i,3) == 1
            quiver(BCDOFs_coords(i,1)-.7e-1*maxHe, BCDOFs_coords(i,2), 0, 0, 'Marker','>', 'MarkerSize', 11, ...
                'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);

        elseif BCDOFs_coords(i,3) == 2
             quiver(BCDOFs_coords(i,1), BCDOFs_coords(i,2)-.7e-1*maxHe, 0, 0, 'Marker','^', 'MarkerSize', 11, ...
                'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);
        end
    end
    hold off;

    %% Plots reaction forces
    subplot2 = subplot(2,1,2, ...
        'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
        'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
        'Xlim', [minX - .5 * maxHe, maxX + .5 * maxHe], ...
        'Ylim', [minY - .5 * maxHe, maxY + .5 * maxHe], ...
        'Color',[0 0 0]);

    % Create labels (X e Y)
    xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
    ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

    % Create title
    title('Reaction loads','FontSize',17, 'Color',[1 1 1]);
    box on;

    hold all;

    % plots original mesh
    plotOriginalMesh(elem_list);

    % plots reaction loads
    FR_coords = node_list.getFRCoords();
    FFR = .25 * (FR_coords(:,1) .* maxHe ./ abs(max(FR_coords(:,1))));
    FR_coords(:,1) = FFR;
    
    for i = 1 : length(FR_coords(:,1))
        if FR_coords(i,4) == 1
            quiver(FR_coords(i,2)-FR_coords(i,1), FR_coords(i,3), FR_coords(i,1), 0,...
                'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);

        elseif FR_coords(i,4) == 2
            quiver(FR_coords(i,2), FR_coords(i,3)-FR_coords(i,1), 0, FR_coords(i,1),...
                'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);
        end
    end

    % plots nodes of the undeformed mesh
    plotNodesOriginalMesh(node_list);
    
    %% Plot element strains
    figure('Colormap',...
        [0 0 0.6667;0 0 1;0 0.3333 1;0 0.6667 1;0 1 1;0 1 0.3333;0.3333 1 0;1 1 0;1 0.6667 0;1 0.3333 0],...
        'Color',[0 0 0]);

    subplot3 = subplot(2,1,1, ...
        'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
        'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
        'Xlim', [minX - .5 * maxHe, maxX + .5 * maxHe], ...
        'Ylim', [minY - .5 * maxHe, maxY + .5 * maxHe], ...
        'Color',[0 0 0]);

    % Create labels
    xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
    ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

    % Create title
    title('Element strains','FontSize',17, 'Color',[1 1 1]);
    box on;

    hold all;

    % plot original mesh
    plotOriginalMesh(elem_list);
    
    % plot deformed mesh
    new_node_coords = node_list.getNodesNewCoords(scale_factor);
    new_elems_coords = elem_list.getElemsNewCoords(new_node_coords);
    elems_defs = elem_list.getElemsDeformations();
    
    for ElemNum = 1 : elem_list.num_elems
        % plot deformed mesh and element strains
        fill([new_elems_coords(ElemNum,1);new_elems_coords(ElemNum,3)],...
            [new_elems_coords(ElemNum,2);new_elems_coords(ElemNum,4)], ...
            elems_defs(ElemNum, :), 'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 1);
    end

    colorbar('peer',subplot3, 'YTick', linspace(min(min(elems_defs)), max(max(elems_defs)), 10), ...      
        'LineWidth', 1,... 
        'FontWeight','normal', 'Color', [.7 .7 .7]);

    % plots os nós da geometria deformada
    plot(new_node_coords(:,1), new_node_coords(:,2), ...
        'o','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);

    hold off;
    
    %% Plot element stresses
    subplot4 = subplot(2,1,2, ...
        'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
        'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
        'Xlim', [minX - .5 * maxHe, maxX + .5 * maxHe], ...
        'Ylim', [minY - .5 * maxHe, maxY + .5 * maxHe], ...
        'Color',[0 0 0]);
    
    % Create labels (X e Y)
    xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
    ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

    % Create title
    title('Element stresses','FontSize',17, 'Color',[1 1 1]);
    box on;

    hold on;

    % plot original mesh
    plotOriginalMesh(elem_list);

    % plots stresses on elements of the deformaded mesh
    for ElemNum = 1 : elem_list.num_elems
        sigma_eq = elem_list.getElemSigmaEq(ElemNum);
        fill([new_elems_coords(ElemNum,1);new_elems_coords(ElemNum,3)], ...
            [new_elems_coords(ElemNum,2);new_elems_coords(ElemNum,4)], ...
            [sigma_eq sigma_eq], ...
            'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 1);
    end

    colorbar('peer',subplot4, 'YTick', linspace(elem_list.getMinStress(), elem_list.getMaxStress(), 10), ...
        'LineWidth', 1,...       
        'FontWeight','normal', 'Color', [.7 .7 .7]);

    % plot nodes of the deformed mesh
    plot(new_node_coords(:,1), new_node_coords(:,2), ...
        'o','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);

    hold off;

    
    
end

