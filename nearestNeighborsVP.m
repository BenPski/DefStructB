function [neighs,vals] = nearestNeighborsVP(q,n,tree)
    %given a query point q, n neighbors, and a vp-tree find the nearest
    %neighbors
    
    [~,neighs,vals] = nnHelper(q,n,tree,inf,[],[]);
end

function [sigma,neighs,vals] = nnHelper(q,n,tree,sigma,neighs,vals)
    %the recursive function to search the vp-tree to find the nearest
    %neighbors
    if isa(tree,'VPNode')
        dist = norm(q-tree.vp);
        if isempty(neighs)
            neighs = tree.vp;
            vals = tree.data;
        %see if the current node is a neighbor
        elseif dist < sigma %found a new neighbor
            new_neighs = [neighs,tree.vp];
            new_vals = [vals,tree.data];
            dists = [sqrt(sum((q-neighs).^2)),dist];
            [dists,indices] = sort(dists);
            neighs = new_neighs(:,indices);
            vals = new_vals(:,indices);
            [~,N] = size(neighs);
            if N >= n %if the neighbor list is overfilled remove the end and update sigma
                neighs = neighs(:,1:n);
                vals = vals(:,1:n);
                sigma = dists(end);
            end
        end
        
        %determine whether to explore the inner, outer, or both subtrees
        %if mu >= dist+sigma then only look inside
        %if mu < dist-sigma then only look outside
        %else look in both
        if dist - sigma < tree.mu
            [sigma,neighs,vals] = nnHelper(q,n,tree.inside,sigma,neighs,vals);
        end
        if dist + sigma >= tree.mu
            [sigma,neighs,vals] = nnHelper(q,n,tree.outside,sigma,neighs,vals);
        end
    end
    %else VPEmpty -> do nothing
end

        