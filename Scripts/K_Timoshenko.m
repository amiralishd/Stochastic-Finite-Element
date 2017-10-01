function [K] = K_Timoshenko(A,L,I,E,nu,alpha)

% This function reads area, length and E of each bar element and gives the
% element Timoshenko stiffnes matrix in local coordinates.

% Shear modulus
G = E/2/(1+nu);
% Relative importance of the shear deformations to the bending deformations
phi = 12*E*I/G/(A/alpha)/L^2;

K = 1/(1+phi)*[E*A/L*(1+phi),  0,           0,            -E*A/L*(1+phi),  0,            0;
               0,              12*E*I/L^3,  6*E*I/L^2,     0,             -12*E*I/L^3,   6*E*I/L^2;
               0,              6*E*I/L^2,  (4+phi)*E*I/L,  0,             -6*E*I/L^2,   (2-phi)*E*I/L;
              -E*A/L*(1+phi),  0,           0,             E*A/L*(1+phi),  0,            0;
               0,             -12*E*I/L^3, -6*E*I/L^2,     0,              12*E*I/L^3,  -6*E*I/L^2;
               0,              6*E*I/L^2,  (2-phi)*E*I/L,  0,             -6*E*I/L^2,   (4+phi)*E*I/L];
end