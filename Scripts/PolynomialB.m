function [UNds,UNds_MEAN,UNds_COV,UNds_STD] = PolynomialB (Par,Corr,Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst)

% This function calculates the mean values of reaction forces and the mean
% values and covariance matrix of the displacement using Polynomial
% approach (with method B)

%% Covariance matrix of input
COV_Inp = zeros(length(El(:,1)),length(El(:,1)));   % Independant RVs
if isempty(Corr) == 1
    [COV_Inp] = COVINP (Par,Mat,El,Nd);             % calculated based on correlation length
elseif Corr ~= 0
    for i = 1:length(El(:,1))                       % predefined
        for j = i:length(El(:,1))
           COV_Inp(i,j) = Corr(i,j)*Mat(El(i,4),4)*Mat(El(j,4),4);
           COV_Inp(j,i) = COV_Inp(i,j);
        end
    end
else
    for i = 1:length(El(:,1))
        COV_Inp(i,i) = Mat(El(i,4),4)^2;
    end
end

NS = Par(3);                                            % number of samples
MU = zeros(1,length(El(:,1)));                          % matrix of mean values

%% Generated samples
RV = mvnrnd(MU,COV_Inp,NS);

%% Creating Element Matrix
Ke = Kelement(Mat,Sec,SecF,Nd,El,Mem);

%% Matrices of derivatives for each element (each RV)
Kder = Ke-Ke;
for i = 1 : length(El(:,1))
    Kder(:,:,i) = Ke(:,:,i) ./ Mat(El(i,4),2);
end

%% Assembling Global Matrix
Kg = Kglobal(Nd,El,Ke);

%% Dummy stiffness
[Kg,CLd] = DummyS(Kg,CLd,Mem);

%% Equivalent Nodal Load
G_e = EqNdLd(DLd,El,Nd);

%% Global matrices of the derivatives
KgPer = zeros(length(Kg(:,1)),length(Kg(:,1)),length(El(:,1)));
for i = 1 : length(El(:,1))
    KPer = Ke-Ke;
    KPer(:,:,i) = Kder(:,:,i);
    KgPer(:,:,i) = Kglobal(Nd,El,KPer);
end

%% Solve F=K.U for Polynomial
% it gives all the outputs while all the rows, columns and elements
% associated with constraints and zeros rows and columns in stiffness
% matrices are deleted.
[Kff,Kff_der,u0,trackM] = SFKUPB (Nd,El,Mem,Rst,CLd,G_e,Kg,KgPer);

% Matrices of the polynomial coefficients
a = zeros (length(El(:,1)),length(Kff(:,1)));
b = a; c = b; d = c; e = d; f = e;

%% Loops to find the polynomila coefficinets
for i = 1:length(El(:,1))                                   % [i] loop pver elements (RVs)
    if El(i,6) == 1                                         % bar element
        trialN = 2+length(Mem(:,1))*2;                      % number of the trial equations to be sloved
    else                                                    % Bernoulli or Timoshenko element
        trialN = 6+length(Mem(:,1))*3;
    end
    
    Us = zeros(length(Kff(1,:)),trialN);                    % answers to trial equations
    for k = 1:trialN                                        % [k] loop pver trials
        Us(:,k) = linsolve(Kff+Kff_der(:,:,i)*RV(k,i),-RV(k,i)*Kff_der(:,:,i)*u0);
                                                            % answers to trial equations
    end
    
%% Loop to calculate different components of the polynomial coefficients
clear GovernM MoKnowns
    for j = 1:length(Kff(:,1))                              % [j] loop over components
        if El(i,6) == 1                                     % bae element
            for k = 1:trialN
                GovernM (k,:) = [RV(k,i) -RV(k,i)*Us(j,k)]; % governing matrix
                MoKnowns(k,:) = Us(j,k);                    % matrix of knowns
            end
            XS = GovernM \ MoKnowns;                        % slove the equation for polynomial coefficients
            a(i,j) = XS(1); b(i,j) = XS(2);                 % polynomial coefficients
        else                                                % Bernoulli or Timoshenko element
            for k = 1:trialN
                GovernM (k,:) = [RV(k,i) RV(k,i)^2 RV(k,i)^3 -RV(k,i)*Us(j,k) -RV(k,i)^2*Us(j,k) -RV(k,i)^3*Us(j,k)];
                MoKnowns(k,:) = Us(j,k);
            end
            XS = GovernM \ MoKnowns;
            a(i,j) = XS(1); b(i,j) = XS(2); c(i,j) = XS(3);
            d(i,j) = XS(4); e(i,j) = XS(5); f(i,j) = XS(6);
        end
    end
