function R = run_grenade(xKN, doPlots, doGif)
% RUN_GRENADE  Run one smoke-grenade simulation for a given KNO3 mass
% fraction xKN and return a results struct R. Used both for a single run
% (smoke_grenade.m) and for the ratio sweep (sweep_xKN.m).
%
%   R = run_grenade(xKN)                 % single run, plots + GIF on
%   R = run_grenade(xKN, doPlots, doGif) % control figures/animation
%
% R fields: xKN, r, yK2, dTad, Tmax_final, Tvent_final, Tvent_peak,
%           K2CO3_total, meanYfu_final, resdir.
%
% Laminar transient SIMPLE solver adapted from final_assignment (V&M), with
% KNSu combustion: temperature-driven burn -> heat + K2CO3 + gas, gas drives
% flow out of a mid-west vent. See README.md / docs/.

if nargin < 2, doPlots = true; end
if nargin < 3, doGif   = true; end

%% ---- global declarations -------------------------------------------------
global x x_u y y_v u v pc p T rho rho_old mu Gamma Cp b SMAX SAVG aP aE aW aN aS eps k ...
    u_old v_old pc_old T_old Dt eps_old k_old uplus yplus yplus1 yplus2 ...
    Yfu YK2 Yfu_old YK2_old Rk mut mueff T_case P_chamber u_vent_orifice
global NPI NPJ XMAX YMAX LARGE U_IN SMALL Cmu sigmak sigmaeps C1eps C2eps ...
    kappa ERough Ti TAMB A_arr Ea_arr Ru yK2 dTad Jvent1 Jvent2 P_ATM R_GAS relax_rho h_wall rho_solid rho_solid_th f_gas n_gas ...
    wburn T_ign a_burn n_burn

%% ---- numerical / geometry parameters -------------------------------------
NPI = 40;  NPJ = 24;  XMAX = 0.08;  YMAX = 0.05;
MAX_ITER = 50;
U_ITER=1; V_ITER=1; PC_ITER=30; T_ITER=1; YFU_ITER=1; YK2_ITER=1;
SMAXneeded = 1E-4;  SAVGneeded = 1E-5;
LARGE = 1E30;  SMALL = 1E-30;  U_IN = 0.0;
Cmu=0.09; sigmak=1.; sigmaeps=1.3; C1eps=1.44; C2eps=1.92; kappa=0.4187; ERough=9.793; Ti=0.04;

% Vent in the MIDDLE of the west wall (per sketch), ~25% of wall height.
% Centred SYMMETRICALLY on the domain mid-plane so the burn spreads evenly up
% and down (the model has no buoyancy, so any off-centre vent biased the front).
% Interior cells are J = 2..NPJ+1, so the mid-plane index is Jmid = (NPJ+3)/2
% (= 13.5 for NPJ=24). An EVEN vent width straddles it exactly.
Jmid   = (NPJ+3)/2;                          % mid-plane (half-integer for even NPJ)
nvent  = max(2, 2*round(0.125*NPJ));         % even count, ~25% of height (=6 for NPJ=24)
Jvent1 = round(Jmid - (nvent-1)/2);          % 11  (symmetric about Jmid)
Jvent2 = round(Jmid + (nvent-1)/2);          % 16
Jcen   = round(Jmid);                        % kept for any legacy reference

%% ---- chemistry / reaction parameters -------------------------------------
TAMB = 298.0;  Ru = 8.314;
A_arr = 5.0e6;  Ea_arr = 8.0e4;

% Smoke = condensed K2CO3 (below its 891 C melting point). Counted two ways:
%  (1) inside the domain: K2CO3 in cells already below T_SMOKE;
%  (2) vented gas: cooled by mixing with a FIXED (finite) amount of ambient air
%      - if that bounded mix is below T_SMOKE the vented K2CO3 condenses (smoke).
% The finite ENTRAIN is deliberate: unlimited mixing would condense everything
% and the metric would collapse to "total K2CO3". A modest value keeps it
% temperature-sensitive (cool/rich gas condenses, hot/stoichiometric stays vapour).
T_SMOKE = 891.0 + 273.15;   % K2CO3 melting point [K]
Cp_air  = 1005.;            % ambient air heat capacity [J/kg/K]
ENTRAIN = 0.5;              % air mass entrained per unit vent-gas mass (modeling choice)

% Ignition: a BRIEF hot kernel at the wall. The igniter fires for t_ign seconds
% and lights the first cells (T >= T_ign); after that the burn propagates as a
% rate-anchored FRONT (see reaction.m) - each lit cell is consumed at the
% MEASURED regression rate r = a_burn*P^n_burn, and its burnt neighbours ignite
% the next layer. So the front speed is the real KNSu burn rate, not a
% conduction artefact.
Tig   = 1500.0;       % igniter kernel temperature [K]
t_ign = 0.05;         % igniter ON for the first t_ign seconds, then released
% KNSu ignition (exothermic-onset) temperature. From KN-sugar calorimetry the
% self-sustaining exotherm starts at ~356-361 C; we use 360 C = 633 K. A cell
% lights (latched) the first time it reaches T_ign, or when the front arrives.
T_ign = 633.0;        % KNSu ignition temperature [K] (~360 C, lit-then-latched)
Iig   = 2;                                 % igniter at the west boundary only (1 cell deep)
nig   = 2;                                 % even igniter width -> symmetric about Jmid
Jig   = round(Jmid-(nig-1)/2):round(Jmid+(nig-1)/2);  % J=13:14, centred on the mid-plane

