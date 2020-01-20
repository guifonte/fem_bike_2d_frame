function plotNodesOriginalMesh(node_list)
    for NodeNum = 1 : node_list.num_nodes
        coords = node_list.getNodeCoords(NodeNum);
        plot(coords(1), coords(2), ...
        'o','MarkerEdgeColor','y','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);
    end
end

