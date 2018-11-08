classdef ModuleInterp
    %a module that interpolates over data rather than iteratively doing
    %local updates
    
    properties
        data
        r
        k
        phi
        N
        energy
    end
    
    methods
        function obj = ModuleInterp(r,k,phi,N,energy,data)
            obj.r = r;
            obj.k = k;
            obj.phi = phi;
            obj.N = N;
            obj.energy = energy;
            obj.data = data;
        end
    end
    
end