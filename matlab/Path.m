classdef Path < handle
    %PEDESTRIAN our pedestrian class
    
    properties(SetAccess = private )
        coordinates;
    end
   
    methods
        
        function obj = Path(ped)
            % takes deleted pedestrian and generates it path
            obj.coordinates = [ped.way ped.destination];
        end
          
    end    
end

