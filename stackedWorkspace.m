function out = stackedWorkspace(modules)
    %gets the total workspace for the given modules (assumed to be
    %interpolated) by combining all possible points
    
    %have to store the bs and thetas for each module and the resulting g
    
    %the maximum row index for each module
    bounds = [];
    widths = [];
    for i=1:length(modules)
        [h,~] = size(modules(i).data);
        bounds(i) = h;
        widths(i) = 2*modules(i).N;
    end
    
    data = zeros(prod(bounds),6+sum(widths));
    
    indices = ones(1,length(modules));
    i = 1;
    data(i,:) = getData(modules,indices);
    while not(all(bounds == indices))
        indices = nextIndex(bounds,indices)
        i = i+1;
        data(i,:) = getData(modules,indices);
    end
    out = data;
    
end

function out = getData(modules,indices)
    out = [];
    g = eye(4);
    for i=1:length(indices)
        out = [out,modules(i).data(indices(i),1:2*modules(i).N)];
        g = g*toConfig(modules(i).data(indices(i),end-5:end)');
    end
    out = [out,fromConfig(g)'];
end

function out = nextIndex(bounds,curr)
    %get the next combination
    %start from [1,1,1...]
    %end at bounds
        
    if isempty(curr)
        out = [];
    elseif curr(1) < bounds(1)
        update = curr;
        update(1) = update(1)+1;
        out = update;
    else
        rest = nextIndex(bounds(2:end),curr(2:end));
        rest = [1,rest];
        out = rest;
    end
end