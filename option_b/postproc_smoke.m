function out = postproc_smoke(rundir)
% POSTPROC_SMOKE — 0-D dilution / optical post-processing.       NEW FILE [B2-7]
% (UPDATE_2_mixing_outputs.md item 3.) PURE post-processing: reads a finished
% run's grenade_history.txt; never feeds back into the solver.
%
% Physics chain: hot vent gas at Tvent_fw entrains ambient air until the mix
% cools to T_c = 1164 K (891 C, K2CO3 condensation trigger). The entrained air
% per kg of vent gas is the dilution D (energy balance). The K2CO3 flux over
% the diluted volume flux is the formation-point smoke concentration C_form.
% The optical layer then gives (a) the concentration REQUIRED to reach the
% target transmittance over a sight line, C_req = ln(1/T_req)/(alpha*L_path),
% and (b) the total screenable area A_screen = alpha*MK2_vented/ln(1/T_req).
% C_form/C_req is the margin: how much FURTHER the plume may dilute beyond the
% formation point and still screen.
%
% Constants (report citations):
%   alpha_g    = 3 m2/g : visible-band mass extinction coefficient of a
%                salt-type (K2CO3/KCl) aerosol. Military smoke handbooks quote
%                2-4 m2/g for salt screening smokes [CITATION NEEDED: pin the
%                exact source in the report; all optical results scale
%                LINEARLY with alpha].
%   T_req      = 0.02   : required transmittance (2 %) over L_path.
%   L_path     = 5 m    : screening sight-line length.
%   T_c        = 1164 K : K2CO3 melting point 891 C (assignment criterion).
%   Cp_gas     = 1200 J/kg/K (product gas, as solver), Cp_air = 1005 J/kg/K.

if nargin < 1, rundir = '.'; end
alpha_g = 3.0;             % [m2/g]
alpha   = alpha_g*1000.;   % [m2/kg]
T_req   = 0.02;   L_path = 5.0;
Cp_gas  = 1200.;  Cp_air = 1005.;
T_c     = 1164.;  TAMB   = 298.;  P_ATM = 101000.;  R_air = 287.;

H = readmatrix(fullfile(rundir,'grenade_history.txt'), ...
               'FileType','text','NumHeaderLines',1);
if size(H,2) < 13
    error('postproc_smoke: history has %d columns; needs the 13-column [B2-6] format.', size(H,2));
end
t      = H(:,1);   m_vent = H(:,6);   Tfw   = H(:,10);
mdotK2 = H(:,11);  MK2    = H(:,12);  pvent = H(:,13);
uvent  = H(:,4);

% --- dilution to the condensation temperature (energy balance) ------------
D        = max(Cp_gas*(Tfw - T_c) ./ (Cp_air*(T_c - TAMB)), 0.);  % [kg air/kg gas]
rho_mix  = P_ATM/(R_air*T_c);                                     % [kg/m3]
Vdot_mix = m_vent.*(1. + D)/rho_mix;                              % [m3/s per m depth]
C_form   = mdotK2 ./ max(Vdot_mix, 1e-12);                        % [kg/m3]

% --- optical requirement and totals ----------------------------------------
C_req    = log(1/T_req)/(alpha*L_path);                           % [kg/m3]
A_screen = alpha*MK2(end)/log(1/T_req);                           % [m2 per m depth]

% --- quasi-steady window: last 50 % of the run (past ramp + settling) ------
qs = t >= 0.5*t(end);
q  = @(x) mean(x(qs));

S = sprintf([ ...
 '== postproc_smoke: %s\n' ...
 'quasi-steady window: t = %.3f..%.3f s (last 50%%)\n' ...
 'Tvent_fw  [K]     : %10.1f (qs mean)   %10.1f (final)\n' ...
 'pvent     [Pa]    : %10.1f (qs mean)\n' ...
 'uvent     [m/s]   : %10.2f (qs mean)\n' ...
 'm_vent    [kg/s/m]: %10.4f (qs mean)\n' ...
 'D dilution[kg/kg] : %10.3f (qs mean)  [air per kg vent gas to reach T_c]\n' ...
 'C_form    [g/m3]  : %10.2f (qs mean)  [smoke conc. at the T_c point]\n' ...
 'C_req     [g/m3]  : %10.3f           [ln(1/%.2f)/(alpha*L), L=%.1f m]\n' ...
 'margin C_form/C_req [-]: %8.1f       [allowable further dilution]\n' ...
 'MK2_vented(end) [kg/m] : %8.4f\n' ...
 'A_screen  [m2 per m depth]: %6.1f    [alpha*MK2/ln(1/T_req)]\n' ...
 'alpha = %.1f m2/g (results scale linearly), T_c = %.0f K\n'], ...
 rundir, t(find(qs,1)), t(end), q(Tfw), Tfw(end), q(pvent), q(uvent), ...
 q(m_vent), q(D), 1000*q(C_form), 1000*C_req, T_req, L_path, ...
 q(C_form)/C_req, MK2(end), A_screen, alpha_g, T_c);

fprintf('%s', S);
fid = fopen(fullfile(rundir,'postproc_summary.txt'),'w');
fprintf(fid,'%s',S); fclose(fid);

% struct output for sweep_figure.m (same quantities as the summary block)
out = struct('Tfw_qs',q(Tfw), 'pvent_qs',q(pvent), 'uvent_qs',q(uvent), ...
             'mvent_qs',q(m_vent), 'D_qs',q(D), 'Cform_qs',q(C_form), ...
             'Creq',C_req, 'MK2_end',MK2(end), 'A_screen',A_screen);
end
