function out = boundaryWorkspace(r,k,phi,N,pert)
    %essentially just for more convenient calling
    out = followEdge(Module(r,k,phi,N,@(b) 0),pert,1);
end

function out = followEdge(m,pert,I)
    %Similar to explore workspace, but tries to detect if the current
    %position is near an edge, if it is that point is tracked
    
    %currently the way this is being done has some redundant computations
    
    bs = m.bs;
    g = m.g;
    N = m.N;
    
    %to see if this current point is an edge, try moving in every direction
    %and seeing if it is detected as an edge
    edges = []; %record edge checks
    for i=1:m.N
        d = zeros(m.N,1);
        d(i) = -pert;
        [~,edge] = m.step(d);
        edges = [edges,edge];
        d(i) = pert;
        [~,edge] = m.step(d);
        edges = [edges,edge];
    end
    
    if any(edges)
        out = [bs',g'];
%         scatter3(g(4),g(5),g(6))
%         drawnow
    else
        out = [];
    end
    
    %out = [bs',g'];
    for i=I:N
        d = zeros(m.N,1);
        d(i) = -pert;
        [m_step,edge] = m.step(d);

        if ~edge
            res = followEdge(m_step,pert,i);
            out = [out;res];
        end
    end
end

% 
% function out = exploreBSpace(r,k,phi,N,as,bs,thetas_prev,pert,I)
%     %a recursive definition for exploring the b-link space
%     %since solutions are very incremental want to make sure thetas_prev
%     %goes to the right spots
%     
%     %have to carry around a dropping index to avoid duplication, should
%     %always be started with a 0 (in any sensible language, but 1 here)
%     
%     bs
%     if any(bs<0) %can't go further
%         out = [];
%         return
%     end
%     
%     [thetas,config,delta] = solution(r,k,phi,N,as,bs,thetas_prev);
%     if any(imag(config)) %not a solution and neither will any subsequent steps
%         out = [];
%         return
%     end
%     
%     out = [bs,thetas,config,delta];
%     for i=I:N
%         bs_pert = bs;
%         bs_pert(i) = bs_pert(i)-pert;
%         res = exploreBSpace(r,k,phi,N,as,bs_pert,thetas,pert,i);
%         out = [out;res];
%     end
%     
% end