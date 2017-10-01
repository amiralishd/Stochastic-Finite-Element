function [Inp] = Input15()
% Input file
%% Test Problem 3 - Project 2A
Inp = struct('Inp',1);

%% Input parameters
% Maximum size of the element
Inp.Par(1) = 20000;
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
Inp.Par(4) = 7500;
%% Materials
% [ {material number} {Young's modulus (ksi)} {Poisson's ratio} {standard deviation, in case of SFEM}]
% 1 --> steel, 2 --> concrete
Inp.Mat = [1 70000  .29 14000
           2 210000 .25 52500];

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
Inp.Sec = [1 2 500 0 0
           2 2 10 0 0];    
       
Inp.SecF = [{'@(x,L) pi*(55+(55-23)*x/L)^2'},{'@(x,L) pi/4*(55+(55-23)*x/L)^4'},{'@(x,L) 5/6*pi*(55+(55-23)*x/L)^2'}];


%% Nodes coordinates
% [ {node number} {x-coordinate} {y-coordinate} ]
Inp.Nd = [1 0 0
          2 0 10000
          3 0 20000
          4 10000 20000
          5 10000 10000
          6 13000 20000
          7 13000 10000
          8 13000 0
          9 23000 0
         10 23000 10000
         11 23000 20000];
              
%% Members
% [ {member number} {startpoint node number} {endpoint node number}
% {material number} {cross section number} {bar[1], Bernouli Beam[2], Timoshenko Beam[3], Timoshenko Linear SF[4]}
% {{start point constraint in local x-dir} {start point constraint in local y-dir} {start point constraint in local z-dir}
% {end point constraint in local x-dir} {end point constraint in local  y-dir} {end point constraint in local z-dir}]
Inp.Mem = [1   1  2 2 1 3 1 1 1 1 1 1
           2   2  3 2 1 3 1 1 1 1 1 1
           3   3  4 2 1 3 1 1 1 1 1 1
           4   4  5 2 1 3 1 1 1 1 1 1
           5   2  5 2 1 3 1 1 1 1 1 1
           6   4  7 2 2 3 1 1 0 1 1 0
           7   5  6 2 2 3 1 1 0 1 1 0
           8   6  7 2 1 3 1 1 1 1 1 1
           9   7  8 2 1 3 1 1 1 1 1 1
           10  6 11 2 1 3 1 1 1 1 1 1
           11  7 10 2 1 3 1 1 1 1 1 1
           12  8  9 2 1 3 1 1 1 1 1 1
           13  9 10 2 1 3 1 1 1 1 1 1
           14 10 11 2 1 3 1 1 1 1 1 1];
       
%% Restraint
% [ {node number} {restraint direction (1=x, 2=y, 3=z)} {imposed displacement} ]
% - Assumed is that there is no spring support at each node.\
Inp.Rst = [1 1 0
           1 2 0
           1 3 0
           8 1 0
           8 2 0
           8 3 0
           9 1 0
           9 2 0
           9 3 0];
        
%% External concentrated load
% [ {node number} {load direction (1=x, 2=y, 3=z)} {load value} ]
Inp.CLd = [2 1 20000
           3 1 25000];

%% External distributed load
% for now only takes uniform loads over the whole length of the element
% [ {member number} {load direction (1=x, 2=y, 3=z)} {load value}]
% - All the points' locations must be entered as a fraction of the length of the element. Thus the values must be between [0,1].
Inp.DLd = [3 2 -6
          10 2 -6];

save('Inp')
end