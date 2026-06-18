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
    kappa ERough Ti TAMB A_arr Ea_arr Ru yK2 dTad Jvent1 Jvent2 P_ATM R_GAS relax_rho h_wall rho_solid

%% ---- numerical / geometry parameters -------------------------------------
NPI = 40;  NPJ = 24;  XMAX = 0.08;  YMAX = 0.05;
MAX_ITER = 50;
U_ITER=1; V_ITER=1; PC_ITER=30; T_ITER=1; YFU_ITER=1; YK2_ITER=1;
SMAXneeded = 1E-4;  SAVGneeded = 1E-5;
LARGE = 1E30;  SMALL = 1E-30;  U_IN = 0.0;
Cmu=0.09; sigmak=1.; sigmaeps=1.3; C1eps=1.44; C2eps=1.92; kappa=0.4187; ERough=9.793; Ti=0.04;

% Vent in the MIDDLE of the west wall (per sketch), ~25% of wall height.
nvent  = max(2, round(0.25*NPJ));
Jcen   = round((NPJ+2)/2);
Jvent1 = Jcen - floor(nvent/2);
Jvent2 = Jvent1 + nvent - 1;

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

% Ignition: a BRIEF hot kernel near the vent. The igniter fires for t_ign
% seconds and then STOPS; the exothermic reaction then propagates NATURALLY by
% conduction. (An energy audit confirmed this conduction-reaction front is
% self-sustaining and energy-conserving in 1-D and 2-D - no forcing needed.)
Tig   = 1500.0;       % igniter kernel temperature [K]
t_ign = 0.05;         % igniter ON for the first t_ign seconds, then released
Iig   = 2;                                 % igniter at the west boundary only (1 cell deep)
Jig   = max(2,Jcen-1):min(NPJ+1,Jcen+1);   % small spot at the wall, centred on the vent

% Variable-density (compressible / low-Mach) parameters. Density follows the
% ideal gas law (density.m, mirrored from the supplied wc3 solver); heating
% lowers density so the gas expands and is driven out of the vent. The
% coupling is stiff during fast combustion, hence the density under-relaxation.
P_ATM     = 101000.;  % reference (atmospheric) pressure [Pa]
R_GAS     = 287.;     % specific gas constant of the products [J/kg/K] (~air)
relax_rho = 0.05;     % density under-relaxation (0.15 diverged to NaN; 0.05 is stable)

% Chamber-pressure model: gas is generated at the SOLID density and vented
% through an orifice; if generation outpaces venting the chamber pressurises.
rho_solid = 1800.;    % solid propellant density [kg/m3] (KNSu)
Cd        = 0.6;      % orifice discharge coefficient [-]
relax_P   = 0.2;      % chamber-pressure under-relaxation (lower if pressure oscillates)
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

[yK2, dTad, rmol] = chemistry(xKN);
fprintf('Composition: %.0f%% KNO3 / %.0f%% sugar | r=%.2f mol | ', xKN*100, (1-xKN)*100, rmol);
fprintf('K2CO3 yield = %.1f wt%% | dTad = %.0f K | Tad = %.0f K\n', yK2*100, dTad, TAMB+dTad);

