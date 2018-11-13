function out = exploreWorkspace(r,k,phi,N,pert)
    m = Module(r,k,phi,N,@(b) 0);
    pert = m.b_max*pert;
    out = exploreWorkspaceHelp(m, pert, 1);
end

function out = exploreWorkspaceHelp(m,pert,I)
    %this just goes through and samples as much of the workspace of the
    %given module as possible
    bs = m.bs;
    thetas = m.thetas;
    g = m.g;
    N = m.N;
    
    out = [bs',thetas',g'];
    for i=I:N
        d = zeros(m.N,1);
        d(i) = -pert;
        [m_step,edge] = m.step(d);

        if ~edge
            res = exploreWorkspaceHelp(m_step,pert,i);
            out = [out;res];
        end
    end
end