% Variable-density (compressible / low-Mach) parameters. Density follows the
% ideal gas law (density.m, mirrored from the supplied wc3 solver); heating
% lowers density so the gas expands and is driven out of the vent. The
% coupling is stiff during fast combustion, hence the density under-relaxation.
P_ATM     = 101000.;  % reference (atmospheric) pressure [Pa]
R_GAS     = 287.;     % specific gas constant of the products [J/kg/K] (~air)
relax_rho = 0.05;     % density under-relaxation for the gas-phase flow (0.15
                      % diverged to NaN historically; 0.05 is stable). The 2-D
                      % field carries only the gentle gas-density source, so it
                      % does not need rho to track P_chamber tightly; the chamber
                      % pressure buildup is handled by the lumped low-Mach closure
                      % (block 1b), which is unconditionally stable.

% Chamber-pressure model: gas is generated at the SOLID density and vented
% through an orifice; if generation outpaces venting the chamber pressurises.
rho_solid = 1800.;    % TRUE solid propellant density [kg/m3] (KNSu) - used for the
                      % gas-generation mass bookkeeping, NOT the thermal inertia.

% --- SOLID thermal properties of the unburnt charge (energy equation only) -----
% The charge should have the THERMAL INERTIA of a solid, not a gas, so the
% conduction-reaction front advances at the real ~mm/s regression rate instead of
% the too-fast gas-phase speed. These properties enter ONLY the energy equation
% (thermal mass in Tcoeff + conductivity in Gamma), blended by the burnt fraction
% Yfu; the gas-phase FLOW (continuity / momentum / density) is left on the gas
% density, so the solid inertia never touches the pressure solve and CANNOT make
% it diverge.
%
% With the RATE-ANCHORED front (reaction.m), the front speed is imposed by the
% measured burn-rate law, NOT by how fast conduction ignites the next cell. That
% removes the old constraint that forced an effective (reduced) thermal density:
% the front can no longer stall/quench, so we can now use the LITERAL solid
% properties for the thermal field. Conduction here just shapes the (sub-grid,
% thin) preheat layer ahead of the front; the unburnt charge therefore stays
% cold until the front arrives, which is physically correct. These enter ONLY
% the energy equation - the flow keeps the gas density, so nothing diverges.
rho_solid_th = 1800.; % thermal density of the unburnt charge [kg/m3] (literal KNSu)
lambda_solid = 0.30;  % solid-charge conductivity [W/m/K] (KNSu ~0.2-0.5)
Cd        = 0.6;      % orifice discharge coefficient [-]
relax_P   = 0.2;      % chamber-pressure under-relaxation (lower if pressure oscillates)
% UNIFIED gas generation (PHYSICAL - no fitting factor). The gas produced each
% step is the SOLID actually consumed by the 2-D burn, at solid density, minus
% the condensing K2CO3:  Mdot_gen = rho_solid*(1-yK2)*d/dt[burned volume]. This
% one rate drives BOTH the chamber pressure AND the predicted exit velocity
% (= Mdot_gen / rho_vent / A_vent), so the thermal field, pressure and venting
% are consistent. The exit velocity is a PREDICTION to sanity-check against real
% grenades (~10-30 m/s), not a tuned target. (Injecting this large source
% directly into the 2-D gas-phase flow extinguishes the gas-phase flame - a
% model limitation; a solid-surface deflagration model would be needed to carry
% the full venting in 2-D. See docs.)
% MEASURED burn-rate law r = a_burn * P[MPa]^n_burn  [mm/s]  (Nakka/Foltran for
% KNSu). This sets the gas-generation rate (and the pressure->burn-rate feedback)
% to the real, slow burn rate instead of the too-fast gas-phase front.
a_burn = 8.26;        % burn-rate coefficient [mm/s / MPa^n] (set from your source)
n_burn = 0.319;       % burn-rate pressure exponent [-]
A_burn = YMAX;        % burning surface area (front height, per unit depth) [m]
% NOTE: the pressure-buildup MAGNITUDE scales with the gas-generation rate, i.e.
% the burn rate - which is currently ~10-20x too fast (uncalibrated Arrhenius).
% So the buildup is qualitatively right but quantitatively high until the burn
% rate is calibrated (Foltran). Incompressible orifice assumed (valid for
% modest overpressure; under-vents once dP approaches ~1 atm / choked flow).
% Wall heat loss by NATURAL CONVECTION (still ambient air, no wind). The
% convection coefficients are computed ANALYTICALLY from temperature each step
% (h = 1.42*(dT/Lc)^0.25, simplified vertical-surface air correlation), so they
% are NOT guessed and they vary in time with the casing temperature:
%   h_wall : internal, gas -> casing   (dT = T_gas - T_case)
%   h_out  : external, casing -> ambient (dT = T_case - TAMB)  <- the no-wind term
% Casing has finite thermal mass (thin sheet steel) so it heats up and the
% cooling self-limits.
Lc        = 0.06;     % casing characteristic length [m]
t_wall    = 5.0e-4;   % casing wall thickness [m] (thin sheet steel)
rho_steel = 7850.;    % steel density [kg/m3]
Cp_steel  = 490.;     % steel heat capacity [J/kg/K]
Lwall     = YMAX + 2*XMAX;                 % cooled wall length (west+top+bottom) [m]
C_case    = rho_steel*Cp_steel*t_wall*Lwall;   % casing heat capacity [J/K per depth]
h_wall    = 5.;  h_out = 5.;               % initial values; recomputed each step (loop)

[yK2, dTad, rmol, f_gas, n_gas] = chemistry(xKN);
fprintf('Composition: %.0f%% KNO3 / %.0f%% sugar | r=%.2f mol | ', xKN*100, (1-xKN)*100, rmol);
fprintf('K2CO3 yield = %.1f wt%% | gas yield = %.1f wt%% (%.1f mol/kg) | dTad = %.0f K | Tad = %.0f K\n', ...
        yK2*100, f_gas*100, n_gas, dTad, TAMB+dTad);

