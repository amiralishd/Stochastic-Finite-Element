function Kg = Kglobal(Nd,El,Ke)

% This function builds the global stiffness matrix using
% the element stiffness matrices in the 3D matrix of Ke.

Kg = zeros(3*length(Nd(:,1)),3*length(Nd(:,1)));

for i = 1 : length(El(:,1));
    nd1 = El(i,2); nd2 = El(i,3);       % the start node and end node
    nd1;
    nd2;
    % Each quarter of the element stiffness matrix is mapped to its right
    % position in the global stiffness matrix.
%     if nd2 > nd1
    Kg((nd1-1)*3+1:nd1*3,(nd1-1)*3+1:nd1*3) = Kg((nd1-1)*3+1:nd1*3,(nd1-1)*3+1:nd1*3) + Ke(1:3,1:3,i);  % K_n1n1(3 by 3)
    Kg((nd1-1)*3+1:nd1*3,(nd2-1)*3+1:nd2*3) = Kg((nd1-1)*3+1:nd1*3,(nd2-1)*3+1:nd2*3) + Ke(1:3,4:6,i);  % K_n1n2(3 by 3)
    Kg((nd2-1)*3+1:nd2*3,(nd1-1)*3+1:nd1*3) = Kg((nd2-1)*3+1:nd2*3,(nd1-1)*3+1:nd1*3) + Ke(4:6,1:3,i);  % K_n2n1(3 by 3)
    Kg((nd2-1)*3+1:nd2*3,(nd2-1)*3+1:nd2*3) = Kg((nd2-1)*3+1:nd2*3,(nd2-1)*3+1:nd2*3) + Ke(4:6,4:6,i);  % K_n2n2(3 by 3)
%     else
%     Kg((nd1-1)*3+1:nd1*3,(nd1-1)*3+1:nd1*3) = Kg((nd1-1)*3+1:nd1*3,(nd1-1)*3+1:nd1*3) + Ke(4:6,4:6,i);  % K_n1n1(3 by 3)
%     Kg((nd1-1)*3+1:nd1*3,(nd2-1)*3+1:nd2*3) = Kg((nd1-1)*3+1:nd1*3,(nd2-1)*3+1:nd2*3) + Ke(4:6,1:3,i);  % K_n1n2(3 by 3)
%     Kg((nd2-1)*3+1:nd2*3,(nd1-1)*3+1:nd1*3) = Kg((nd2-1)*3+1:nd2*3,(nd1-1)*3+1:nd1*3) + Ke(1:3,4:6,i);  % K_n2n1(3 by 3)
%     Kg((nd2-1)*3+1:nd2*3,(nd2-1)*3+1:nd2*3) = Kg((nd2-1)*3+1:nd2*3,(nd2-1)*3+1:nd2*3) + Ke(1:3,1:3,i);  % K_n2n2(3 by 3)
%     end
end
end