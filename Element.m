classdef Element < handle
    properties
        n_i
        n_f
        he
        lx
        ly
        E
        De
        Di
        thick
        A
        Izz
        K
        Ke
        L
        rho
        sigma_eq
        sigma_esc
        weight
        Nxmax = 0
        Vymax = 0
        Mzmax = 0
    end 
    methods
        function obj = Element(n_i, n_f, E, sigma_esc, De, thick, rho)
            if nargin > 0
                obj.n_i = n_i;
                obj.n_f = n_f;
                obj.E = E;
                obj.sigma_esc = sigma_esc;
                obj.De = De;
                obj.thick = thick;
                obj.rho = rho;
                obj.calcDi();
                obj.calcIzz();
                obj.calcA();
                obj.calcHe();
                obj.calcLx();
                obj.calcLy();
                obj.calcL();
                obj.calcK();
                obj.calcWeight();
            end
        end
        function calcWeight(obj)
            obj.weight = obj.A*obj.he*obj.rho;
        end
        function calcA(obj)
            obj.A = pi*((obj.De/2)^2-(obj.Di/2)^2);
        end
        function calcDi(obj)
            obj.Di = obj.De - 2*obj.thick;
        end
        function calcIzz(obj)
            obj.Izz = pi/4*((obj.De/2)^4-((obj.Di/2))^4);
        end
        function updateDe(obj,newDe)
            obj.De = newDe;
            obj.calcDi();
            obj.calcIzz();
            obj.calcA();
            obj.calcK();
            obj.calcWeight();
        end
        function calcHe(obj)
            obj.he = sqrt((obj.n_f.x - obj.n_i.x)^2+(obj.n_f.y - obj.n_i.y)^2);
        end
        function calcLx(obj)
            obj.lx = (obj.n_f.x - obj.n_i.x)/obj.he;
        end
        function calcLy(obj)
            obj.ly = (obj.n_f.y - obj.n_i.y)/obj.he;
        end
        function calcL(obj)
            La = [obj.lx obj.ly 0;
                 -obj.ly obj.lx 0; 
                  0  0  1];
            obj.L = blkdiag(La,La);
        end
        function updateNode(obj)
            obj.calcHe();
            obj.calcLx();
            obj.calcLy();
            obj.calcL();
            obj.calcK();
            obj.calcWeight();
        end
        function calcK(obj)
            Le = obj.he;
            
            Kb = obj.E*obj.A/Le;
            Kf = obj.E*obj.Izz/Le^3;
            
            Ke_t = [Kb 0       0        -Kb 0       0;
                  0  12*Kf   6*Le*Kf   0 -12*Kf   6*Le*Kf;
                  0  6*Le*Kf 4*Le^2*Kf 0 -6*Le*Kf 2*Le^2*Kf;
                 -Kb 0       0         Kb 0       0;
                  0 -12*Kf  -6*Le*Kf   0  12*Kf  -6*Le*Kf;
                  0  6*Le*Kf 2*Le^2*Kf 0 -6*Le*Kf 4*Le^2*Kf];
            obj.Ke = Ke_t;
            obj.K = obj.L'*Ke_t*obj.L;
        end
        function calcForces(obj, q)
            F_temp = obj.Ke*obj.L*q;
            obj.Nxmax = max(F_temp(1),F_temp(4));
            obj.Vymax = max(F_temp(2),F_temp(5));
            obj.Mzmax = max(abs(F_temp(3)),abs(F_temp(6)));
        end
        function calcSigmaEq(obj)
            sigma_n = obj.Nxmax/obj.A;
            sigma_m = obj.Mzmax*obj.De/2/obj.Izz;
            tau_xy = 4*obj.Vymax/3/obj.A;
            obj.sigma_eq = sqrt((sigma_n+sigma_m)^2+3*tau_xy^2);
        end
        
    end
end

