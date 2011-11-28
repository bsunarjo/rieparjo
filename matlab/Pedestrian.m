classdef Pedestrian < handle
    %PEDESTRIAN our pedestrian class
    
     properties(SetAccess = private )
        destination;
        way;
        ground;
     end
    
    properties(SetAccess = public)
        position;
    end  
    
    methods
        function obj = Pedestrian(entryP,aPlain)
            % generate new pedestrian and randomly choose origin and
            % destination from given entry points
            
            r = randperm(length(entryP));
            orig = entryP(r(1),:);
            dest = entryP(r(2),:);
            obj.way = orig;
            obj.destination = dest;
            obj.position = orig;
            MakeRelativePath(aPlain);
            ground_property = aPlain.relativePath(obj.position(1),obj.position(2));
            obj.ground = ground_property;
        end
        
        function set.position(obj,pos)
            % put pedestrian to position
            obj.position = pos;
        end
        
        function saveWay(obj,aPlain)
            % save way of pedestrian and property of ground
            obj.way = [obj.way; obj.position];
            ground_property = aPlain.relativePath(obj.position(1),obj.position(2));
            obj.ground = [obj.ground; ground_property];
        end
        
        function val = isAtDestination(obj)
            % check if pedestrian arrived at destination
            val = (norm(obj.position - obj.destination)<2);
        end         
    end    
end

