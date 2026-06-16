function [] = viscosity()
% Purpose: To calculate the viscosity in the fluid as a function of temperature.

% constants
global NPI NPJ Cmu SMALL
% variables
global rho k mu mut mueff eps

% LAMINAR run: turbulent viscosity is switched off (mut = 0), so the
% effective viscosity is just the molecular value. Turbulence (k-eps) can be
% re-enabled later by restoring the eddy-viscosity line below.
% See docs/design-decisions.md (laminar choice).
for I = 1:NPI+1
    for J = 2: NPJ+2
        mut(I,J)    = 0.;                 % laminar: no eddy viscosity
        % mut(I,J)  = rho(I,J)*Cmu*k(I,J)^2 /(eps(I,J)+SMALL);  % turbulent
        mueff(I,J)  = mu(I,J) + mut(I,J);
    end
end
end