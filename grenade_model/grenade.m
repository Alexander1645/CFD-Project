%% Smoke grenade combustion model (4RC30 final assignment)
%
% Solves an unsteady, variable-density, LAMINAR reacting flow with the
% transient SIMPLE algorithm described in ch. 8.7.1 of "Computational
% Fluid Dynamics" by H.K. Versteeg and W. Malalasekera. The numerical
% structure (staggered grid, hybrid scheme, TDMA, SIMPLE) is taken from
% the course base code in ProjectInfo/code_final_assignment.
%
% Physical model (see README.md for details):
%  * Closed rectangular grenade casing with one venting hole in the left
%    wall near the top (see problem description sketch).
%  * The canister is filled with solid KNO3/sucrose composition, treated
%    with a ONE-PHASE approach: it is "gas" whose viscosity is enormous
%    and whose velocity is pinned to zero while unburnt, so that it
%    behaves as a solid.
%  * Species (Lecture 6 framework): mfu (sucrose), mox (KNO3), mk2
%    (K2CO3 smoke particulate); product gas mpr = 1 - mfu - mox - mk2.
%       48 KNO3 + 5 C12H22O11 -> 24 K2CO3 + 36 CO2 + 55 H2O + 24 N2
%  * Laminar flow -> the reaction sink is the KINETIC (Arrhenius) rate,
%    not the eddy break-up rate (Lecture 6: the slowest timescale
%    governs; without turbulence there is no eddy mixing timescale).
%  * NO forced combustion: an ignition kernel (hot pocket representing
%    the igniter charge, located at the propellant surface next to the
%    hole) starts the reaction; propagation into the bed is
%    self-sustained through conduction + Arrhenius kinetics.
%  * Gas generation: when solid burns the local density drops from RHOS
%    to the ideal-gas density; the term (rho_old-rho)/Dt*V enters the
%    pressure-correction equation as a mass source, and this is what
%    pushes the smoke out through the hole (no prescribed inlet).
%  * Walls are NOT adiabatic: every casing segment is a lumped thermal
%    mass (steel, thickness TWTH) heated by conduction from the interior
%    and cooled by natural convection on the outside (walltemp.m).
%
% Run "as is", or set any of the variables below beforehand to override
% (see sweep_composition.m). This script intentionally does NOT clear
% the workspace, so a sweep script can pass parameters in.

% ---- user-overridable run settings -------------------------------------
if ~exist('xKN','var'),        xKN        = 0.65;  end % KNO3 mass fraction of composition [-] (0.739 = stoichiometric)
if ~exist('TOTAL_TIME','var'), TOTAL_TIME = 0.50;  end % simulated time [s]
if ~exist('Dt_in','var'),      Dt_in      = 2.0E-5;end % time step [s]
if ~exist('NPI_in','var'),     NPI_in     = 60;    end % grid cells in x [-]
if ~exist('NPJ_in','var'),     NPJ_in     = 30;    end % grid cells in y [-]
if ~exist('RUNTAG','var'),     RUNTAG     = sprintf('xKN%03.0f',100*xKN); end
if ~exist('PLOTS','var'),      PLOTS      = true;  end % live plots during run
if ~exist('MAXIT_in','var'),   MAXIT_in   = 25;    end % max outer iterations
if ~exist('PCIT_in','var'),    PCIT_in    = 20;    end % pc inner iterations
close all

%% declare all global variables and constants
% constants
global NPI NPJ XMAX YMAX Dt LARGE SMALL P_ATM RUNIV TAMB ...
    DHOLE YHOLEC XGAP YFU0 TIGN IGNDEPTH JH1 JH2 ...
    S_ST WK2 DHFU AK EA MGAS RMAXF CAPFRAC ...
    RHOS RHOP CPMIX KSOL KGAS0 MUGAS0 MUSOLID SFPIN UOUTMAX ...
    RHOW CPW TWTH HEXT relax_u relax_v relax_pc relax_T relax_Y relax_uh
% variables
global x y y_v u v pc T mfu mox mk2 rho rho_old sf Rfu b SMAX SAVG ...
    aP aE aW aN aS F_u u_old v_old T_old mfu_old mox_old mk2_old ...
    TwB TwT TwL TwR u_hole m_gen

