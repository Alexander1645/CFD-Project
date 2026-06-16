function [] = bound()
% Purpose: Boundary conditions for the closed smoke-grenade box (v1).
%
% Geometry (v1): a sealed rectangular box, no-slip on all four walls and
% NO vent flow yet (the pressure-driven vent + gasification mass source is
% the planned v2 extension -- see docs/design-decisions.md). With no flow
% driver the velocity field stays ~0; the model resolves the temperature
% distribution and K2CO3 field, which answer research questions 1 and 2.
%
% Thermal BCs:
%   - right (east) wall : adiabatic / no heat transfer  (Neumann, zero grad)
%   - left, top, bottom : held at ambient TAMB (heat-sink walls; placeholder
%                         for the prescribed convective flux of the problem
%                         description).
% Species BCs: zero flux (zero gradient) through all walls.

% constants
global NPI NPJ TAMB TIGN
% variables
global u v T Yfu YK2

% --- No-slip on all four walls (closed box) ---------------------------
u(2,1:NPJ+2)     = 0.;   % west wall (no inlet)
u(NPI+2,1:NPJ+2) = 0.;   % east wall
v(1:NPI+2,2)     = 0.;   % bottom wall
v(1:NPI+2,NPJ+2) = 0.;   % top wall

% --- Temperature BCs --------------------------------------------------
% East, bottom, top walls: adiabatic -> zero normal gradient.
% (Right/east wall = the "no heat transfer" wall of the problem statement;
%  bottom/top adiabatic in v1 is a stand-i