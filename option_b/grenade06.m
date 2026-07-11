%% grenade06.m — Option B smoke-grenade driver (advancing burning surface)
% Cloned from final_assignment/transient05.m (Versteeg & Malalasekera transient
% SIMPLE). Every deviation from the supplied code is marked with a [B] tag so
% the diff against the course code is greppable:   grep -n "\[B\]" *.m
%
% Model: gas cavity west of a moving burning surface; unburnt charge = blocked
% cells; surface = moving INLET (mass flux f_gas*rho_s*r(P), temperature
% T_flame); vent = pressure-driven orifice on the west wall. Pressure buildup
% is resolved by the 2-D field itself (transient compressible continuity +
% ideal-gas density). See optionB_design.md and optionB_walkthrough.md.
%
% STATUS: UNTESTED skeleton (written without MATLAB access). Run verification
% tests V1/V2 (design doc section 8) before any burn run:
%   V1: VENT_OPEN=0, BURN_ON=0  -> total mass constant
%   V2: VENT_OPEN=1, BURN_ON=0, p0>0 -> blow-down matches 0-D orifice ODE

clear
close all
clc

%% declare all variables and constants ------------------------------------
% (identical to transient05.m lines 17-20, plus the [B] group)
global x x_u y y_v u v pc p T rho mu Gamma b SMAX SAVG aP aE aW aN aS eps k ...
    u_old v_old pc_old T_old Dt eps_old k_old uplus yplus yplus1 yplus2 Cp
global NPI NPJ XMAX YMAX LARGE U_IN SMALL Cmu sigmak sigmaeps C1eps C2eps kappa ERough Ti
% [B] Option B globals: smoke scalar, old density, front state, chemistry, vent
global YK2 YK2_old rho_old R_GAS P_ATM relax_rho TAMB ...
    xf Ifr mdotpp T_flame Y_in yK2 f_gas dTad Sc_Y ...
    Jv1 Jv2 Cd_vent relax_vent a_burn n_burn rho_solid t_ramp VENT_OPEN BURN_ON ...
    h_wall lam_wall    % [B2-5/6] wall-cooling parameters (UPDATE_2)

NPI        = 48;        % number of grid cells in x-direction [-]   [B] dev grid
NPJ        = 22;        % number of grid cells in y-direction [-]   [B] dev grid
XMAX       = 0.146;     % width of the domain (M18 chamber length) [m]   [B]
YMAX       = 0.064;     % height of the domain (M18 diameter) [m]        [B]
MAX_ITER   = 40;        % maximum number of outer iterations [-]
U_ITER     = 1;         % number of Newton iterations for u equation [-]
V_ITER     = 1;         % number of Newton iterations for v equation [-]
PC_ITER    = 30;        % number of Newton iterations for pc equation [-]
T_ITER     = 1;         % number of Newton iterations for T equation [-]
Y_ITER     = 1;         % [B] iterations for the smoke (YK2) equation [-]
SMAXneeded = 1E-5;      % maximum accepted error in mass balance [kg/s]
SAVGneeded = 1E-6;      % maximum accepted average error in mass balance [kg/s]
LARGE      = 1E30;      % arbitrary very large value [-]
SMALL      = 1E-30;     % arbitrary very small value [-]
P_ATM      = 101000.;   % atmospheric pressure [Pa]
U_IN       = 0.;        % [B] no duct inlet: the burning surface is the inlet

Cmu        = 0.09;      % k-eps constants kept for structural parity; the run
sigmak     = 1.;        % is laminar (k=0 -> mut=0), kcoeff/epscoeff not called
sigmaeps   = 1.3;       % [B]
C1eps      = 1.44;
C2eps      = 1.92;
kappa      = 0.4187;
ERough     = 9.793;
Ti         = 0.04;

Dt         = 2.0e-5;    % [B] CFL-limited by the vent jet (design doc sec. 6)
                        % [B2-3] briefly 1e-5 (checklist knob 2) against the
                        % pressure limit cycle; REVERTED to 2e-5 after [B2-4]
                        % (implicit compressibility in pccoeff.m) removed the
                        % 1/Dt^2 instability at its root — see CHANGELOG.md
