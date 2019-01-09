function out = exploreWorkspaceStacked(s,pert)
    out = exploreWorkspaceHelp(s, pert, 1);
end

function out = exploreWorkspaceHelp(s,pert,I)
    %this is for going through the grid when there are several modules
    %the main difference is that one module can hit an edge while the other
    %may not and thus may stop only in certain directions

    bs = s.bs
    thetas = s.thetas;
    g = s.g;
    Ns = s.N;
    
    out = [bs',thetas',g'];
    for i=I:sum(Ns)
        d = zeros(sum(Ns),1);
        d(i) = -pert;
        [s_step,edges] = s.step(d);
        
        %can keep stepping if there is a contacted edge as long as it
        %continues with the non-edge modules, so if the bottom module is at
        %an edge and i is relevant to the bottom module it is over, if it
        %is at a module above the bottom continue
        
        if ~atEdge(Ns,edges,i)
            res = exploreWorkspaceHelp(s_step,pert,i);
            out = [out;res];
        end
    end
end

function out = atEdge(Ns,edges,i)
    %determine if i is in a direction that is at an edge
    
    out = false;
    range = 0;
    for j=1:length(edges)
        edge = edges(j);
        N = Ns(j);
        range = range+N;
        if edge && i<=range
            out = true;
            break;
        end
    end
end