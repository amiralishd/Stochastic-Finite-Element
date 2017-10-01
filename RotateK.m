function Ke = RotateK(xi,yi,xii,yii,Ke)
% This function rotates the stiffness matrix from localcoord. to global coord.

% Manipulate the angle of the element with +x-dir
% this is because of the special way MATLAB defines Arctan function.
% if xi < xii && yi == yii
%     teta = 0;
% elseif xi < xii && yi < yii
%     teta = atan((yii-yi)/(xii-xi));
% elseif xi == xii && yi < yii
%     teta = pi/2;
% elseif xi > xii && yi < yii
%     teta = atan((yii-yi)/(xii-xi))+pi;
% elseif xi > xii && yi == yii
%     teta = pi;
% elseif xii < xi && yi > yii
%     teta = atan((yii-yi)/(xii-xi))+pi;
% elseif xi == xii && yi > yii
%     teta = 3*pi/2;
% elseif xi < xii && yi > yii
%     teta = atan((yii-yi)/(xii-xi))+2*pi;
% end
teta = atan((yii-yi)/(xii-xi));
% teta*180/pi;
% Now, we have a teta out!

C = @ (teta) cos(teta);     % cos
S = @ (teta) sin(teta);     % sin

% Rotation matrix
T = [C(teta)  S(teta)  0   0  0  0   
     -S(teta) C(teta)  0   0  0  0
     0  0  1   0  0  0
     0  0  0   C(teta)  S(teta)  0   
     0  0  0   -S(teta)  C(teta)  0
     0  0  0   0  0  1];

% element stiffness matrix in global coord.
Ke = T'*Ke*T;
end