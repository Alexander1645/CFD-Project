%% SMOKE GRENADE - laminar reacting-flow model (v1)
% Adapted from the supplied final_assignment transient SIMPLE solver
% (Versteeg & Malalasekera). Models the premixed KNO3/sugar charge in a
% closed 2D box: a temperature-driven (Arrhenius) burn converts solid fuel
% to heat and K2CO3, starting from an igniter kernel. Outputs the
% temperature distribution and the K2CO3 field as functions of the
% KNO3/sugar ratio (research questions 1 and 2).
%
% v1 scope: closed box, LAMINAR, no vent flow (velocities ~0). The
% pressure-driven vent + gasification mass source is the planned v2 step.
% See docs/design-decisions.md and smoke_grenade/README.md.
%
% References: docs/references.md  (Nakka; Olde 2018 TU Delft; Oliveira 2019)

clear; close all; clc

%% ---- global declarations -------------------------------------------------
global x x_u y y_v u v pc T rho mu Gamma b SMAX SAVG aP aE aW aN aS eps k ...
    u_old v_old pc_old T_old Dt eps_old k_old uplus yplus yplus1 yplus2 ...
    Yfu YK2 Yfu_old YK2_old Rk mut mueff
global NPI NPJ XMAX YMAX LARGE U_IN SMALL Cmu sigmak sigmaeps C1eps C2eps ...
    kappa ERough Ti TAMB TIGN A_arr Ea_arr Ru xKN yK2 dTad

%% ---- numerical / geometry parameters -------------------------------------
NPI        = 40;        % grid cells in x [-]
NPJ        = 24;        % grid cells in y [-]
XMAX       = 0.08;      % box width  [m]  (handheld scale; keep variable)
YMAX       = 0.05;      % box height [m]
MAX_ITER   = 30;        % max outer (SIMPLE) iterations per time step
U_ITER     = 1; V_ITER = 1; PC_ITER = 30;
T_ITER     = 1; YFU_ITER = 1; YK2_ITER = 1;
SMAXneeded = 1E-5;      % mass-balance convergence
SAVGneeded = 1E-6;
LARGE      = 1E30;  SMALL = 1E-30;
U_IN       = 0.0;       % no inlet

% turbulence constants (kept for the disabled k-eps machinery)
Cmu=0.09; sigmak=1.; sigmaeps=1.3; C1eps=1.44; C2eps=1.92; kappa=0.4187; ERough=9.793; Ti=0.04;

%% ---- chemistry / reaction parameters -------------------------------------
TAMB    = 298.0;        % ambient temperature [K]
TIGN    = 1100.0;       % igniter (hot west wall) temperature [K]
Ru      = 8.314;        % universal gas constant [J/mol/K]
A_arr   = 5.0e6;        % Arrhenius pre-exponential [1/s]
Ea_arr  = 8.0e4;        % activation energy [J/mol]
xKN     = 0.65;         % KNO3 mass fraction of the charge (VARY THIS, RQ1/RQ2)

[yK2, dTad, rmol] = chemistry(xKN);   % yields & adiabatic dT from the ratio
fprintf('Composition: %.0f%% KNO3 / %.0f%% sugar | r=%.2f mol | ', ...
        xKN*100, (1-xKN)*100, rmol);
fprintf('K2CO3 yield = %.1f wt%% | dTad = %.0f K\n', yK2*100, dTad);

Dt         = 1.0e-3;    % time step [s]
TOTAL_TIME = 4.0;       % total simulated time [s]

%% ---- initialise ----------------------------------------------------------
init();
bound();      % applies the igniter (hot west wall) and wall BCs
T_old = T;    % refresh old-time field after BCs

%% ---- diagnostics storage -------------------------------------------------
nsteps = round(TOTAL_TIME/Dt);
hist_t   = zeros(nsteps,1);
hist_Tmax= zeros(nsteps,1);
hist_K2  = zeros(nsteps,1);   % total K2CO3 [kg per unit depth]
cellVol  = (XMAX/NPI)*(YMAX/NPJ);
istep = 0;

