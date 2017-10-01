function [Nd,El,Sec,Mem] = Automesh(Par,Mat,Nd,Mem,Sec)

% This function gets the required data and gives the:
% 1) the completely calculated cross section matrix,
% 2) the new nodes and their coordinates,
% 3) and the new set of elements

%% Section Properties

Sec1 = Sec;                             %create a copy to work with and at the end overwrite
for i = 1 : length(Sec(:,1))            % goes over the cross sections in the library
    if Sec(i,2) == 1                    % RECTANGLE
        b = Sec(i,3); h = Sec(i,4);     % reads width and height
        A = b*h;    Sec1(i,3) = A;         % area
        I = 1/12*b*h^3; Sec1(i,4) = I;  % moment of Inertia
        As = b*h*5/6; Sec1(i,5) = As;   % shear area
    elseif  Sec(i,2) == 2               % CIRCLE
        r = Sec(i,3)/2;                 % reads the radius
        A = pi*r^2; Sec1(i,3) = A;      % area
        I = pi/4*r^4; Sec1(i,4) = I;    % moment of inertia
        As = 0.9*pi*r^2; Sec1(i,5) = As;% shear area
    end
end
clear Sec; Sec= Sec1;                   %overwrite

%% Creating New Nodes

NdnoUp = length(Nd(:,1));       % number of primary nodes (gets updated during the iterations)
NdnoFx = NdnoUp;                % number of the primary nodes (fixed during the iterations)
Meno = length(Mem(:,1));        % number of the members (fixed during the iterations)
MenoUp = 0;                     % number of the members (gets updated during the iterations)
El = [];                        % new element matrix to be created

% maximum length of the element
overall = 0;        % set the sum of the lengths of the members equal to zero
for i = 1 : Meno    % goes over all the members   
    nstart = min(Mem(i,2),Mem(i,3));    nend = max(Mem(i,2),Mem(i,3));
    Mem(i,2) = nstart;  Mem(i,3) = nend;
    xi = Nd(Mem(i,2),2); xii = Nd(Mem(i,3),2);
    yi = Nd(Mem(i,2),3); yii = Nd(Mem(i,3),3);
    ell = sqrt((yii-yi)^2+(xii-xi)^2);      % calculates the length of the member
    Mem(i,13) = ell;                        % stores the length of the element for later
    overall = overall + ell;                % cumulatively adds them up
end
elmax = Par(1);                             % maximum length of an element

% Plotting the primary nodes and members
subplot(1,2,1)
% members
for i = 1 : Meno
    if Mem(i,6) == 1
        plot([Nd(Mem(i,2),2),Nd(Mem(i,3),2)],[Nd(Mem(i,2),3),Nd(Mem(i,3),3)],'color','g');
    else
        plot([Nd(Mem(i,2),2),Nd(Mem(i,3),2)],[Nd(Mem(i,2),3),Nd(Mem(i,3),3)],'color','r');
    end
    text(0.5*(Nd(Mem(i,2),2)+Nd(Mem(i,3),2)),0.5*(Nd(Mem(i,2),3)+Nd(Mem(i,3),3)),num2str(Mem(i,1)),'fontweight','bold','backgroundcolor','w','edgecolor','k')
    title('Initial model','fontweight','normal')
    hold on
end
% nodes
scatter(Nd(:,2),Nd(:,3),'filled','b')
% node labels
text(elmax*.4/length(Nd(:,1))+Nd(:,2),elmax*.4/length(Nd(:,1))+Nd(:,3),num2str(Nd(:,1)))
hold on

% creating new nodes
for i = 1 : Meno        % goes over all the members
    xi = Nd(Mem(i,2),2); xii = Nd(Mem(i,3),2);
    yi = Nd(Mem(i,2),3); yii = Nd(Mem(i,3),3);
    ell = sqrt((yii-yi)^2+(xii-xi)^2);  % calculates the member length
    j=1;
    if ell >= elmax                     % checks the member to be larger than than the maximum element length
        nex = ceil(ell/elmax);         %  number of new nodes to be inserted in the member i
        nel = ell / nex;                % length of the elements in memeber i 
        for j = 1 : nex-1               % goes over each of the new nodes j
            Nd(NdnoUp+j,1) = NdnoUp+j;  % gives a number to the new node j in member i (golablly Ndno + j)
            Nd(NdnoUp+j,2) = xi + (xii-xi)*j*(nel/ell);   % x-coord of the node by linear interpolation
            Nd(NdnoUp+j,3) = yi + (yii-yi)*j*(nel/ell);   % y-coord of the node by linear interpolation
        end
    end
    NdnoUp = length(Nd(:,1));           % updates the number of existing nodes (primary + new ones so far)
end

%% Creating New Elements

for i = 1 : Meno      % goes over the members
    xi = Nd(Mem(i,2),2); xii = Nd(Mem(i,3),2);
    yi = Nd(Mem(i,2),3); yii = Nd(Mem(i,3),3);
    ell = sqrt((yii-yi)^2+(xii-xi)^2);  % calculates the member length
    j = 1;
    if ceil(ell/elmax)  >= 2           % checks the member to be larger than than the maximum element length
        nex = ceil(ell/elmax);         % number of new nodes to be inserted in the member i
        for j = 1 : nex        % goes over all the elements that are to be created in the member i
                El(MenoUp+j,1) = MenoUp+j;      % assigns a number to the element
                El(MenoUp+j,4:12) = Mem(i,4:12);% copies all the member properties to the element in it
                El(MenoUp+j,13) = Mem(i,1);     % assigns the mother member number to the element just in case
                if j == 1                               % the first element of each member  
                El(MenoUp+j,2) = Mem(i,2);                  % start node is a primary node (already existing)
                El(MenoUp+j,3) = MenoUp+j-i+NdnoFx+1;       % end node is a new one
                elseif j>=2 && j<= nex-1                % any element but the two at the two ends
                El(MenoUp+j,2) = MenoUp+j-i+NdnoFx;         % new start node
                El(MenoUp+j,3) = MenoUp+j-i+NdnoFx+1;       % new end node (= start node + 1)
                elseif j == nex                         % the last element in the member
                El(MenoUp+j,2) = MenoUp+j-i+NdnoFx;         % new start node
                El(MenoUp+j,3) = Mem(i,3);                  % end node is a primary node (already existing)
                end                    
        end
    else        % if the member size is smaller than the maximum element size
        El(MenoUp+j,1) = MenoUp+j;      % assigns a number to the element
        El(MenoUp+j,2:12) = Mem(i,2:12);% copies all the member properties to the element in it
        El(MenoUp+j,13) = Mem(i,1);     % assigns the mother member number to the element just in case
    end
    MenoUp = length(El(:,1));       % updates the number of created elements so far
end

for i = 1:length(El(:,1))
   El(i,14) = Mat(El(i,4),2); 
end

% Plotting the primary+new nodes and elements
subplot(1,2,2)
% elements
for i = 1 : MenoUp      % goes over all the elements
    if El(i,6) == 1
        plot([Nd(El(i,2),2),Nd(El(i,3),2)],[Nd(El(i,2),3),Nd(El(i,3),3)],'color','g');
    else
        plot([Nd(El(i,2),2),Nd(El(i,3),2)],[Nd(El(i,2),3),Nd(El(i,3),3)],'color','r');
    end
    title('Discretized model','fontweight','normal')
    hold on
end
% nodes (new and primary)
scatter(Nd(:,2),Nd(:,3),'filled','b')
% node lables
text(elmax*.32/length(Nd(:,1))+Nd(:,2),elmax*.32/length(Nd(:,1))+Nd(:,3),num2str(Nd(:,1)))
end