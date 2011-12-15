%function smDriver(dur, inten, vis, importance, location, numframes)
%SMDRIVER Sets up a simulation

f1 = figure('OuterPosition',[0 0 700 600]);
winsize = get(f1,'Position');
numframes = 100;


% selecting elevation model
%load elevation
%if(strcmp(location,'fri'))
    elevation = friburg(1:1100,1:1260); % for Friburg
    entryPoints = [667 503; 596 534; 693 607; 599 227; 612 459; 546 417; 255 223; 662 399; 412 655; 510 689; 523 514; 418 366; 418 570; 267 669];
%elseif(strcmp(location,'stm'))
%    elevation = stmoritz(1:1140,:); % for St. Moritz
%    entryPoints = [454 620; 567 452; 674 638; 528 542; 328 785; 623 372];
%end


% resizing elevation model (original elevation dim must be multiple of 20)
%elevation_re = zeros(size(elevation)/20);
%[m n] = size(elevation);

%for i=20:20:m
%   for j=20:20:n 
%    elevation_re(i/20,j/20) = mean2(elevation(i-19:i,j-19:j));
%   end
%end

elevation_re = elevation;
[m n] = size(elevation_re);


% Set the parameters
dur = 25;                       % Durability
inten = 10;                     % Intensity
vis = 4;                        % Visability
importance = 1.6;               % Weight of the destination vector
speed.horizontal.min = 4000;    % min horizontal speed in m/h
speed.horizontal.max = 6000;    % max horizontal speed in m/h
speed.vertical = 500;           % vertical speed in m/h
gridSize = 500;                 % grid size of plain in m
pathMax = 100;                  % maximal value of a path


initialGround = max(max(elevation_re))-elevation_re; % inverting elevation
groundMax = initialGround + ones(m,n)*pathMax;
intensity = ones(m,n) * inten;
durability = ones(m,n) * dur;
visibility = ones(m,n) * vis;
elevation = elevation_re;

% create new plain with the specified values
myplain = Plain(initialGround,groundMax,intensity,durability,visibility,...
    elevation,gridSize);

% show the plain for input of the entry points
%pcolor(myplain.realGround);
%colormap(gray);
%axis ij;
%entryPoints = ginput;
%entryPoints = floor([entryPoints(:,2) entryPoints(:,1)]);

% create a state machine with the specified plain
mysm = StateMachine(myplain);
mysm.importance = importance;
mysm.entryPoints = entryPoints;
mysm.speed = speed;
% make cell, where possible paths on Plain are later saved
noPossPaths = length(nchoosek(1:length(mysm.entryPoints),2));
mysm.pathsSorted = cell(1,noPossPaths); 

% Do 'numframes' timesteps
C(1) = getframe(gcf);
for i=1:numframes
    
    % print every 20th timestep into a .png file
    if(mod(i,20)==0 && i >0)
        str = sprintf('images/im_%d_d%d_i%d_v%d_%d.png',...
            importance,dur,inten,vis,i);
        saveas(f1,str);
    end
    
    % compute a new transition in the state machine
    vtr = mysm.transition;
    
    % tell the StateMachine in which state it is in
    mysm.time = i; 
    
    % display how many pedestrians are on the plane
    pedestrians = mysm.pedestrians;
    fprintf('Number of pedestrians: %d\n',length(pedestrians));
    
    % making the 3 subplots
    clf(f1);
    suptitle({[];[];['Grid:' num2str(m) 'x' num2str(n)];['Durability:'...
        num2str(dur) ' Visibility:' num2str(vis) ' '];[ 'Intensity:' ...
        num2str(inten) ' Importance:' num2str(importance) ' '];['After '...
        num2str(i) ' timesteps']});
    
    % subplot 1
    subplot(1,3,1);
    title('Initial Ground Structure');
    pcolor(myplain.realGround);
    shading interp;
    axis equal tight off ij;
    colormap(gray)
    freezeColors
    
    % subplot 2
    subplot(1,3,2);
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
    
    freezeColors % http://www.mathworks.com/matlabcentral/fileexchange/7943

    % subplot 3
    subplot(1,3,3);
    title('Attractiveness');
    pcolor(vtr);
    shading interp;
    axis equal tight off ij;
    colormap(jet)
    freezeColors
    
    % plotting the pedestrians into the subplots
    for j=1:length(pedestrians)
        ped = pedestrians(j);
        
        subplot(1,3,1);
        title('Initial Ground Structure');
        
        hold on;
        plot(ped.position(2),ped.position(1),'wo');
        
        subplot(1,3,2);
        title('Evolving Trails');
        
        hold on;
        plot(ped.position(2),ped.position(1),'wo');
        
        subplot(1,3,3);
        title('Attractiveness');
        
        hold on;
        plot(ped.position(2),ped.position(1),'wo');
    end
    
    
    drawnow;
    C(i)=getframe(gcf);
end


i = 1;
str = sprintf('movie%d.avi',i);

while(exist(str)>0)
    i = i+1;
    str = sprintf('movie%d.avi',i);
end

%save movie to file
movie2avi(C,str,'fps',3);

%end