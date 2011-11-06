function smDriver( )
%SMDRIVER Sets up a simulation

f1 = figure('OuterPosition',[0 0 700 600]);
winsize = get(f1,'Position');
numframes = 2;

% resize ground model

load elevation
elevation = stmoritz; % specify which ground model

elevation = elevation(1:1140,:); % matrix dim. must be a multiple of 20
mn = size(elevation);
m = mn(1);
n = mn(2);

elevation_re = zeros(m/20,n/20);

for i=20:20:m
   for j=20:20:n 
    elevation_re(i/20,j/20) = mean2(elevation(i-19:i,j-19:j));
   end
end

elevation = max(max(elevation_re))-elevation_re; % inverting elevation model
elevation = elevation./4; % lowering elevation model
mn = size(elevation);
m = mn(1);
n = mn(2);

% Set the parameters

dur = 25;           % Durability
inten = 10;         % Intensity
vis = 4;            % Visability
importance = 1.6;   % Weight of the destination vector

initialGround = elevation;
groundMax = ones(m,n) * 100;
intensity = ones(m,n) * inten;
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

% Do 'numframes' timesteps
A(1) = getframe(gcf);
for i=1:numframes
    
    % print every 20th timestep into a .png file
    if(mod(i,20)==0 && i >0)
        str = sprintf('images/im_%d_d%d_i%d_v%d_%d.png',...
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