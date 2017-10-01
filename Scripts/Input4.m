function [Inp] = Input4()
% Input file

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
Inp.Par(2) = 22;
% Number of samples
Inp.Par(3) = 1000;
% Correlation length
Inp.Par(4) = 8000;

%% Materials
% [ {material number} {Young's modulus (ksi)} {Poisson's ratio} ]
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
%                                     ...];
Inp.Sec = [1 14 1 0 0
           2 1 60 100 0
           3 3 4954.8 12528565.9 2530.6
           4 3 5883.9 15608678.5 2817.4
           5 2 100 0 0];    
       
Inp.SecF = [{'@(x,L) pi*(55-(55-23)*x/L)^2'},{'@(x,L) pi/4*(55-(55-23)*x/L)^4'},{'@(x,L) 5/6*pi*(55-(55-23)*x/L)^2'}];

%% Nodes coordinates
% [ {node number} {x-coordinate} {y-coordinate} ]
Inp.Nd = [1 0 0
          2 4000 8000
          3 12000 0
          4 16000 12000
          5 24000 20000
          6 28000 0
          7 32000 24000
          8 36000 0
          9 40000 20000
          10 48000 12000
          11 52000 0
          12 60000 8000
          13 64000 0];

%% Members
% [ {member number} {startpoint node number} {endpoint node number}
% {material number} {cross section number} {bar[1], Bernouli Beam[2], Timoshenko Beam[3], Timoshenko Linear SF[4]}
% {{start point constraint in local x-dir} {start point constraint in local y-dir} {start point constraint in local z-dir}
% {end point constraint in local x-dir} {end point constraint in local  y-dir} {end point constraint in local z-dir}]
Inp.Mem = [1 1 2 1 5 1 1 1 0 1 1 0
           2 1 3 1 5 1 1 1 0 1 1 0
           3 2 3 1 5 1 1 1 0 1 1 0
           4 2 4 1 5 1 1 1 0 1 1 0
           5 3 4 1 5 1 1 1 0 1 1 0
           6 3 6 1 5 1 1 1 0 1 1 0
           7 4 6 1 5 1 1 1 0 1 1 0
           8 4 5 1 5 1 1 1 0 1 1 0
           9 5 6 1 5 1 1 1 0 1 1 0
           10 5 7 1 5 1 1 1 0 1 1 0
           11 6 7 1 5 1 1 1 0 1 1 0
           12 6 8 1 5 1 1 1 0 1 1 0
           13 7 8 1 5 1 1 1 0 1 1 0
           14 7 9 1 5 1 1 1 0 1 1 0
           15 8 9 1 5 1 1 1 0 1 1 0
           16 9 10 1 5 1 1 1 0 1 1 0
           17 8 10 1 5 1 1 1 0 1 1 0
           18 8 11 1 5 1 1 1 0 1 1 0
           19 10 11 1 5 1 1 1 0 1 1 0
           20 10 12 1 5 1 1 1 0 1 1 0
           21 11 12 1 5 1 1 1 0 1 1 0
           22 11 13 1 5 1 1 1 0 1 1 0
           23 12 13 1 5 1 1 1 0 1 1 0
           24 1 4 1 5 1 1 1 0 1 1 0
           25 3 5 1 5 1 1 1 0 1 1 0
           26 6 9 1 5 1 1 1 0 1 1 0
           27 5 8 1 5 1 1 1 0 1 1 0
           28 9 11 1 5 1 1 1 0 1 1 0
           29 10 13 1 5 1 1 1 0 1 1 0];
       
%% Restraint
% [ {node number} {restraint direction (1=x, 2=y, 3=z)} {imposed displacement} ]
% - Assumed is that there is no spring support at each node.\
Inp.Rst = [1 1 0
           1 2 0
           13 2 0];
        
%% External concentrated load
% [ {node number} {load direction (1=x, 2=y, 3=z)} {load value} ]
Inp.CLd = [2 2 -15000
           4 2 -15000
           5 2 -15000
           7 2 -15000
           9 2 -15000
           10 2 -15000
           12 2 -15000];

%% External distributed load
% [ {member number} {load direction (1=x, 2=y, 3=z)} {1st point} {load value at 1st point}
% {2nd point} {load value at 2nd point}]
% - All the points' locations must be entered as a fraction of the length of the element. Thus the values must be between [0,1].
Inp.DLd = [];

save('Inp')
end