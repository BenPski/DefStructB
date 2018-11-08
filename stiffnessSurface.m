function out = stiffnessSurface(r,k,phi,N)
    %get the stiffness surface for the desired module
    %this is just getting the extreme trajectories of the module
    %works best with N=3 for now just because that means n_soft=1 is
    %kinematically constrained
    
    
    d0 = zeros(N,1); %the direction vector
    hold on
%     for K = linspace(10,1/10,20)
%         m = Module(r,k,phi,N,@(b) dot([K,1,1e10],b.^2));
%         traj = [];
%         for i=1:100
%             m = m.step_energy(0.01);
%             p = m.g(4:6);
%             traj = [traj,p];
%         end
%         plot3(traj(1,:),traj(2,:),traj(3,:))
%         drawnow
%     end
    for i=1:2
        m = Module(r,k,phi,N,@(b) 0);
        %for each leg get the single soft trajectory
        edge = false;
        d = d0;
        d(i) = -0.01;
        traj = [];
        while ~edge
            [m,edge] = m.step(d);
            p = m.g(4:6);
            traj = [traj,p];
        end
%         %do the fully compressed phase
%         edge = false;
%         %m = m.step(-d);
%         %d = [d(end);d(1:end-1)];
%         d = [d(2:end);d(1)];
%         while ~edge
%             [m,edge] = m.step(d);
%             p = m.g(4:6);
%             traj = [traj,p];
%         end
            
        plot3(traj(1,:),traj(2,:),traj(3,:))
    end
    
    for i=1:1
        m = Module(r,k,phi,N,@(b) 0);
        %for each leg get the single soft trajectory
        edge = false;
        d = d0;
        d(i) = -0.01;
        d(i+1) = -0.01;
        traj = [];
        while ~edge
            [m,edge] = m.step(d);
            p = m.g(4:6);
            traj = [traj,p];
        end
%         %do the fully compressed phase
%         edge = false;
%         %m = m.step(-d);
%         %d = [d(end);d(1:end-1)];
%         d = [d(2:end);d(1)];
%         while ~edge
%             [m,edge] = m.step(d);
%             p = m.g(4:6);
%             traj = [traj,p];
%         end
            
        plot3(traj(1,:),traj(2,:),traj(3,:))
    end

%     m = Module(r,k,phi,N,@(b) dot([1e10,1,1e10],b.^2));
%     hold on
%     traj = [];
%     for i=1:100
%         m = m.step_energy(0.01);
%         p = m.g(4:6);
%         traj = [traj,p];
%     end
%     
%     m.energy = @(b) dot([1e10,1,1e10],b.^2);
%     for i=1:100
%         m = m.step_energy(0.01);
%         p = m.g(4:6);
%         traj = [traj,p];
%     end
    plot3(traj(1,:),traj(2,:),traj(3,:))
        

end
            