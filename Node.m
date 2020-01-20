classdef Node < handle
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        node_num
        x
        y
        u
        v
        theta
        Nx = 0
        Vy = 0
        Mz = 0
    end
    
    methods
        function obj = Node(node_num, x, y)
            if nargin > 0
                obj.node_num = node_num;
                obj.x = x;
                obj.y = y;
            end
        end
        function updateNode(obj, new_x, new_y)
            obj.x = new_x;
            obj.y = new_y;
        end
        function coords = getCoords(obj)
            coords = [obj.x obj.y];
        end
        function coords = getDisp(obj)
            coords = [obj.u obj.v];
        end
    end
end

