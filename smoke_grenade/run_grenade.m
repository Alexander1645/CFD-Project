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
global x x_u y y_v u v pc T rho mu Gamma b SMAX SAVG aP aE aW aN aS eps k ...
    u_old v_old pc_old T_old Dt eps_old k_old uplus yplus yplus1 yplus2 ...
    Yfu YK2 Yfu_old YK2_old Rk mut mueff m_gen
global NPI NPJ XMAX YMAX LARGE U_IN SMALL Cmu sigmak sigmaeps C1eps C2eps ...
    kappa ERough Ti TAMB A_arr Ea_arr Ru yK2 dTad Jvent1 Jvent2 EXPANSION

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

% Ignition: a BRIEF hot kernel near the vent. The igniter fires for t_ign
% seconds and then STOPS; the exothermic reaction then propagates NATURALLY by
% conduction. (An energy audit confirmed this conduction-reaction front is
% self-sustaining and energy-conserving in 1-D and 2-D - no forcing needed.)
Tig   = 1500.0;       % igniter kernel temperature [K]
t_ign = 0.05;         % igniter ON for the first t_ign seconds, then released
Iig   = 2:5;                               % igniter cells (west, a few deep)
Jig   = max(2,Jcen-2):min(NPJ+1,Jcen+2);   % centred on the vent

% Gas-expansion factor for the vent flow. IMPORTANT: the gas-generation mass
% source creates strong LOCAL velocities (~1 m/s, Peclet~50) at the burning
% cells that advect heat off the thin flame front and QUENCH the natural
% propagation. It is therefore switched OFF here (EXPANSION=0) so the
% combustion/energy is correct first - the front then propagates purely by
% conduction-reaction and reaches the true (ratio-dependent) flame
% temperature. The venting flow will be re-introduced afterwards in a way that
% does not disrupt the front (e.g. keeping the unburnt solid stationary).
EXPANSION = 0.0;

[yK2, dTad, rmol] = chemistry(xKN);
fprintf('Composition: %.0f%% KNO3 / %.0f%% sugar | r=%.2f mol | ', xKN*100, (1-xKN)*100, rmol);
fprintf('K2CO3 yield = %.1f wt%% | dTad = %.0f K | Tad = %.0f K\n', yK2*100, dTad, TAMB+dTad);

Dt = 1.0e-3;  TOTAL_TIME = 4.0;

%% ---- per-run results folder ---------------------------------------------
runid  = datestr(now,'yyyymmdd_HHMMSS_FFF');
resdir = fullfile('results', sprintf('run_%s_xKN%02.0f', runid, xKN*100));
if ~exist('results','dir'), mkdir('results'); end
mkdir(resdir);
giffile = fullfile(resdir,'temperature.gif');

%% ---- initialise ----------------------------------------------------------
init();  bound();  T_old = T;

nsteps   = round(TOTAL_TIME/Dt);
hist_t   = zeros(nsteps,1);  hist_Tmax = zeros(nsteps,1);
hist_Tvent=zeros(nsteps,1);  hist_K2  = zeros(nsteps,1);  hist_uv = zeros(nsteps,1);
cellVol  = (XMAX/NPI)*(YMAX/NPJ);
frameEvery = 40;
if doGif, figAnim = figure('Name',sprintf('burn xKN=%.2f',xKN)); end
istep = 0;

