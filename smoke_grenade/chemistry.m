function [yK2, dTad, r, f_gas, n_gas] = chemistry(xKN)
% CHEMISTRY  Product yields and adiabatic flame-temperature rise for a
% KNO3/sugar (KNSu) composition, as a function of KNO3 mass fraction xKN.
%
% Outputs:
%   yK2   - kg K2CO3 produced per kg propellant (smoke-forming solid) = 0.683*xKN
%   dTad  - adiabatic temperature rise of a fully-burned cell [K] (COMPUTED;
%           no longer anchored to a literature value)
%   r     - mol KNO3 per mol sucrose (reference)
%   f_gas - GAS mass produced per kg propellant [-] (CO2/CO/H2O/H2/N2/O2);
%           the rest (K2CO3 + soot) is condensed. Drives venting/pressure.
%   n_gas - moles of gaseous product per kg propellant [mol/kg] (for the
%           ideal-gas chamber-pressure update)
%
% Flame-temperature model (this is the refined, peaked version):
%   1. Work out the combustion products for the ratio by ordered atom
%      allocation:  all K -> K2CO3, all N -> N2, then oxygen is shared between
%      H2O and carbon (CO2/CO), with the leftovers handled by branch:
%        - fuel-rich  (O deficit): some H2 and solid carbon (soot) form;
%        - oxidiser-rich (O excess): all carbon -> CO2, surplus O -> O2.
%   2. Heat of reaction Hr = sum Hf(products) - sum Hf(reactants).
%   3. Adiabatic rise dTad = -Hr / (sum n_i*Cp_i)  (product heat capacities).
%      This is now used DIRECTLY - the previous anchor to 1300 K at xKN=0.65
%      and the dissociation cap have been removed, so the flame temperature is
%      genuinely computed from the energetics (e.g. ~1779 K at 65/35).
%
% This reproduces the real behaviour: flame T rises with KNO3, peaks near the
% stoichiometric ratio (xKN ~ 0.74), and falls for oxidiser-rich mixes.
% NOTE: it is a transparent closure, not a full chemical-equilibrium solve; the
% CO/CO2/H2 split and the oxidiser-rich tail are approximate, and dissociation
% is not modelled (so near-stoichiometric Tad is an upper bound). See
% docs/references.md and docs/design-decisions.md.

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

% --- flame temperature: COMPUTED (no longer anchored to 1300 K) ----------
% dTad is the adiabatic temperature rise straight from the enthalpy balance
% above (Hr / sum n_i*Cp_i). NOTE: chemical dissociation is NOT modelled, so
% near-stoichiometric mixes (xKN ~ 0.74) are over-predicted relative to a real
% flame; the TREND (rise with KNO3, peak near stoichiometric, fall when
% oxidiser-rich) is physical. See docs/design-decisions.md.
dTad = dTad_raw;

% --- gaseous-product yield from the balanced equation --------------------
% Split the products into GAS (vents -> drives pressure) and CONDENSED
% (K2CO3 + soot, which stay behind as smoke/residue). These let the 2-D burn
% generate gas directly from the chemistry (used in pccoeff and the chamber
% pressure), replacing the old empirical burn-rate law.
M_gas  = [44.009, 28.010, 18.015, 2.016, 28.013, 31.998];  % CO2 CO H2O H2 N2 O2 [g/mol]
n_gasv = [nCO2,   nCO,    nH2O,   nH2,   nN2,    nO2];      % moles per mol sucrose
mass_prop = M_suc + r*M_KNO3;            % g propellant per mol sucrose
gas_mass  = sum(n_gasv .* M_gas);        % g gaseous products per mol sucrose
f_gas = gas_mass / mass_prop;            % gas mass fraction of the charge [-]
n_gas = sum(n_gasv) / (mass_prop/1000.); % mol gas per kg propellant [mol/kg]
end