%% numerical settings
NPI        = NPI_in;    % number of grid cells in x-direction [-]
NPJ        = NPJ_in;    % number of grid cells in y-direction [-]
XMAX       = 0.12;      % length of the grenade interior [m]
YMAX       = 0.06;      % height of the grenade interior [m]
Dt         = Dt_in;     % time step [s]
MAX_ITER   = MAXIT_in;  % maximum number of outer iterations [-]
PC_ITER    = PCIT_in;   % number of inner iterations for pc equation [-]
SMAXneeded = 1E-5;      % maximum accepted error in mass balance [kg/s]
SAVGneeded = 1E-6;      % maximum accepted average error in mass balance [kg/s]
LARGE      = 1E30;      % arbitrary very large value [-]
SMALL      = 1E-30;     % arbitrary very small value [-]
relax_u    = 0.5;       % relaxation factor u (eq. 6.36)
relax_v    = relax_u;   % relaxation factor v (eq. 6.37)
relax_pc   = 1.1 - relax_u; % relaxation factor pressure correction (eq. 6.33)
relax_T    = 0.8;       % relaxation factor temperature
relax_Y    = 0.9;       % relaxation factor species
relax_uh   = 0.15;      % relaxation factor for the hole outflow velocity
relax_rho  = 0.5;       % relaxation factor for the density update

%% physical constants and geometry
P_ATM      = 101325.;   % atmospheric pressure [Pa]
RUNIV      = 8.314;     % universal gas constant [J/(mol K)]
TAMB       = 300.;      % ambient temperature [K]
DHOLE      = 0.012;     % height of the venting hole in the left wall [m]
YHOLEC     = YMAX-0.012;% centre of the hole: near the top of the left wall [m]
XGAP       = 0.012;     % gas gap between left wall and propellant surface [m]

%% composition and chemistry
% 48 KNO3 + 5 C12H22O11 -> 24 K2CO3 + 36 CO2 + 55 H2O + 24 N2
% mass basis: 1 kg fuel + 2.836 kg KNO3 -> 1.938 kg K2CO3 + 1.898 kg gas
YFU0       = 1 - xKN;   % initial fuel (sucrose) mass fraction in the solid [-]
S_ST       = 2.836;     % stoichiometric ratio: kg KNO3 per kg sucrose [-]
WK2        = 1.938;     % kg K2CO3 produced per kg sucrose burnt [-]
MGAS       = 0.0282;    % molar mass of the product gas (CO2/H2O/N2 mix) [kg/mol]
DHFU       = 8.0E6;     % heat of reaction per kg sucrose burnt [J/kg]
AK         = 1.0E6;     % Arrhenius pre-exponential factor [1/s]
EA         = 8.0E4;     % activation energy [J/mol] (ignition ~ 700 K)
RMAXF      = 4.0;       % fractional rate ceiling [1/s]: max kg fuel per kg
                        % mixture per second (cell burn time ~ 65 ms)
CAPFRAC    = 0.5;       % availability limiter (fraction of cell content per Dt) [-]

%% material properties (one-phase solid/gas treatment)
RHOS       = 50.;       % density of unburnt composition [kg/m3] (scaled, see README)
RHOP       = 2430.;     % density of K2CO3 particulate [kg/m3]
CPMIX      = 1500.;     % heat capacity (same for solid and gas) [J/(kg K)]
KSOL       = 4.0;       % EFFECTIVE thermal conductivity of the solid [W/(m K)]
                        % (regularised above the real ~0.4 so that the flame
                        % thickness sqrt(alpha*t_burn) is grid-resolvable;
                        % lumps radiative/dispersive preheating, see README)
KGAS0      = 0.026;     % gas thermal conductivity at 300 K [W/(m K)]
MUGAS0     = 1.8E-5;    % gas viscosity at 300 K [Pa s]
MUSOLID    = 1.0E3;     % viscosity given to the pseudo-solid [Pa s]
SFPIN      = 0.3;       % solid fraction above which velocities are pinned [-]
UOUTMAX    = 50.;       % safety clamp on the hole outflow velocity [m/s]

%% ignition (igniter charge next to the hole - NOT forced combustion)
TIGN       = 1100.;     % initial temperature of the ignition kernel [K]
IGNDEPTH   = 0.007;     % kernel reach into the propellant surface [m]

%% casing (conducting, non-adiabatic walls)
RHOW       = 7800.;     % steel density [kg/m3]
CPW        = 470.;      % steel heat capacity [J/(kg K)]
TWTH       = 0.001;     % casing wall thickness [m]
HEXT       = 15.;       % external natural-convection coefficient [W/(m2 K)]

%% start main function here
init();       % initialization
bound();      % apply boundary conditions

