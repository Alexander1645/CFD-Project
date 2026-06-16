function [yK2, dTad, r] = chemistry(xKN)
% CHEMISTRY  Product yields and adiabatic flame-temperature rise for a
% KNO3/sugar (KNSu) composition, as a function of KNO3 mass fraction xKN.
%
% Outputs:
%   yK2  - kg K2CO3 produced per kg propellant (smoke-forming solid)  = 0.683*xKN
%   dTad - adiabatic temperature rise of a fully-burned cell [K]
%   r    - mol KNO3 per mol sucrose (reference)
%
% Flame-temperature model (this is the refined, peaked version):
%   1. Work out the combustion products for the ratio by ordered atom
%      allocation:  all K -> K2CO3, all N -> N2, then oxygen is shared between
%      H2O and carbon (CO2/CO), with the leftovers handled by branch:
%        - fuel-rich  (O deficit): some H2 and solid carbon (soot) form;
%        - oxidiser-rich (O excess): all carbon -> CO2, surplus O -> O2.
%   2. Heat of reaction Hr = sum Hf(products) - sum Hf(reactants).
%   3. Raw rise = -Hr / (sum n_i*Cp_i)  (product heat capacities).
%   4. Anchor so that xKN = 0.65 gives dTad = 1300 K (Tad ~ 1600 K, the
%      measured KNSu value), then CAP at a dissociation limit (Tad <= ~1720 K).
%
% This reproduces the real behaviour: flame T rises with KNO3, peaks near the
% stoichiometric ratio (xKN ~ 0.74), and falls for oxidiser-rich mixes.
% NOTE: it is a transparent closure, not a full chemical-equilibrium solve;
% the CO/CO2/H2 split and the oxidiser-rich tail are approximate. The 65/35
% anchor and ~1720 K cap come from the literature (Nakka; Olde 2018 TU Delft).
% See docs/references.md and docs/design-decisions.md.

M_KNO3=101.103; M_suc=342.297; M_K2CO3=138.205;
nKN = xKN/M_KNO3;  nsuc = (1-xKN)/M_suc;  r = nKN/nsuc;

% --- K2CO3 yield (mass fraction) -----------------------------------------
yK2 = (nKN/2.0) * M_K2CO3;             % = 0.683*xKN  (44 wt% at xKN=0.65)

% --- combustion products per mol sucrose ---------------------------------
nK2CO3=r/2; nN2=r/2;
C1 = 12 - r/2;          % carbon left after K2CO3
O1 = 11 + 1.5*r;        % oxygen left after K2CO3
nCO2=0; nCO=0; nH2O=0; nH2=0; nO2=0; nC=0;
if O1 >= 11             % enough O for all H2O
    nH2O = 11;  Orem = O1 - 11;
    a = Orem - C1;
    if a >= C1          % excess O -> all CO2 + surplus O2
        nCO2 = C1;  nO2 = (Orem - 2*C1)/2;
    elseif a >= 0       % CO2/CO mix
        nCO2 = a;   nCO = C1 - a;
    else                % O deficit for carbon -> CO + soot
        nCO = max(Orem,0);  nC = C1 - nCO;
    end
else                    % fuel-rich: not enough O for all H2O
    if O1 >= C1
        nCO = C1;  OH = O1 - C1;  nH2O = OH;  nH2 = 11 - OH;
    else
        nCO = O1;  nC = C1 - O1;  nH2O = 0;  nH2 = 11;
    end
end

% --- heats of formation [kJ/mol] and high-T heat capacities [J/mol/K] ----
Hf_suc=-2225.0; Hf_KNO3=-494.6;
Hf  = [-1151.0, -393.5, -110.5, -241.8, 0, 0, 0];   % K2CO3 CO2 CO H2O H2 N2 O2(+C=0)
Cp  = [ 160.0,    57.0,   33.0,   45.0, 31, 33, 36];
n   = [nK2CO3,  nCO2,  nCO,  nH2O, nH2, nN2, nO2];
Hr  = sum(n.*Hf) + nC*0.0 - (Hf_suc + r*Hf_KNO3);   % kJ/mol sucrose
nCp = sum(n.*Cp) + nC*25.0;                          % include soot Cp
dTad_raw = -Hr*1000.0/nCp;                           % K

% --- anchor to literature (xKN=0.65 -> 1300 K) and cap for dissociation --
persistent raw65
if isempty(raw65)
    % raw value at the anchor ratio, computed once
    raw65 = local_raw(0.65, M_KNO3, M_suc, Hf_suc, Hf_KNO3, Hf, Cp);
end
dTad = dTad_raw * (1300.0/raw65);
dTad = min(dTad, 1450.0);             % dissociation cap (Tad <= ~1748 K)
end

% ----- helper: raw adiabatic rise at a given xKN (no anchor/cap) ----------
function raw = local_raw(xKN, M_KNO3, M_suc, Hf_suc, Hf_KNO3, Hf, Cp)
nKN=xKN/M_KNO3; nsuc=(1-xKN)/M_suc; r=nKN/nsuc;
nK2CO3=r/2; nN2=r/2; C1=12-r/2; O1=11+1.5*r;
nCO2=0; nCO=0; nH2O=0; nH2=0; nO2=0; nC=0;
if O1>=11
    nH2O=11; Orem=O1-11; a=Orem-C1;
    if a>=C1, nCO2=C1; nO2=(Orem-2*C1)/2;
    elseif a>=0, nCO2=a; nCO=C1-a;
    else, nCO=max(Orem,0); nC=C1-nCO; end
else
    if O1>=C1, nCO=C1; OH=O1-C1; nH2O=OH; nH2=11-OH;
    else, nCO=O1; nC=C1-O1; nH2=11; end
end
n=[nK2CO3,nCO2,nCO,nH2O,nH2,nN2,nO2];
Hr=sum(n.*Hf)-(Hf_suc+r*Hf_KNO3);
nCp=sum(n.*Cp)+nC*25.0;
raw=-Hr*1000.0/nCp;
end
