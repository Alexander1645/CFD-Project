function [] = density()
% DENSITY  Update gas density from the ideal gas law (variable-density / low-Mach).
% Mirrors the supplied wc3/convdiff03.m density routine:
%     rho = (1-relax_rho)*rho + relax_rho*(p + P_ATM)/(R_GAS*T)
% Under-relaxation (relax_rho) is used because the density<->pressure<->velocity
% coupling is stiff, especially with the fast temperature change from combustion.
% Heating lowers rho -> the gas expands -> it is pushed out of the vent (this is
% the physical mechanism that replaces the old constant-density mass-source hack).

% constants
global NPI NPJ relax_rho R_GAS SMALL P_ATM
% variables
global rho p T

% Ideal-gas density at ~atmospheric (low-Mach). The chamber-pressure buildup is
% modelled separately (0-D) in run_grenade and would only feed back here if the
% venting could be resolved in the 2-D flow, which it can't cheaply.
for I = 1:NPI+2
    for J = 2:NPJ+1
        if I == 1                 % p(1,J) doesn't exist; use the neighbour
            pcell = p(2,J);
        else
            pcell = p(I,J);
        end
        rho(I,J) = (1-relax_rho)*rho(I,J) ...
                 + relax_rho*(pcell + P_ATM)/(R_GAS*max(T(I,J),SMALL));
    end
end
end
