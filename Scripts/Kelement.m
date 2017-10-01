function Ke = Kelement(Mat,Sec,SecF,Nd,El,Mem)

% This function builds a 3D matrix of all the elements matrices (each in
% one floor) and stores them.

Ke = zeros(6,6,length(El(:,1)));        % creates a storage area of required

for i = 1 : length(El(:,1))             % goes over all the elements
    
% extracting element properties
    xi = Nd(El(i,2),2);  yi = Nd(El(i,2),3);    % start node coord.
    xii = Nd(El(i,3),2); yii = Nd(El(i,3),3);   % end node coord.
    L = sqrt((yii-yi)^2+(xii-xi)^2);            % length
    nu = Mat(El(i,4),3);                        % nu
%     E = Mat(El(i,4),2);                         % E     
    E = El(i,14);                               % E                  % to match the SFEM

    if Sec(El(i,5),2) == 14     % checks if the cross section is varying   
        Af = str2func(char(SecF(Sec(El(i,5),3),1)));
        If = str2func(char(SecF(Sec(El(i,5),3),2)));
        Asf = str2func(char(SecF(Sec(El(i,5),3),2)));
        xm = 0.5*(xi + xii);    ym = 0.5*(yi+yii);
        A = Af(sqrt(xm^2+ym^2),Mem(El(i,13),13));
        I = If(sqrt(xm^2+ym^2),Mem(El(i,13),13));
        As = Asf(sqrt(xm^2+ym^2),Mem(El(i,13),13));
    else                % for constant cross sections
        A = Sec(El(i,5),3);                     % element area
        I = Sec(El(i,5),4);                     % element moment of inertia
        As = Sec(El(i,5),5);                    % element effective shear area
    end
    alpha = A/Sec(El(i,5),5);                   % alpha
% calculating the element stiffness matrix
    if El(i,6) == 1
        Ke(:,:,i) = K_bar(A,L,E);
    elseif El(i,6) == 2
        Ke(:,:,i) = K_Bernouli(A,L,I,E);
    elseif El(i,6) == 3
        Ke(:,:,i) = K_Timoshenko(A,L,I,E,nu,alpha);
    elseif El(i,6) == 4
        Ke(:,:,i) = K_ShapeFunc(A,L,I,E,nu,alpha);
    end
    % End releases
    if El(i,9) == 0 && El(i,12) == 0 && El(i,6) ~= 1        % just in case for now...
        Ke(:,:,i) = Endrelease(El(i,:),Ke(:,:,i));
    end
    % Here, each element's stiffness matrix is rotated from local coordinates to the global coordinates.
    Ke(:,:,i) = RotateK(xi,yi,xii,yii,Ke(:,:,i));
end
end