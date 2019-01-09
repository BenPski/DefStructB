function out = stiffSurf(r,k,phi,N)
    %this draws the bounding of the stiffness surface
    %uses interpolation since it seems less likely to get stuck on an edge
    
    m = Module(r,k,phi,N,@(b) 0);
    
    data = exploreWorkspace(r,k,phi,N,0.1*m.b_max);
    hold on
    
    %the left side
    m = ModuleInterp(r,k,phi,N,@(b) 0, data);    
    edge = false;
    pos = [m.g(4:6)];
    d = zeros(N,1);
    d(1) = -0.01;
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    edge = false;
    d = zeros(N,1);
    d(2) = -0.01;
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    plot3(pos(1,:),pos(2,:),pos(3,:),'LineWidth',3)
    
    
    %the right side
    m = ModuleInterp(r,k,phi,N,@(b) 0, data);    
    edge = false;
    pos = [m.g(4:6)];
    d = zeros(N,1);
    d(2) = -0.01;
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    edge = false;
    d = zeros(N,1);
    d(1) = -0.01;
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    plot3(pos(1,:),pos(2,:),pos(3,:),'LineWidth',3)
    
    
    %the center
    m = ModuleInterp(r,k,phi,N,@(b) 0, data);    
    edge = false;
    pos = [m.g(4:6)];
    d = zeros(N,1);
    d(1) = -0.01;
    d(2) = -0.01;
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    plot3(pos(1,:),pos(2,:),pos(3,:),'LineWidth',3,'LineStyle','-')
    
    
    %various stiffnesses
    Ks = [10,1/10];
    for i=1:length(Ks)
        m = ModuleInterp(r,k,phi,N,@(b) dot([Ks(i),1,1e10],b.^2), data);    
        edge = false;
        pos = [m.g(4:6)];
        while ~edge
            [m,edge] = m.step_energy(0.01);
            pos = [pos,m.g(4:6)];
        end

        plot3(pos(1,:),pos(2,:),pos(3,:))
    end
end