function [K] = K_Bernouli(A,L,I,E)

% This function reads A, L, I and E of each beam element and gives the
% element Bernouli stiffnes matrix in local coordinates.

K = [E*A/L      0           0       -E*A/L          0              0;
     0      12*E*I/L^3	 6*E*I/L^2     0	   -12*E*I/L^3,    6*E*I/L^2;
     0      6*E*I/L^2     4*E*I/L      0        -6*E*I/L^2	    2*E*I/L;
     -E*A/L     0            0       E*A/L          0               0;
     0     -12*E*I/L^3	-6*E*I/L^2     0        12*E*I/L^3	   -6*E*I/L^2;
     0      6*E*I/L^2	  2*E*I/L	   0        -6*E*I/L^2      4*E*I/L];
end