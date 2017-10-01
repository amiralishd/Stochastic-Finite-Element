function [K] = K_bar(A,L,E)

% This function reads A, L and E of each bar element and gives the
% element stiffnes matrix in local coordinates.

K = E*A/L * [1 0 0 -1 0 0
             0 0 0 0 0 0
             0 0 0 0 0 0
             -1 0 0 1 0 0
             0 0 0 0 0 0
             0 0 0 0 0 0];
end

