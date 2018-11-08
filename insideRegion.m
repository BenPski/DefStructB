function out = insideRegion(region,point)
    %looks to see if a point is within a region
    %finds a sample of nearest neighbors and if it is never inside any of
    %the simplices that can be created then it is outside
    
    N = length(point);
    neighs = nearestNeighbors(region,point,N+2);
    
    outside = true; %go through a process of proving that it is inside
    for i=1:N+2
        %combination to consider
        consider = [neighs(:,1:i-1),neighs(:,i+1:end)];
        
        origin = consider(:,1);
        M = consider(:,2:end)-origin;
        if rank(M)<N %degenerate simplex (no inversion possible)
            options = optimset('Display','off');
            w = fsolve(@(w) M*w-point+origin,ones(N,1)/N,options);
        else
            w = M\(point-origin);
        end
        
        weights = [1-sum(w);w];
        if all(weights >= 0)
            outside = false;
            break;
        end
    end
    
    out = ~outside;
end