NSTEP  = ceil(TOTAL_TIME/Dt);
DV     = (XMAX/NPI)*(YMAX/NPJ);          % cell volume per metre depth [m3/m]
zeroS  = zeros(NPI+2,NPJ+2);
ventK2 = 0.;                             % K2CO3 vented through the hole [kg/m]
hist = struct('t',zeros(NSTEP,1),'iters',zeros(NSTEP,1),'uout',zeros(NSTEP,1),...
    'Tout',zeros(NSTEP,1),'Tmax',zeros(NSTEP,1),'msolid',zeros(NSTEP,1),...
    'mK2dom',zeros(NSTEP,1),'mK2cum',zeros(NSTEP,1),'mdot',zeros(NSTEP,1),...
    'Twmax',zeros(NSTEP,1));
outdir = fullfile('runs',RUNTAG);
if ~exist(outdir,'dir'), mkdir(outdir); end

fprintf('Smoke grenade model: xKN = %.3f, grid %dx%d, Dt = %.1e s, t_end = %.2f s (%d steps)\n',...
    xKN,NPI,NPJ,Dt,TOTAL_TIME,NSTEP);
fprintf('Progress prints every 25 steps; the first ~100 steps (ignition) are the slowest.\n');
fprintf('%6s %9s %5s %9s %8s %8s %8s %11s %11s\n',...
    'step','time[s]','iter','SMAX','u_out','T_out','T_max','solid[g/m]','K2CO3[g/m]');

if PLOTS % show the initial state right away, then refresh during the run
    figure(1); set(gcf,'Name','smoke grenade - live fields');
    plotresults(0,xKN); drawnow;
end

step = 0;
for time = Dt:Dt:TOTAL_TIME
    step = step + 1;
    iter = 0;

    % outer iteration loop (transient SIMPLE)
    while iter < MAX_ITER && SMAX > SMAXneeded && SAVG > SAVGneeded
        % chemistry, energy and species FIRST, so that the density change
        % (gas generation) enters this iteration's pressure correction
        reaction(); % Arrhenius kinetic rate Rfu from current T, mfu, mox

        Tcoeff();
        T = solve(T, b, aE, aW, aN, aS, aP);

        % species transport (Lecture 6), consumption implicit via SP < 0
        scacoeff(mfu, mfu_old, -Rfu./max(mfu,1e-8), zeroS);
        mfu = solve(mfu, b, aE, aW, aN, aS, aP);
        mfu = min(max(mfu,0),1);

        scacoeff(mox, mox_old, -S_ST*Rfu./max(mox,1e-8), zeroS);
        mox = solve(mox, b, aE, aW, aN, aS, aP);
        mox = min(max(mox,0),1);

        scacoeff(mk2, mk2_old, zeroS, WK2*Rfu);
        mk2 = solve(mk2, b, aE, aW, aN, aS, aP);
        mk2 = min(max(mk2,0),1);

        mixprops(relax_rho); % rho, mu, Gamma from new T and composition
        bound();      % updates the hole outflow from the new gas generation

        % momentum and continuity
        derivatives();
        ucoeff();
        u = solve(u, b, aE, aW, aN, aS, aP);

        vcoeff();
        v = solve(v, b, aE, aW, aN, aS, aP);

        bound();

        pccoeff();
        for iter_pc = 1:PC_ITER
            pc = solve(pc, b, aE, aW, aN, aS, aP);
        end

        velcorr(); % correct pressure and velocity

        iter = iter + 1;
    end

    walltemp(); % lumped casing temperature (conducting walls)

    % store data of current time level as "old" data for the next step
    u_old   = u;    v_old   = v;    T_old   = T;
    mfu_old = mfu;  mox_old = mox;  mk2_old = mk2;
    rho_old = rho;

    % monitors
    % K2CO3 leaving through the hole this step (outflow: F_u(2,J) < 0);
    % total production = inventory in the domain + what has vented
    for J = JH1:JH2
        ventK2 = ventK2 + max(-F_u(2,J),0)*(y_v(J+1)-y_v(J))*mk2(2,J)*Dt;
    end
    rhoi = rho(2:NPI+1,2:NPJ+1);
    hist.t(step)      = time;
    hist.iters(step)  = iter;
    hist.uout(step)   = u_hole;
    hist.Tout(step)   = sum(rho(1,JH1:JH2).*T(2,JH1:JH2))/max(sum(rho(1,JH1:JH2)),SMALL);
    hist.Tmax(step)   = max(max(T(2:NPI+1,2:NPJ+1)));
    hist.msolid(step) = sum(sum(rhoi.*sf(2:NPI+1,2:NPJ+1)))*DV;
    hist.mK2dom(step) = sum(sum(rhoi.*mk2(2:NPI+1,2:NPJ+1)))*DV;
    hist.mK2cum(step) = hist.mK2dom(step) + ventK2;
    hist.mdot(step)   = m_gen;
    hist.Twmax(step)  = max([max(TwB),max(TwT),max(TwL),max(TwR)]);

    if mod(step,25) == 0 || step == 1
        fprintf('%6d %9.4f %5d %9.2e %8.2f %8.1f %8.1f %11.2f %11.2f\n',...
            step,time,iter,SMAX,hist.uout(step),hist.Tout(step),...
            hist.Tmax(step),1000*hist.msolid(step),1000*hist.mK2cum(step));
        if ~all(isfinite(T(:))) || ~all(isfinite(u(:)))
            error('grenade:diverged','Non-finite field values at t = %g s.',time);
        end
    end
    if PLOTS && mod(step,100) == 0
        figure(1); plotresults(time,xKN); drawnow;
    end

    % reset SMAX and SAVG
    SMAX = LARGE;
    SAVG = LARGE;
