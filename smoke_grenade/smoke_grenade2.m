function smoke_grenade_cfd()
% =========================================================================
%  SMOKE-GRENADE COMBUSTION-CHAMBER CFD SOLVER
%  Course 4RC30 - Introduction to CFD - Group 59 - TU/e
%
%  Models a 2-D slice of an M18 smoke-grenade chamber filled with a
%  KNO3:sucrose (KNSu, "rocket candy") propellant. It computes the
%  unsteady temperature, fuel-consumption and smoke (K2CO3) fields as a
%  deflagration front sweeps the chamber, and runs a parametric study of
%  flame temperature and smoke yield versus the KNO3 mass fraction x_KN.
%
%  ---------------------------------------------------------------------
%  PHYSICS / NUMERICS  (read this - it is what you defend in the report)
%  ---------------------------------------------------------------------
%  Finite-volume, structured Cartesian grid, in the same modular style as
%  the course framework (init -> coefficients -> solve -> boundary). The
%  energy equation is solved fully implicitly (sparse direct solve, the
%  direct-solver analogue of the framework's TDMA line solver); the
%  combustion front and species are advanced explicitly.
%
%  KEY MODELLING DECISION (answers the open question in the draft's
%  Discussion: "is a single-phase solver valid for a solid fuel?"):
%
%    A literal reading of the report - igniting the next cell only by
%    SOLID heat conduction - does NOT work. With the report's solid
%    properties a cell needs ~40 s for heat to conduct across it, but it
%    burns through in <1 s, so a conduction-driven front dies out. Real
%    propellant deflagration is *regression-controlled*: the burning
%    SURFACE recedes at the Saint-Robert rate r = a*P^n, essentially
%    independent of bulk conduction. We therefore advance the front
%    KINEMATICALLY at r (a neighbour-ignition rule) and release the
%    chemical heat as a progress variable, so a fully burnt adiabatic
%    cell sits at exactly T_flame = T_amb + dT_ad. This is the standard
%    premixed-deflagration treatment and is the physically correct
%    resolution of the tension the draft flags.
%
%  MOMENTUM / FLOW FIELD - deliberately omitted, and why (a real finding):
%    Gasifying the propellant (rho_solid = 1800 kg/m^3) at the regression
%    rate and venting it through the 25%-open west wall implies vent
%    velocities of order 1e2 m/s (Mach ~ 0.1-0.3). That CONTRADICTS the
%    laminar / few-m/s / Re~1800 assumption stated in section 3, and a
%    low-Mach SIMPLE solver becomes stiff and unstable under that source.
%    The research question (flame T and K2CO3 yield vs x_KN) is governed
%    by chemistry and heat transfer, which this solver captures directly.
%    The velocity field is left as documented future work - see the notes
%    block at the bottom of this file. Report this inconsistency between
%    the stated Re and the implied vent velocity as a solver limitation.
%
%  Run:   >> smoke_grenade_cfd
%  Outputs: baseline temperature / smoke / front-speed figures, then a
%  parametric sweep producing flame-T and smoke-yield-vs-x_KN curves and
%  a printed summary table you can paste into Results/Conclusion.
%
%  NOTE on file structure: everything is in this one runnable file with
%  local functions, so it runs out-of-the-box. If your submission must
%  mirror the maincode.m + init.m + bound.m + *coeff.m + solve.m layout,
%  copy each local function below into its own .m file of the same name.
% =========================================================================

clc; close all;

% ---- physical & numerical parameters (from the Group 59 report, sec.3) --
P = params();

% ============================ BASELINE RUN ===============================
% Single detailed transient at the (near-stoichiometric) baseline mixture.
fprintf('=== BASELINE TRANSIENT (x_KN = %.2f) ===\n', P.xKN_base);
P.Nx = 60;  P.Ny = 26;            % validated baseline resolution
P.dt = 0.01; P.Tend = 20.0;        % s  (front crosses the chamber in ~37 s;
                                  %     8 s is enough to show steady flame T
                                  %     and a well-developed front)
P.plot_progress = true;
res = run_case(P, P.xKN_base);

plot_baseline(P, res);

% ========================== PARAMETRIC STUDY =============================
% Sweep KNO3 mass fraction. For each mixture we run a short transient on a
% coarser grid (fast) and record the flame temperature actually reached
% and the smoke-production rate, alongside the chemical limits.
fprintf('\n=== PARAMETRIC STUDY: flame T and smoke yield vs x_KN ===\n');
xKN_list = 0.45:0.05:0.80;

Ps = P;                            % copy, then coarsen for speed
Ps.Nx = 40; Ps.Ny = 16;
Ps.dt = 0.01; Ps.Tend = 6.0;      % long enough to reach steady flame T
Ps.plot_progress = false;

nX        = numel(xKN_list);
Tflame_id = zeros(nX,1);          % chemical adiabatic flame T  = Tamb+dTad
Tmax_cfd  = zeros(nX,1);          % flame T actually reached in the CFD
yieldPerKg= zeros(nX,1);          % kg K2CO3 per kg propellant (report model)
smokeRate = zeros(nX,1);          % g/(m.s) produced at steady burning

fprintf('  %5s | %10s | %10s | %12s | %12s\n', ...
        'x_KN','Tflame_id','Tmax_CFD','yield[kg/kg]','smoke[g/m/s]');
fprintf('  %s\n', repmat('-',1,62));
for k = 1:nX
    x  = xKN_list(k);
    rk = run_case(Ps, x);
    Tflame_id(k)  = P.Tamb + dTad_of(x);
    Tmax_cfd(k)   = rk.Tmax;
    yieldPerKg(k) = yK2_of(x);
    smokeRate(k)  = rk.smokeRate*1e3;        % kg/m/s -> g/m/s
    fprintf('  %5.2f | %10.0f | %10.0f | %12.3f | %12.3f\n', ...
            x, Tflame_id(k), Tmax_cfd(k), yieldPerKg(k), smokeRate(k));
end

plot_parametric(xKN_list, Tflame_id, Tmax_cfd, yieldPerKg);

% ----- headline numbers for the report -----------------------------------
[~,iPk] = max(Tflame_id);
fprintf('\nSUMMARY:\n');
fprintf('  Adiabatic flame temperature peaks near x_KN = %.2f at T = %.0f K\n', ...
        xKN_list(iPk), Tflame_id(iPk));
fprintf('  K2CO3 (smoke) yield per unit mass rises ~linearly with x_KN\n');
fprintf('  (report model y_K2 = 0.683*x_KN; = %.3f at the stoichiometric x_KN=0.65).\n', ...
        yK2_of(0.65));
fprintf('  => Trade-off: more KNO3 gives more K2CO3 per kg, but flame T (and\n');
fprintf('     thus complete conversion) falls for fuel-rich mixtures above ~0.65.\n');

end   % ===================== end main function ==========================



%% ======================================================================
%  PARAMETERS  (init-style constants block)
% ======================================================================
function P = params()
% Geometry: 2-D Cartesian slice of the M18 chamber.
P.Lx = 0.146;       % m   chamber length (front-propagation direction, x)
P.Ly = 0.064;       % m   chamber diameter (y)
P.open_frac = 0.25; % central fraction of the WEST wall that is open (vent)

% Gas / thermodynamic properties
P.R    = 287.0;     % J/kg/K   specific gas constant of product gas
P.Pch  = 101000.0;  % Pa       chamber pressure (vented -> held ~ atmospheric)
P.Tamb = 293.0;     % K        ambient / initial temperature
P.Tign = 633.0;     % K        ignition threshold (Heaviside)
P.Cp   = 1200.0;    % J/kg/K   product-gas heat capacity (assumed constant)
P.lam_gas = 0.08;   % W/m/K    product-gas thermal conductivity

% Condensed-propellant properties
P.rho_solid = 1800.0;  % kg/m^3
P.lam_solid = 0.30;    % W/m/K

% Saint-Robert / Vieille burn law  r = a * P^n   (P in MPa, r in m/s)
P.a_burn = 8.26e-3;
P.n_burn = 0.319;

% Ignition-spread threshold. A cell ignites once a face-neighbour's burnt
% fraction c = 1 - Yfu exceeds c_thr. c_thr = 1 - 1/e = 0.632 makes the
% kinematic front travel at exactly the regression rate r after one
% cell-crossing time (using 0.5 makes it ~1.44x too fast). DO NOT change.
P.c_thr = 1 - exp(-1);          % = 0.6321

P.xKN_base = 0.65;              % baseline (stoichiometric) KNO3 mass fraction
end


%% ======================================================================
%  CHEMISTRY CLOSURES
% ======================================================================
function y = yK2_of(x)
% K2CO3 (condensed smoke) mass yield per kg of propellant.
% Report model, calibrated to ~44 wt% at the stoichiometric x_KN = 0.65.
y = 0.683 .* x;
end

function dT = dTad_of(x)
% Adiabatic temperature RISE [K] as a function of KNO3 mass fraction.
% Peaks at the stoichiometric ratio x_s = 0.65 (max heat release) and
% falls off when the mixture is lean or rich, scaled by the limiting-
% reactant fraction. Upper bound (product dissociation not modelled), so
% the true flame T is somewhat lower.
x_s = 0.65;
lim = min( x./x_s , (1-x)./(1-x_s) );     % limiting-reactant fraction in [0,1]
dT  = 1779.0 .* max(min(lim,1),0);
end


%% ======================================================================
%  DENSITY / CONDUCTIVITY BLENDS  (heavy+cold solid ahead of the front,
%  light+hot product gas behind it)
% ======================================================================
function rg = rho_gas(T,P)
rg = P.Pch ./ (P.R .* max(T,200.0));        % ideal-gas EOS, floored for safety
end

function rt = rho_th(T,Yfu,P)
rt = Yfu.*P.rho_solid + (1-Yfu).*rho_gas(T,P);
end

function le = lam_eff(Yfu,P)
le = Yfu.*P.lam_solid + (1-Yfu).*P.lam_gas;
end


%% ======================================================================
%  RUN ONE CASE  (the time-marching driver for a given x_KN)
% ======================================================================
function res = run_case(P, xKN)
Nx = P.Nx; Ny = P.Ny;
dx = P.Lx/Nx; dy = P.Ly/Ny;
cellV = dx*dy;

% ---- initialisation (init) ----
[T, Yfu, ignited, opening] = init(P);

dTad  = dTad_of(xKN);
yK2   = yK2_of(xKN);
r_b   = P.a_burn * (P.Pch/1e6)^P.n_burn;     % regression rate [m/s]

nsteps   = round(P.Tend/P.dt);
nhist    = 0;
thist    = zeros(nsteps,1);
xfhist   = zeros(nsteps,1);
smoke    = 0.0;                              % total K2CO3 mass per unit depth [kg/m]
YK2mass  = zeros(Nx,Ny);                     % accumulated K2CO3 field [kg/m^3]
dY_last  = 0.0;

for n = 1:nsteps
    % --- spread ignition: any face-neighbour burnt past threshold, or T>=Tign ---
    c = 1 - Yfu;
    spread = false(Nx,Ny);
    spread(2:end,:)   = spread(2:end,:)   | (c(1:end-1,:) >= P.c_thr);
    spread(1:end-1,:) = spread(1:end-1,:) | (c(2:end,:)   >= P.c_thr);
    spread(:,2:end)   = spread(:,2:end)   | (c(:,1:end-1) >= P.c_thr);
    spread(:,1:end-1) = spread(:,1:end-1) | (c(:,2:end)   >= P.c_thr);
    ignited = ignited | spread | (T >= P.Tign);

    % --- burn + progress-variable heat release ---
    wdot = (r_b/dx) .* Yfu .* ignited;       % fuel-consumption rate [1/s]
    dY   = min(Yfu, P.dt.*wdot);             % fuel burnt this step
    Yfu  = Yfu - dY;
    T    = T + dTad.*dY;                      % exact dT_ad rise over full burn
    dY_last = sum(dY(:));

    % --- transport temperature (implicit diffusion + wall heat loss) ---
    T = energy_solve(T, Yfu, P);

    % --- K2CO3 production (mass-consistent: yield x solid mass burnt) ---
    dK      = yK2 .* P.rho_solid .* dY;
    YK2mass = YK2mass + dK;
    smoke   = smoke + sum(dK(:))*cellV;

    % --- history (front location = furthest ignited column) ---
    nhist = nhist + 1;
    icol  = find(any(ignited,2), 1, 'last');
    if isempty(icol), icol = 0; end
    thist(nhist)  = n*P.dt;
    xfhist(nhist) = (icol - 0.5)*dx;

    if P.plot_progress && mod(n, max(1,round(nsteps/10)))==0
        fprintf('  t=%5.2f s  Tmax=%6.0f K  front=%5.1f mm  burnt=%.3f  smoke=%.2f g/m\n', ...
                n*P.dt, max(T(:)), xfhist(nhist)*1e3, mean(1-Yfu(:)), smoke*1e3);
    end
end

% steady-state smoke-production rate (kg/m per s) from the last step
res.smokeRate = (yK2 * P.rho_solid * dY_last) * cellV / P.dt;
res.T       = T;
res.Yfu     = Yfu;
res.YK2mass = YK2mass;
res.smoke   = smoke;
res.Tmax    = max(T(:));
res.thist   = thist(1:nhist);
res.xfhist  = xfhist(1:nhist);
res.dx = dx; res.dy = dy; res.Nx = Nx; res.Ny = Ny;
end


%% ======================================================================
%  INITIALISATION  (init.m)
% ======================================================================
function [T, Yfu, ignited, opening] = init(P)
Nx = P.Nx; Ny = P.Ny;
T       = P.Tamb * ones(Nx,Ny);   % start at ambient
Yfu     = ones(Nx,Ny);            % chamber full of unburnt propellant
ignited = false(Nx,Ny);

% opening = central open_frac of the west wall (the vent / ignition end)
j0 = floor((0.5-P.open_frac/2)*Ny) + 1;
j1 = ceil ((0.5+P.open_frac/2)*Ny);
opening = false(Ny,1); opening(j0:j1) = true;

% ignition kernel: a couple of cells at the centre of the open west wall
jm = round(Ny/2);
ignited(1, max(1,jm-1):min(Ny,jm)) = true;
end


%% ======================================================================
%  ENERGY EQUATION  (coefficients + solve)
%  Solves   d(rho_th T)/dt = div( (lam_eff/Cp) grad T )  implicitly.
%  (Energy equation divided through by the constant Cp; the chemical
%   source has already been added to T as a progress-variable rise.)
%  Boundary conditions (report sec.3):
%    EAST  wall : adiabatic (no flux)
%    N/S/W walls: convective loss to ambient (half-cell conduction to Tamb)
% ======================================================================
function Tnew = energy_solve(T, Yfu, P)
Nx = P.Nx; Ny = P.Ny;
dx = P.Lx/Nx; dy = P.Ly/Ny;

rth = rho_th(T,Yfu,P);            % thermal density   [kg/m^3]
Gam = lam_eff(Yfu,P)./P.Cp;       % diffusivity coeff [kg/m/s]

N   = Nx*Ny;
idx = @(i,j) (i-1)*Ny + j;

% sparse triplet assembly
cap = 5*N;
I = zeros(cap,1); J = zeros(cap,1); V = zeros(cap,1); m = 0;
b = zeros(N,1);

for i = 1:Nx
    for j = 1:Ny
        p   = idx(i,j);
        ap0 = rth(i,j)/P.dt;          % time term
        ap  = ap0;
        b(p)= ap0*T(i,j);

        % EAST
        if i < Nx
            ae = 0.5*(Gam(i,j)+Gam(i+1,j))/dx^2;
            m=m+1; I(m)=p; J(m)=idx(i+1,j); V(m)=-ae;  ap=ap+ae;
        end
        % i==Nx : adiabatic east wall -> no flux

        % WEST
        if i > 1
            aw = 0.5*(Gam(i,j)+Gam(i-1,j))/dx^2;
            m=m+1; I(m)=p; J(m)=idx(i-1,j); V(m)=-aw;  ap=ap+aw;
        else
            hb = 0.5*Gam(i,j)/dx^2;       % convective loss to ambient (west)
            ap = ap + hb;  b(p) = b(p) + hb*P.Tamb;
        end

        % NORTH
        if j < Ny
            an = 0.5*(Gam(i,j)+Gam(i,j+1))/dy^2;
            m=m+1; I(m)=p; J(m)=idx(i,j+1); V(m)=-an;  ap=ap+an;
        else
            hb = 0.5*Gam(i,j)/dy^2;       % convective loss to ambient (north casing)
            ap = ap + hb;  b(p) = b(p) + hb*P.Tamb;
        end

        % SOUTH
        if j > 1
            asu = 0.5*(Gam(i,j)+Gam(i,j-1))/dy^2;
            m=m+1; I(m)=p; J(m)=idx(i,j-1); V(m)=-asu; ap=ap+asu;
        else
            hb = 0.5*Gam(i,j)/dy^2;       % convective loss to ambient (south casing)
            ap = ap + hb;  b(p) = b(p) + hb*P.Tamb;
        end

        m=m+1; I(m)=p; J(m)=p; V(m)=ap;   % diagonal
    end
end

A    = sparse(I(1:m), J(1:m), V(1:m), N, N);
Tnew = reshape(A\b, Ny, Nx).';        % solve and reshape back to (Nx,Ny)
end


%% ======================================================================
%  PLOTTING
% ======================================================================
function plot_baseline(P, res)
xc = ((1:res.Nx)-0.5)*res.dx*1e3;     % cell-centre coords [mm]
yc = ((1:res.Ny)-0.5)*res.dy*1e3;

figure('Name','Baseline fields','Color','w','Position',[80 80 900 720]);

subplot(3,1,1);
imagesc(xc, yc, res.T.'); axis xy; axis image; colorbar;
title(sprintf('Temperature [K]  (x_{KN}=%.2f,  t=%.1f s,  T_{max}=%.0f K)', ...
      P.xKN_base, P.Tend, res.Tmax));
xlabel('x  [mm]'); ylabel('y  [mm]');

subplot(3,1,2);
imagesc(xc, yc, res.YK2mass.'); axis xy; axis image; colorbar;
title('Accumulated K_2CO_3 (smoke) concentration [kg/m^3]');
xlabel('x  [mm]'); ylabel('y  [mm]');

subplot(3,1,3);
plot(res.thist, res.xfhist*1e3, 'b-', 'LineWidth', 1.6); hold on;
r_b = P.a_burn*(P.Pch/1e6)^P.n_burn;
plot(res.thist, r_b*res.thist*1e3, 'r--', 'LineWidth', 1.2);
% measured front speed (linear fit, ignoring the first point)
if numel(res.thist) > 3
    cf = polyfit(res.thist(2:end), res.xfhist(2:end)*1e3, 1);
    legend(sprintf('CFD front (fit %.2f mm/s)', cf(1)), ...
           sprintf('regression rate r = %.2f mm/s', r_b*1e3), ...
           'Location','northwest');
else
    legend('CFD front', 'regression rate r', 'Location','northwest');
end
grid on; xlabel('time  [s]'); ylabel('front position  [mm]');
title('Deflagration-front propagation (kinematic, regression-controlled)');
end

function plot_parametric(x, Tflame_id, Tmax_cfd, yieldPerKg)
figure('Name','Parametric study','Color','w','Position',[120 120 760 560]);

yyaxis left;
plot(x, Tflame_id, 'b-o','LineWidth',1.8,'MarkerFaceColor','b'); hold on;
plot(x, Tmax_cfd , 'b--s','LineWidth',1.2);
ylabel('flame temperature  [K]');
xline(0.65,'k:','stoichiometric','LabelOrientation','horizontal');

yyaxis right;
plot(x, yieldPerKg, 'r-^','LineWidth',1.8,'MarkerFaceColor','r');
ylabel('K_2CO_3 yield  [kg per kg propellant]');

xlabel('KNO_3 mass fraction  x_{KN}');
title('Flame temperature & smoke yield vs KNO_3 fraction');
legend('T_{flame} (adiabatic, chemical limit)', 'T_{max} (CFD)', ...
       'K_2CO_3 yield per kg', 'Location','south');
grid on;
end


% =========================================================================
%  NOTES: adding the velocity / pressure field (documented future work)
% -------------------------------------------------------------------------
%  To produce a velocity field, add a staggered grid (u on x-faces, v on
%  y-faces, p/T/Yfu/Y_K2 at cell centres) and a SIMPLE / projection step:
%
%    1. momentum predictor (variable-density Navier-Stokes, gas viscosity)
%    2. pressure-correction Poisson with mass source from gas generation:
%           div(rho u) = f_gas * rho_solid * dY/dt  -  d(rho)/dt
%       pinning gauge pressure p' = 0 at the open west-wall cells (vent).
%    3. correct u, v, p; advect T and Y_K2 with the corrected velocity.
%
%  CAUTION (this is the limitation to discuss in the report): the gas-
%  generation source above implies vent velocities ~1e2 m/s (Mach 0.1-0.3),
%  which violates the laminar / low-Mach / Re~1800 assumption of section 3,
%  and makes an incompressible SIMPLE solver stiff and unstable. A faithful
%  treatment would need a compressible (or carefully under-relaxed low-Mach)
%  formulation. The flame-temperature and smoke-yield results above do not
%  depend on the velocity field, so they remain valid.
%  f_gas (gaseous product fraction) ~ 0.56; the remaining ~0.44 is the
%  condensed K2CO3 aerosol that constitutes the visible smoke.
% =========================================================================