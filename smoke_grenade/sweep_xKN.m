%% SWEEP over KNO3/sugar ratio - research questions 1 and 2
% Runs the smoke-grenade model at a small set of KNO3 mass fractions and plots
% how the K2CO3 yield (smoke) and the escaping-gas temperature change with the
% stoichiometric composition. The 891 C ceiling (K2CO3 melting point) is
% marked on the temperature plot.
%
% Kept deliberately small (3 ratios). Each run also saves its own results
% folder + GIF is skipped for speed. See README.md / docs/.

clear; close all; clc

xlist = [0.55 0.65 0.75];          % KNO3 mass fractions to compare
nR    = numel(xlist);

% run each ratio (no per-run plots/GIF; we make summary plots below)
for kk = 1:nR
    R(kk) = run_grenade(xlist(kk), false, false);   %#ok<SAGROW>
end

% collect
xKN   = [R.xKN];
K2CO3 = [R.K2CO3_total];
Tvf   = [R.Tvent_final] - 273.15;     % escaping-gas T [C]
Tvp   = [R.Tvent_peak]  - 273.15;
Tmax  = [R.Tmax_final]  - 273.15;     % peak in-domain T [C]
yK2   = [R.yK2]*100;                  % K2CO3 yield [wt%]

%% ---- summary figure ------------------------------------------------------
figure('Name','xKN sweep');

subplot(2,1,1);
yyaxis left;  plot(xKN*100, K2CO3, 'o-','LineWidth',1.5); ylabel('total K_2CO_3 [kg]');
yyaxis right; plot(xKN*100, yK2,  's--','LineWidth',1.5); ylabel('K_2CO_3 yield [wt%]');
xlabel('KNO_3 fraction [wt%]'); title('Smoke (K_2CO_3) vs composition'); grid on;

subplot(2,1,2);
plot(xKN*100, Tmax,'^-','LineWidth',1.5); hold on;
plot(xKN*100, Tvf, 'o-','LineWidth',1.5);
plot(xKN*100, Tvp, 'o:','LineWidth',1.0);
yline(891,'r--','891 C ceiling (K_2CO_3 melts)','LineWidth',1.2);
xlabel('KNO_3 fraction [wt%]'); ylabel('temperature [C]');
legend('peak in-domain T','escaping-gas T (final)','escaping-gas T (peak)','Location','best');
title('Temperature vs composition'); grid on;

saveas(gcf, fullfile('results','sweep_xKN.png'));

%% ---- table to console + file --------------------------------------------
fprintf('\n  xKN   r     K2CO3yield  totalK2CO3   Tmax[C]  Tvent[C]  fuelLeft\n');
ft = fopen(fullfile('results','sweep_xKN.txt'),'w');
fprintf(ft,'xKN\tr\tyK2_wt%%\ttotalK2CO3_kg\tTmax_C\tTventfinal_C\tmeanYfu\n');
for kk = 1:nR
    fprintf('%5.2f %5.2f %9.1f %12.3e %9.0f %9.0f %8.2f\n', ...
        R(kk).xKN, R(kk).r, R(kk).yK2*100, R(kk).K2CO3_total, ...
        R(kk).Tmax_final-273.15, R(kk).Tvent_final-273.15, R(kk).meanYfu_final);
    fprintf(ft,'%.2f\t%.2f\t%.1f\t%.3e\t%.0f\t%.0f\t%.3f\n', ...
        R(kk).xKN, R(kk).r, R(kk).yK2*100, R(kk).K2CO3_total, ...
        R(kk).Tmax_final-273.15, R(kk).Tvent_final-273.15, R(kk).meanYfu_final);
end
fclose(ft);
fprintf('\nSweep figure saved to results/sweep_xKN.png\n');