% Run just past full burn-out. With the rate-anchored front the charge burns at
% r = a*P^n ~ 4 mm/s, so the whole grain (diamond spread from the igniter) is
% consumed in ~22-23 s; 24 s captures the complete burn plus the cool-down. (For
% a quick check, drop TOTAL_TIME back to ~1-2 s.)
% The 2-D field carries only the gentle gas-density source (~0-3 m/s), so the
% convective CFL is comfortable at Dt=1e-3. The chamber pressure buildup is
% advanced by the lumped low-Mach closure (block 1b), which is stable at this Dt.
Dt = 1.0e-3;  TOTAL_TIME = 24.0;

%% ---- per-run results folder ---------------------------------------------
runid  = datestr(now,'yyyymmdd_HHMMSS_FFF');
resdir = fullfile('results', sprintf('run_%s_xKN%02.0f', runid, xKN*100));
if ~exist('results','dir'), mkdir('results'); end
mkdir(resdir);
giffile = fullfile(resdir,'evolution.gif');   % T + pressure + velocity over time

%% ---- chamber-pressure state (init at ambient) ---------------------------
P_chamber      = P_ATM;
u_vent_orifice = 0.;
M_gas          = (P_ATM/(R_GAS*TAMB)) * (XMAX*YMAX);   % initial gas mass [kg/m depth]
M_solid        = rho_solid * (XMAX*YMAX);              % total solid to burn [kg/m depth]
A_vent         = (Jvent2 - Jvent1 + 1)*(YMAX/NPJ);     % vent area [m, per depth]

%% ---- initialise ----------------------------------------------------------
init();  bound();  T_old = T;

nsteps   = round(TOTAL_TIME/Dt);
hist_t   = zeros(nsteps,1);  hist_Tmax = zeros(nsteps,1);
hist_Tvent=zeros(nsteps,1);  hist_K2  = zeros(nsteps,1);  hist_uv = zeros(nsteps,1);
hist_smoke=zeros(nsteps,1);  hist_P   = zeros(nsteps,1);  hist_Pfield=zeros(nsteps,1);
hist_uexit=zeros(nsteps,1);  % mean 2-D gas exit velocity at the vent (+ = outflow) [m/s]
% K2CO3 yield histories (as MASS FRACTION of the original charge):
hist_K2frac=zeros(nsteps,1); % TOTAL K2CO3 produced so far / charge mass  [-]
hist_K2cold=zeros(nsteps,1); % K2CO3 currently BELOW 891 C (condensed smoke) / charge mass [-]
cellVol  = (XMAX/NPI)*(YMAX/NPJ);
Dy       = YMAX/NPJ;
smoke_vent = 0.;          % cumulative vented K2CO3 that condenses (smoke) [kg/m depth]
t_burn   = NaN;           % time when ~fully burned (meanYfu<0.05)
frameEvery = max(1, round(nsteps/50));   % ~50 animation/live-plot frames over the whole run
if doGif, figAnim = figure('Name',sprintf('burn xKN=%.2f',xKN)); end
if doPlots, figK2 = figure('Name',sprintf('K2CO3 yield xKN=%.2f',xKN)); end   % LIVE K2CO3 graphs
istep = 0;
gifStarted = false;        % becomes true after the first GIF frame is written

% Field SNAPSHOTS (saved as plain data, no rendering). These let the
% temperature/K2CO3/velocity evolution be re-plotted or animated OUTSIDE MATLAB
% (e.g. in Python) if MATLAB's figure renderer misbehaves - the data is always
% captured even when on-screen plotting comes out blank.
snap_t = [];  snapT = [];  snapYK2 = [];  snapU = [];  snapV = [];

% --- FIXED plotting scales (so colour bars / arrow lengths do NOT shift -----
% between animation frames). All are constants for the whole run.
T_CLIM    = [TAMB, ceil((TAMB+dTad)/50)*50];     % temperature colour range [K]
PDEV_REF  = 1e-4;                                % Pa, floor for signed-log pressure colour scale
PDS_MAX   = log10(1 + 2.0/PDEV_REF);            % fixed signed-log colour limit (~4.3; peak dev ~1.7 Pa)
V_REF     = 1e-4;                                % vel. scale: arrows shrink below this [m/s]
V_LOGMAX  = log10(1 + 0.5/V_REF);                % normaliser (expected peak ~0.5 m/s)
ARROW_LEN = 1.6*min(XMAX/NPI, YMAX/NPJ);         % longest arrow in data units (~1.6 cells)

