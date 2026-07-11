function [] = front(time)
% FRONT — advance the burning surface one time step.               NEW FILE [B]
% Called ONCE per time step, before the outer iteration loop.
%
% Physics: the surface regresses at the measured Saint-Robert rate
%     r = a_burn * (P_front[MPa])^n_burn   [mm/s]
% where P_front is the ABSOLUTE pressure the field itself computes next to the
% surface — this closes the burn-rate <-> pressure feedback loop inside the
% CFD (design doc sec. 1). The surface consumes solid at rho_solid*r and
% releases the gaseous fraction as inlet mass flux
%     mdotpp = f_gas * rho_solid * r        [kg/m2/s]
% (the condensed K2CO3 rides along as scalar loading Y_in, see YK2coeff.m).
%
% Grid bookkeeping: xf is the continuous front position; Ifr = 2+floor(xf/Dx)
% is the first SOLID column (the "ghost"/inlet column, pinned at T_flame).
% When xf crosses a cell boundary the ghost column becomes a gas cell — it
% already holds the inlet values, so the flip is smooth — and the inlet face
% moves one column east ("moving wall": the cavity volume grows).

% constants
global NPI NPJ XMAX Dt P_ATM a_burn n_burn f_gas rho_solid t_ramp BURN_ON ...
    R_GAS T_flame Y_in
% variables
global p T rho v YK2 xf Ifr mdotpp

if ~BURN_ON || Ifr > NPI+1      % switched off, or charge fully consumed
    mdotpp = 0.;
    return;
end

Dx = XMAX/NPI;

% --- burn rate from the field pressure at the surface ----------------------
P_front = P_ATM + mean(p(max(Ifr-1,2), 2:NPJ+1));       % absolute [Pa]
r = a_burn*(max(P_front,0.5*P_ATM)/1.0e6)^n_burn/1000.; % regression [m/s]
r = r*min(time/t_ramp, 1.);                             % startup ramp

% --- advance the surface, set the inlet mass flux --------------------------
xf     = xf + r*Dt;
mdotpp = f_gas*rho_solid*r;                             % [kg/m2/s]

% --- cell flip(s): ghost column becomes gas, inlet moves east --------------
Ifnew = min(2 + floor(xf/Dx + 1e-12), NPI+2);
while Ifr < Ifnew
    % The old ghost column already carries T_flame and Y_in (pinned by
    % Tcoeff/YK2coeff), so only flow variables need priming:
    p(Ifr,2:NPJ+1)   = p(Ifr-1,2:NPJ+1);                       % neighbour p
    rho(Ifr,2:NPJ+1) = (p(Ifr,2:NPJ+1)+P_ATM)./(R_GAS*T(Ifr,2:NPJ+1));
    v(Ifr,2:NPJ+2)   = 0.;                                     % starts at rest
    % (the u-face at the old Ifr keeps its inlet velocity — a good initial
    % guess for the now-interior face; the SIMPLE loop takes it from there)
    Ifr = Ifr + 1;
    if Ifr <= NPI+1   % prime the NEW ghost column with inlet values
        T(Ifr,2:NPJ+1)   = T_flame;
        YK2(Ifr,2:NPJ+1) = Y_in;
    end
end

if Ifr > NPI+1        % burn-out: charge consumed, inlet switches off
    mdotpp = 0.;
end
end
