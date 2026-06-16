function [yK2, dTad, r] = chemistry(xKN)
% CHEMISTRY  Product yields and adiabatic temperature rise for a KNO3/sugar
% (KNSu) smoke composition, as a function of the KNO3 mass fraction xKN.
%
% Inputs:
%   xKN   - mass fraction of potassium nitrate (KNO3) in the solid charge
%           (sugar/sucrose mass fraction = 1 - xKN).
% Outputs:
%   yK2   - mass of K2CO3 produced per unit mass of propellant [kg/kg]
%           (this is the smoke-forming solid we want to maximise).
%   dTad  - adiabatic temperature rise of a fully-burned cell [K], anchored
%           to the literature flame temperature (see notes below).
%   r     - moles of KNO3 per mole of sucrose (for reference / validation).
%
% Reaction model (ordered allocation, premixed solid):
%   C12H22O11 + r KNO3 -> (r/2) K2CO3 + (r/2) N2 + 11 H2O + a CO2 + b CO
%   All K -> K2CO3, all N -> N2, all H -> H2O; remaining O splits the
%   leftover carbon between CO2 and CO. This reproduces the known
%   ~44 wt% K2CO3 at the 65/35 composition (TU Delft / Nakka), which is the
%   quantity of interest. The CO/CO2 split is approximate (no H2 / KOH).
%
% References (see docs/references.md):
%   [2] Nakka, Propellant Combustion (65/35 equilibrium reaction).
%   [3] Olde 2018 TU Delft / [4] DARE: adiabatic flame temperature ~1600 K,
%       K2CO3 ~44 wt% of products.

% molar masses [g/mol]
M_KNO3 = 101.103;  M_suc = 342.297;  M_K2CO3 = 138.205;

% moles per kg of propellant
nKN  = xKN     / M_KNO3;
nsuc = (1-xKN) / M_suc;
r    = nKN / nsuc;                 % mol KNO3 per mol sucrose

% K2CO3 produced: r/2 mol per mol sucrose. With nKN in mol per gram of
% propellant, (mol/g)*(g/mol) is already a mass fraction (kg/kg):
nK2CO3 = nKN/2.0;                  % mol K2CO3 per gram propellant
yK2    = nK2CO3 * M_K2CO3;         % kg K2CO3 per kg propellant  (= 0.683*xKN)

% Adiabatic temperature rise, anchored to the literature flame temperature.
% KNSu at 65/35 reaches ~1600 K from ~298 K  => dTad ~ 1300 K at xKN=0.65.
% The flame temperature increases with oxidiser content over the fuel-rich
% range studied; we use a mild linear anchoring (capped) rather than the
% crude constant-Cp estimate, which over-predicts at high xKN.
dTad = 1300.0 * (xKN/0.65);
dTad = min(dTad, 1600.0);          % cap (dissociation limits real flame T)
end
