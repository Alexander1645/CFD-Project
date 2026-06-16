%% SMOKE GRENADE - single run
% Laminar reacting-flow model of a KNO3/sugar (KNSu) smoke grenade.
% This is a thin wrapper: set the ratio and call run_grenade. To study several
% ratios at once, run sweep_xKN.m instead.
%
% Change the composition here:
%     xKN = KNO3 mass fraction of the charge   (sugar fraction = 1 - xKN)
%
% Outputs (temperature, K2CO3, velocity fields, history, GIF) are saved to a
% timestamped folder under results/. See README.md and docs/.

clear; close all; clc

xKN = 0.65;                 % <-- change the KNO3/sugar ratio here

R = run_grenade(xKN, true, true);   % (xKN, make plots, make GIF)

fprintf('\nResults saved in: %s\n', R.resdir);
fprintf('Escaping-gas T = %.0f C  (ceiling 891 C / 1164 K)\n', R.Tvent_final-273.15);
