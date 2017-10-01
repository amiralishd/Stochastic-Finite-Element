function [UNds_MEAN,UNds_COV,UNds_STD] = Perturbation (Par,Corr,Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst)
% This function runs the perturbation approach to asses the probabilistic
% characteristics of the response of the finite element model

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

%% Creating Element Matrix
Ke = Kelement(Mat,Sec,SecF,Nd,El,Mem);

%% Matrices of derivatives for each element
Kder = zeros(length(Ke(:,1)),length(Ke(:,1)),length(El(:,1)));
for i = 1 : length(El(:,1))
    Kder(:,:,i) = Ke(:,:,i) ./ Mat(El(i,4),2);
end

%% Assembling Global Matrix
Kg = Kglobal(Nd,El,Ke);

%% Dummy stiffness
[Kg,CLd] = DummyS(Kg,CLd,Mem);

%% Equivalent Nodal Load
G_e = EqNdLd(DLd,El,Nd);

%% Global matrices of derivatives for different random variables
KgPer = zeros(length(Kg(:,1)),length(Kg(:,1)),length(El(:,1)));
for i = 1 : length(El(:,1))
    KPer = Ke-Ke;
    KPer(:,:,i) = Kder(:,:,i);
    KgPer(:,:,i) = Kglobal(Nd,El,KPer);
end

%% Solve F=K.U for Perturbation method
[UNds,UNdsPer] = SFKUP (Nd,El,Mem,Rst,CLd,G_e,Kg,KgPer);

%% Covariance matrix of the output 
COV_Per = zeros(length(UNds(:,1)),length(UNds(:,1)));
for i  = 1 : length(El(:,1))
    for j = 1 : length(El(:,1))
        COV_Per = UNdsPer(:,i)*UNdsPer(:,j)'*COV_Inp(i,j)+COV_Per;
    end
end

%% Probabilistic characteristics
UNds_MEAN = UNds;                               % mean values of the nodal displacements
UNds_COV = COV_Per;                             % covariance of the nodal displacements
UNds_STD = sqrt(diag(UNds_COV));                % standard deviation of the nodal displacements

end