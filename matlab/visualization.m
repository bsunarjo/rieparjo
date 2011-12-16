function visualization

global f1;
f1 = figure('OuterPosition',[0 0 700 600]);

files = dir('data/*stm.mat');

for file=1:numel(files)
    
    clear myplain mysm;
    clf;
    
    filename = files(file).name;
    
    % extract parameter values
    params = sscanf(filename, 'd%d_i%d_v%f_i%f_.mat');
    dur = params(1);
	inten = params(2);
	vis = params(3);
	importance = params(4);
	location = 'fri';
    
    plot_paths(filename);
    [n t dist dist_std traveltime] = completed_paths(filename);
    
    data = sprintf('%i,%i,%f,%f,%i,%f,%f,%f,%f',dur,inten,vis,importance,n,t,dist,dist_std,traveltime);
    disp(data);

end

end



%----------------------------------------------------
function [n t_norm dist dist_std traveltime] = completed_paths(filename)
    load(strcat('data/',filename));
    
    % number of paths completed
    n = length(mysm.paths);
    
    % travel time
    t = zeros(3,n);
    
    for i=1:n
        path=mysm.paths(i);
        start = path.coordinates(1,:);
        dest = path.coordinates(end,:);
        dist = sqrt(sum((dest-start).^2));
        
        traveltime = path.time;
        
        t(:,i) = [dist;traveltime;dist/traveltime];
    end
    
    t_norm = mean(t(3,:));
    dist = mean(t(1,:));
    dist_std = std(t(1,:));
    traveltime = mean(t(2,:));
    
end



%----------------------------------------------------
function plot_paths(filename)
    global f1;
    load(strcat('data/',filename));


    % plot ground structure
    subplot(1,2,1);
    pathMax = 100;
    title('Evolving Trails');

    A=myplain.realGround;
    B=myplain.ground-myplain.initialGround;

    % shift B above the maximum of A
    B_shifted = B-min(B(:))+max(A(:))+1;

    % create fitted colormap out of two colormaps
    range_A = max(A(:))-min(A(:));
    range_B = max(B(:))-min(B(:));


    % to adjust caxis and colormap
    range_b = range_B;

    for i=1:10
        if  (range_b>=pathMax/10*(i-1))&&(range_b<=pathMax/10*i)
            range_B = pathMax/10*i;
        end
    end

    % adjusting colormap

    cm = [gray(ceil(64*range_A/range_B));flipud(summer(64))];

    % plotting
    pcolor(B_shifted)
    shading interp
    hold on
    contour(A)
    axis equal tight off ij;
    colormap(cm)
    caxis([min(A(:)) max(A(:))+range_B])
    
    if(strfind(filename,'fri'))
        p = [34 26;30 27;35 31;30 12;31 23;28 21;13 12;34 20;21 33;26 35;27 26;21 19;21 29;14 34];
    else
        p = [23 31;29 23;34 32;27 28;17 40;32 19];
    end
    plot(p(:,1),p(:,2),'wo');

    freezeColors % http://www.mathworks.com/matlabcentral/fileexchange/7943


    % plot vector paths
    for ped=mysm.pedestrians
        plot(ped.way(:,1), ped.way(:,2));
    end

    hold off;



    % plot travel time
    subplot(1,2,2);
    hold on;
    for path=mysm.paths
        plot(path.timeOfArrival,path.time,'o');
        text(path.timeOfArrival,path.time,sprintf('%i',path.type));
    end
        
    axis square;
    hold off;
    
    
    saveas(f1,strcat('images2/',filename,'.png'));

end
