function [UNds,Fs] = Deterministic (Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst)

% Creating Element Matrix
Ke = Kelement(Mat,Sec,SecF,Nd,El,Mem);
 
% Assembling Global Matrix
Kg = Kglobal(Nd,El,Ke);
[Kg,CLd] = DummyS(Kg,CLd,Mem);

% Equivalent Nodal Load
G_e = EqNdLd(DLd,El,Nd);

% Solve F=K.U
[UNds,Fs] = SolveFKU (Nd,El,Mem,Rst,CLd,G_e,Kg);

end