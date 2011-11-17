classdef Pedestrian < handle
    %PEDESTRIAN our pedestrian class
    
     properties(SetAccess = private )
        destination;
        way;
     end
    
    properties(SetAccess = public)
        position;
    end  
    
    methods
        function obj = Pedestrian(entryP)
            % generate new pedestrian and randomly choose origin and
            % destination from given entry points
            
            r = randperm(length(entryP));
            orig = entryP(r(1),:);
            dest = entryP(r(2),:);
            obj.way = orig;
            obj.destination = dest;
            obj.position = orig;
        end
        
        function set.position(obj,pos)
            % put pedestrian to position
            obj.position = pos;
        end
        
        function saveWay(obj)
            % save way of pedestrian
            obj.way = [obj.way, obj.position];
        end
        
        function val = isAtDestination(obj)
            % check if pedestrian arrived at destination
            val = (norm(obj.position - obj.destination)<2);
        end         
    end    
end

