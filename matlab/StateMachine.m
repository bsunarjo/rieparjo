classdef StateMachine < handle
    %STATEMACHINE Handles the state changes in the simulation
    %   Computes the change of the environment and moves all the pedestrians
    
    properties(SetAccess = public)
        plain;          % G ... the current plain
        pedestrians;    % Array of pedestrians which are currently walking
        importance;     % How to weight the vector to the destination
        entryPoints;    % entry points as specified by ginput
        paths;
    end
    
    methods
        function obj = StateMachine(aPlain)
            % Constructor: set the plain
            obj.plain = aPlain;
        end
        
        function [Vtr] = transition(obj)
            % Does a transition in the state machine according to the plain
            % and the pedestrians.
            
            [n m] = size(obj.plain.ground);
            Vtr = zeros(n,m);
            
            % Generate new pedestrians and put it to the other
            % pedestrians
            
            newPed = Pedestrian(obj.entryPoints);
            obj.pedestrians = [obj.pedestrians,newPed];
           
            % Change the environment according to the pedestrian positions
            obj.plain.changeEnvironment(obj.pedestrians);
            
            % Compute the attractiveness for each point in the plain
            for i=1:n
                for j=1:m
                    Vtr(i,j) = obj.computeAttractiveness([i;j]);
                end
            end
            
            % Delete pedestrians which are at their destination or near
            ToDelete = false(1,length(obj.pedestrians));
            
            for i=1:length(obj.pedestrians)
                ToDelete(i) = isAtDestination(obj.pedestrians(i));
            end
            
            DeletedPed = obj.pedestrians(ToDelete);
            obj.pedestrians = obj.pedestrians(~ToDelete);
            
            % Save path of delted pedestrians
            for i=1:length(DeletedPed)
                obj.paths = [obj.paths, Path(DeletedPed(i),obj.entryPoints)];
            end
                    
            % move and save way of pedestrians
            for i=1:length(obj.pedestrians)
                movePedestrian(obj,i,Vtr);
                saveWay(obj.pedestrians(i));
            end
            
        end
        
        
        function movePedestrian(obj,pedestNum,vtr)
            % Moves a pedestrian according to the attractiveness of the
            % neighbourhood and its destination
            
            pedest = obj.pedestrians(pedestNum);
            
            maxvtr = -inf;
            maxcoords = [0;0];
            
            % compute the maximum value of vtr in the neighbourhood and
            % save the direction to it
            for i = -1:1
                for j = -1:1
                    y = pedest.position(1)+i;
                    x = pedest.position(2)+j;
                    if(obj.plain.isPointInPlain(y,x))
                        if maxvtr < vtr(y,x)
                            maxvtr = vtr(y,x);
                            maxcoords = [i j];
                        end
                    end
                    
                end
            end
            
            % normalize the gradient vector (but check for zero division)
            if(norm(maxcoords)>0)
                maxcoords = maxcoords / norm(maxcoords);
            end
            
            % compute the vector to the destination and normalize it
            toDest = pedest.destination - pedest.position;
            toDest = toDest ./ norm(toDest);
            
            % add both vectors, but multiply the toDest vector with
            % importance to get better results
            moveDir = obj.importance * toDest + maxcoords;
            
            % compute the angle of the directional vector
            alpha = atan(moveDir(1)/moveDir(2));
            
            % Because tan is pi periodic we have to add pi to the angle
            % if x is less than zero
            if moveDir(2) < 0
                alpha = alpha + pi;
            end
            
            % Define the direction vectors
            up = [-1 0];
            down = [1 0];
            left = [0 -1];
            right = [0 1];
            
            % Initialize the move vector
            move = [0 0];
            
            % Shortcut for pi/8
            piEi = pi/8;
            
            % Check the angle of the resulting vector and choose
            % the moving direction accordingly
            
            if (alpha < -3*piEi) || (alpha >  11*piEi)
                % move up
                move = up;
                
            elseif (alpha >= -3*piEi) && (alpha < -piEi)
                % move right up
                move = up + right;
                
            elseif (alpha >= -piEi) && (alpha < piEi)
                % move right
                move = right;
                
            elseif (alpha >= piEi) && (alpha < 3*piEi)
                % move down right
                move = down + right;
                
            elseif (alpha >= 3*piEi) && (alpha < 5*piEi)
                % move down
                move = down;
                
            elseif (alpha >= 5*piEi) && (alpha < 7*piEi)
                % move down left
                move = down + left;
                
            elseif (alpha >= 7*piEi) && (alpha < 9*piEi)
                % move left
                move = left;
                
            elseif (alpha >= 9*piEi) && (alpha < 11*piEi)
                % move up left
                move = up + left;
            end
            
            % Actually move the pedestrian
            pedest.position = pedest.position + move;
        end
        
        
        function Vtr = computeAttractiveness(obj,coords)
            % This function computes the sum of all attracivenesses
            % of the whole area from the viewpoint of coords
           
            % Get the visibility at point coords
            visibility = obj.plain.visibility(coords(1),coords(2));
            
            % Get the current ground structure
            G = obj.plain.ground;
            [n m] = size(G);
            
            % Efficient implementation for the sum
            [A,B]=meshgrid(((1:m)-coords(2)).^2,((1:n)-coords(1)).^2);
            S=-sqrt(A+B);
            S = exp(S/visibility);
            S = S.*G;
            Vtr = sum(sum(S));
            
            % Average the sum over the number of squares in the plain
            Vtr = Vtr/(m*n);
        end
        
        
    end
   
end