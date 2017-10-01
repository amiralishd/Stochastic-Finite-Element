function [K] = K_ShapeFunc(A,L,I,E,nu,alpha)

% This function reads area, length and E of each bar element and gives the
% element Timoshenko stiffnes matrix in local coordinates.

% Shear modulus
G = E/2/(1+nu);

syms x   
N1 = 0.5*(1-x);      N2 = 0.5*(1+x);
B1 = diff(N1);  B2 = diff(N2);

B = [2/L*B1,  0, 0,     2/L*B2,  0,  0
    0,  2/L*B1, -N1,    0,  2/L*B2,  -N2 
    0,  0,  2/L*B1,     0,   0,   2/L*B2];

C = [E*A, 0, 0
     0, G*A/alpha, 0
     0, 0, E*I];
 
K = (8/9*double(subs(B'*C*B,'x',0))+...
    5/9*double(subs(B'*C*B,'x',sqrt(3/5)))+...
    5/9*double(subs(B'*C*B,'x',-sqrt(3/5))))*L/2;


end