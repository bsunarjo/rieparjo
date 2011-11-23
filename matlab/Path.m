classdef Path < handle
    %PATH our path class
    
    properties(SetAccess = public)
        coordinates;
        type;
        time;
    end
   
    methods
        
        function obj = Path(ped,entryP,speed,aPlain)
            % takes deleted pedestrian and generates its path with
            % properties
            obj.coordinates = [ped.way; ped.destination];
            PathType(obj,entryP);      
            PathTime(obj,speed,aPlain);
        end 
        
        function PathType(obj,entryP)
            % checks which from the possible paths the pedestrian went
            
            % generate possible paths
            PossPathIndex = nchoosek(1:length(entryP),2);
            
            PossPath.origin = zeros(size(PossPathIndex));
            PossPath.destination = zeros(size(PossPathIndex));
            
            for i=1:size(PossPathIndex,1)
                PossPath.origin(i,:) = entryP(PossPathIndex(i,1),:);
                PossPath.destination(i,:) = entryP(PossPathIndex(i,2),:);
            end
            
            % check which from the possible paths the path is
            for i=1:size(PossPathIndex,1)
               
                if ((obj.coordinates(1,:)==PossPath.origin(i,:)|obj.coordinates(1,:)==PossPath.destination(i,:))&(obj.coordinates(end,:)==PossPath.origin(i,:)|obj.coordinates(end,:)==PossPath.destination(i,:)))
                  obj.type=i;
                end
                
            end            
        end
        
        function PathTime(obj,speed,aPlain)
           % calculates the time it takes the pedestrian to walk the path
           aRealGround = aPlain.realGround;
           aGridSize = aPlain.gridSize;
           path.horiz = obj.coordinates;
           
           % extracting height info from elevation model
           path.vert = zeros(size(path.horiz,1),1);
           for i=1:size(path.horiz,1)
               path.vert(i) = aRealGround(path.horiz(i,1),path.horiz(i,2));
           end
           
               
               
           % calculating horizontal and vertical distance from path
           % (vertical distance only taken if path goes uphill)
           
           dist_horiz = 0;
           dist_vert = 0;
           
           for i=1:size(path.horiz,1)-1
               
               delta_horiz = norm(path.horiz(i+1,:)-path.horiz(i,:));
               dist_horiz = dist_horiz + delta_horiz;
               
               delta_vert = path.horiz(i+1)-path.horiz(i);
               if delta_vert>=0
                   dist_vert = dist_vert + delta_vert;
               end
               
           end
           
           % scale horizontal distance with grid size and calculate walking
           % time
           
           obj.time = dist_horiz*aGridSize/speed.horizontal + dist_vert*aGridSize/speed.vertical;
         
        end
        
    end  
    
end

