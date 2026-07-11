function [] = density()
% Purpose: update the gas density from the ideal-gas law.           NEW FILE [B]
% Taken from the supplied wc3/convdiff03.m, lines 71-83 (the course's own
% variable-density machinery), with two adaptations:
%   - loop runs only over the GAS region + ghost/inlet column (I <= Ifr);
%     deeper solid keeps its initial value (it is excluded from the flow).
%   - R_GAS is the product-gas constant computed in grenade06.m from the
%     chemistry (mean molar mass), instead of hard-coded 287.
%
%     rho = (1-relax_rho)*rho + relax_rho*(p + P_ATM)/(R_GAS*T)
%
% Called INSIDE the outer SIMPLE loop (wc3's placement): as p and T evolve
% during the iterations, rho follows, and the (rho_old-rho)/Dt accumulation
% term in pccoeff.m converges together with the flow. This coupling is what
% anchors the ABSOLUTE pressure level to the gas mass in the cavity
% (design doc sec. 5).

% constants
global NPI NPJ relax_rho R_GAS P_ATM SMALL
% variables
global rho p T Ifr

for I = 1:min(Ifr,NPI+2)
    for J = 2:NPJ+1
        rho(I,J) = (1-relax_rho)*rho(I,J) ...
                 + relax_rho*(p(I,J) + P_ATM)/(R_GAS*max(T(I,J),SMALL));
    end
end
end
