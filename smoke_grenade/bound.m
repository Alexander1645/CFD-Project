function [] = bound()
% Purpose: Boundary conditions for the smoke-grenade box (v2 - with vent).
%
% Geometry: rectangular box, no-slip walls, with a small OUTLET (vent) on the
% upper-west side (per the problem-description sketch). The igniter is the
% hot west wall just BELOW the vent (so gas escapes right where it is made -
% the safe/real configuration; see the discussion in the project notes).
%
% Flow driver (v2): combustion converts solid to gas (the mass source added
% in pccoeff). The total gas generated, m_gen [kg/s], must leave through the
% vent. We enforce this by prescribing the vent outflow velocity
%       u_vent = -m_gen/(rho*A_vent)         (negative = leaving to the west)
% so escaping-gas velocity is tied directly to the burn rate and vent area.
%
% Thermal BCs: ALL walls adiabatic (zero gradient), vent included (escaping
% gas carries its interior temperature). Ignition is a prescribed regression
% front applied in run_grenade, not a fixed-temperature wall.
% Species BCs: zero gradient (no flux) at all walls and the vent.

% constants
global NPI NPJ XMAX YMAX Jvent1 Jvent2
% variables
global u v T Yfu YK2 Rk rho m_gen EXPANSION

Dx = XMAX/NPI;  Dy = YMAX/NPJ;  Vol = Dx*Dy;

% --- total gas generation rate over the charge [kg/s per unit depth] ------
% (EXPANSION scales the generated gas to crudely account for the volume
%  increase the incompressible solver omits; must match pccoeff's source.)
m_gen = 0.;
for I = 2:NPI+1
    for J = 2:NPJ+1
        m_gen = m_gen + EXPANSION*Rk(I,J)*rho(I,J)*Yfu(I,J)*Vol;
    end
end

% --- velocities: no-slip on all walls -------------------------------------
u(2,1:NPJ+2)     = 0.;   % west wall
u(NPI+2,1:NPJ+2) = 0.;   % east wall
v(1:NPI+2,2)     = 0.;   % bottom wall
v(1:NPI+2,NPJ+2) = 0.;   % top wall

% --- vent on the upper-west side: prescribe outflow to vent all gas -------
A_vent = (Jvent2 - Jvent1 + 1)*Dy;          % vent area (per unit depth) [m]
rho_v  = rho(2,Jvent1);
u_vent = -m_gen/(rho_v*A_vent + 1e-30);     % m/s, negative = leaving west
u(2,Jvent1:Jvent2) = u_vent;

% --- temperature BCs: ALL walls adiabatic (zero gradient) -----------------
% The igniter is now a BRIEF hot kernel applied in run_grenade (fires for a
% short ignition time, then stops), NOT a permanent fixed-temperature wall.
% The old sustained hot wall acted as a large heat reservoir that clamped the
% burned-gas temperature near it and drained the combustion heat, so the
% flame never reached its real temperature. With adiabatic walls the
% combustion itself sets the temperature (-> ~Tad), and it varies with ratio.
% The vent is also zero-gradient: gas leaves carrying its interior T.
T(NPI+2,1:NPJ+2) = T(NPI+1,1:NPJ+2);   % east
T(1,1:NPJ+2)     = T(2,1:NPJ+2);        % west (incl. vent)
T(1:NPI+2,1)     = T(1:NPI+2,2);        % bottom
T(1:NPI+2,NPJ+2) = T(1:NPI+2,NPJ+1);    % top

% --- species BCs: zero gradient (no flux) through walls and vent ----------
Yfu(1,:)  = Yfu(2,:);     Yfu(NPI+2,:) = Yfu(NPI+1,:);
Yfu(:,1)  = Yfu(:,2);     Yfu(:,NPJ+2) = Yfu(:,NPJ+1);
YK2(1,:)  = YK2(2,:);     YK2(NPI+2,:) = YK2(NPI+1,:);
YK2(:,1)  = YK2(:,2);     YK2(:,NPJ+2) = YK2(:,NPJ+1);
end
