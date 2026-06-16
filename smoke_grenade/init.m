function [] = init()
% Purpose: Initialise all parameters for the smoke-grenade reacting-flow model.
% Adapted from the supplied final_assignment/init.m. Key changes:
%   - quiescent start (no inlet velocity profile),
%   - ambient initial temperature (TAMB),
%   - LAMINAR start: k = 0, eps = SMALL,
%   - new reacting-flow fields: Yfu (unburnt fuel), YK2 (K2CO3) + old copies,
%     and the reaction-rate field Rk.
% See docs/design-decisions.md.

% constants
global NPI NPJ LARGE U_IN XMAX YMAX TAMB SMALL
% variables
global x x_u y y_v u v pc p T rho mu mut mueff Gamma Cp k eps delta E E2 yplus yplus1 ...
    yplus2 uplus tw b SP Su d_u d_v omega SMAX SAVG m_in m_out relax_u relax_v ...
    relax_pc relax_T aP aE aW aN aS F_u F_v u_old v_old pc_old T_old k_old ...
    eps_old dudx dudy dvdx dvdy Yfu YK2 Yfu_old YK2_old Rk

% begin: memalloc()========================================================
x   = zeros(1,NPI+2);   x_u = zeros(1,NPI+2);
y   = zeros(1,NPJ+2);   y_v = zeros(1,NPJ+2);

u   = zeros(NPI+2,NPJ+2);   v   = zeros(NPI+2,NPJ+2);
pc  = zeros(NPI+2,NPJ+2);   p   = zeros(NPI+2,NPJ+2);
T   = zeros(NPI+2,NPJ+2);   rho = zeros(NPI+2,NPJ+2);
mu  = zeros(NPI+2,NPJ+2);   mut = zeros(NPI+2,NPJ+2);   mueff = zeros(NPI+2,NPJ+2);
Gamma = zeros(NPI+2,NPJ+2); Cp  = zeros(NPI+2,NPJ+2);
k   = zeros(NPI+2,NPJ+2);   eps = zeros(NPI+2,NPJ+2);
delta = zeros(NPI+2,NPJ+2); E = zeros(NPI+2,NPJ+2);     E2 = zeros(NPI+2,NPJ+2);
yplus = zeros(NPI+2,NPJ+2); yplus1 = zeros(NPI+2,NPJ+2); yplus2 = zeros(NPI+2,NPJ+2);
uplus = zeros(NPI+2,NPJ+2); tw = zeros(NPI+2,NPJ+2);

% reacting-flow fields
Yfu   = zeros(NPI+2,NPJ+2);  YK2   = zeros(NPI+2,NPJ+2);
Yfu_old = zeros(NPI+2,NPJ+2);YK2_old = zeros(NPI+2,NPJ+2);
Rk    = zeros(NPI+2,NPJ+2);

u_old = zeros(NPI+2,NPJ+2);  v_old = zeros(NPI+2,NPJ+2);
pc_old= zeros(NPI+2,NPJ+2);  T_old = zeros(NPI+2,NPJ+2);
k_old = zeros(NPI+2,NPJ+2);  eps_old = zeros(NPI+2,NPJ+2);

dudx = zeros(NPI+2,NPJ+2);   dudy = zeros(NPI+2,NPJ+2);
dvdx = zeros(NPI+2,NPJ+2);   dvdy = zeros(NPI+2,NPJ+2);

aP = zeros(NPI+2,NPJ+2); aE = zeros(NPI+2,NPJ+2); aW = zeros(NPI+2,NPJ+2);
aN = zeros(NPI+2,NPJ+2); aS = zeros(NPI+2,NPJ+2); b  = zeros(NPI+2,NPJ+2);
SP = zeros(NPI+2,NPJ+2); Su = zeros(NPI+2,NPJ+2);
F_u = zeros(NPI+2,NPJ+2); F_v = zeros(NPI+2,NPJ+2);
d_u = zeros(NPI+2,NPJ+2); d_v = zeros(NPI+2,NPJ+2);
% end of memory allocation=================================================

% begin: grid()============================================================
Dx = XMAX/NPI;   Dy = YMAX/NPJ;

x(1) = 0.;  x(2) = 0.5*Dx;
for I = 3:NPI+1,  x(I) = x(I-1) + Dx;  end
x(NPI+2) = x(NPI+1) + 0.5*Dx;

y(1) = 0.;  y(2) = 0.5*Dy;
for J = 3:NPJ+1,  y(J) = y(J-1) + Dy;  end
y(NPJ+2) = y(NPJ+1) + 0.5*Dy;

x_u(1) = 0.;  x_u(2) = 0.;
for i = 3:NPI+2,  x_u(i) = x_u(i-1) + Dx;  end

y_v(1) = 0.;  y_v(2) = 0.;
for j = 3:NPJ+2,  y_v(j) = y_v(j-1) + Dy;  end
% end of grid setting======================================================

% begin: init()============================================================
omega = 1.0;
SMAX  = LARGE;   SAVG = LARGE;
m_in  = 1.;      m_out = 1.;

% Quiescent start: no inlet, gas initially at rest.
u(:,:)   = 0.;
v(:,:)   = 0.;
p(:,:)   = 0.;
T(:,:)   = TAMB;       % ambient initial temperature [K]
rho(:,:) = 1.0;        % gas density (incompressible, constant) [kg/m3]
mu(:,:)  = 2.E-5;      % molecular viscosity [Pa s]
Cp(:,:)  = 1200.;      % heat capacity of combustion gases [J/(kg K)]
Gamma    = 0.05./Cp;   % thermal conductivity / Cp  (~0.05 W/m/K hot gas)

% LAMINAR: turbulence off
k(:,:)    = 0.;
eps(:,:)  = SMALL;
mut(:,:)  = 0.;
mueff     = mu + mut;
uplus(:,:)= 1.;
yplus(:,:)= 1.;        % < 11.63  -> wall-function code uses the laminar branch
yplus1(:,:)= 1.;       yplus2(:,:)= 1.;
tw(:,:)   = 0.;

% Reacting fields: the whole interior is packed with solid propellant
% (Yfu = 1); no K2CO3 yet. (Ignition kernel is applied in the driver.)
Yfu(:,:)  = 1.0;
YK2(:,:)  = 0.0;
Rk(:,:)   = 0.0;

% store "old" (previous time level) copies
u_old = u;  v_old = v;  pc_old = pc;  T_old = T;
eps_old = eps;  k_old = k;
Yfu_old = Yfu;  YK2_old = YK2;

% relaxation factors
relax_u  = 0.8;
relax_v  = relax_u;
relax_pc = 1.1 - relax_u;
relax_T  = 1.0;
% end of initialisation====================================================
end
