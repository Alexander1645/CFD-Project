function [] = init()
% Purpose: To initialise all parameters, following the structure of
% ProjectInfo/code_final_assignment/init.m (grid: fig. 6.2-6.4 in
% Versteeg & Malalasekera).

% constants
global NPI NPJ XMAX YMAX LARGE TAMB XGAP IGNDEPTH TIGN DHOLE YHOLEC YFU0 JH1 JH2
% variables
global x x_u y y_v u v pc p T mfu mox mk2 rho rho_old mu Gamma GammaY sf Rfu ...
    u_old v_old T_old mfu_old mox_old mk2_old aP aE aW aN aS b SP Su ...
    d_u d_v F_u F_v dudx dudy dvdx dvdy TwB TwT TwL TwR SMAX SAVG u_hole m_gen

% begin: memalloc()========================================================
x   = zeros(1,NPI+2);
x_u = zeros(1,NPI+2);
y   = zeros(1,NPJ+2);
y_v = zeros(1,NPJ+2);

u      = zeros(NPI+2,NPJ+2);
v      = zeros(NPI+2,NPJ+2);
pc     = zeros(NPI+2,NPJ+2);
p      = zeros(NPI+2,NPJ+2);
T      = zeros(NPI+2,NPJ+2);
mfu    = zeros(NPI+2,NPJ+2);
mox    = zeros(NPI+2,NPJ+2);
mk2    = zeros(NPI+2,NPJ+2);
rho    = zeros(NPI+2,NPJ+2);
rho_old= zeros(NPI+2,NPJ+2);
mu     = zeros(NPI+2,NPJ+2);
Gamma  = zeros(NPI+2,NPJ+2);
GammaY = zeros(NPI+2,NPJ+2);
sf     = zeros(NPI+2,NPJ+2);
Rfu    = zeros(NPI+2,NPJ+2);

u_old   = zeros(NPI+2,NPJ+2);
v_old   = zeros(NPI+2,NPJ+2);
T_old   = zeros(NPI+2,NPJ+2);
mfu_old = zeros(NPI+2,NPJ+2);
mox_old = zeros(NPI+2,NPJ+2);
mk2_old = zeros(NPI+2,NPJ+2);

dudx = zeros(NPI+2,NPJ+2);
dudy = zeros(NPI+2,NPJ+2);
dvdx = zeros(NPI+2,NPJ+2);
dvdy = zeros(NPI+2,NPJ+2);

aP = zeros(NPI+2,NPJ+2);
aE = zeros(NPI+2,NPJ+2);
aW = zeros(NPI+2,NPJ+2);
aN = zeros(NPI+2,NPJ+2);
aS = zeros(NPI+2,NPJ+2);
b  = zeros(NPI+2,NPJ+2);

SP = zeros(NPI+2,NPJ+2);
Su = zeros(NPI+2,NPJ+2);

F_u = zeros(NPI+2,NPJ+2);
F_v = zeros(NPI+2,NPJ+2);

d_u = zeros(NPI+2,NPJ+2);
d_v = zeros(NPI+2,NPJ+2);

TwB = TAMB*ones(1,NPI+2);   % casing temperature, bottom wall [K]
TwT = TAMB*ones(1,NPI+2);   % casing temperature, top wall [K]
TwL = TAMB*ones(1,NPJ+2);   % casing temperature, left wall [K]
TwR = TAMB*ones(1,NPJ+2);   % casing temperature, right wall [K]
% end of memory allocation=================================================

% begin: grid()===========================================================
% Length of volume element
Dx = XMAX/NPI;
Dy = YMAX/NPJ;

% Length variable for the scalar points in the x direction
x(1) = 0.;
x(2) = 0.5*Dx;
for I = 3:NPI+1
    x(I) = x(I-1) + Dx;
end
x(NPI+2) = x(NPI+1) + 0.5*Dx;

% Length variable for the scalar points T(i,j) in the y direction
y(1) = 0.;
y(2) = 0.5*Dy;
for J = 3:NPJ+1
    y(J) = y(J-1) + Dy;
end
y(NPJ+2) = y(NPJ+1) + 0.5*Dy;

% Length variable for the velocity components u(i,j) in the x direction
x_u(1) = 0.;
x_u(2) = 0.;
for i = 3:NPI+2
    x_u(i) = x_u(i-1) + Dx;
end

% Length variable for the velocity components v(i,j) in the y direction
y_v(1) = 0.;
y_v(2) = 0.;
for j = 3:NPJ+2
    y_v(j) = y_v(j-1) + Dy;
end
% end of grid setting======================================================

% begin: hole rows on the left wall =======================================
JH1 = 0;
JH2 = 0;
for J = 2:NPJ+1
    if abs(y(J) - YHOLEC) <= DHOLE/2
        if JH1 == 0, JH1 = J; end
        JH2 = J;
    end
end
if JH1 == 0
    error('init:hole','No grid rows fall inside the hole; refine the grid.');
end
% end hole=================================================================

% begin: initial fields ===================================================
T(:,:) = TAMB;
for I = 1:NPI+2
    for J = 1:NPJ+2
        if x(I) > XGAP
            % unburnt solid composition fills the canister
            mfu(I,J) = YFU0;
            mox(I,J) = 1 - YFU0;
        end
        % ignition kernel: igniter charge at the propellant surface next
        % to the hole (initial hot pocket; combustion is NOT forced)
        if x(I) <= XGAP + IGNDEPTH && abs(y(J) - YHOLEC) <= DHOLE/2 + 0.003
            T(I,J) = TIGN;
        end
    end
end

mixprops(1.);      % rho, mu, Gamma, GammaY, sf from the initial fields
rho_old = rho;     % consistent old time level (no artificial mass source)

u_old   = u;
v_old   = v;
T_old   = T;
mfu_old = mfu;
mox_old = mox;
mk2_old = mk2;

SMAX   = LARGE;
SAVG   = LARGE;
u_hole = 0.;
m_gen  = 0.;
% end of initialisation====================================================
end