TOTAL_TIME = 1.0;       % [B] dev window; flow is quasi-steady after ~0.5 s

%% [B] ===== Option B physical parameters ==================================
xKN       = 0.65;       % KNO3 mass fraction (research variable: .55/.65/.75)
TAMB      = 298.;       % ambient temperature [K]
rho_solid = 1800.;      % KNSu solid charge density [kg/m3]
a_burn    = 8.26;       % Saint-Robert burn law r=a*P[MPa]^n [mm/s] (Nakka)
n_burn    = 0.319;      % burn-law pressure exponent [-]
Cd_vent   = 0.6;        % vent orifice discharge coefficient [-]
h_wall    = 10.;        % [B2-5] casing heat-loss coefficient [W/m2K]; 0 = adiabatic
                        % (UPDATE_2 item 1: cooling ON for physics/sweep runs;
                        % the archived adiabatic V3 is the h_wall=0 reference)
lam_wall  = 0.05;       % [B2-5] near-wall gas conductivity for the Robin Bi [W/mK]
relax_vent= 0.3;        % under-relaxation of the vent-velocity BC [-]
relax_rho = 0.05;       % density (EOS) under-relaxation, wc3-style [-]
                        % [B2-2] 0.1 -> 0.05: burn-run pbar oscillated +-3 kPa
                        % with iter pinned at MAX_ITER (divergence checklist
                        % knob 1, design doc sec. 5/7)
Sc_Y      = 0.7;        % Schmidt number for the smoke scalar [-]
t_ramp    = 0.05;       % burn-rate startup ramp [s] (avoids inlet shock)
ngap0     = 3;           % initial gas-gap columns between west wall and charge
VENT_OPEN = 1;          % verification switch (V1: 0)
BURN_ON   = 1;          % verification switch (V1/V2: 0)

% chemistry closure for this composition (yield, flame T, gas fraction)
[yK2, dTad, rmol, f_gas, n_gas] = chemistry(xKN);
R_GAS   = 8.314*(n_gas/f_gas);  % product-gas constant from mean molar mass [J/kg/K]
T_flame = TAMB + dTad;          % inlet (adiabatic flame) temperature [K]
Y_in    = yK2/f_gas;            % K2CO3 loading of the inlet stream [kg/kg gas]
fprintf('xKN=%.2f | yK2=%.3f | f_gas=%.3f | dTad=%.0f K | T_flame=%.0f K | R=%.0f J/kg/K\n', ...
        xKN, yK2, f_gas, dTad, T_flame, R_GAS);

% front state: continuous position xf, first-solid-column index Ifr
Dx  = XMAX/NPI;  Dy = YMAX/NPJ;
xf  = ngap0*Dx;
Ifr = 2 + floor(xf/Dx + 1e-12);
mdotpp = 0.;                    % inlet mass flux [kg/m2/s], set by front()

% vent rows: middle 25% of the west wall  (CHECK vs approved sketch: top-left)
nv  = max(2, round(0.25*NPJ));
Jmid= (NPJ+3)/2;
Jv1 = round(Jmid-(nv-1)/2);  Jv2 = round(Jmid+(nv-1)/2);
%% [B] =====================================================================

%% start main function here ------------------------------------------------
init();     % initialization  (edited: Option B fields, see init.m)
bound();    % apply boundary conditions (rewritten, see bound.m)

nsteps = round(TOTAL_TIME/Dt);
hist   = zeros(nsteps,13);      % [B] t, pbar, Tvent, uvent, m_in, m_vent, massErr, xf, K2prod
                                % [B2-6] + Tvent_fw, mdotK2_vent, MK2_vented, pvent (UPDATE_2 item 2)
M_prev = gasmass();             % [B] initial gas mass for the balance check
MK2v   = 0.;                    % [B2-6] cumulative K2CO3 vented [kg/m]
istep  = 0;

