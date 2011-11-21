function smDriver( )
%SMDRIVER Sets up a simulation

f1 = figure('OuterPosition',[0 0 700 600]);
winsize = get(f1,'Position');
numframes = 3;

% resizing elevation model
load elevation
elevation = stmoritz; % specify which ground model

elevation = elevation(1:1140,:); % matrix dim. must be a multiple of 20
[m n] = size(elevation);

elevation_re = zeros(size(elevation)/20);

for i=20:20:m
   for j=20:20:n 
    elevation_re(i/20,j/20) = mean2(elevation(i-19:i,j-19:j));
   end
end

elevation = max(max(elevation_re))-elevation_re; % inverting elevation model
[m n] = size(elevation);

% Set the parameters
dur = 25;           % Durability
inten = 10;         % Intensity
vis = 1;            % Visability; dependent on scale factor!!
importance = 1.6;   % Weight of the destination vector

initialGround = elevation;
groundMax = elevation + ones(m,n)*100;
intensity = ones(m,n) * inten;
durability = ones(m,n) * dur;
visibility = ones(m,n) * vis;


% create new plain with the specified values
myplain = Plain(initialGround,groundMax,intensity,durability,visibility);

% show the plain for input of the entry points
%pcolor(myplain.ground);
%entryPoints = ginput;
%entryPoints = floor([entryPoints(:,2) entryPoints(:,1)]);

% hard coded entry points;
% eventually we'll want to have these be coordinates of cities
entryPoints = [38 28; 25 18; 22 27];

% create a state machine with the specified plain
mysm = StateMachine(myplain);
mysm.importance = importance;
mysm.entryPoints = entryPoints;

% Do 'numframes' timesteps
%A(1) = getframe(gcf);
for i=1:numframes
    
    % print every 20th timestep into a .png file
    if(mod(i,20)==0 && i >0)
        str = sprintf('images/im_%d_d%d_i%d_v%d_%d.png',...
            importance,dur,inten,vis,i);
        %saveas(f1,str);
    end
    
    % compute a new transition in the state machine
    vtr = mysm.transition;
    
    pedestrians = mysm.pedestrians;
    fprintf('Number of pedestrians: %d\n',length(pedestrians));
    
    clf(f1);
    suptitle({[];[];['Grid:' num2str(m) 'x' num2str(n)];['Durability:'...
        num2str(dur) ' Visibility:' num2str(vis) ' '];[ 'Intensity:' ...
        num2str(inten) ' Importance:' num2str(importance) ' '];['After '...
        num2str(i) ' timesteps']});
    subplot(1,2,1);
    title('Ground structure (evolving trails)');
    pcolor(myplain.ground);
    %caxis([0 50]);
    shading interp;
    axis equal tight off;
    
    subplot(1,2,2);
    pcolor(vtr);
    %caxis([0 1]);
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
    %A(i)=getframe(gcf);
end

%{
i = 1;
str = sprintf('movie%d.avi',i);

while(exist(str)>0)
    i = i+1;
    str = sprintf('movie%d.avi',i);
end

%save movie to file
movie2avi(A,str,'fps',3);
%}
end