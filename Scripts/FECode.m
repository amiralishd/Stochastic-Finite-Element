% ############    Main file    ##############
%% Reading Input
tic
clc, clear all, close all;

%% INPUT
% -------- Analyst must select the input file here. --------

Inp = Input15;

    Par = Inp.Par;   Mat =  Inp.Mat;  Sec = Inp.Sec;
    SecF = Inp.SecF; Nd = Inp.Nd;    Rst = Inp.Rst;
    Mem = Inp.Mem;   CLd = Inp.CLd;  DLd = Inp.DLd;  
    Corr = Inp.Corr;

%% AUTO_MESHING
[Nd,El,Sec,Mem] = Automesh(Par,Mat,Nd,Mem,Sec);

%% ANALYSIS
if Par(2) == 1
    [UNds,Fs] = Deterministic (Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst);
elseif Par(2) == 21
    [UNds,Fs,UNds_MEAN,Fs_MEAN,UNds_COV,Fs_COV,UNds_STD,Fs_STD] = MCS (Par,Corr,Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst);
elseif Par(2) == 22
    [UNds_MEAN,UNds_COV,UNds_STD] = Perturbation (Par,Corr,Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst);
elseif Par(2) == 232
    [UNds,UNds_MEAN,UNds_COV,UNds_STD] = PolynomialB (Par,Corr,Mat,Sec,SecF,Nd,El,Mem,CLd,DLd,Rst); 
end
toc