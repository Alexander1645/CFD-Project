function [] = bound()
% Boundary conditions (variable density; stable thermal-expansion vent)
%
% Flow: the 2-D vent carries the thermal expansion out (gentle, stable). The
% realistic chamber pressure / orifice vent velocity / burn time are computed
% as a separate 0-D model in run_grenade (one-way: burn -> pressure), because a
% fully-coupled solid-density source makes the 2-D venting supersonic/unstable.
%
% Thermal BCs:
%   - east (right) wall : adiabatic / no heat transfer  (problem statement)
%   - west, bottom, top : CONVECTIVE loss  q = h*(T - TAMB)  (Robin BC),
%        ghost T = (T_int + Bi*TAMB)/(1+Bi),  Bi = h*spacing/(2*lambda)
%   - west vent          : zero gradient (escaping gas carries its T out)
% Species BCs: zero flux (zero gradient) at all walls and the vent.

% constants
global NPI NPJ XMAX YMAX Jvent1 Jvent2 SMALL TAMB Dt h_wall
% variables
global u v T Yfu YK2 rho rho_old T_case

Dx = XMAX/NPI;  Dy = YMAX/NPJ;  Vol = Dx*Dy;
lambda = 0.05;                 % conductivity used in the wall-flux BC [W/m/K]

% --- thermal-expansion outflow (stable 2-D vent) [kg/s per depth] ---------
m_gen = 0.;
for I = 2:NPI+1
    for J = 2:NPJ+1
        m_gen = m_gen + (rho_old(I,J) - rho(I,J))*Vol/Dt;
    end
end

% --- velocities: no-slip on all walls -------------------------------------
u(2,1:NPJ+2)     = 0.;
u(NPI+2,1:NPJ+2) = 0.;
v(1:NPI+2,2)     = 0.;
v(1:NPI+2,NPJ+2) = 0.;

% --- vent (mid-west): carries the thermal expansion out (gentle, stable) ---
A_vent = (Jvent2 - Jvent1 + 1)*Dy;
rho_v  = rho(2,Jvent1);
u(2,Jvent1:Jvent2) = -m_gen/(rho_v*A_vent + SMALL);

% --- temperature BCs ------------------------------------------------------
% Walls cool the gas toward the CASING temperature T_case (which itself heats
% up over time - finite thermal mass, updated in run_grenade). East adiabatic.
T(NPI+2,1:NPJ+2) = T(NPI+1,1:NPJ+2);              % east: adiabatic
BiX = h_wall*Dx/(2*lambda);                        % west wall (spacing Dx)
BiY = h_wall*Dy/(2*lambda);                        % top/bottom walls (spacing Dy)
T(1,2:NPJ+1)     = (T(2,2:NPJ+1)     + BiX*T_case)/(1+BiX);   % west: convective
T(1:NPI+2,1)     = (T(1:NPI+2,2)     + BiY*T_case)/(1+BiY);   % bottom: convective
T(1:NPI+2,NPJ+2) = (T(1:NPI+2,NPJ+1) + BiY*T_case)/(1+BiY);   % top: convective
T(1,Jvent1:Jvent2) = T(2,Jvent1:Jvent2);           % vent: zero gradient (gas leaves)

% --- species BCs: zero gradient (no flux) ---------------------------------
Yfu(1,:)  = Yfu(2,:);     Yfu(NPI+2,:) = Yfu(NPI+1,:);
Yfu(:,1)  = Yfu(:,2);     Yfu(:,NPJ+2) = Yfu(:,NPJ+1);
YK2(1,:)  = YK2(2,:);     YK2(NPI+2,:) = YK2(NPI+1,:);
YK2(:,1)  = YK2(:,2);     YK2(:,NPJ+2) = YK2(:,NPJ+1);
end
