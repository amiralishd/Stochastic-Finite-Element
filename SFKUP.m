function [UNds,UNdsPer] = SFKUP (Nd,El,Mem,Rst,CLd,G_e,Kg,KgPer)
% Solve F=K.U Perturbation
% This function solves the equation of equilibrium (F=K*U) and gives the displacement vector and constraint forces.

Rst (:,4) = (Rst (:,1)-1)*3 + Rst(:,2);     % local coord. to global coord.
if isempty(CLd) == 1
    CLd = [];
else
    CLd (:,4) = (CLd (:,1)-1)*3 + CLd(:,2); % local coord. to global coord.
end

U = zeros(length(Kg),1);                    % displacement vector (active + constrainted)
F = zeros(length(Kg),1);                    % force vector (reaction + applied + any other nodal load)
Uf = U;                                     % active nodes displacement vectors
UfPer = repmat(Uf,length(El(:,1)));         % For perturbation matrix
Kgff = Kg;                                  % active nodes stiffness sub matrix

%% Concentrated loads at the location of the nodes

if isempty(CLd) == 1  
    CLd = zeros(max(Nd(:,1))*3,1);
else
    for i = 1 : length(CLd(:,1))    % goes over all the concemtrated loads
        F(CLd(i,4),1) = CLd(i,3);   % inserts their values in their right location in F vector
    end
end

%% Equivalent nodal loads of distributed loads

F = F + G_e;
Fnx = F;

%% Deleting the rows and columns in the matrices which correspond to the constrainted nodes

count = 0;                          % due to deleting a row from the top in the matrices in each iteration and to keep track
for i = 1 : length(Rst(:,1))        % goes over all the constraints
   Kgff(:,Rst(i,4)-count) = [];     % deletes the column in Kgff
   Kgff(Rst(i,4)-count,:) = [];     % deletes the row in Kgff
   KgPer(:,Rst(i,4)-count,:) = [];     % deletes the columns in KgPer
   KgPer(Rst(i,4)-count,:,:) = [];     % deletes the rows in KgPer
   Uf(Rst(i,4)-count,:) = [];       
   UfPer(Rst(i,4)-count,:) = [];
   F(Rst(i,4)-count,:) = [];
   count = count+1;                 % keeps track of the deleted rows, columns and elements
end
%% Fix the singular stiffness matrix
% There are some of the rows in the Kgff matrix that has all the elements equal to zero. This makes the matrix a singukar matrix and this prevents
% the equation to be solved. Thus, we get rid of them for now but keep track of them also. later we add them back.

trackM = zeros(length(Kgff(:,1)),1);        % a vector with value of elements = 1 for nodes with corresponding rows in Kgff "not" with all the elements equal to zero and zero for the rest
count = 0;  
for i = 1 : length(Kgff(:,1))               % goes over all the rows in Kgff
    if sum(abs(Kgff(i-count,:))) == 0       % to check which row has all the elements equal to zero
       Kgff(:,i-count) = [];                % deletes the column
       Kgff(i-count,:) = [];                % deletes the row
       Uf(i-count,:) = [];
       F(i-count,:) = [];
       KgPer(:,i-count,:) = [];             % deletes the columns in KgPer
       KgPer(i-count,:,:) = [];             % deletes the rows in KgPer
       UfPer(i-count,:) = [];
     
       count = count+1;                     % keeps track
    else
    trackM(i,1) = 1;                        % for rows with not all the elements equal to zero
    end
end

%% SOLVING THE EQUILIBRIUM!!!
% Ufsolve = linsolve(Kgff,F);               % this is the very first vector of nodal displacements
Ufsolve = Kgff\F;                           % this is the very first vector of nodal displacements

%% Perturbation parameters

Kff_inv = Kgff^-1;
UfPerS = zeros(length(Ufsolve),length(El(:,1)));
for i = 1:length(El(:,1))   
    UfPerS(:,i) = -Kff_inv*KgPer(:,:,i)*Ufsolve;    
end

%% Relocate the displacmenets of active nodes
% Here, the displacements are put in their right position. (with zeros in
% between corresponding to those rows in Kgff with all the elements equal to zero.

UfPer = zeros(length(trackM(:,1)),length(El(:,1)));
Uf = zeros(length(trackM(:,1)),1);          % to be later the vector of all the nodal displacements for active nodes
count = 0;                                  % to keep track of the elements added to the vector of Uf from UfSolve
for i = 1 : length(trackM(:,1))             % goes over the position of all the active nodes displacements
    if trackM(i,1) == 1                     % if the row corresponding to the node was not consisting of all zero elements in Kgff
        Uf(i,1) = Ufsolve(1+count);         % puts the displacement of that node in its right position in the vector of active nodes displacements
        UfPer(i,:) = UfPerS(1+count,:);
        count = count+1;                    % counts the number of nodes with the row corresponding to it in Kgff not consisting of all zero elements
    end
end
%% Adding the zero displacmenets of constrainted nodes
% At last, all the constrainted nodes with displacements equal to zero must
% also be inserted in their right place.

UPer = UfPer;
U = Uf;                                             % Temporarily be the vector of all the displacmenets.
for i = 1 : length(Rst(:,1))                        % goes over all the constrainted nodes
	clear Utemp                                     % to be cleard at each iteration
    Utemp = U(Rst(i,4):length(U));                  % copies whatever displacement that is at and after the position of the ith constrainted node
    U(Rst(i,4)) = 0;                                % sets that constrainted node equal to zero
    U(Rst(i,4)+1:length(Utemp)+Rst(i,4))=Utemp;     % relocates all the copied displacments in Utemp right after the ith constrainted node
	clear UtempPer                                  
    UtempPer = UPer(Rst(i,4):length(UPer),:);          
    UPer(Rst(i,4),:) = 0;                           
    UPer(Rst(i,4)+1:length(Utemp)+Rst(i,4),:)=UtempPer;
end

UNds = U(1 : 3*max(max(Mem(:,2:3))));
UNdsPer = UPer(1 : 3*max(max(Mem(:,2:3))),:);
% %% Nodal Forces
% F = Kg*U-Fnx;
% 
% %% Reaction forces
% for i = 1 : length(Rst(:,1))
%    Fs(i) = F(Rst(i,4));
% end
end