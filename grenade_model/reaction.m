function [] = reaction()
% Purpose: single-step kinetic (Arrhenius) rate for the KNSu reaction
%    48 KNO3 + 5 C12H22O11 -> 24 K2CO3 + 36 CO2 + 55 H2O + 24 N2
% Lecture 6: the slowest timescale determines the reaction rate. The
% flow is laminar, so there is no eddy break-up (micro-mixing) rate and
% the kinetic rate applies:
%    Rfu = AK * rho * mfu * mox * exp(-EA/(R*T))   [kg fuel/(m3 s)]
% The rate saturates at RMAX (finite-rate ceiling) and can never consume
% more than the reactants available in a cell during one time step.
% There is NO forced ignition here: at ambient temperature the
% exponential makes the rate vanish (~1e-16), and the reaction only runs
% where the mixture has been heated (ignition kernel, flame front).

% constants
global NPI NPJ Dt AK EA RUNIV S_ST RMAXF CAPFRAC
% variables
global T rho mfu mox Rfu

Rfu = AK*rho.*mfu.*mox.*exp(-EA./(RUNIV*max(T,250.)));
% finite-rate ceiling PER UNIT MASS (RMAXF [1/s]): the absolute rate must
% scale down with the cell density, otherwise a nearly burnt-out cell
% (small rho) receives the full heat release and its temperature runs away
Rfu = min(Rfu, RMAXF*rho);
cap = CAPFRAC*rho.*min(mfu, mox/S_ST)/Dt;        % availability limiter
Rfu = max(min(Rfu, cap), 0.);

% no reaction in boundary (ghost) cells
Rfu(1,:) = 0.; Rfu(NPI+2,:) = 0.;
Rfu(:,1) = 0.; Rfu(:,NPJ+2) = 0.;
end
