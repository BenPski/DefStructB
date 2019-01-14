function out = makeVPTree(points,values)
    [~,n] = size(points);
    if n == 0
        %out = VPLeaf(points,values);
        out = VPEmpty();
    else
        %in order to partition the data need to select the vantage
        %point and then find the median distance between the vantage
        %point and the rest of the points, the data is then the points
        %within the median distance and the points outside the median
        %distance

        %for now the vantage point is selected randomly
        i = randi(n);
        vp = points(:,i);
        val = values(:,i);

        points(:,i) = [];
        values(:,i) = [];

        dists = sum((vp - points).^2);

        mu = median(dists);
        if isnan(mu)
            mu = 0;
        end

        inside = points(:,dists<=mu);
        outside = points(:,dists>mu);
        inside_vals = values(:,dists<=mu);
        outside_vals = values(:,dists>mu);

            
        
        out = VPNode(vp,val,mu,makeVPTree(inside,inside_vals),makeVPTree(outside,outside_vals));
    end
end