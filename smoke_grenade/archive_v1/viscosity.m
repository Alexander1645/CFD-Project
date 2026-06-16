function [] = viscosity()
% Purpose: To calculate the viscosity in the fluid as a function of temperature.

% constants
global NPI NPJ Cmu SMALL
% variables
global rho k mu mut mueff eps

% LAMINAR run: turbulent viscosity is switched off (mut = 0), so the
% effective viscosity is just the molecular value. Turbulence (k-eps) can be
% re-enabled l