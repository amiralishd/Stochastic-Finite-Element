function Ke = Endrelease(El,Ke)
Kpp = Ke;
Krp = Ke;
Kpr = Ke;
Krr = Ke;
countr = 0;
countp = 0;
for i = 1:6
    if El(6+i) == 0
        Kpp(i-countp,:) = [];
        Kpp(:,i-countp) = [];
        Kpr(i-countp,:) = [];
        Krp(:,i-countp) = [];
        countp = countp + 1;
    else
        Krr(i-countr,:) = [];
        Krr(:,i-countr) = [];
        Kpr(:,i-countr) = [];
        Krp(i-countr,:) = [];
        countr = countr + 1;
    end
end
clear Ke
Ke = Kpp-Kpr*Krr^-1*Krp;
for i = 1:6
    size = length(Ke(:,1));
    if El(6+i) == 0
        Ke(i+1:size+1,:) = Ke(i:size,:);
        Ke(:,i+1:size+1) = Ke(:,i:size);
        Ke(i,:) = 0;
        Ke(:,i) = 0;
    end
end
end