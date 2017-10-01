function [Inp] = Input14()
% Input file
%% Test Problem 3 - Project 2A
Inp = struct('Inp',1);

%% Input parameters
% Maximum size of the element
Inp.Par(1) = 10000;
% Deterministic/Probabilistic
    % Detereministic analysis : 1
    % Probabilistic analysis:
        % Monte Carlo Simulation : 21
        % Perturbation Method : 22
        % Polynomial, Method A : 231
        % Polynomial, Method B : 232
Inp.Par(2) = 232;
% Number of samples
Inp.Par(3) = 10000;
% Correlation length
Inp.Par(4) = 4000;
%% Materials
% [ {material number} {Young's modulus (ksi)} {Poisson's ratio} {standard deviation, in case of SFEM}]
% 1 --> steel, 2 --> concrete
Inp.Mat = [1 70000  .29 14000
           2 200000 .35 6000];

%% Correlation matrix
% - Predefined correlation matrix --> Build the matrix down here
% - Correlation length used --> Let the value be equal to []
% - Independent random variables --> Let the parameter be equal to [0]
Inp.Corr = [];
            
%% Cross sections
% [{1 = cross section number}...
% If the shape of the section is regular like rectangle or circle, etc.:
%   [ ...{2 = shape} {1st dimension} {2nd dimension} {3rd dimension}... ]
%       Rectangle --> two parameters are required --> [ ...{2 = 1} {3 = width} {4 = height} {5 = 0}]
%       Circle --> only one parameter is required --> [ ...{2 = 2} {3 = diameter} {4 = 0} {5 = 0}]
% If the shape of the section is predefined:
%   [ ...{2 = 3} {3 = area} {4 = moment of inertia} {5 = shear area} ]
% If the cross section area is varying over the length:
%   [ ...{2 = 4} {3 = number of the function} {4 = 0} {5 = 0}]
%   And the ith functions should be entered with the below format:
%   Inp.SecFi = [{'@(x,L) A_1(x,L)'},{'@(x,L) I_1(x,L)'},{'@(x,L) As_1(x,L)'};
%                {'@(x,L) A_2(x,L)'},{'@(x,L) I_2(x,L)'},{'@(x,L) As_2(x,L)'};
%                                      ...];
Inp.Sec = [1 1 300 300 0
           2 1 200 200 0
           3 1 100 100 0];    
       
Inp.SecF = [{'@(x,L) pi*(55+(55-23)*x/L)^2'},{'@(x,L) pi/4*(55+(55-23)*x/L)^4'},{'@(x,L) 5/6*pi*(55+(55-23)*x/L)^2'}];


%% Nodes coordinates
% [ {node number} {x-coordinate} {y-coordinate} ]
Inp.Nd = [1 0 0
          2 0 5000
          3 2500 5000
          4 5000 5000
          5 5000 0
          6 7500 5000
          7 10000 5000
          8 10000 0];
              
%% Members
% [ {member number} {startpoint node number} {endpoint node number}
% {material number} {cross section number} {bar[1], Bernouli Beam[2], Timoshenko Beam[3], Timoshenko Linear SF[4]}
% {{start point constraint in local x-dir} {start point constraint in local y-dir} {start point constraint in local z-dir}
% {end point constraint in local x-dir} {end point constraint in local  y-dir} {end point constraint in local z-dir}]
Inp.Mem = [1 1 2 2 1 3 1 1 1 1 1 1
           2 2 3 2 2 3 1 1 1 1 1 1
           3 3 1 2 3 1 1 1 0 1 1 0
           4 3 4 2 2 3 1 1 1 1 1 1
           5 3 5 2 3 1 1 1 0 1 1 0
           6 4 5 2 1 3 1 1 1 1 1 1
           7 4 6 2 2 3 1 1 1 1 1 1
           8 5 6 2 3 1 1 1 0 1 1 0
           9 6 8 2 3 1 1 1 0 1 1 0
          10 6 7 2 2 3 1 1 1 1 1 1
          11 7 8 2 1 3 1 1 1 1 1 1];

% Inp.Mem = [1 1 2 2 1 3 1 1 1 1 1 1
%            2 2 3 2 2 3 1 1 1 1 1 1
%            3 3 4 2 2 3 1 1 1 1 1 1
%            4 4 5 2 1 3 1 1 1 1 1 1
%            5 4 6 2 2 3 1 1 1 1 1 1
%            6 6 7 2 2 3 1 1 1 1 1 1
%            7 7 8 2 1 3 1 1 1 1 1 1];
       
%% Restraint
% [ {node number} {restraint direction (1=x, 2=y, 3=z)} {imposed displacement} ]
% - Assumed is that there is no spring support at each node.\
Inp.Rst = [1 1 0
           1 2 0
           1 3 0
           5 1 0
           5 2 0
           5 3 0
           8 1 0
           8 2 0
           8 3 0];
        
%% External concentrated load
% [ {node number} {load direction (1=x, 2=y, 3=z)} {load value} ]
Inp.CLd = [2 1 250000];

%% External distributed load
% for now only takes uniform loads over the whole length of the element
% [ {member number} {load direction (1=x, 2=y, 3=z)} {load value}]
% - All the points' locations must be entered as a fraction of the length of the element. Thus the values must be between [0,1].
Inp.DLd = [4 2 -50
           5 2 -50
           7 2 -50
          10 2 -50];
% Inp.DLd = [2 2 -50
%            3 2 -50
%            5 2 -50
%            6 2 -50];

save('Inp')
end