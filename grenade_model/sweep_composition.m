%% Composition sweep: effect of the KNO3/sugar ratio (research questions 1+2)
% Runs the grenade model for several KNO3 mass fractions and summarises
% the K2CO3 (smoke) production and the outlet gas temperature.
% 0.739 is the stoichiometric ratio of
%   48 KNO3 + 5 C12H22O11 -> 24 K2CO3 + 36 CO2 + 55 H2O + 24 N2;
% commercial smoke compositions are fuel-rich (0.60-0.65) to keep the
% flame temperature below the K2CO3 vaporisation limit of 891 C = 1164 K.

clear; close all; clc

xKNlist = [0.60 0.65 0.739 0.80];

for irun = 1:numel(xKNlist)
    xKN        = xKNlist(irun);
    RUNTAG     = sprintf('xKN%03.0f',100*xKN);
    TOTAL_TIME = 0.5;        % [s] increase for full-burn studies
    fprintf('\n######## run %d/%d : xKN = %.3f ########\n',irun,numel(xKNlist),xKN);
    grenade;                 % grenade.m does not clear the workspace
end

% summary table from the saved results
fprintf('\n  x_KN   K2CO3 [g/m]   max T_out [K]   max T [K]\n');
for irun = 1:numel(xKNlist)
    S = load(fullfile('runs',sprintf('xKN%03.0f',100*xKNlist(irun)),'results.mat'));
    fprintf('  %.3f  %10.2f  %12.0f  %10.0f\n',xKNlist(irun),...
        1000*S.hist.mK2cum(end),max(S.hist.Tout),max(S.hist.Tmax));
end
