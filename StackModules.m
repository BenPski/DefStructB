classdef StackModules
    %handling multiple modules stacked on each other to determine the
    %trajectory 
    
    properties
        modules %an array of modules
    end
    
    methods
        function obj = StackModules(modules)
            obj.modules = modules;
        end
        
        function out = curr_energy(obj,b)
            if nargin == 2
                %go through and set the individual bs for the different
                %modules
                n = length(obj.modules);
                j = 1; %the starting point
                for i=1:n
                    bs0 = obj.modules(i).bs;
                    obj.modules(i).bs = b(j:length(bs0)+j-1);
                    j = j+length(bs0);
                end
            end
            out = 0;
            for i=1:length(obj.modules)
                out = out + obj.modules(i).curr_energy();
            end
        end
        
        function [obj,edges] = step(obj,d)
            %step all the modules in their different directions
            obj_orig = obj;
            j=1;
            edges = []; 
            for i=1:length(obj.modules)
                ds = d(j:j+length(obj.modules(i).bs)-1);
                j = j + length(obj.modules(i).bs);
                [obj_i,edge_i] = obj.modules(i).step(ds);
                obj.modules(i) = obj_i;
                edges = [edges,edge_i];
            end
            %edge = all(edges); %at an edge if all at an edge
        end
        
        function obj = step_energy(obj,b_del)
            %want to step in the direction that minimizes the total energy
            %and takes steps of the desired magnitude
            U0 = obj.curr_energy();
            b0 = [];
            for i=1:length(obj.modules)
                b0 = [b0;obj.modules(i).bs];
            end
            options = optimset('Display','off');
            b = fmincon(@(b) (obj.curr_energy(b)-U0)^2,b0,[],[],[],[],[],[],@(b) obj.stepConstraints(b0,b_del,b),options);
            obj = obj.step(b-b0);
        end
        
        function [c,ceq] = stepConstraints(obj,b0,b_del,b)
            c = [];
            %obj_test = obj.step(b-b0);
            ceq = norm(b0)-norm(b)-b_del;
            %ceq = [ceq;obj_test.LConstraints()];
        end
        
        function plot(obj)
            %plot the objects in order
            %need to adjust the individual modules to stack correctly
            g = eye(4);
            for i=1:length(obj.modules)
                obj.modules(i).plot(g);
                g = g*toConfig(obj.modules(i).g);
            end
        end
        
        function out = bs(obj)
            out = [];
            for i=1:length(obj.modules)
                out = [out;obj.modules(i).bs];
            end
        end
        
        function out = thetas(obj)
            out = [];
            for i=1:length(obj.modules)
                out = [out;obj.modules(i).thetas];
            end
        end
        
        function out = g(obj)
            out = eye(4);
            for i=1:length(obj.modules)
                out = out*toConfig(obj.modules(i).g);
            end
            out = fromConfig(out);
        end
        
        function out = N(obj)
            out = [];
            for i=1:length(obj.modules)
                out = [out,obj.modules(i).N];
            end
        end
    end
end