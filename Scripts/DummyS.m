function [Kg,CLd] = DummyS(Kg,CLd,Mem)

% This function check the stiffness matrix to
%   1- Detect any node that is off and not connected to the system.
%   2- Checks if any diagonal element of the stiffness matrix is equal to
%      zero and asks the analyst if the execution should be stopped or
%      continued.
%   3- If case 2 happens (diagonal elemenet = 0), it also check if there is
%      any concentrated load at that node.

for i = 1 : length(Kg(:,1))                                                         % goes over all the diagonal elements
%###############################################################################################################################################################################    
    if Kg(i,i) == 0                                                                 % checks if the element is equal to zero
        if  i <= length(Kg(:,1))-2 & Kg(i+1,i+1) == 0 & Kg(i+2,i+2) == 0            % also checks if the two DOFs after that have the same situation (k_ii = 0)    
            disp(['The node ' num2str(ceil(i/3))...
                  ' is not connected to the system.'])
            error('Execution stopped!')                                             % stops execution and sends the error of having a node off the system
%###############################################################################################################################################################################        
        elseif any (Mem(:,6) ~= 1)                                                  % checks if this is not the case for bar elements (they are supposed to have some kii = 0)
            choice = questdlg(['The diagonal stiffness of global DOF ' num2str(i)...
                ' belonging to node ' num2str(ceil(i/3)) ' is equal to zero. Do you want to continue?'], ...
                'Input Error', ...
                'Yes' ,'No' ,'No');                                                 % a window shows up and asks the user if the execution should continue
            switch choice
                case 'Yes'
                    Kg(i,i) = 1;
                    disp(['The diagonal stiffness of global DOF ' num2str(i)...     
                    ' belonging to node ' num2str(ceil(i/3)) ' is set equal to 1.'])% replaces the zero diagonal element with one andcontinues execution
                case 'No'
                    close all;
                    error('Execution stopped!')                                     % stops execution
            end
        end
%###############################################################################################################################################################################        
     if isempty(CLd) ~= 1    
        for j = 1 : length(CLd(:,1))                                                % goes over all the nodal loads
            if mod(i,3) == 0                                                    
            dir = 3;                                                                % for loads in global z-dir
            else
                dir = mod(i,3);                                                     % for loads in global x-dir and y-dir
            end
            
            if any (CLd(j,1) == ceil(i/3) & CLd(j,3) ~= 0 & CLd(j,2) == dir)        % checks to find any nodal load at that DOF
                choice = questdlg(['There is a load applied to node ' num2str(ceil(i/3))...
                    ' in the direction ' num2str(dir) ' . Do you want to continue?'], ...
                    'Input Error', ...
                    'Yes' ,'No' ,'No');                                             % a windows shows up and asks the user if he wants to continue                                       
                switch choice
                    case 'Yes'
                        CLd(j,3) = 0;
                        disp(['The load at node ' num2str(ceil(i/3))...
                        ' in the direction ' num2str(dir) ' is set to be zero.'])   % If "Yes" is selected, the load sets to be equal to zero and execution continues
                    case 'No'
                        close all;
                        error('Execution stopped!')                                 % if "No", the execution stops
                end
            end
        end
     end
%###############################################################################################################################################################################            
    end
end
end