%% ---- time loop -----------------------------------------------------------
for time = Dt:Dt:TOTAL_TIME
    istep = istep + 1;  iter = 0;

    % store previous-time-level fields ONCE per step (backward-Euler transient).
    % rho_old in particular must be the previous step's density so the
    % expansion term (rho_old-rho) in pccoeff is non-zero.
    u_old=u; v_old=v; pc_old=pc; T_old=T; Yfu_old=Yfu; YK2_old=YK2; rho_old=rho;

    % natural-convection coefficients (analytical, no-wind; vary with T_case)
    Twg    = (mean(T(2,2:NPJ+1)) + mean(T(2:NPI+1,2)) + mean(T(2:NPI+1,NPJ+1)))/3;
    h_wall = max(1.42*(max(Twg   - T_case,0)/Lc)^0.25, 2.);   % gas -> casing
    h_out  = max(1.42*(max(T_case - TAMB ,0)/Lc)^0.25, 2.);   % casing -> ambient (no wind)

    if time < t_ign, T(Iig,Jig) = Tig; end   % brief igniter; then natural propagation

    % --- (1) advance chemistry + energy to the new time level (once per step) -
    % Refresh the convective mass fluxes from the latest velocity first so the
    % scalar transport uses consistent F_u/F_v (convect also runs in pccoeff).
    derivatives();  convect();
    reaction();                 % sets wburn = local regression consumption rate [1/s]
    % Unburnt charge is SOLID and stationary -> no diffusion/convection of fuel.
    % It is simply consumed where the front is active (explicit, local update);
    % wburn is already capped at Yfu/Dt so Yfu cannot go negative.
    Yfu = max(Yfu - wburn*Dt, 0.0);
    YK2coeff(); for it=1:YK2_ITER, YK2 = solve(YK2,b,aE,aW,aN,aS,aP); end
    Tcoeff();   for it=1:T_ITER,   T   = solve(T,b,aE,aW,aN,aS,aP); end

    % --- (1b) LOW-MACH THERMODYNAMIC PRESSURE: the pressure-buildup model ------
    % In the low-Mach (zero-Mach-number) combustion formulation the pressure
    % splits into a spatially-UNIFORM thermodynamic part P_chamber(t) and the
    % small hydrodynamic field p(x,t) (solved by SIMPLE, drives the flow).
    % Integrating continuity over the whole fixed chamber volume gives the
    % chamber mass balance that IS the pressure-buildup model:
    %     dM_gas/dt = Sgen_mass - mdot_vent(P_chamber)
    % with the ideal-gas closure   M_gas = P_chamber * C_T,
    %     C_T = (1/R) * sum(Vcell / T)      ["gas capacity" of the box, kg/Pa/m]
    % The burn converts SOLID propellant to gas at the REAL (measured) rate
    %     Sgen_mass = f_gas * rho_solid * sum(wburn) * Vcell        [kg/s/m]
    % and the orifice vents
    %     mdot_vent = Cd*A_vent*sqrt(2*rho_v*(P_chamber-P_ATM)),  rho_v=P_chamber/(R*Tvent).
    % Gas generated faster than it can vent RAISES P_chamber - that is the
    % pressure buildup. This lumped balance carries the REAL solid-density
    % generation safely (it is a 0-D ODE, no cell-level divergence), and is solved
    % semi-implicitly (mdot_vent depends on the unknown P_chamber) by an
    % under-relaxed fixed-point iteration. P_chamber feeds the gas density via the
    % EOS (density.m), so the rising chamber pressure is felt by the 2-D field as a
    % gentle bulk density increase. NOTE: the full solid-density source cannot be
    % injected into the 2-D continuity (pccoeff) - at 2 mm resolution it is a
    % sub-grid surface feature ~2000 kg/m3/s per front cell and sends the velocity
    % field to NaN regardless of this global closure; the 2-D source therefore
    % stays on gas density and this block is the authoritative pressure model.
    % See pressure_model.md.
    C_T       = sum(sum(cellVol ./ max(T(2:NPI+1,2:NPJ+1), SMALL))) / R_GAS;       % [kg/Pa/m]
    Sgen_mass = f_gas * rho_solid * sum(sum(wburn(2:NPI+1,2:NPJ+1))) * cellVol;    % [kg/s/m]
    Tvent_n   = mean(T(2,Jvent1:Jvent2));
    P0 = P_chamber;
    for itP = 1:30
        rho_v     = P0/(R_GAS*Tvent_n);
        mdot_vent = Cd*A_vent*sqrt(2.*rho_v*max(P0-P_ATM,0.));
        M_gas_new = M_gas + Dt*(Sgen_mass - mdot_vent);          % chamber gas mass at n+1
        P0        = P0 + relax_P*(M_gas_new/C_T - P0);           % under-relaxed fixed point
    end
    rho_v     = P0/(R_GAS*Tvent_n);
    mdot_vent = Cd*A_vent*sqrt(2.*rho_v*max(P0-P_ATM,0.));        % converged vent flux
    M_gas     = max(M_gas + Dt*(Sgen_mass - mdot_vent), 1e-12);  % commit conserved gas mass
    P_chamber = max(M_gas/C_T, 0.5*P_ATM);                       % thermodynamic pressure
    M_solid   = max(M_solid - Sgen_mass*Dt, 0.);                 % deplete the charge (gas part)

    % --- (2) update density + transport properties from the new T (ONCE) ------
    % Done once per step (NOT inside the SIMPLE loop) so the thermal-expansion
    % source (rho_old - rho) in pccoeff is non-zero AND held fixed while the flow
    % is solved. The OLD code updated density AFTER pccoeff and ran a single
    % iteration, so pccoeff always saw a zero source: the vent outflow was set
    % but the interior never developed a flow toward the vent. See density.m.
    density();
    mu(1:NPI+2,2:NPJ+1)    = (0.0395*T(1:NPI+2,2:NPJ+1) + 6.58)*1.E-6;
    % Effective thermal conductivity: SOLID (lambda_solid) where unburnt, gas
    % conductivity where burnt, blended by Yfu. Gamma = lambda_eff/Cp is the
    % diffusion coefficient of the (Cp-divided) energy equation.
    lam_gas = 6.1E-5*T(1:NPI+2,2:NPJ+1) + 8.4E-3;                      % hot-gas conductivity [W/m/K]
    lam_eff = Yfu(1:NPI+2,2:NPJ+1)*lambda_solid + (1-Yfu(1:NPI+2,2:NPJ+1)).*lam_gas;
    Gamma(1:NPI+2,2:NPJ+1) = lam_eff ./ Cp(1:NPI+2,2:NPJ+1);
    viscosity();  bound();

    % --- (3) SIMPLE: iterate momentum + pressure-correction to continuity -----
    % With the expansion source now live and FIXED, pccoeff develops a pressure
    % gradient from the hot expanding cells to the vent and velcorr drives the
    % interior gas toward the outlet (the chamber-wide flow that was missing).
    % Converges on the real continuity residual instead of a stale zero.
    SMAX = LARGE;  SAVG = LARGE;  iter = 0;
    while iter < MAX_ITER && SMAX > SMAXneeded && SAVG > SAVGneeded
        derivatives();
        ucoeff();  for it=1:U_ITER, u = solve(u,b,aE,aW,aN,aS,aP); end
        vcoeff();  for it=1:V_ITER, v = solve(v,b,aE,aW,aN,aS,aP); end
        bound();
        pccoeff(); for it=1:PC_ITER, pc = solve(pc,b,aE,aW,aN,aS,aP); end
        velcorr();
        bound();
        iter = iter + 1;
    end

    % --- vent / flow diagnostics ---------------------------------------------
    % m_gen_th = thermal-expansion source, m_vent_th = mass actually leaving the
    % vent; with the corrected timestep order these track each other (the 2-D
    % flow now conserves mass) while the chamber pressurises thermodynamically
    % via P_chamber. Pfield is the small hydrodynamic pressure that drives the
    % interior flow toward the vent (~Pa; tiny vs P_chamber, as expected low-Mach).
    Pfield_max = max(max(p(2:NPI+1,2:NPJ+1)));                                       % peak gauge over-pressure [Pa]
    m_gen_th   = sum(sum(rho_old(2:NPI+1,2:NPJ+1)-rho(2:NPI+1,2:NPJ+1)))*cellVol/Dt; % thermal-expansion source [kg/s/m]
    m_vent_th  = 0.;
    for J = Jvent1:Jvent2
        m_vent_th = m_vent_th + rho(2,J)*max(-u(2,J),0.)*Dy;                         % actual vented flux [kg/s/m]
    end

    % --- casing temperature update (finite thermal mass; self-limiting cooling)
    Dxc = XMAX/NPI;  Dyc = YMAX/NPJ;
    Qin  = h_wall*( sum(T(2,2:NPJ+1)-T_case)*Dyc ...            % west wall
                  + sum(T(2:NPI+1,2)-T_case)*Dxc ...            % bottom wall
                  + sum(T(2:NPI+1,NPJ+1)-T_case)*Dxc );         % top wall
    Qout = h_out*Lwall*(T_case - TAMB);                          % casing -> ambient
    T_case = T_case + Dt*(Qin - Qout)/C_case;

    % --- gas generation / vent diagnostics ------------------------------------
    % P_chamber, M_gas, M_solid and the vent flux (mdot_vent, rho_v) were already
    % advanced in the low-Mach pressure solve (1b) above. Here we only record
    % diagnostics. Two DIFFERENT velocities are reported on purpose: u_exit_2d is
    % the slow internal low-Mach circulation in the 2-D field (gas-density source),
    % while u_vent_orifice is the physical discharge speed from the P_chamber
    % closure (1b). The latter is the one to compare with real grenades.
    r_burn      = a_burn*(max(P_chamber,P_ATM)/1e6)^n_burn / 1000.;  % regression rate [m/s] (burn-time ETA)
    meanYfu_now = mean(mean(Yfu(2:NPI+1,2:NPJ+1)));
    Mdot_gen    = Sgen_mass;                                    % real gas-generation rate [kg/s/m]
    u_exit_2d      = mean(max(-u(2,Jvent1:Jvent2), 0.));       % 2-D vent speed (from the flow) [m/s]
    u_vent_orifice = mdot_vent/(rho_v*A_vent + SMALL);         % 0-D orifice estimate [m/s]

    hist_t(istep)    = time;
    hist_Tmax(istep) = max(max(T(2:NPI+1,2:NPJ+1)));

    % stop cleanly on divergence (instead of pages of NaN; note the Yfu clamp
    % hides NaN as 1.0, so check T here)
    if ~isfinite(hist_Tmax(istep))
        fprintf('\n** DIVERGED (NaN) at step %d, t=%.3f s. Try lowering relax_rho or Dt. **\n', istep, time);
        break;
    end
    hist_Tvent(istep)= mean(T(2,Jvent1:Jvent2));
    hist_K2(istep)   = sum(sum(rho(2:NPI+1,2:NPJ+1).*YK2(2:NPI+1,2:NPJ+1)))*cellVol;
    hist_uv(istep)   = u_vent_orifice;                 % orifice vent velocity [m/s]
    hist_P(istep)    = P_chamber;
    hist_Pfield(istep) = Pfield_max;                   % peak 2-D gauge over-pressure [Pa]
    % predicted gas exit velocity (gas generated / vent-gas density / vent area).
    % This is the physical efflux speed implied by the burn (to benchmark vs
    % real grenades). The 2-D field velocity is the low-Mach flow pattern only.
    hist_uexit(istep)= u_exit_2d;                      % 2-D vent exit velocity [m/s]

    % --- K2CO3 yield as MASS FRACTION of the charge (the two LIVE graphs) ---
    % K2CO3 is produced in proportion to the charge consumed: yK2 kg per kg
    % propellant. The consumed fraction of a cell is (1-Yfu); averaged over all
    % cells it is the burnt fraction of the whole grain. Multiplying by yK2 gives
    % the K2CO3 mass produced as a fraction of the original charge mass. The
    % "cold" version counts only the K2CO3 sitting in cells below 891 C (its
    % melting point) - i.e. the part that has CONDENSED into solid smoke.
    burned = 1 - Yfu(2:NPI+1,2:NPJ+1);                 % consumed fraction per cell
    Tcell  = T(2:NPI+1,2:NPJ+1);
    hist_K2frac(istep) = yK2 * sum(sum(burned))                  / (NPI*NPJ);  % total K2CO3
    hist_K2cold(istep) = yK2 * sum(sum(burned.*(Tcell < T_SMOKE)))/ (NPI*NPJ); % < 891 C only

    % --- SMOKE = condensed K2CO3 (below 891 C) -----------------------------
    % (1) inside the box: K2CO3 currently in cells colder than T_SMOKE
    Tin  = T(2:NPI+1,2:NPJ+1);
    cond_in = sum(sum( (Tin < T_SMOKE) .* rho(2:NPI+1,2:NPJ+1) .* YK2(2:NPI+1,2:NPJ+1) ))*cellVol;
    % (2) vented gas: cool it by mixing with a FIXED amount of ambient air; if
    %     that bounded mix is below T_SMOKE the K2CO3 leaving this step condenses
    Tmix = (1200.*hist_Tvent(istep) + ENTRAIN*Cp_air*TAMB)/(1200. + ENTRAIN*Cp_air);
    if Tmix < T_SMOKE
        for J = Jvent1:Jvent2
            uout = max(-u(2,J),0.);                  % outflow speed (u<0 = leaving west)
            smoke_vent = smoke_vent + rho(2,J)*uout*Dy*YK2(2,J)*Dt;
        end
    end
    hist_smoke(istep) = cond_in + smoke_vent;        % total condensed (smoke)

    meanYfu = mean(mean(Yfu(2:NPI+1,2:NPJ+1)));
    if isnan(t_burn) && M_solid <= 0, t_burn = time; end     % solid fully consumed (real burn time)
    if istep==1
        fprintf('step   time[s] iter  Tmax[K]  Tvent[K]  Pchamber[kPa]  Pfield[Pa]  Uexit[m/s]  Uvent0D[m/s]  K2CO3[kg]  meanYfu  SMAX\n');
    end
    fprintf('%5d %8.3f %4d %8.1f %8.1f %12.2f %10.2f %11.3e %11.3e %10.3e %7.4f %9.2e\n', istep, time, iter, ...
        hist_Tmax(istep), hist_Tvent(istep), P_chamber/1000, Pfield_max, hist_uexit(istep), hist_uv(istep), hist_K2(istep), meanYfu, SMAX);

    % periodic pressure / balance check. Two distinct things are reported:
    %  - 2-D FLOW: the vent carries the thermal expansion, so m_gen ~ m_vent and
    %    the hydrodynamic field Pfield stays ~0 (expected in a low-Mach model).
    %  - CHAMBER: P_chamber rises whenever the burn generates gas faster than the
    %    orifice vents it (Mdot_gen > mdot_vent); dP = P_chamber - P_ATM is the
    %    "small pressure buildup" we set out to observe (now coupled via density).
    if mod(istep,frameEvery)==0
        dPkPa = (P_chamber - P_ATM)/1000.;
        fprintf(['   >> t=%.3f s | 2-D flow: m_gen=%+.2e m_vent=%+.2e kg/s/m (Pfield=%.1f Pa) | ' ...
                 'chamber: Mdot_gen=%+.2e mdot_vent=%+.2e kg/s/m -> dP=%+.2f kPa\n'], ...
            time, m_gen_th, m_vent_th, Pfield_max, Mdot_gen, mdot_vent, dPkPa);
    end

    % --- field snapshot (pure data, ALWAYS captured - independent of rendering) -
    if mod(istep,frameEvery)==0 || istep==nsteps
        snap_t(end+1)      = time;
        snapT(:,:,end+1)   = T;     snapYK2(:,:,end+1) = YK2;
        snapU(:,:,end+1)   = u;     snapV(:,:,end+1)   = v;
    end

    if doGif && (mod(istep,frameEvery)==0 || istep==nsteps)
      try
        figure(figAnim); clf;
        % cell-centred velocities for a clean quiver (u,v live on cell faces)
        ug = zeros(NPI+2,NPJ+2);  vg = zeros(NPI+2,NPJ+2);
        ug(2:NPI+1,:) = 0.5*(u(2:NPI+1,:) + u(3:NPI+2,:));
        vg(:,2:NPJ+1) = 0.5*(v(:,2:NPJ+1) + v(:,3:NPJ+2));
        % Hydrodynamic pressure relative to the domain mean. The SIMPLE pressure
        % field p carries an arbitrary uniform offset (the level is undetermined
        % in an all-walls box); only the spatial VARIATION drives the flow, so we
        % subtract the mean to reveal the structure that matches the velocity.
        % (Absolute pressure = this tiny field + the ~uniform chamber pressure.)
        pp = p;  pmean = mean(mean(p(2:NPI+1,2:NPJ+1)));
        pp(1,:)=pp(2,:); pp(NPI+2,:)=pp(NPI+1,:); pp(:,1)=pp(:,2); pp(:,NPJ+2)=pp(:,NPJ+1);
        % log-scaled velocity arrows: direction kept, length = normalised
        % log10(1+speed/V_REF) so weak far-field flow is visible next to the fast
        % vent jet. Fixed scaling (constants above) => arrow lengths are
        % comparable BETWEEN frames, not re-autoscaled each frame.
        spg = hypot(ug,vg);
        Lng = log10(1 + spg/V_REF) / V_LOGMAX;             % normalised 0..~1
        uqg = ug ./ max(spg,SMALL) .* Lng * ARROW_LEN;
        vqg = vg ./ max(spg,SMALL) .* Lng * ARROW_LEN;
        subplot(3,1,1); contourf(x,y,T',20,'LineColor','none'); colormap(jet); colorbar;
        clim(T_CLIM);                                       % FIXED temperature scale
        title(sprintf('Temperature [K]   t=%.3f s   (xKN=%.2f)',time,xKN)); axis equal tight; ylabel('y [m]');
        % signed-log of the deviation: |dev| spans ~1000x over the run, so a
        % linear scale washes out all but the ignition spike. sign*log10(1+|dev|/ref)
        % keeps sign and shows structure at every magnitude; FIXED clim = stable colours.
        pds = sign(pp-pmean) .* log10(1 + abs(pp-pmean)/PDEV_REF);
        subplot(3,1,2); contourf(x,y,pds',20,'LineColor','none'); colorbar;
        clim([-PDS_MAX PDS_MAX]);                           % FIXED signed-log scale
        title(sprintf('Gauge pressure (signed log_{10}, ref %.0e Pa)   (chamber P = %.2f kPa)',PDEV_REF,P_chamber/1000)); axis equal tight; ylabel('y [m]');
        subplot(3,1,3); quiver(x,y,uqg',vqg',0,'Color',[0 0 0.6]); axis equal tight;
        xlim([0 XMAX]); ylim([0 YMAX]);
        title('Velocity (log-scaled arrows; out the vent during burn, inward as it cools)'); xlabel('x [m]'); ylabel('y [m]');
        drawnow;
        % Render the frame from the FIGURE OBJECT (print -RGBImage), not the
        % screen. getframe() screen-scrapes, so it returns a blank frame whenever
        % the window is occluded / unfocused / minimised during the run - which is
        % what produced the empty GIF/figures. print/exportgraphics are immune.
        cdata = print(figAnim,'-RGBImage','-r80'); [A,map] = rgb2ind(cdata,256);
        if ~gifStarted
            imwrite(A,map,giffile,'gif','LoopCount',Inf,'DelayTime',0.05);
            gifStarted = true;
        else
            imwrite(A,map,giffile,'gif','WriteMode','append','DelayTime',0.05);
        end
      catch ME_gif
        % Rendering failed (e.g. broken OpenGL) - do NOT abort the run; the
        % simulation and all data/snapshots are still written. Warn once.
        if ~gifStarted
            fprintf('  [plot] animation rendering failed (%s) - continuing; data + snapshots.mat still saved.\n', ME_gif.message);
            gifStarted = true;   % suppress repeat warnings
        end
      end
    end

    % --- LIVE K2CO3 graphs: total produced, and only the part below 891 C -----
    if doPlots && (mod(istep,frameEvery)==0 || istep==nsteps)
      try
        figure(figK2); clf;
        subplot(2,1,1);
        plot(hist_t(1:istep), hist_K2frac(1:istep), 'b-', 'LineWidth',1.5); grid on;
        ylabel('K_2CO_3 mass frac [-]'); xlim([0 TOTAL_TIME]); ylim([0 max(1.05*yK2,1e-3)]);
        title(sprintf('Total K_2CO_3 produced (xKN=%.2f)   t=%.2f s', xKN, time));
        subplot(2,1,2);
        plot(hist_t(1:istep), hist_K2cold(1:istep), 'r-', 'LineWidth',1.5); grid on;
        xlabel('t [s]'); ylabel('K_2CO_3 < 891\circC [-]'); xlim([0 TOTAL_TIME]); ylim([0 max(1.05*yK2,1e-3)]);
        title('Condensed K_2CO_3 below 891 \circC (usable smoke)');
        drawnow;
      catch ME_k2
        if istep<=frameEvery, fprintf('  [plot] K2CO3 live graph failed (%s) - continuing.\n', ME_k2.message); end
      end
    end

    SMAX = LARGE;  SAVG = LARGE;
end

%% ---- save data (always) --------------------------------------------------
fp = fopen(fullfile(resdir,'grenade_output.txt'),'w');
for I = 1:NPI+2
    for J = 1:NPJ+2
        fprintf(fp,'%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\n', ...
            x(I), y(J), T(I,J), YK2(I,J), Yfu(I,J), ...
            0.5*(u(I,J)+u(min(I+1,NPI+2),J)), 0.5*(v(I,J)+v(I,min(J+1,NPJ+2))));
    end
    fprintf(fp,'\n');
end
fclose(fp);

fh = fopen(fullfile(resdir,'grenade_history.txt'),'w');
fprintf(fh,'# time[s]  Tmax[K]  Tvent[K]  totalK2CO3[kg]  Uvent0D[m/s]  smoke[kg]  Pchamber[Pa]  Pfield_max[Pa]  Uexit_pred[m/s]  K2frac_total[-]  K2frac_below891[-]\n');
for n = 1:nsteps
    fprintf(fh,'%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\n', hist_t(n),hist_Tmax(n),hist_Tvent(n),hist_K2(n),hist_uv(n),hist_smoke(n),hist_P(n),hist_Pfield(n),hist_uexit(n),hist_K2frac(n),hist_K2cold(n));
end
fclose(fh);

fpar = fopen(fullfile(resdir,'params.txt'),'w');
fprintf(fpar,'xKN=%.3f yK2=%.3f dTad=%.0f Tad=%.0f Tig=%.0f t_ign=%.2f relax_rho=%.3f h_wall=%.0f A=%.2e Ea=%.2e\n',xKN,yK2,dTad,TAMB+dTad,Tig,t_ign,relax_rho,h_wall,A_arr,Ea_arr);
fprintf(fpar,'NPI=%d NPJ=%d XMAX=%.3f YMAX=%.3f Dt=%.1e TOTAL_TIME=%.1f ventJ=%d..%d\n',NPI,NPJ,XMAX,YMAX,Dt,TOTAL_TIME,Jvent1,Jvent2);
fclose(fpar);

% Field snapshots for external (e.g. Python) plotting/animation - saved as
% MATLAB v7 so scipy.io.loadmat can read it. Always written, even if MATLAB's
% own figure rendering is broken. Contains: x, y, snap_t, snapT, snapYK2, snapU,
% snapV  (snap* are NPI+2 x NPJ+2 x nframes).
try
    save(fullfile(resdir,'snapshots.mat'),'x','y','snap_t','snapT','snapYK2','snapU','snapV', ...
         'hist_t','hist_K2frac','hist_K2cold','-v7');
catch ME_snap
    fprintf('  [save] snapshots.mat could not be written (%s).\n', ME_snap.message);
end

% Save the final K2CO3-yield figure (total + below-891 C) as a PNG.
if doPlots
    try
        exportgraphics(figK2, fullfile(resdir,'k2co3_yield.png'), 'Resolution',150);
    catch ME_k2png
        fprintf('  [plot] k2co3_yield.png could not be written (%s).\n', ME_k2png.message);
    end
end

%% ---- summary figure ------------------------------------------------------
if doPlots
  try
    figure('Name',sprintf('fields xKN=%.2f',xKN));
    ugf = zeros(NPI+2,NPJ+2);  vgf = zeros(NPI+2,NPJ+2);
    ugf(2:NPI+1,:) = 0.5*(u(2:NPI+1,:) + u(3:NPI+2,:));
    vgf(:,2:NPJ+1) = 0.5*(v(:,2:NPJ+1) + v(:,3:NPJ+2));
    spf  = hypot(ugf,vgf);                              % log-scaled arrows (as in the GIF)
    Lnf  = log10(1 + spf/V_REF) / V_LOGMAX;
    uqf  = ugf ./ max(spf,SMALL) .* Lnf * ARROW_LEN;
    vqf  = vgf ./ max(spf,SMALL) .* Lnf * ARROW_LEN;
    subplot(4,1,1); contourf(x,y,T',20,'LineColor','none'); colormap(jet); colorbar; clim(T_CLIM);
    title(sprintf('Temperature [K]  (xKN=%.2f)',xKN)); ylabel('y [m]'); axis equal tight;
    subplot(4,1,2); contourf(x,y,YK2',20,'LineColor','none'); colorbar; clim([0 1]);
    title('K_2CO_3 mass fraction [-]'); ylabel('y [m]'); axis equal tight;
    ppf = p;  pmeanf = mean(mean(p(2:NPI+1,2:NPJ+1)));   % gauge pressure rel. to mean (flow-driving structure)
    ppf(1,:)=ppf(2,:); ppf(NPI+2,:)=ppf(NPI+1,:); ppf(:,1)=ppf(:,2); ppf(:,NPJ+2)=ppf(:,NPJ+1);
    pdsf = sign(ppf-pmeanf) .* log10(1 + abs(ppf-pmeanf)/PDEV_REF);   % signed-log (as in the GIF)
    subplot(4,1,3); contourf(x,y,pdsf',20,'LineColor','none'); colorbar; clim([-PDS_MAX PDS_MAX]);
    title(sprintf('Gauge pressure (signed log_{10}, ref %.0e Pa)  (chamber P = %.2f kPa)',PDEV_REF,P_chamber/1000)); ylabel('y [m]'); axis equal tight;
    subplot(4,1,4); quiver(x,y,uqf',vqf',0,'Color',[0 0 0.6]); xlim([0 XMAX]); ylim([0 YMAX]);
    title('Velocity (log-scaled arrows; end snapshot = post-burn inflow)'); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
    % exportgraphics renders from the figure object (not a screen grab), so the
    % saved PNG is never blank even if the window was behind others when saving.
    exportgraphics(gcf, fullfile(resdir,'fields.png'), 'Resolution',150);
  catch ME_fig
    fprintf('  [plot] summary figure failed (%s) - data + snapshots.mat are still saved.\n', ME_fig.message);
  end
end

%% ---- results struct ------------------------------------------------------
R.xKN          = xKN;
R.r            = rmol;
R.yK2          = yK2;
R.dTad         = dTad;
R.Tmax_final   = hist_Tmax(end);
R.Tvent_final  = hist_Tvent(end);
R.Tvent_peak   = max(hist_Tvent);
R.K2CO3_total  = hist_K2(end);
R.smoke        = hist_smoke(end);     % condensed K2CO3 (< 891 C) = usable smoke
R.Ppeak        = max(hist_P);         % peak chamber pressure [Pa] (0-D lumped model)
R.Pfield_peak  = max(hist_Pfield);    % peak 2-D gauge over-pressure [Pa] (CFD field)
R.uexit_peak   = max(hist_uexit);     % peak 2-D gas exit velocity at the vent [m/s]
if isnan(t_burn), t_burn = XMAX/max(r_burn,1e-9); end  % projected from burn rate if not reached in TOTAL_TIME
R.t_burn       = t_burn;              % (projected) burn time = charge length / burn rate [s]
R.meanYfu_final= meanYfu;
R.resdir       = resdir;

fprintf('Done xKN=%.2f: Tmax=%.0f K, vent T=%.0f C, peak P=%.1f kPa (%.2f atm), burn time=%.2f s, K2CO3=%.3e, smoke=%.3e kg\n\n', ...
    xKN, R.Tmax_final, R.Tvent_final-273.15, R.Ppeak/1000, R.Ppeak/P_ATM, R.t_burn, R.K2CO3_total, R.smoke);
end
