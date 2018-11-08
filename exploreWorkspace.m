function out = exploreWorkspace(r,k,phi,N,pert)
    out = exploreWorkspaceHelp(Module(r,k,phi,N,@(b) 0), pert, 1);
end

function out = exploreWorkspaceHelp(m,pert,I)
    %this just goes through and samples as much of the workspace of the
    %given module as possible
    bs = m.bs;
    g = m.g;
    N = m.N;
    
    out = [bs',g'];
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