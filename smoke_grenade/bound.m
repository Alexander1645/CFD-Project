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
global NPI NPJ XMAX YMAX Jvent1 Jvent2 SMALL TAMB Dt h_wall f_gas
% variables
global u v T Yfu YK2 rho rho_old T_case wburn

Dx = XMAX/NPI;  Dy = YMAX/NPJ;  Vol = Dx*Dy;
lambda = 0.05;                 % conductivity used in the wall-flux BC [W/m/K]

% --- total gas the box must vent this step [kg/s per depth] ----------------
% Two physical sources (identical to the pccoeff continuity source):
%   (1) thermal expansion / compression of the gas   (rho_old-rho)/Dt
%   (2) combustion gas from the rate-anchored burn    f_gas*wburn*rho
% Term (2) uses the LOCAL GAS density, matching the pccoeff source: the real
% solid-density generation is a sub-grid surface feature that the 2-D field
% cannot carry (it NaNs locally), so the real discharge/pressure are taken from
% the lumped low-Mach P_chamber closure in run_grenade.m (block 1b). This vent BC
% only balances the gentle internal low-Mach flow. See pressure_model.md.
m_src = 0.;
for I = 2:NPI+1
    for J = 2:NPJ+1
        m_src = m_src + ((rho_old(I,J) - rho(I,J))/Dt ...
                         + f_gas*wburn(I,J)*rho(I,J))*Vol;
    end
end

% --- velocities: no-slip on the solid walls -------------------------------
u(2,1:NPJ+2)     = 0.;
u(NPI+2,1:NPJ+2) = 0.;
v(1:NPI+2,2)     = 0.;
v(1:NPI+2,NPJ+2) = 0.;

% --- vent (mid-west): OUTFLOW driven by the flow, NOT by the gas rate ------
% The vent speed is the pressure-driven interior velocity (zero-gradient
% u(2)=u(3)), only RESCALED so the total vented mass equals m_src (global
% continuity - the supplied solver's m_in/m_out outlet trick, here with an
% internal gas source instead of an inlet). So the vent PROFILE comes from the
% 2-D pressure solution; mass conservation fixes only the overall scale. This
% replaces the old "u_vent = -m_gen/(rho*A)" that pinned the speed to the
% generation rate and distorted the pressure field.
A_vent = (Jvent2 - Jvent1 + 1)*Dy;
prof   = max(-u(3,Jvent1:Jvent2), 0.);                 % outward interior profile
Pcarry = sum(rho(2,Jvent1:Jvent2).*prof)*Dy;           % mass that profile carries
if Pcarry > SMALL
    u(2,Jvent1:Jvent2) = -prof * (m_src / Pcarry);     % scale profile to carry m_src
else
    rho_v = rho(2,Jvent1);                             % start-up: no interior flow yet
    u(2,Jvent1:Jvent2) = -m_src/(rho_v*A_vent + SMALL);
end

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
