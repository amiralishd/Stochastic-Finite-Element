function G_e = EqNdLd(DLd,El,Nd)

% This function taked the distributed loads on the elements and gives the
% equivalental nodal loads as the output.

syms x
N1 = 0.5*(1-x);      N2 = 0.5*(1+x);
N = [N1,  0,  0,  N2,  0,  0
    0,  N1,  0,    0,  N2,   0 
    0,  0,  N1,   0,   0,   N2];

if isempty(DLd) == 1                                        % checks to see if there is any distributed load exisiting    
    G_e = zeros(max(Nd(:,1))*3,1);                          % if yes, makes it a matrix of zeros.
else                                                        % otherwise...
    G_e = zeros(max(Nd(:,1))*3,1);
    for j = 1 : length(DLd(:,1))                            % goes over all the distributed loads
        p = DLd(j,3);                                       % unifrom load p
        for i = 1 : length(El(:,1))                         % goes over all the elements
            if El(i,13) == DLd(j,1)                         % checks if the element i belongs to the member of which the unifrom load j is applied to
                xi = Nd(El(i,2),2);  yi = Nd(El(i,2),3);    % start node coord. of the element i
                xii = Nd(El(i,3),2); yii = Nd(El(i,3),3);   % end node coord. of the element i
                L = sqrt((yii-yi)^2+(xii-xi)^2);            % length if the element i

                if El(i,6) == 4                             % the case of FEM with shape functions
                    if DLd(j,2) == 1                        % axial load (uniform)
                    g_eTemp = [p, 0, 0]';
                    elseif DLd(j,2) == 2                    % transverse load (uniform)
                    g_eTemp = [0, p, 0]';
                    elseif DLd(j,2) == 3                    % unifrom moment
                    g_eTemp = [0, 0, p]';
                    end
                    g_e = (8/9*double(subs(N,'x',0))+...
                           5/9*double(subs(N,'x',sqrt(3/5)))+...
                           5/9*double(subs(N,'x',-sqrt(3/5))))'*g_eTemp*L/2;
                else                                        % any other case: Bernouli, Timoshenko and Bar element...
                    if DLd(j,2) == 1                        % axial load (uniform)
                    g_e = [p*L/2, 0, 0, p*L/2, 0, 0]';
                    elseif DLd(j,2) == 2                    % transverse load (uniform)
                    g_e = [0, p*L/2, p*L^2/12, 0, p*L/2, -p*L^2/12]';
                    elseif DLd(j,2) == 3                    % unifrom moment
                    g_e = [0, 0, p*L/2, 0, 0, p*L/2]';
                    end
                end
                g_e = RotateG(xi,yi,xii,yii,g_e);           % rotated from local coord. to global coord.
                % mapping the eq nodal load of start node to the global node
                if El(i,2) < El(i,3)
                G_e((El(i,2)-1)*3+1:El(i,2)*3) = G_e((El(i,2)-1)*3+1:El(i,2)*3) + g_e(1:3);
                % mapping the eq nodal load of end node to the global node
                G_e((El(i,3)-1)*3+1:El(i,3)*3) = G_e((El(i,3)-1)*3+1:El(i,3)*3) + g_e(4:6);
                else
                G_e((El(i,2)-1)*3+1:El(i,2)*3) = G_e((El(i,2)-1)*3+1:El(i,2)*3) + g_e(4:6);
                % mapping the eq nodal load of end node to the global node
                G_e((El(i,3)-1)*3+1:El(i,3)*3) = G_e((El(i,3)-1)*3+1:El(i,3)*3) + g_e(1:3);
                end
            end
        end
    end
end
end