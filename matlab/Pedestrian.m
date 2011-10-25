classdef Pedestrian < handle
    %PEDESTRIAN our pedestrian class
    
     properties(SetAccess = private )
        destination;
     end
    
    properties
        position;
    end  
    
    methods
        function obj = Pedestrian(dest)
            obj.destination = dest;
        end
        
        function set.position(obj,x)
            obj.position = x;
        end
        
        function val = isAtDestination(obj)
            val = (norm(obj.position - obj.destination)<2);
        end
    end
    
end

