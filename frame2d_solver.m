function [Q_out, stress_out, FR_out] = frame2d_solver(node_list, elem_list)
    
    bclines = node_list.getBClines();
    Kg = elem_list.calcKg(node_list.num_nodes);
    
    Fg_temp = node_list.getFg();
    Fg_temp(bclines,:) = [];

    Kg_temp = Kg;
    Kg_temp(bclines,:) = [];
    Kg_temp(:,bclines) = [];

    Q = Kg_temp\Fg_temp;

    Q_t = zeros(node_list.DOFs,1);
    zeroRows = ismember(1:length(Q_t), bclines);
    oldindcount = 1;
    for i = 1 : node_list.DOFs
        if zeroRows(i) == 0
            Q_t(i) = Q(oldindcount);
            oldindcount = oldindcount + 1;
        end
    end
    
    node_list.setDisplacement(Q_t);
    
    Kg_R = Kg(bclines,:);
    Kg_R(:,bclines) = [];
    FR = Kg_R*Q;
    
    node_list.setReactionForces(FR);
    
    stress = zeros(elem_list.num_elems,1);
    
    for i = 1 : elem_list.num_elems
        n_i_ind = elem_list.getElemNiNodeNum(i);
        n_f_ind = elem_list.getElemNfNodeNum(i);
        temp_q = [Q_t(n_i_ind*3-2:n_i_ind*3,:); Q_t(n_f_ind*3-2:n_f_ind*3,:)];
        elem_list.elems(i).elem.calcForces(temp_q);
        elem_list.elems(i).elem.calcSigmaEq();
        stress(i) = elem_list.getElemSigmaEq(i);
    end
    
    FR_out = FR;
    Q_out = Q_t;
    stress_out = stress;
end

