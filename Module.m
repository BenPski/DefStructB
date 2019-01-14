classdef Module
    %defining a deformable module
    %allows for doing local motions of the module
    
    properties
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
        thetas %angles for the constraints
        g %the config 

    end
    
    methods
        function obj = Module(r,k,phi,N,energy)
            %for now assuming it falls in the category of a regular module
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
            obj.thetas = zeros(N,1); %definately need a better initialization for this
            obj.g = [0;0;phi;0;0;k*r];
            obj = obj.step(zeros(N,1)); %make sure thetas are reasonable
        end
        
        function plot(obj,g)
            if nargin == 1
                g = eye(4);
            end
            %show the module
            hold on
            %plot the bottom
            bot = [];
            for i=1:obj.N
                p_h = g*[obj.r_vec(i);1];
                p = p_h(1:3);
                bot = [bot,p];
            end
            bot = [bot,bot(:,1)];
            plot3(bot(1,:),bot(2,:),bot(3,:),'red')
            
            %plot the top
            top = [];
            for i=1:obj.N
                p_h = g*[R(obj.g(1:3))*obj.r_vec(i)+obj.g(4:6);1];
                p = p_h(1:3);
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
            %step the bs in the direction d and update the geometry
            %only returns a good solution if the current configuration is
            %close to the next one
            obj_orig = obj;
            bs_next = obj.bs+d;
            
            %want to determine the thetas that satisfy the circle
            %constraints for the given bs
            obj.bs = bs_next;
            options = optimset('Display','off');
            obj.thetas = fsolve(@(thetas) obj.LConstraints(thetas),obj.thetas,options);
            obj = obj.updateConfig();
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
            %whether or not it is kinematically proper, are the constraints
            %sufficiently satisfied
            
            constraints = all(abs(obj.LConstraints())<1e-6);
            extension = all(obj.bs<=obj.b_max);
            
            out = constraints && extension;
        end
        
        function out = LConstraints(obj,thetas)
            %does the object satisfy the circle constriants
            %compute the equations

            if nargin == 2
                obj.thetas = thetas;
            end
            
            Ls = zeros(obj.N,1); %the L/circle constraints
            for i=1:obj.N
                x = obj.h(i)*obj.H(i)+obj.q_vec(i)-obj.h(mod(i,obj.N)+1)*obj.H(mod(i,obj.N)+1)-obj.q_vec(mod(i,obj.N)+1);
%                 if i == obj.N
%                     x = obj.h(i)*obj.H(i)+obj.q_vec(i)-obj.h(1)*obj.H(1)-obj.q_vec(1);
%                 else
%                     x = obj.h(i)*obj.H(i)+obj.q_vec(i)-obj.h(i+1)*obj.H(i+1)-obj.q_vec(i+1);
%                 end
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