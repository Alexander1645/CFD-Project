function [] = reaction()
% REACTION  Temperature-driven (Arrhenius) burn-rate coefficient for the
% premixed KNO3/sugar charge.
%
% Computes, per cell, the first-order rate coefficient
%       Rk(I,J) = A_arr * exp( -Ea_arr / (Ru*T) )            [1/s]
% so that the local fuel consumption rate (a sink in the fuel equation and a
% source of heat + K2CO3) is
%       omega = Rk * rho * Yfu                                [kg/m3/s].
%
% The exponential makes the reaction negligible at ambient temperature and
% self-accelerating once an igniter kernel raises T -- giving the slow-start,
% then-fast burn requested in the design (see docs/design-decisions.md).
%
% Rk is stored as a global and used in Yfucoeff (sink), Tcoeff (heat source)
% and YK2coeff (K2CO3 source).

% constants
global NPI NPJ A_arr Ea_arr Ru SMALL Dt
% variables
global T Rk Yfu

% Cap on the rate coefficient: a single time step may not burn more than a
% fraction (~0.5) of the local fuel. This keeps the explicit heat source in
% Tcoeff bounded (max temperature rise ~0.5*dTad per step) so the burn climbs
% to the adiabatic flame temperature over a few steps instead of overshooting.
RKMAX = 0.5/Dt;

for I = 1:NPI+2
    for J = 1:NPJ+2
        % only where unburnt fuel remains
        if Yfu(I,J) > SMALL
            Rk(I,J) = A_arr * exp( -Ea_arr / (Ru*max(T(I,J),SMALL)) );
            if Rk(I,J) > RKMAX
                Rk(I,J) = RKMAX;
            end
        else
            Rk(I,J) = 0.;
        end
    end
end
end
