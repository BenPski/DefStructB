classdef ModuleInterp
    %a module that interpolates over data rather than iteratively doing
    %local updates
    %this is nearly the same as the regular module,
    %so could use some better organization here
    
    properties
        data %the data for the workspace
        l %the length of a side on the plate
        r %the base radius
        k %the relative hight
        phi %the relative angle
        N %the number of sides
        energy %energy function, [b] -> U
        as %the a-links (assumed rigid)
        bs %the b-links (assumed soft)
        a_max 
        b_max %the maximum length for the b-links
        b0 %original bs
        g %the config 
        thetas
    end
    
    methods
        function obj = ModuleInterp(r,k,phi,N,energy,data)
            obj.r = r;
            obj.k = k;
            obj.phi = phi;
            obj.N = N;
            obj.energy = energy;
            
            obj.l = 2*r*sin(pi/N);
            
            a = r*sqrt(2*(1-cos(phi))+k^2);
            b = r*sqrt(2*(1-cos(phi-2*pi/N))+k^2);
            obj.a_max = a;
            obj.b_max = b;
            obj.as = a*ones(N,1);
            obj.bs = b*ones(N,1);
            obj.b0 = obj.bs;
            obj.g = [0;0;phi;0;0;k*r];
            obj.thetas = zeros(N,1);
            
            if nargin ~= 6
                %generate own data
                data = exploreWorkspace(r,k,phi,N,0.1*b);
                obj.data = data;
            else %provided data            
                obj.data = data;
            end
            
        end
        
        function plot(obj)
            %show the module
            hold on
            %plot the bottom
            bot = [];
            for i=1:obj.N
                p = obj.r_vec(i);
                bot = [bot,p];
            end
            bot = [bot,bot(:,1)];
            plot3(bot(1,:),bot(2,:),bot(3,:),'red')
            
            %plot the top
            top = [];
            for i=1:obj.N
                p = R(obj.g(1:3))*obj.r_vec(i)+obj.g(4:6);
                top = [top,p];
            end
            top = [top,top(:,1)];
            plot3(top(1,:),top(2,:),top(3,:),'red')
            
            %plot the links
            for i=1:obj.N
                plot3([top(1,i),bot(1,i)],[top(2,i),bot(2,i)],[top(3,i),bot(3,i)],'blue')
                plot3([top(1,i),bot(1,i+1)],[top(2,i),bot(2,i+1)],[top(3,i),bot(3,i+1)],'green')
            end            
        end
        
        function out = curr_energy(obj,b)
            if nargin == 2
                obj.bs = b;
            end
            out = obj.energy(obj.bs-obj.b0);
        end
        
        function [obj,edge] = step_energy(obj,b_del)
            %take a step of length b_del in the direction that minimizes
            %the increase in energy
            U0 = obj.curr_energy();
            b0 = obj.bs;
            options = optimset('Display','off');
            b = fmincon(@(b) (obj.curr_energy(b)-U0)^2,b0,[],[],[],[],[],[],@(b) obj.stepConstraints(b0,b_del,b),options);
            [obj,edge] = obj.step(b-b0);
        end
        
        function [c,ceq] = stepConstraints(obj,b0,b_del,b)
            c = [];
            %obj_test = obj.step(b-b0);
            ceq = norm(b0)-norm(b)-b_del;
            %ceq = [ceq;obj_test.LConstraints()];
        end
        
        function [obj,edge] = step(obj,d)
            %the main change for the interpolating structure
            %now updating is just a matter of interpolating the data
            obj_orig = obj;
            bs_next = obj.bs+d;
            
            params = nearestNeighborInterp(obj.data(:,1:3)',obj.data(:,4:end)',bs_next);
            obj.thetas = params(1:obj.N);
            obj.g = params(end-5:end);
            obj.bs = bs_next;
            
            edge = false;
            if ~obj.proper() %if it did not properly solve don't step
                obj = obj_orig;
                edge = true;
            end
        end
        
        function out = r_vec(obj,i)
            out = obj.r*Rz(i*2*pi/obj.N)*[1;0;0];
        end
        
        function out = sigma(obj,i)
            out = (1+(obj.as(i)^2-obj.bs(i)^2)/obj.l^2)/2;
        end
        
        function out = mu(obj,i)
            out = sqrt(obj.as(i)^2/obj.l^2-obj.sigma(i)^2);
        end
        
        function out = q_vec(obj,i)
            out = obj.sigma(i)*(obj.r_vec(i+1)-obj.r_vec(i))+obj.r_vec(i);
        end
        
        function out = w_vec(obj,i)
            out = (obj.r_vec(i+1)-obj.r_vec(i))/obj.l;
        end

        function out = h(obj,i)
            out = obj.mu(i)*obj.l;
        end
        
        function out = H(obj,i)
            out = R_axis(obj.w_vec(i),obj.thetas(i))*[0;0;1];
        end
        
        function out = proper(obj)
            %it is proper if the bs are within the defined data
            out = insideRegion(obj.data(:,1:3)',obj.bs);
        end
        
        function out = LConstraints(obj,thetas)
            %does the object satisfy the circle constriants
            %compute the equations

            if nargin == 2
                obj.thetas = thetas;
            end
            
            Ls = zeros(obj.N,1); %the L/circle constraints
            for i=1:obj.N
                if i == obj.N
                    x = obj.h(i)*obj.H(i)+obj.q_vec(i)-obj.h(1)*obj.H(1)-obj.q_vec(1);
                else
                    x = obj.h(i)*obj.H(i)+obj.q_vec(i)-obj.h(i+1)*obj.H(i+1)-obj.q_vec(i+1);
                end
                L = obj.l^2-dot(x,x);
                Ls(i) = L;
            end
            out = Ls;
        end
        
        function obj = updateConfig(obj)
            %make sure g is consistent with the thetas
            pos = [];
            for i=1:obj.N
                p = obj.h(i)*obj.H(i)+obj.q_vec(i);
                pos = [pos,p];
            end
            options = optimset('Display','off','Algorithm','levenberg-marquardt');
            obj.g = fsolve(@(g) obj.configFromPositions(pos,g),obj.g,options);
        end
        

        function out = configFromPositions(obj,pos,g)
            %using g see if the positions are correct
            rot = R(g(1:3));
            p = g(4:6);

            out = [];
            for i=1:obj.N
                out = [out;rot*obj.r_vec(i)+p-pos(:,i)];
            end
        end
        
    end
    
end