function [] = reaction()
% REACTION  Rate-anchored Heaviside (ignition-temperature) burn model for the
% KNO3/sugar charge. This REPLACES the temperature-driven Arrhenius rate.
%
% The burn is a regressing FRONT, not a volumetric reaction:
%   - a cell is LIT (latched) the first time it reaches the ignition temperature
%     T_ign (the igniter kernel), OR once the front has reached it - i.e. a
%     face-neighbour is already substantially burnt;
%   - once lit, the cell is consumed at the MEASURED regression rate
%       r = a_burn * (P_chamber[MPa])^n_burn        (Saint-Robert / Vieille law),
%     so the front sweeps through a cell of width dx in dx/r seconds.
%
% Output (global): wburn(I,J) = local fractional consumption rate of the charge
%   [1/s]  (fraction of the cell's solid converted to products per second).
%   It drives the heat source (Tcoeff), the K2CO3 source (YK2coeff), the gas
%   source (pccoeff / bound) and the explicit Yfu update in run_grenade.
%
% WHY THIS FORM: the real KNSu burn rate is set by the gas-phase flame feeding
% heat back to the surface, which a bulk-conduction model cannot reproduce (its
% front speed is a grid artefact ~ alpha/dx and has no pressure dependence). By
% imposing r = a*P^n we get the real, MESH-INDEPENDENT, pressure-dependent burn
% rate and keep the burn-rate<->chamber-pressure coupling. Solid conduction
% (Tcoeff / Gamma) still shapes the thermal field; it no longer sets the speed.

% constants
global NPI NPJ Dt XMAX SMALL a_burn n_burn P_chamber P_ATM T_ign
% variables
global T Yfu wburn

dx     = XMAX/NPI;
r_burn = a_burn*(max(P_chamber,P_ATM)/1.0e6)^n_burn / 1000.;   % regression rate [m/s]
Rreg   = r_burn/dx;                                            % cell-sweep rate [1/s]

for I = 2:NPI+1
    for J = 2:NPJ+1
        % A cell lights when a face-neighbour is (almost) fully consumed, so the
        % burnt region advances one cell-layer per cell burn-time dx/r -> the
        % front speed is the regression rate r (using a higher threshold would
        % overlap burning cells and speed the front up by ~1/(1-thr)). THR is the
        % only knob on front sharpness; THR->0 gives exactly r.
        THR = 0.05;
        lit = (Yfu(I,J) < 0.999);          % already burning (latched: Yfu only falls)
        if ~lit
            nb = min([Yfu(I-1,J), Yfu(I+1,J), Yfu(I,J-1), Yfu(I,J+1)]);
            if (nb < THR) || (T(I,J) >= T_ign)     % front arrived, or igniter
                lit = true;
            end
        end
        if lit && Yfu(I,J) > SMALL
            wburn(I,J) = min(Rreg, Yfu(I,J)/Dt);   % cap so Yfu cannot go negative
        else
            wburn(I,J) = 0.;
        end
    end
end
end