%% ---- time loop -----------------------------------------------------------
for time = Dt:Dt:TOTAL_TIME
    istep = istep + 1;
    iter = 0;
    while iter < MAX_ITER && SMAX > SMAXneeded && SAVG > SAVGneeded
        % --- momentum + pressure (laminar; ~0 flow in v1) ---
        derivatives();
        ucoeff();
        for it = 1:U_ITER,  u = solve(u, b, aE, aW, aN, aS, aP);  end
        vcoeff();
        for it = 1:V_ITER,  v = solve(v, b, aE, aW, aN, aS, aP);  end
        bound();
        pccoeff();
        for it = 1:PC_ITER, pc = solve(pc, b, aE, aW, aN, aS, aP); end
        velcorr();

        % --- chemistry: reaction rate, fuel, K2CO3, temperature ---
        reaction();
        Yfucoeff();
        for it = 1:YFU_ITER, Yfu = solve(Yfu, b, aE, aW, aN, aS, aP); end
        Yfu = max(min(Yfu,1.0),0.0);            % keep physical
        YK2coeff();
        for it = 1:YK2_ITER, YK2 = solve(YK2, b, aE, aW, aN, aS, aP); end
        Tcoeff();
        for it = 1:T_ITER,   T = solve(T, b, aE, aW, aN, aS, aP);  end

        viscosity();          % laminar (mut = 0)
        bound();

        % store current as "old" for the next time level
        u_old(3:NPI+1,2:NPJ+1) = u(3:NPI+1,2:NPJ+1);
        v_old(2:NPI+1,3:NPJ+1) = v(2:NPI+1,3:NPJ+1);
        pc_old(2:NPI+1,2:NPJ+1)= pc(2:NPI+1,2:NPJ+1);
        T_old(2:NPI+1,2:NPJ+1) = T(2:NPI+1,2:NPJ+1);
        Yfu_old(2:NPI+1,2:NPJ+1)= Yfu(2:NPI+1,2:NPJ+1);
        YK2_old(2:NPI+1,2:NPJ+1)= YK2(2:NPI+1,2:NPJ+1);

        iter = iter + 1;
    end

    % diagnostics
    hist_t(istep)    = time;
    hist_Tmax(istep) = max(max(T(2:NPI+1,2:NPJ+1)));
    hist_K2(istep)   = sum(sum(rho(2:NPI+1,2:NPJ+1).*YK2(2:NPI+1,2:NPJ+1)))*cellVol;

    if istep==1
        fprintf('step    time[s]   Tmax[K]   K2CO3[kg]   meanYfu\n');
    end
    if mod(istep,50)==0 || istep==nsteps
        fprintf('%5d %9.3f %9.1f %11.3e %9.3f\n', istep, time, ...
            hist_Tmax(istep), hist_K2(istep), mean(mean(Yfu(2:NPI+1,2:NPJ+1))));
    end

    SMAX = LARGE;  SAVG = LARGE;   % reset for next time step
end

%% ---- output --------------------------------------------------------------
% Field dump: x  y  T  YK2  Yfu
fp = fopen('grenade_output.txt','w');
for I = 1:NPI+2
    for J = 1:NPJ+2
        fprintf(fp,'%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\n', ...
            x(I), y(J), T(I,J), YK2(I,J), Yfu(I,J));
    end
    fprintf(fp,'\n');
end
fclose(fp);

% Time history
fh = fopen('grenade_history.txt','w');
fprintf(fh,'# time[s]  Tmax[K]  totalK2CO3[kg]\n');
for n = 1:nsteps
    fprintf(fh,'%11.5e\t%11.5e\t%11.5e\n', hist_t(n), hist_Tmax(n), hist_K2(n));
end
fclose(fh);

fprintf('\nDone. Final: Tmax = %.1f K (%.0f C), total K2CO3 = %.3e kg.\n', ...
    hist_Tmax(end), hist_Tmax(end)-273.15, hist_K2(end));
fprintf('Ceiling check: escaping-gas target < 891 C (1164 K).\n');

%% ---- plots (run in MATLAB) ----------------------------------------------
[X,Y] = meshgrid(x, y);
figure;
subplot(2,1,1); contourf(X, Y, T', 20, 'LineColor','none'); colorbar;
title('Temperature [K]'); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
subplot(2,1,2); contourf(X, Y, YK2', 20, 'LineColor','none'); colorbar;
title('K_2CO_3 mass fraction [-]'); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