for time = Dt:Dt:TOTAL_TIME
    istep = istep + 1;

    % [B] store previous-TIME-LEVEL fields ONCE per time step (V&M sec. 8.7.1:
    % "old" values are the previous time level, held FIXED during the outer
    % iterations). In transient05.m this block sits INSIDE the while loop
    % (lines 100-111), which overwrites "old" every outer iteration and
    % degenerates the transient terms; for a pressurisation problem the
    % accumulation term (rho_old-rho)/Dt must be a true time derivative, so
    % the store is moved here. State this (one sentence) in the report.
    u_old   = u;   v_old   = v;   pc_old = pc;
    T_old   = T;   YK2_old = YK2; rho_old = rho;

    front(time);   % [B] advance burning surface, set mdotpp (uses field p)
    bound();

    iter = 0;  SMAX = LARGE;  SAVG = LARGE;
    % outer iteration loop (same layout as transient05.m lines 60-99;
    % kcoeff/epscoeff calls omitted -> laminar; density() added per wc3)
    while iter < MAX_ITER && SMAX > SMAXneeded && SAVG > SAVGneeded

        density();      % [B] rho from ideal gas law (wc3 convdiff03.m 71-83)
        derivatives();

        ucoeff();
        for iter_u = 1:U_ITER
            u = solve(u, b, aE, aW, aN, aS, aP);
        end

        vcoeff();
        for iter_v = 1:V_ITER
            v = solve(v, b, aE, aW, aN, aS, aP);
        end

        bound();

        pccoeff();
        for iter_pc = 1:PC_ITER
            pc = solve(pc, b, aE, aW, aN, aS, aP);
        end

        velcorr(); % Correct pressure and velocity

        % [B] kcoeff()/epscoeff() calls removed: laminar (k=0 at init -> mut=0
        % through the unchanged viscosity.m). Re-insert here to add turbulence.

        Tcoeff();
        for iter_T = 1:T_ITER
            T = solve(T, b, aE, aW, aN, aS, aP);
        end

        YK2coeff();     % [B] smoke (K2CO3 loading) scalar, cloned from Tcoeff
        for iter_Y = 1:Y_ITER
            YK2 = solve(YK2, b, aE, aW, aN, aS, aP);
        end

        % [B] temperature-dependent gas properties (wc3 correlations)
        mu(1:NPI+2,2:NPJ+1)    = (0.0395*T(1:NPI+2,2:NPJ+1) + 6.58)*1.E-6;
        Gamma(1:NPI+2,2:NPJ+1) = (6.1E-5*T(1:NPI+2,2:NPJ+1) + 8.4E-3) ...
                                 ./ Cp(1:NPI+2,2:NPJ+1);

        viscosity();
        bound();

        iter = iter + 1;
    end % end of while loop (outer iteration)

    % [B] ---- diagnostics: mass balance + research-question metrics --------
    m_in   = mdotpp*YMAX;                                 % inlet [kg/s/m]
    m_vent = 0.;
    for J = Jv1:Jv2
        m_vent = m_vent + rho(2,J)*max(-u(2,J),0.)*Dy;    % vent outflow [kg/s/m]
    end
    M_now   = gasmass();
    massErr = (M_now - M_prev)/Dt - (m_in - m_vent);      % should be ~0 (V3)
    M_prev  = M_now;
    pbar    = mean(mean(p(2:max(Ifr-1,3),2:NPJ+1)));      % mean cavity gauge p [Pa]
    Tvent   = mean(T(2,Jv1:Jv2));                         % vent temperature [K]
    uvent   = mean(max(-u(2,Jv1:Jv2),0.));                % vent speed [m/s]
    K2prod  = yK2*rho_solid*YMAX*max(xf - ngap0*Dx, 0.);  % K2CO3 made [kg/m]

    % [B2-6] flux-weighted vent state for the dilution post-processing
    % (UPDATE_2 item 2): use the vent MASS FLUX as the weight so the value
    % represents what actually leaves; arithmetic Tvent kept for continuity.
    fw = rho(2,Jv1:Jv2).*max(-u(2,Jv1:Jv2),0.);           % [kg/m2/s] weights
    if sum(fw) > 1e-12
        Tvent_fw = sum(fw.*T(2,Jv1:Jv2))/sum(fw);         % [K]
    else
        Tvent_fw = Tvent;                                 % fallback: no flux
    end
    mdotK2 = sum(fw.*YK2(2,Jv1:Jv2))*Dy;                  % K2CO3 out [kg/s/m]
    MK2v   = MK2v + mdotK2*Dt;                            % cumulative [kg/m]
    pvent  = mean(p(2,Jv1:Jv2));                          % orifice-driving p [Pa]

    hist(istep,:) = [time pbar Tvent uvent m_in m_vent massErr xf K2prod ...
                     Tvent_fw mdotK2 MK2v pvent];

    if ~isfinite(pbar) || ~isfinite(Tvent)
        fprintf('** DIVERGED (NaN) at t=%.5f s — see design doc sec. 7 checklist **\n', time);
        break;
    end

    % print convergence to the screen (style of transient05.m lines 117-125)
    if istep == 1
        fprintf('step\t time\t iter\t pbar[Pa] Tvent[K] uvent[m/s] m_in\t m_vent\t massErr\t xf[mm]\n');
    end
    if mod(istep,100) == 0 || istep == 1
        fprintf('%5d %9.4f %3d %9.2f %8.1f %8.2f %9.2e %9.2e %9.2e %7.2f\n', ...
            istep, time, iter, pbar, Tvent, uvent, m_in, m_vent, massErr, xf*1000);
    end

    % reset SMAX and SAVG
    SMAX = LARGE;
    SAVG = LARGE;
