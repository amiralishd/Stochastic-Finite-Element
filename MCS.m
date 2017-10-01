function [UNds,Fs,UNds_MEAN,Fs_MEAN,UNds_COV,Fs_COV,UNds_STD,Fs_STD] = MCS (Par,Corr,Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst)
% This function runs Monte Carlo simulation on the finite element model and
% gives the distribution of the reaction forces and nodal displacements
% along with their mean values and covariances as the output.

NS = Par(3);                                    % number of samples
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

%% Mean values of the fluctuations
MU(1:length(El(:,1))) = 0;

%% Generated samples
E_MCS = mvnrnd(MU,COV_Inp,NS);                  % generating the input samples

%% Iterations
for i = 1:NS
    
    % Adding the fluctuations in the Young's modulus to the corresponding mean values
    El_MCS = El;
    El_MCS(:,14) = El(:,14) + E_MCS(i,:)';

    % Creating Element Matrix
    Ke = Kelement(Mat,Sec,SecF,Nd,El_MCS,Mem);

    % Assembling Global Matrix
    Kg = Kglobal(Nd,El_MCS,Ke);
    [Kg,CLd] = DummyS(Kg,CLd,Mem);

    % Equivalent Nodal Load
    G_e = EqNdLd(DLd,El_MCS,Nd);

    % Solve F=K.U
    [UNds(:,i),Fs(:,i)] = SolveFKU (Nd,El_MCS,Mem,Rst,CLd,G_e,Kg);   

end

%% Probabilistic characteristics
UNds_MEAN = mean(UNds,2);                   % mean values of the nodal displacements
UNds_COV = cov(UNds');                      % covariance of the nodal displacements
UNds_STD = sqrt(diag(UNds_COV));            % standard deviation of the nodal displacements
Fs_MEAN = mean(Fs,2);                       % mean values of the reaction forces
Fs_COV = cov(Fs');                          % covariance of the reaction forces
Fs_STD = sqrt(diag(Fs_COV));                % standard deviation of the nodal displacements
   
%% Plotting
figure                                      % Displacements
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

figure                                      % reaction forces
for i = 1:length(Fs(:,1))
    [f(:,i),y(:,i)] = ksdensity (Fs(i,:)); 
    if sum(abs(Fs(i,:))) == 0               % if the value is deterministically equal to zero
       y(:,i) = 0; 
    end
    subplot(floor(length(Fs(:,1))/3),3,i)
    plot(y(:,i),f(:,i),'color','m')
    if sum(abs(Fs(i,:))) ~= 0             % if the value is deterministically equal to zero
        text(Fs_MEAN(i)+Fs_STD(i),0.9*max(f(:,i)),['MEAN = ' num2str(Fs_MEAN(i))])
        text(Fs_MEAN(i)+Fs_STD(i),0.8*max(f(:,i)),['STD = ' num2str(Fs_STD(i))])
        grid on
    else
        text(0.1,0.35,'Deterministic value = 0')
    end
    if i == 2
        title('Probability distribution of the reaction forces')
    end
    ylabel('pdf')
    xlabel(['F_{s nd' num2str(Rst(i,1)) ',dir' num2str(Rst(i,2)) '}'])
end
end