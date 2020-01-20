classdef ListOfNode < handle
    %LISTOFELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nodes
        num_nodes
        DOFs
        Fg
        load_coords
        BCDOFs_coords
        bclines
        FR
        FR_coords
    end
    
    methods
        function obj = ListOfNode(node_list)
            if nargin > 0
                 obj.nodes = node_list;
                 obj.num_nodes = length(node_list);
                 obj.DOFs = obj.num_nodes*3;
            end
        end
        function setNode(obj, node, i)
            obj.nodes(i).node = node;
        end
        function updateNode(obj, node_num, new_x, new_y)
            obj.nodes(node_num).node.updateNode(new_x,new_y);
        end
        function x = getMaxX(obj)
            x = obj.nodes(1).node.x;
            for i = 2 : obj.num_nodes
                if (x < obj.nodes(i).node.x)
                    x = obj.nodes(i).node.x;
                end
            end
        end
        function y = getMaxY(obj)
            y = obj.nodes(1).node.y;
            for i = 2 : obj.num_nodes
                if (y < obj.nodes(i).node.y)
                    y = obj.nodes(i).node.y;
                end
            end
        end
        function x = getMinX(obj)
            x = obj.nodes(1).node.x;
            for i = 2 : obj.num_nodes
                if (x > obj.nodes(i).node.x)
                    x = obj.nodes(i).node.x;
                end
            end
        end
        function y = getMinY(obj)
            y = obj.nodes(1).node.y;
            for i = 2 : obj.num_nodes
                if (y > obj.nodes(i).node.y)
                    y = obj.nodes(i).node.y;
                end
            end
        end
        function setNx(obj,node_num,Nx)
            obj.nodes(node_num).node.Nx = Nx;
        end
        function setVy(obj,node_num,Vy)
            obj.nodes(node_num).node.Vy = Vy;
                end
        function setMz(obj,node_num,Mz)
            obj.nodes(node_num).node.Mz = Mz;
        end
        function calcFg(obj)
            Fg_temp = zeros(obj.DOFs,1);
            load_counter = 0;
            for i = 1 : obj.num_nodes
                if (obj.nodes(i).node.Nx ~= 0)
                    Fg_temp(3*i-2) = obj.nodes(i).node.Nx;
                    load_counter = load_counter + 1;
                end
                if (obj.nodes(i).node.Vy ~= 0)
                    Fg_temp(3*i-1) = obj.nodes(i).node.Vy;
                    load_counter = load_counter + 1;
                end
                if (obj.nodes(i).node.Mz ~= 0)
                    Fg_temp(3*i) = obj.nodes(i).node.Mz;
                    load_counter = load_counter + 1;
                end
            end
            load_coordinates = zeros(load_counter,4);
            lc = 1;
            for i = 1 : obj.num_nodes
                if (obj.nodes(i).node.Nx ~= 0)
                    load_coordinates(lc,1) = obj.nodes(i).node.Nx;
                    load_coordinates(lc,2:3) = obj.nodes(i).node.getCoords();
                    load_coordinates(lc,4) = 1;
                    lc = lc + 1;
                end
                if (obj.nodes(i).node.Vy ~= 0)
                    load_coordinates(lc,1) = obj.nodes(i).node.Vy;
                    load_coordinates(lc,2:3) = obj.nodes(i).node.getCoords();
                    load_coordinates(lc,4) = 2;
                    lc = lc + 1;
                end
                if (obj.nodes(i).node.Mz ~= 0)
                    load_coordinates(lc,1) = obj.nodes(i).node.Mz;
                    load_coordinates(lc,2:3) = obj.nodes(i).node.getCoords();
                    load_coordinates(lc,4) = 3;
                    lc = lc + 1;
                end
            end
            obj.Fg = Fg_temp;
            obj.load_coords = load_coordinates;
        end
        function Fg = getFg(obj)
            Fg = obj.Fg;
        end
        function setBClines(obj, bclines)
            obj.bclines = bclines;
            num_bcdofs = length(bclines);
            BCDOFs_matrix = zeros(num_bcdofs,3);
            for i = 1 : num_bcdofs
                node_num = floor((bclines(i)-1)/3) + 1;
                xyz = mod(bclines(i),3);
                BCDOFs_matrix(i,1:2) = obj.nodes(node_num).node.getCoords();
                BCDOFs_matrix(i,3) = xyz;
            end
            obj.BCDOFs_coords = BCDOFs_matrix;
        end
        function bclines = getBClines(obj)
            bclines = obj.bclines;
        end
        function coords = getNodeCoords(obj, node_num)
            coords = obj.nodes(node_num).node.getCoords();
        end
        function disp = getNodeDisp(obj, node_num)
            disp = obj.nodes(node_num).node.getDisp();
        end  
        function load_coords = getLoadCoords(obj)
            load_coords = obj.load_coords;
        end
        function BCDOFs_coords = getBCDOFsCoords(obj)
            BCDOFs_coords = obj.BCDOFs_coords;
        end
        function FR_coords = getFRCoords(obj)
            FR_coords = obj.FR_coords;
        end
        function setSafetyFactor(obj, Q)
            obj.Fg = obj.Fg*Q;
            obj.load_coords(:,1) = obj.load_coords(:,1)*Q;
            for i = 1 : obj.num_nodes
                obj.nodes(i).node.Nx = obj.nodes(i).node.Nx*Q;
                obj.nodes(i).node.Vy = obj.nodes(i).node.Vy*Q;
                obj.nodes(i).node.Mz = obj.nodes(i).node.Mz*Q;
            end
        end
        function setDisplacement(obj, Q)
            for i = 1 : obj.num_nodes
                obj.nodes(i).node.u = Q(3*i-2);
                obj.nodes(i).node.v = Q(3*i-1);
                obj.nodes(i).node.theta = Q(3*i);
            end      
        end
        function setReactionForces(obj, FR)
            obj.FR = FR;
            obj.FR_coords = [FR obj.BCDOFs_coords];
        end
        function new_nodes_coords = getNodesNewCoords(obj, scale_factor)
            new_nodes_coords = zeros(obj.num_nodes, 2);
            for i = 1 : obj.num_nodes
                coords = obj.getNodeCoords(i);
                disp = obj.getNodeDisp(i);
                new_nodes_coords(i,:) = coords + disp*scale_factor;
            end
        end
    end
end

