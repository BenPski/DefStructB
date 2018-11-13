function out = surfaceDrawing(r,k,phi,N)
    data = exploreWorkspace(r,k,phi,N,0.05);
    
    hold on
    
    %drawing the left boundary
    m = ModuleInterp(r,k,phi,N,@(b) 0, data);
    edge = false;
    pos = [m.g(4:6)];
    d = zeros(N,1);
    d(1) = -0.05*m.b_max;
    
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    edge = false;
    d = zeros(N,1);
    d(2) = -0.05*m.b_max;
    
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    plot3(pos(1,:),pos(2,:),pos(3,:),'LineWidth',5)
    
    
    %drawing the right boundary
    m = ModuleInterp(r,k,phi,N,@(b) 0,data);
    edge = false;
    pos = [m.g(4:6)];
    d = zeros(N,1);
    d(2) = -0.05*m.b_max;
    
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    edge = false;
    d = zeros(N,1);
    d(1) = -0.05*m.b_max;
    
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    plot3(pos(1,:),pos(2,:),pos(3,:),'LineWidth',5)
    
    
    %drawing the center
    m = ModuleInterp(r,k,phi,N,@(b) 0,data);
    edge = false;
    pos = [m.g(4:6)];
    d = zeros(N,1);
    d(1) = -0.05*m.b_max;
    d(2) = -0.05*m.b_max;
    
    while ~edge
        [m,edge] = m.step(d);
        pos = [pos,m.g(4:6)];
    end
    
    plot3(pos(1,:),pos(2,:),pos(3,:),'LineWidth',5,'LineStyle','-')
    
    %draw varied stiffness lines
    
    %leftward
    m = ModuleInterp(r,k,phi,N,@(b) dot([1,10,1e10],b.^2),data);
    edge = false;
    pos = [m.g(4:6)];
    while ~edge
        [m,edge] = m.step_energy(0.1*m.b_max);
        pos = [pos,m.g(4:6)];
    end
    plot3(pos(1,:),pos(2,:),pos(3,:))
    
    m = ModuleInterp(r,k,phi,N,@(b) dot([1,5,1e10],b.^2),data);
    edge = false;
    pos = [m.g(4:6)];
    while ~edge
        [m,edge] = m.step_energy(0.1*m.b_max);
        pos = [pos,m.g(4:6)];
    end
    plot3(pos(1,:),pos(2,:),pos(3,:))
    
    %rightward
    m = ModuleInterp(r,k,phi,N,@(b) dot([10,1,1e10],b.^2),data);
    edge = false;
    pos = [m.g(4:6)];
    while ~edge
        [m,edge] = m.step_energy(0.1*m.b_max);
        pos = [pos,m.g(4:6)];
    end
    plot3(pos(1,:),pos(2,:),pos(3,:))
    
    m = ModuleInterp(r,k,phi,N,@(b) dot([5,1,1e10],b.^2),data);
    edge = false;
    pos = [m.g(4:6)];
    while ~edge
        [m,edge] = m.step_energy(0.1*m.b_max);
        pos = [pos,m.g(4:6)];
    end
    plot3(pos(1,:),pos(2,:),pos(3,:))
   
    
    
    daspect([1,1,1])
    
end
        
    
    
    