Dt = 1.0e-3;  TOTAL_TIME = 4.0;

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
hist_smoke=zeros(nsteps,1);  hist_P   = zeros(nsteps,1);
cellVol  = (XMAX/NPI)*(YMAX/NPJ);
Dy       = YMAX/NPJ;
smoke_vent = 0.;          % cumulative vented K2CO3 that condenses (smoke) [kg/m depth]
t_burn   = NaN;           % time when ~fully burned (meanYfu<0.05)
frameEvery = 40;
if doGif, figAnim = figure('Name',sprintf('burn xKN=%.2f',xKN)); end
istep = 0;

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

    while iter < MAX_ITER && SMAX > SMAXneeded && SAVG > SAVGneeded
        derivatives();
        ucoeff();  for it=1:U_ITER, u = solve(u,b,aE,aW,aN,aS,aP); end
        vcoeff();  for it=1:V_ITER, v = solve(v,b,aE,aW,aN,aS,aP); end
        bound();
        pccoeff(); for it=1:PC_ITER, pc = solve(pc,b,aE,aW,aN,aS,aP); end
        velcorr();

        reaction();
        Yfucoeff(); for it=1:YFU_ITER, Yfu = solve(Yfu,b,aE,aW,aN,aS,aP); end
        Yfu = max(min(Yfu,1.0),0.0);
        YK2coeff(); for it=1:YK2_ITER, YK2 = solve(YK2,b,aE,aW,aN,aS,aP); end
        Tcoeff();   for it=1:T_ITER,   T   = solve(T,b,aE,aW,aN,aS,aP); end

        density();                      % ideal-gas density update (wc3)
        % temperature-dependent transport properties (from wc3):
        mu(1:NPI+2,2:NPJ+1)    = (0.0395*T(1:NPI+2,2:NPJ+1) + 6.58)*1.E-6;
        Gamma(1:NPI+2,2:NPJ+1) = (6.1E-5*T(1:NPI+2,2:NPJ+1) + 8.4E-3)./Cp(1:NPI+2,2:NPJ+1);
        viscosity();  bound();

        iter = iter + 1;
    end

    % --- casing temperature update (finite thermal mass; self-limiting cooling)
    Dxc = XMAX/NPI;  Dyc = YMAX/NPJ;
    Qin  = h_wall*( sum(T(2,2:NPJ+1)-T_case)*Dyc ...            % west wall
                  + sum(T(2:NPI+1,2)-T_case)*Dxc ...            % bottom wall
                  + sum(T(2:NPI+1,NPJ+1)-T_case)*Dxc );         % top wall
    Qout = h_out*Lwall*(T_case - TAMB);                          % casing -> ambient
    T_case = T_case + Dt*(Qin - Qout)/C_case;

    % --- chamber-pressure update (ideal gas; gas generated minus vented) ---
    % Gas generation from the MEASURED burn-rate law r = a*P^n (regressing solid
    % surface), tracking remaining solid. This is the correct, slow rate.
    r_burn   = a_burn*(max(P_chamber,P_ATM)/1e6)^n_burn / 1000.;  % burn rate [m/s]
    Mdot_gen = rho_solid*A_burn*r_burn * (M_solid > 0);          % gas generated [kg/s/m]
    M_solid  = max(M_solid - Mdot_gen*Dt, 0.);
    Tvent_n  = mean(T(2,Jvent1:Jvent2));
    rho_v    = P_chamber/(R_GAS*Tvent_n);                        % vent-gas density
    dP       = max(P_chamber - P_ATM, 0.);
    mdot_vent= Cd*A_vent*sqrt(2.*rho_v*dP);                      % orifice outflow [kg/s/m]
    M_gas    = max(M_gas + (Mdot_gen - mdot_vent)*Dt, 1e-12);
    invT     = sum(sum(1./T(2:NPI+1,2:NPJ+1)));
    P_new    = M_gas*R_GAS/(cellVol*invT);                       % ideal gas, uniform P
    P_chamber= P_chamber + relax_P*(P_new - P_chamber);          % under-relaxed
    u_vent_orifice = mdot_vent/(rho_v*A_vent + SMALL);           % vent velocity [m/s]

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
        fprintf('step   time[s]  Tmax[K]  Tvent[K]  Pchamber[kPa]  Uvent[m/s]  K2CO3[kg]  meanYfu  SMAX\n');
    end
    fprintf('%5d %8.3f %8.1f %8.1f %12.2f %10.3e %10.3e %7.4f %9.2e\n', istep, time, ...
        hist_Tmax(istep), hist_Tvent(istep), P_chamber/1000, hist_uv(istep), hist_K2(istep), meanYfu, SMAX);

    if doGif && (mod(istep,frameEvery)==0 || istep==nsteps)
        figure(figAnim); clf;
        % cell-centred velocities for a clean quiver (u,v live on cell faces)
        ug = zeros(NPI+2,NPJ+2);  vg = zeros(NPI+2,NPJ+2);
        ug(2:NPI+1,:) = 0.5*(u(2:NPI+1,:) + u(3:NPI+2,:));
        vg(:,2:NPJ+1) = 0.5*(v(:,2:NPJ+1) + v(:,3:NPJ+2));
        pabs = p + P_chamber;                      % absolute pressure [Pa]
        subplot(3,1,1); contourf(x,y,T',20,'LineColor','none'); colormap(jet); colorbar;
        title(sprintf('Temperature [K]   t=%.3f s   (xKN=%.2f)',time,xKN)); axis equal tight; ylabel('y [m]');
        subplot(3,1,2); contourf(x,y,pabs',20,'LineColor','none'); colorbar;
        title('Absolute pressure [Pa]'); axis equal tight; ylabel('y [m]');
        subplot(3,1,3); quiver(x,y,ug',vg'); axis equal tight;
        title('Velocity [m/s]  (out the vent during burn; inward as it cools)'); xlabel('x [m]'); ylabel('y [m]');
        drawnow;
        Fr = getframe(gcf); [A,map] = rgb2ind(Fr.cdata,256);
        if istep==frameEvery
            imwrite(A,map,giffile,'gif','LoopCount',Inf,'DelayTime',0.15);
        else
            imwrite(A,map,giffile,'gif','WriteMode','append','DelayTime',0.15);
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
fprintf(fh,'# time[s]  Tmax[K]  Tvent[K]  totalK2CO3[kg]  Uvent[m/s]  smoke[kg]  Pchamber[Pa]\n');
for n = 1:nsteps
    fprintf(fh,'%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\n', hist_t(n),hist_Tmax(n),hist_Tvent(n),hist_K2(n),hist_uv(n),hist_smoke(n),hist_P(n));
end
fclose(fh);

fpar = fopen(fullfile(resdir,'params.txt'),'w');
fprintf(fpar,'xKN=%.3f yK2=%.3f dTad=%.0f Tad=%.0f Tig=%.0f t_ign=%.2f relax_rho=%.3f h_wall=%.0f A=%.2e Ea=%.2e\n',xKN,yK2,dTad,TAMB+dTad,Tig,t_ign,relax_rho,h_wall,A_arr,Ea_arr);
fprintf(fpar,'NPI=%d NPJ=%d XMAX=%.3f YMAX=%.3f Dt=%.1e TOTAL_TIME=%.1f ventJ=%d..%d\n',NPI,NPJ,XMAX,YMAX,Dt,TOTAL_TIME,Jvent1,Jvent2);
fclose(fpar);

%% ---- summary figure ------------------------------------------------------
if doPlots
    figure('Name',sprintf('fields xKN=%.2f',xKN));
    ugf = zeros(NPI+2,NPJ+2);  vgf = zeros(NPI+2,NPJ+2);
    ugf(2:NPI+1,:) = 0.5*(u(2:NPI+1,:) + u(3:NPI+2,:));
    vgf(:,2:NPJ+1) = 0.5*(v(:,2:NPJ+1) + v(:,3:NPJ+2));
    subplot(4,1,1); contourf(x,y,T',20,'LineColor','none'); colormap(jet); colorbar;
    title(sprintf('Temperature [K]  (xKN=%.2f)',xKN)); ylabel('y [m]'); axis equal tight;
    subplot(4,1,2); contourf(x,y,YK2',20,'LineColor','none'); colorbar;
    title('K_2CO_3 mass fraction [-]'); ylabel('y [m]'); axis equal tight;
    pabsf = p + P_chamber;                     % absolute pressure [Pa]
    subplot(4,1,3); contourf(x,y,pabsf',20,'LineColor','none'); colorbar;
    title('Absolute pressure [Pa]'); ylabel('y [m]'); axis equal tight;
    subplot(4,1,4); quiver(x,y,ugf',vgf');
    title('Velocity vectors [m/s] (note: end snapshot = post-burn inflow)'); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
    saveas(gcf, fullfile(resdir,'fields.png'));
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
R.Ppeak        = max(hist_P);         % peak chamber pressure [Pa]
if isnan(t_burn), t_burn = XMAX/max(r_burn,1e-9); end  % projected from burn rate if not reached in TOTAL_TIME
R.t_burn       = t_burn;              % (projected) burn time = charge length / burn rate [s]
R.meanYfu_final= meanYfu;
R.resdir       = resdir;

fprintf('Done xKN=%.2f: Tmax=%.0f K, vent T=%.0f C, peak P=%.1f kPa (%.2f atm), burn time=%.2f s, K2CO3=%.3e, smoke=%.3e kg\n\n', ...
    xKN, R.Tmax_final, R.Tvent_final-273.15, R.Ppeak/1000, R.Ppeak/P_ATM, R.t_burn, R.K2CO3_total, R.smoke);
end
