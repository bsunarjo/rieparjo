function smDriver( )
%SMDRIVER Sets up a simulation

f1 = figure('OuterPosition',[0 0 700 600]);
winsize = get(f1,'Position');
numframes = 200;

% Set the grid size
m = 30;
n = 30;


% Set the parameters
gauss = fspecial('gaussian',15,5);

initialGround = zeros(m,n); % Modify this to get objects or slopes into
%initialGround(6:20,16:30)= - (gauss * 5000);
% the simulation.
% Example: Box in the middle
% initialGround(9:12,20:40) = -1000;
dur = 25;           % Durability
inten = 10;         % Intensity
vis = 4;            % Visability
importance = 1.6;   % Weight of the destination vector

groundMax = ones(m,n) * 100;
intensity = ones(m,n) * inten;
%intensity(6:20,16:30) = inten - gauss*1000 ;
durability = ones(m,n) * dur;
visibility = ones(m,n) * vis;


% create new plain with the specified values
myplain = Plain(initialGround,groundMax,intensity,durability,visibility);

% show the plain for input of the entry points
pcolor(myplain.ground);
entryPoints = ginput;

% create a state machine with the specified plain
mysm = StateMachine(myplain);
mysm.importance = importance;

% Do 200 timesteps
A(1) = getframe(gcf);
for i=1:200
    
    % print every 20th timestep into a .png file
    if(mod(i,20)==0 && i >0)
        str = sprintf('images/triangle/im_%d_d%d_i%d_v%d_%d.png',...
            importance,dur,inten,vis,i);
        saveas(f1,str);
    end
    
    % specify the function handle which generates new pedestrians
    newpedsfun = @(size)entries(i,size,entryPoints);
    %newpedsfun = @(size)corners(i,size);
    %newpedsfun = @(size)corners(i,size);

    % compute a new transition in the state machine
    vtr = mysm.transition(newpedsfun);
    pedestrians = mysm.pedestrians;
    %positions = zeros(m,n);
    fprintf('Number of pedestrians: %d\n',length(pedestrians));
    
    clf(f1);
    suptitle({[];[];['Grid:' num2str(m) 'x' num2str(n)];['Durability:'...
        num2str(dur) ' Visibility:' num2str(vis) ' '];[ 'Intensity:' ...
        num2str(inten) ' Importance:' num2str(importance) ' '];['After '...
        num2str(i) ' timesteps']});
    subplot(1,2,1);
    title('Ground structure (evolving trails)');
    pcolor(myplain.ground);
    caxis([0 50]);
    shading interp;
    axis equal tight off;
    
    subplot(1,2,2);
    pcolor(vtr);
    caxis([0 1]);
    shading interp;
    axis equal tight off;
    
    for j=1:length(pedestrians)
        ped = pedestrians(j);
        
        subplot(1,2,1);
        title('Ground structure (evolving trails)');
        
        hold on;
        plot(ped.position(2),ped.position(1),'wo');
        
        subplot(1,2,2);
        title('Attractiveness');
        
        hold on;
        plot(ped.position(2),ped.position(1),'wo');
    end
    
    
    drawnow;
    A(i)=getframe(gcf);
end


i = 1;
str = sprintf('movie%d.avi',i);

while(exist(str)>0)
    i = i+1;
    str = sprintf('movie%d.avi',i);
end


%save movie to file
movie2avi(A,str,'fps',3);

end

function peds = leftToRight(i,pSize)
n = pSize(1);
m = pSize(2);
    ystart = 1 + floor((n).*rand(1,1));
    ydest = 1 + floor((n).*rand(1,1));
    xstart = 1;
    xdest = m;
    ped = Pedestrian([ydest xdest]);
    ped.position = [ystart xstart];
    peds = [ped];
end

function peds = corners(i,pSize)
corners = [1 1;...
    1 pSize(2);...
    pSize(1) pSize(2);...
    pSize(1) 1];

r = randperm(4);
ped = Pedestrian(corners(r(1),:));
ped.position = corners(r(2),:);
peds = [ped];

end

function peds = entries(i,pSize,ent)
corners = floor([ent(:,2) ent(:,1)]);

r = randperm(size(corners,1));
ped = Pedestrian(corners(r(1),:));
ped.position = corners(r(2),:);
peds = [ped];

end