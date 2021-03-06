function [Inp] = Input3()
% Input file

Inp = struct('Inp',1);

%% Input parameters
% Maximum size of the element
Inp.Par(1) = 7000;
% Deterministic/Probabilistic
    % Detereministic analysis : 1
    % Probabilistic analysis:
        % Monte Carlo Simulation : 21
        % Perturbation Method : 22
        % Polynomial, Method A : 231
        % Polynomial, Method B : 232
Inp.Par(2) = 232;
% Number of samples
Inp.Par(3) = 1000;
% Correlation length
Inp.Par(4) = 8000;
%% Materials
% [ {material number} {Young's modulus (ksi)} {Poisson's ratio} {standard deviation, in case of SFEM}]
% 1 --> steel, 2 --> concrete
Inp.Mat = [1 70000  .29 14000
           2 200000 .29 40000];
            
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
Inp.Sec = [1 14 1 0 0
           2 1 60 100 0
           3 3 4954.8 125285659.1 2530.6
           4 3 5883.9 156086784.6 2817.4];    
       
Inp.SecF = [{'@(x,L) pi*(55+(55-23)*x/L)^2'},{'@(x,L) pi/4*(55+(55-23)*x/L)^4'},{'@(x,L) 5/6*pi*(55+(55-23)*x/L)^2'}];


%% Nodes coordinates
% [ {node number} {x-coordinate} {y-coordinate} ]
Inp.Nd = [1 0 0
          2 0 3000
          3 0 6000
          4 0 9000
          5 7000 9000
          6 7000 6000
          7 7000 3000
          8 7000 0];
              
%% Members
% [ {member number} {startpoint node number} {endpoint node number}
% {material number} {cross section number} {bar[1], Bernouli Beam[2], Timoshenko Beam[3], Timoshenko Linear SF[4]}
% {{start point constraint in local x-dir} {start point constraint in local y-dir} {start point constraint in local z-dir}
% {end point constraint in local x-dir} {end point constraint in local  y-dir} {end point constraint in local z-dir}]
Inp.Mem = [1 1 2 2 3 3 1 1 1 1 1 1
           2 2 3 2 3 3 1 1 1 1 1 1
           3 3 4 2 3 3 1 1 1 1 1 1
           4 4 5 2 4 3 1 1 1 1 1 1
           5 5 6 2 3 3 1 1 1 1 1 1
           6 6 7 2 3 3 1 1 1 1 1 1
           7 7 8 2 3 3 1 1 1 1 1 1
           8 3 6 2 4 3 1 1 1 1 1 1
           9 2 7 2 4 3 1 1 1 1 1 1];
       
%% Restraint
% [ {node number} {restraint direction (1=x, 2=y, 3=z)} {imposed displacement} ]
% - Assumed is that there is no spring support at each node.\
Inp.Rst = [1 1 0
           1 2 0
           1 3 0
           8 1 0
           8 2 0
           8 3 0];
        
%% External concentrated load
% [ {node number} {load direction (1=x, 2=y, 3=z)} {load value} ]
Inp.CLd = [2 1 10000
           3 1 20000 
           4 1 30000];

%% External distributed load
% for now only takes uniform loads over the whole length of the element
% [ {member number} {load direction (1=x, 2=y, 3=z)} {load value}]
% - All the points' locations must be entered as a fraction of the length of the element. Thus the values must be between [0,1].
Inp.DLd = [4 2 -600];

save('Inp')
end