function out = followEdge(m,pert,I)
    bs = m.bs
    g = m.g;
    N = m.N;
    
    d = zeros(m.N,1);
    out = [bs',g'];
    for i=I:N
        d = zeros(m.N,1);
        d(i) = -pert;
        [m_step,edge] = m.step(d);
        %if the step ran into an edge want to record the data
        %if it does not run into an edge keep looking
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