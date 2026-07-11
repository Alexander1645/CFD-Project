function [] = init()
% Purpose: To initialise all parameters.
% Cloned from final_assignment/init.m. [B] marks Option B changes:
%   - YK2 / YK2_old / rho_old arrays added
%   - quiescent start (u=v=0), T=TAMB, rho from the ideal-gas law
%   - front ghost column primed at T_flame (the ignited surface)
%   - k=0, eps=1 -> mut=0 through viscosity.m (laminar)

% constants
global NPI NPJ LARGE U_IN XMAX YMAX
% variables
global x x_u y y_v u v pc p T rho mu mut mueff Gamma Cp k eps delta E E2 yplus yplus1 ...
    yplus2 uplus tw b SP Su d_u d_v omega SMAX SAVG m_in m_out relax_u relax_v ...
    relax_pc relax_T aP aE aW aN aS F_u F_v u_old v_old pc_old T_old k_old ...
    eps_old dudx dudy dvdx dvdy
% [B] Option B globals
global YK2 YK2_old rho_old TAMB P_ATM R_GAS T_flame Y_in Ifr

% begin: memalloc()========================================================
% (identical to supplied init.m lines 13-68, plus the [B] arrays)
x   = zeros(1,NPI+2);
x_u = zeros(1,NPI+2);
y   = zeros(1,NPJ+2);
y_v = zeros(1,NPJ+2);

u   = zeros(NPI+2,NPJ+2);
v   = zeros(NPI+2,NPJ+2);
pc  = zeros(NPI+2,NPJ+2);
p   = zeros(NPI+2,NPJ+2);
T   = zeros(NPI+2,NPJ+2);
rho = zeros(NPI+2,NPJ+2);
mu  = zeros(NPI+2,NPJ+2);
mut  = zeros(NPI+2,NPJ+2);
mueff  = zeros(NPI+2,NPJ+2);
Gamma = zeros(NPI+2,NPJ+2);
Cp  = zeros(NPI+2,NPJ+2);
k  = zeros(NPI+2,NPJ+2);
eps  = zeros(NPI+2,NPJ+2);
delta  = zeros(NPI+2,NPJ+2);
E  = zeros(NPI+2,NPJ+2);
E2  = zeros(NPI+2,NPJ+2);
yplus  = zeros(NPI+2,NPJ+2);
yplus1  = zeros(NPI+2,NPJ+2);
yplus2  = zeros(NPI+2,NPJ+2);
uplus  = zeros(NPI+2,NPJ+2);
tw  = zeros(NPI+2,NPJ+2);

u_old  = zeros(NPI+2,NPJ+2);
v_old  = zeros(NPI+2,NPJ+2);
pc_old = zeros(NPI+2,NPJ+2);
T_old  = zeros(NPI+2,NPJ+2);
k_old  = zeros(NPI+2,NPJ+2);
eps_old  = zeros(NPI+2,NPJ+2);

YK2     = zeros(NPI+2,NPJ+2);   % [B] smoke (K2CO3) loading [kg/kg gas]
YK2_old = zeros(NPI+2,NPJ+2);   % [B]
rho_old = zeros(NPI+2,NPJ+2);   % [B] previous-time-level density

dudx   = zeros(NPI+2,NPJ+2);
dudy   = zeros(NPI+2,NPJ+2);
dvdx   = zeros(NPI+2,NPJ+2);
dvdy   = zeros(NPI+2,NPJ+2);

aP  = zeros(NPI+2,NPJ+2);
aE  = zeros(NPI+2,NPJ+2);
aW  = zeros(NPI+2,NPJ+2);
aN  = zeros(NPI+2,NPJ+2);
aS  = zeros(NPI+2,NPJ+2);
b   = zeros(NPI+2,NPJ+2);

SP  = zeros(NPI+2,NPJ+2);
Su  = zeros(NPI+2,NPJ+2);

F_u = zeros(NPI+2,NPJ+2);
F_v = zeros(NPI+2,NPJ+2);

d_u = zeros(NPI+2,NPJ+2);
d_v = zeros(NPI+2,NPJ+2);
% end of memory allocation=================================================

% begin: grid()===========================================================
% (identical to supplied init.m lines 70-105)
Dx = XMAX/NPI;
Dy = YMAX/NPJ;

x(1) = 0.;
x(2) = 0.5*Dx;
for I = 3:NPI+1
    x(I) = x(I-1) + Dx;
end
x(NPI+2) = x(NPI+1) + 0.5*Dx;

y(1) = 0.;
y(2) = 0.5*Dy;
for J = 3:NPJ+1
    y(J) = y(J-1) + Dy;
end
y(NPJ+2) = y(NPJ+1) + 0.5*Dy;

x_u(1) = 0.;
x_u(2) = 0.;
for i = 3:NPI+2
    x_u(i) = x_u(i-1) + Dx;
end

y_v(1) = 0.;
y_v(2) = 0.;
for j = 3:NPJ+2
    y_v(j) = y_v(j-1) + Dy;
end
% end of grid setting======================================================

% begin: init()===========================================================
omega = 1.0;

SMAX = LARGE;
SAVG = LARGE;

m_in  = 1.;   % kept for structural parity; the m_in/m_out outlet trick is
m_out = 1.;   % NOT used in Option B (see bound.m header)               [B]

% [B] quiescent, sealed start (supplied init gives a parabolic duct profile,
% lines 118-122; here there is no duct inlet)
u(:,:)     = 0.;
v(:,:)     = 0.;
p(:,:)     = 0.;       % gauge pressure (absolute = p + P_ATM)
T(:,:)     = TAMB;     % [B] everything at ambient ...
T(Ifr,2:NPJ+1) = T_flame;   % [B] ... except the ignited surface (ghost column)
YK2(Ifr,2:NPJ+1) = Y_in;    % [B] ghost column primed with inlet smoke loading

rho(:,:)   = P_ATM/(R_GAS*TAMB);              % [B] ideal gas at ambient
rho(Ifr,2:NPJ+1) = P_ATM/(R_GAS*T_flame);     % [B] hot ghost column
mu(:,:)    = (0.0395*TAMB + 6.58)*1.E-6;      % [B] wc3 correlation at TAMB
Cp(:,:)    = 1200.;    % [B] J/(K*kg), hot combustion products (const, as in
                       %     the supplied code's constant-Cp treatment)
Gamma      = (6.1E-5*TAMB + 8.4E-3)./Cp;      % [B] lambda(T)/Cp at TAMB
k(:,:)     = 0.;       % [B] laminar: k=0 -> mut = rho*Cmu*k^2/eps = 0
eps(:,:)   = 1.;       % [B] nonzero only to avoid 0/0 in viscosity.m
uplus(:,:) = 1.;
yplus1(:,:)= 1.;       % [B] supplied line 134 divides by u=0; harmless const
yplus2(:,:)= 1.;       % [B]
yplus(:,:) = 1.;       % keeps ucoeff/vcoeff wall shear on the laminar branch
tw(:,:)    = 5.;

u_old      = u;
v_old      = v;
pc_old     = pc;
T_old      = T;
eps_old    = eps;
k_old      = k;
YK2_old    = YK2;      % [B]
rho_old    = rho;      % [B]

% Setting the relaxation parameters (identical to supplied lines 147-150)
relax_u   = 0.8;
relax_v   = relax_u;
relax_pc  = 1.1 - relax_u;
relax_T   = 1.0;
% end of initialisation====================================================
end