end % end of calculation

%% begin: output() ----------------------------------------------------------
% Final fields, transient05.m style (lines 133-147): x, y, u, v, p, T, rho, YK2
fp = fopen('grenade_output.txt','w');
for I = 1:NPI+1
    i = I;
    for J = 2:NPJ+1
        j = J;
        ugrid = 0.5*(u(i,J)+u(i+1,J));
        vgrid = 0.5*(v(I,j)+v(I,j+1));
        fprintf(fp,'%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\n',...
            x(I), y(J), ugrid, vgrid, p(I,J), T(I,J), rho(I,J), YK2(I,J));
    end
    fprintf(fp, '\n');
end
fclose(fp);

fh = fopen('grenade_history.txt','w');
% [B2-6] columns 10-13 appended (UPDATE_2 item 2)
fprintf(fh,'# t[s]  pbar[Pa]  Tvent[K]  uvent[m/s]  m_in[kg/s/m]  m_vent[kg/s/m]  massErr  xf[m]  K2CO3[kg/m]  Tvent_fw[K]  mdotK2_vent[kg/s/m]  MK2_vented[kg/m]  pvent[Pa]\n');
for n = 1:istep
    fprintf(fh,['%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t' ...
                '%11.5e\t%11.5e\t%11.5e\t%11.5e\n'], hist(n,:));
end
fclose(fh);

% quick-look figures (course style; use ProjectInfo/contourfplots.m for report)
figure; contourf(x,y,T',20,'LineColor','none'); colorbar; axis equal tight;
title(sprintf('T [K], t=%.2f s, xKN=%.2f (front at x=%.0f mm)',time,xKN,xf*1000));
figure; plot(hist(1:istep,1),hist(1:istep,2)); grid on;
xlabel('t [s]'); ylabel('mean cavity gauge pressure [Pa]');

%% [B] helper: total gas mass in the cavity (per unit depth) ----------------
function M = gasmass()
global NPI NPJ XMAX YMAX rho Ifr
M = sum(sum(rho(2:max(Ifr-1,2),2:NPJ+1)))*(XMAX/NPI)*(YMAX/NPJ);
end
