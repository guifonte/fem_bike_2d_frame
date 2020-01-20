function plotOriginalMesh(elem_list)
    for ElemNum = 1 : elem_list.num_elems
        n_i_coords = elem_list.getNiCoords(ElemNum);
        n_f_coords = elem_list.getNfCoords(ElemNum);
        
        fill([n_i_coords(1);n_f_coords(1)], [n_i_coords(2);n_f_coords(2)], ...
            [.5 .5 .5], 'EdgeColor', [.7 .7 .7], 'LineWidth', 1);
    end
end

