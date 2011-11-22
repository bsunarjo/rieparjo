classdef Path < handle
    %PATH our path class
    
    properties(SetAccess = private )
        coordinates;
        type;
    end
   
    methods
        
        function obj = Path(ped,entryP)
            % takes deleted pedestrian and generates its path with
            % properties
            obj.coordinates = [ped.way; ped.destination];
            PathType(obj,entryP);      
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
        
    end  
    
end

