function [] = bound()
% Purpose: Specify boundary conditions for a calculation.
% Rewritten from final_assignment/bound.m for Option B.                  [B]
%
% Differences vs the supplied bound.m:
%  - No duct inlet (supplied lines 9-17): the burning surface (interior moving
%    inlet, see front.m/ucoeff.m) replaces it.
%  - No m_in/m_out outlet rescaling (supplied lines 23-41): that trick forces
%    instantaneous global mass balance, which would FORBID pressurisation.
%    Here the vent velocity follows from the local field pressure (orifice
%    law) and global balance emerges through the transient compressible
%    continuity term in pccoeff.m.
%  - Walls adiabatic by default (zero-gradient ghost cells) instead of the
%    supplied fixed-T walls (lines 20-21). Optional convective-loss (Robin)
%    block below, commented.

% constants
global NPI NPJ SMALL Jv1 Jv2 Cd_vent relax_vent VENT_OPEN BURN_ON Ifr
% variables
global u v T YK2 p rho mdotpp

% --- velocities: no-slip on all outer walls --------------------------------
u(2,1:NPJ+2)     = 0.;      % west wall (vent rows overwritten below)
u(NPI+2,1:NPJ+2) = 0.;      % east wall (behind the charge until burn-out)
v(1:NPI+2,2)     = 0.;      % bottom wall
v(1:NPI+2,NPJ+2) = 0.;      % top wall

% --- vent: orifice outflow driven by the LOCAL field pressure ----------[B]
% u_orifice = Cd*sqrt(2*max(p,0)/rho) with p the gauge pressure of the cell
% next to the vent. Under-relaxed against the previous face value (the face
% value itself stores the history, no persistent variable needed).
% Outflow only (no backflow) — stated model limitation.
if VENT_OPEN
    for J = Jv1:Jv2
        u_orf  = Cd_vent*sqrt(2.*max(p(2,J),0.)/max(rho(2,J),SMALL));
        u(2,J) = (1.-relax_vent)*u(2,J) + relax_vent*(-u_orf);
    end
end

% --- burning-surface inlet face (kept consistent with the ucoeff pin) --[B]
% The face velocity carries EXACTLY the generated mass flux mdotpp [kg/m2/s]:
% u = -mdotpp/rho_face (negative = gas enters the cavity flowing west).
if BURN_ON && Ifr <= NPI+1
    for J = 2:NPJ+1
        rho_f    = 0.5*(rho(Ifr-1,J) + rho(Ifr,J));
        u(Ifr,J) = -mdotpp/max(rho_f,SMALL);
    end
end

% --- temperature ghost cells: adiabatic walls (zero gradient) ----------[B]
% The vent rows are included: the escaping gas carries its temperature out.
T(1,1:NPJ+2)     = T(2,1:NPJ+2);        % west wall + vent
T(NPI+2,1:NPJ+2) = T(NPI+1,1:NPJ+2);    % east wall
T(1:NPI+2,1)     = T(1:NPI+2,2);        % bottom wall
T(1:NPI+2,NPJ+2) = T(1:NPI+2,NPJ+1);    % top wall

% --- OPTIONAL convective wall loss (Robin BC), west/top/bottom ---------[B]
% Uncomment to model casing heat loss q = h*(T - TAMB). Ghost value:
%   T_ghost = (T_int + Bi*TAMB)/(1+Bi),  Bi = h*spacing/(2*lambda_gas)
% Keep east adiabatic (insulated by the unburnt charge, design doc sec. 1).
% global TAMB XMAX YMAX
% h_wall = 10.;  lam = 0.05;
% BiX = h_wall*(XMAX/NPI)/(2*lam);  BiY = h_wall*(YMAX/NPJ)/(2*lam);
% T(1,2:NPJ+1)     = (T(2,2:NPJ+1)     + BiX*TAMB)/(1+BiX);
% T(1:NPI+2,1)     = (T(1:NPI+2,2)     + BiY*TAMB)/(1+BiY);
% T(1:NPI+2,NPJ+2) = (T(1:NPI+2,NPJ+1) + BiY*TAMB)/(1+BiY);
% T(1,Jv1:Jv2)     = T(2,Jv1:Jv2);   % vent stays zero-gradient

% --- smoke scalar ghost cells: zero flux everywhere --------------------[B]
YK2(1,1:NPJ+2)     = YK2(2,1:NPJ+2);
YK2(NPI+2,1:NPJ+2) = YK2(NPI+1,1:NPJ+2);
YK2(1:NPI+2,1)     = YK2(1:NPI+2,2);
YK2(1:NPI+2,NPJ+2) = YK2(1:NPI+2,NPJ+1);
end