end % end of calculation

%% output
hist.t      = hist.t(1:step);      hist.iters  = hist.iters(1:step);
hist.uout   = hist.uout(1:step);   hist.Tout   = hist.Tout(1:step);
hist.Tmax   = hist.Tmax(1:step);   hist.msolid = hist.msolid(1:step);
hist.mK2dom = hist.mK2dom(1:step); hist.mK2cum = hist.mK2cum(1:step);
hist.mdot   = hist.mdot(1:step);   hist.Twmax  = hist.Twmax(1:step);

save(fullfile(outdir,'results.mat'),'hist','xKN','NPI','NPJ','Dt',...
    'x','y','u','v','T','mfu','mox','mk2','rho','sf','TwB','TwT','TwL','TwR');

fh = figure('Visible','off','Position',[50 50 1250 650]);
plotresults(hist.t(end),xKN);
print(fh,fullfile(outdir,'fields.png'),'-dpng','-r140');
close(fh);

fh = figure('Visible','off','Position',[50 50 1000 700]);
subplot(2,2,1)
plot(hist.t,hist.Tout,'r-',hist.t,hist.Tmax,'k--',...
    [0 hist.t(end)],[1164 1164],'b:','LineWidth',1.2);
legend('T_{out}','T_{max}','891 C limit','Location','best');
xlabel('t [s]'); ylabel('T [K]'); title('gas temperatures'); grid on
subplot(2,2,2)
plot(hist.t,hist.uout,'LineWidth',1.2);
xlabel('t [s]'); ylabel('u_{out} [m/s]'); title('hole outflow velocity'); grid on
subplot(2,2,3)
plot(hist.t,1000*hist.mK2cum,'g-',hist.t,1000*hist.mK2dom,'g--','LineWidth',1.2);
legend('produced','in domain','Location','best');
xlabel('t [s]'); ylabel('K_2CO_3 [g/m]'); title('smoke particulate'); grid on
subplot(2,2,4)
plot(hist.t,1000*hist.msolid,'k-','LineWidth',1.2); hold on
yyaxis right; plot(hist.t,hist.Twmax,'m-');
ylabel('T_{wall,max} [K]');
yyaxis left; xlabel('t [s]'); ylabel('solid [g/m]');
title('unburnt composition / casing temperature'); grid on
print(fh,fullfile(outdir,'history.png'),'-dpng','-r140');
close(fh);

fid = fopen(fullfile(outdir,'history.txt'),'w');
fprintf(fid,'%9s %5s %10s %10s %10s %12s %12s %12s %10s\n','t[s]','iter',...
    'u_out[m/s]','T_out[K]','T_max[K]','solid[kg/m]','K2CO3[kg/m]','mdot[kg/sm]','Twmax[K]');
for n = 1:step
    fprintf(fid,'%9.5f %5d %10.3f %10.1f %10.1f %12.5e %12.5e %12.5e %10.1f\n',...
        hist.t(n),hist.iters(n),hist.uout(n),hist.Tout(n),hist.Tmax(n),...
        hist.msolid(n),hist.mK2cum(n),hist.mdot(n),hist.Twmax(n));
end
fclose(fid);

fprintf('\n==== run %s finished ====\n',RUNTAG);
fprintf('K2CO3 produced            : %.2f g per m depth (%.2f g vented)\n',...
    1000*hist.mK2cum(end),1000*ventK2);
fprintf('solid consumed            : %.1f %%\n',100*(1-hist.msolid(end)/max(hist.msolid(1),SMALL)));
fprintf('max outlet gas temperature: %.0f K  (target < 1164 K = 891 C)\n',max(hist.Tout));
fprintf('max casing temperature    : %.0f K\n',max(hist.Twmax));
fprintf('results in %s\n',outdir);

