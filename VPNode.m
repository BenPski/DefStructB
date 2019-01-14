classdef VPNode < VPTree
    properties
        vp %the vantage point
        mu %the partition radius
        data %the contained data
        inside %the tree on the inside of the partition
        outside %the tree on the outside of the partition
    end
    
    methods 
        function obj = VPNode(vp,data,mu,inside,outside)
            obj.vp = vp;
            obj.data = data;
            obj.mu = mu;
            obj.inside = inside;
            obj.outside = outside;
        end
    end
end

            
            
            
            
            
            
            