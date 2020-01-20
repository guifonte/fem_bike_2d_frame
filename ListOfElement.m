classdef ListOfElement < handle
    %LISTOFELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        elems
        num_elems
        groups
        num_groups
    end
    
    methods
        function obj = ListOfElement(elem_list,groups,num_groups)
             obj.elems = elem_list;
             obj.num_elems = length(elem_list);
             obj.groups = groups;
             obj.num_groups = num_groups;
        end
        function updateExtDiameterOfGroup(obj, group_num, newDiameter)
           first_elem_ind = sum(obj.groups(1:group_num))-obj.groups(group_num)+1;
           last_elem_ind = first_elem_ind+obj.groups(group_num)-1;
           
           for i = first_elem_ind : last_elem_ind
               obj.elems(i).elem.updateDe(newDiameter);
           end
        end
        function updateElementsByNodeNum(obj, node_num)
           for i = 1 : obj.num_elems
               if ((obj.elems(i).elem.n_i.node_num == node_num) || (obj.elems(i).elem.n_f.node_num == node_num))
                   obj.elems(i).elem.updateNode();
               end
           end
        end
        function Kg = calcKg(obj,num_nodes)
            Kg = zeros(num_nodes*3);

            for i = 1 : obj.num_elems
                n1 = obj.elems(i).elem.n_i.node_num;
                n2 = obj.elems(i).elem.n_f.node_num;
                ind = [n1*3-2 n1*3-1 n1*3 n2*3-2 n2*3-1 n2*3];
                Kg(ind,ind) = Kg(ind,ind) + obj.elems(i).elem.K;
            end
        end
        function he = getMaxAbsHe(obj)
            he = abs(obj.elems(1).elem.he);
            for i = 2 : obj.num_elems
                if (he < abs(obj.elems(i).elem.he))
                    he = abs(obj.elems(i).elem.he);
                end
            end
        end
        function sigma_eq = getMaxStress(obj)
            sigma_eq = abs(obj.elems(1).elem.sigma_eq);
            for i = 2 : obj.num_elems
                if (sigma_eq < abs(obj.elems(i).elem.sigma_eq))
                    sigma_eq = abs(obj.elems(i).elem.sigma_eq);
                end
            end
        end
        function sigma_eq = getMinStress(obj)
            sigma_eq = abs(obj.elems(1).elem.sigma_eq);
            for i = 2 : obj.num_elems
                if (sigma_eq > abs(obj.elems(i).elem.sigma_eq))
                    sigma_eq = abs(obj.elems(i).elem.sigma_eq);
                end
            end
        end
        function coords = getNiCoords(obj, elem_num)
            coords = obj.elems(elem_num).elem.n_i.getCoords();
        end
        function coords = getNfCoords(obj, elem_num)
            coords = obj.elems(elem_num).elem.n_f.getCoords();
        end
        function node_num = getElemNiNodeNum(obj,elem_num)
            node_num = obj.elems(elem_num).elem.n_i.node_num;
        end
        function node_num = getElemNfNodeNum(obj,elem_num)
            node_num = obj.elems(elem_num).elem.n_f.node_num;
        end
        function sigma_eq = getElemSigmaEq(obj,elem_num)
            sigma_eq = obj.elems(elem_num).elem.sigma_eq;
        end
        function sigma_esc = getElemSigmaEsc(obj,elem_num)
            sigma_esc = obj.elems(elem_num).elem.sigma_esc;
        end
        function weight = getElemWeight(obj,elem_num)
            weight = obj.elems(elem_num).elem.weight;
        end
        function new_elems_coords = getElemsNewCoords(obj, new_nodes_coords)
            new_elems_coords = zeros(obj.num_elems,4);
            for i = 1 : obj.num_elems
                n_i_num = obj.getElemNiNodeNum(i);
                n_f_num = obj.getElemNfNodeNum(i);
                new_elems_coords(i,:) = [new_nodes_coords(n_i_num,:) new_nodes_coords(n_f_num,:)];
            end
        end
        function elems_defs = getElemsDeformations(obj)
            elems_defs = zeros(obj.num_elems,2);
            for i = 1 : obj.num_elems
                he = obj.elems(i).elem.he;
                n_i_def = abs(obj.elems(i).elem.n_i.u)+abs(obj.elems(i).elem.n_i.v)/he;
                n_f_def = abs(obj.elems(i).elem.n_f.u)+abs(obj.elems(i).elem.n_f.v)/he;
                elems_defs(i,:) = [n_i_def n_f_def];
            end
        end
        function setSafetyFactor(obj,S)
            for i = 1 : obj.num_elems
                obj.elems(i).elem.sigma_esc = obj.elems(i).elem.sigma_esc/S;
            end
        end
        function weight = getTotalWeight(obj)
            weight = 0;
            for i = 1 : obj.num_elems
                weight = weight + obj.getElemWeight(i);
            end
        end
    end
end