end

%% Functions of RVs in the form of Polynomial ratios
for i = 1:length(El(:,1))                                   % [i] loop over elements (RVs)
    for j = 1:length(Kff(:,1))                              % [j] loop over components
        if El(i,6) == 1                                     % bar elements
            u.(['func' num2str(i) num2str(j)]) = @ (alpha) (a(i,j)*alpha)/(1+b(i,j)*alpha);
        else                                                % Bernoulli or Timoshenko element
            u.(['func' num2str(i) num2str(j)]) = @ (alpha) (a(i,j)*alpha+b(i,j)*alpha^2+c(i,j)*alpha^3)/(1+d(i,j)*alpha+e(i,j)*alpha^2+f(i,j)*alpha^3);
        end
    end
end

%% MCS - Generating samples using polynomial ratios
U  = zeros(NS,length(Kff(:,1)));
for l = 1:NS                                                % [l] loop over samples
    for j = 1 : length(Kff(:,1))                            % [j] loop over components
        U(l,j) = u0(j);                                     % equals to the deterministic value (mean value)
        for i = 1 : length(El(:,1))                         % loop over elements (RVs)
            U(l,j) = U(l,j)+u.(['func' num2str(i) num2str(j)])(RV(l,i)); 
                                                            % adds up the values associated with each RV
        end
    end
end

%% Relocate the displacmenets of active nodes
Uf = zeros(NS,length(trackM(:,1)));         % to be later the vector of all the nodal displacements for active nodes
count = 0;                                  % to keep track of the elements added to the vector of Uf from UfSolve
for i = 1 : length(trackM(:,1))             % goes over the position of all the active nodes displacements
    if trackM(i,1) == 1                     % if the row corresponding to the node was not consisting of all zero elements in Kgff
        Uf(:,i) = U(:,1+count);             % puts the displacement of that node in its right position in the vector of active nodes displacements
        count = count+1;                    % counts the number of nodes with the row corresponding to it in Kgff not consisting of all zero elements
    end
end

%% Adding the zero displacmenets of constrainted nodes
clear U
U = Uf;
Rst (:,4) = (Rst (:,1)-1)*3 + Rst(:,2);                     % local coord. to global coord.
for i = 1 : length(Rst(:,1))                                % goes over all the constrainted nodes
	clear Utemp                                             % to be cleard at each iteration
    Utemp = U(:,Rst(i,4):length(U(1,:)));                   % copies whatever displacement that is at and after the position of the ith constrainted node
    U(:,Rst(i,4)) = 0;                                      % sets that constrainted node equal to zero
    U(:,Rst(i,4)+1:length(Utemp(1,:))+Rst(i,4))=Utemp;      % relocates all the copied displacments in Utemp right after the ith constrainted node
end
UNds = U(:,1 : 3*max(max(Mem(:,2:3))));
UNds = UNds';


%% Probabilistic characteristics
UNds_MEAN = mean(UNds,2);                   % mean values of the nodal displacements
UNds_COV = cov(UNds');                      % covariance of the nodal displacements
UNds_STD = sqrt(diag(UNds_COV));            % standard deviation of the nodal displacements

%% Plotting
clear u x
for i = 1:length(UNds(:,1))  
    [u(:,i),x(:,i)] = ksdensity (UNds(i,:));  
    if sum(abs(UNds(i,:))) == 0             % if the value is deterministically equal to zero
       x(:,i) = 0; 
    end
    subplot(floor(length(UNds(:,1))/3),3,i)
    plot(x(:,i),u(:,i),'color','m')
    if sum(abs(UNds(i,:))) ~= 0             % if the value is deterministically equal to zero
        text(UNds_MEAN(i)+UNds_STD(i),0.9*max(u(:,i)),['MEAN = ' num2str(UNds_MEAN(i))])
        text(UNds_MEAN(i)+UNds_STD(i),0.8*max(u(:,i)),['STD = ' num2str(UNds_STD(i))])
        grid on
    else
        text(0.1,0.35,'Deterministic value = 0')
    end
    if i == 2
        title('Probability distribution of the nodal displacements')
    end
    if mod(i,3) == 1
        ylabel('pdf')
    end
    xlabel(['u_{nd' num2str(ceil(i/3)) ',dir' num2str(min(3,mod(i+2,3)+1)) '}'])
end
end