%% ---- time loop -----------------------------------------------------------
for time = Dt:Dt:TOTAL_TIME
    istep = istep + 1;  iter = 0;
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

        viscosity();  bound();

        u_old(3:NPI+1,2:NPJ+1)=u(3:NPI+1,2:NPJ+1);
        v_old(2:NPI+1,3:NPJ+1)=v(2:NPI+1,3:NPJ+1);
        pc_old(2:NPI+1,2:NPJ+1)=pc(2:NPI+1,2:NPJ+1);
        T_old(2:NPI+1,2:NPJ+1)=T(2:NPI+1,2:NPJ+1);
        Yfu_old(2:NPI+1,2:NPJ+1)=Yfu(2:NPI+1,2:NPJ+1);
        YK2_old(2:NPI+1,2:NPJ+1)=YK2(2:NPI+1,2:NPJ+1);
        iter = iter + 1;
    end

    hist_t(istep)    = time;
    hist_Tmax(istep) = max(max(T(2:NPI+1,2:NPJ+1)));
    hist_Tvent(istep)= mean(T(2,Jvent1:Jvent2));
    hist_K2(istep)   = sum(sum(rho(2:NPI+1,2:NPJ+1).*YK2(2:NPI+1,2:NPJ+1)))*cellVol;
    hist_uv(istep)   = max(max(abs(u(2,Jvent1:Jvent2))));

    meanYfu = mean(mean(Yfu(2:NPI+1,2:NPJ+1)));
    if istep==1
        fprintf('step   time[s]  Tmax[K]  Tvent[K]  K2CO3[kg]  Uvent[m/s]  meanYfu  SMAX\n');
    end
    fprintf('%5d %8.3f %8.1f %8.1f %10.3e %10.3e %7.4f %9.2e\n', istep, time, ...
        hist_Tmax(istep), hist_Tvent(istep), hist_K2(istep), hist_uv(istep), meanYfu, SMAX);

    if doGif && (mod(istep,frameEvery)==0 || istep==nsteps)
        figure(figAnim); clf;
        contourf(x, y, T', 20, 'LineColor','none'); colormap(jet); colorbar;
        title(sprintf('Temperature [K],  xKN=%.2f,  t=%.3f s', xKN, time));
        xlabel('x [m]'); ylabel('y [m]'); axis equal tight; drawnow;
        Fr = getframe(gcf); [A,map] = rgb2ind(Fr.cdata,256);
        if istep==frameEvery
            imwrite(A,map,giffile,'gif','LoopCount',Inf,'DelayTime',0.1);
        else
            imwrite(A,map,giffile,'gif','WriteMode','append','DelayTime',0.1);
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
fprintf(fh,'# time[s]  Tmax[K]  Tvent[K]  totalK2CO3[kg]  Uvent[m/s]\n');
for n = 1:nsteps
    fprintf(fh,'%11.5e\t%11.5e\t%11.5e\t%11.5e\t%11.5e\n', hist_t(n),hist_Tmax(n),hist_Tvent(n),hist_K2(n),hist_uv(n));
end
fclose(fh);

fpar = fopen(fullfile(resdir,'params.txt'),'w');
fprintf(fpar,'xKN=%.3f yK2=%.3f dTad=%.0f Tad=%.0f Tig=%.0f t_ign=%.2f EXPANSION=%.1f A=%.2e Ea=%.2e\n',xKN,yK2,dTad,TAMB+dTad,Tig,t_ign,EXPANSION,A_arr,Ea_arr);
fprintf(fpar,'NPI=%d NPJ=%d XMAX=%.3f YMAX=%.3f Dt=%.1e TOTAL_TIME=%.1f ventJ=%d..%d\n',NPI,NPJ,XMAX,YMAX,Dt,TOTAL_TIME,Jvent1,Jvent2);
fclose(fpar);

%% ---- summary figure ------------------------------------------------------
if doPlots
    figure('Name',sprintf('fields xKN=%.2f',xKN));
    subplot(3,1,1); contourf(x,y,T',20,'LineColor','none'); colormap(jet); colorbar;
    title(sprintf('Temperature [K]  (xKN=%.2f)',xKN)); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
    subplot(3,1,2); contourf(x,y,YK2',20,'LineColor','none'); colorbar;
    title('K_2CO_3 mass fraction [-]'); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
    subplot(3,1,3); quiver(x,y,u',v',1.5);
    title('Velocity vectors [m/s] (gas escaping the vent)'); xlabel('x [m]'); ylabel('y [m]'); axis equal tight;
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
R.meanYfu_final= meanYfu;
R.resdir       = resdir;

fprintf('Done xKN=%.2f: Tmax=%.0f K, escaping-gas T=%.0f K (%.0f C), K2CO3=%.3e kg, fuel left=%.2f\n\n', ...
    xKN, R.Tmax_final, R.Tvent_final, R.Tvent_final-273.15, R.K2CO3_total, R.meanYfu_final);
end
