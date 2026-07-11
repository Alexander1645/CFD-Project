function [] = pccoeff()
% Purpose: To calculate the coefficients for the pc equation.
% Cloned from final_assignment/pccoeff.m with two [B] changes:
%   (1) the TRANSIENT COMPRESSIBLE term (rho_old-rho)*V/Dt added to b — this
%       is the transient part of continuity (V&M ch. 8) and is what lets a
%       cell STORE mass, i.e. lets the cavity pressurise. Without it, any
%       injected mass must leave a cell instantly (the old model's failure).
%   (2) the solid region (I >= Ifr) is excluded from the pressure solve:
%       pc pinned to 0 exactly the way the supplied code excludes ghost
%       cells — pinned value + the surrounding d_u/d_v already ~0 (see
%       ucoeff/vcoeff [B] blocks).
% There is NO volumetric mass source anywhere: combustion gas enters through
% the inlet FACE flux F_u(Ifr,J), which the b' imbalance below already sees.

% constants
global NPI NPJ Dt
% variables
global x_u y_v pc rho SP Su F_u F_v d_u d_v Istart Iend Jstart Jend ...
    b aE aW aN aS aP SMAX SAVG
% [B] Option B: old density (previous time level) + front index
global rho_old Ifr
% [B2-4] EOS coupling for the implicit compressibility term (see below)
global T R_GAS SMALL

Istart = 2;
Iend = NPI+1;
Jstart = 2;
Jend = NPJ+1;

SMAX = 0.;
SSUM = 0.;
SAVG = 0.;
ncell = 0;                       % [B] gas-cell counter for SAVG

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        % Geometrical parameters: Areas of the cell faces
        AREAw = y_v(j+1) - y_v(j); % = A(i,J) See fig. 6.2 or fig. 6.5
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i); % = A(I,j)
        AREAn = AREAs;

        % [B] ===== solid region: excluded from the pressure solve ===========
        if I >= Ifr
            aE(I,J) = 0.; aW(I,J) = 0.; aN(I,J) = 0.; aS(I,J) = 0.;
            aP(I,J) = 1.;  b(I,J) = 0.;  SP(I,J) = 0.;  Su(I,J) = 0.;
            pc(I,J) = 0.;
            continue;   % no residual contribution from solid cells
        end
        % ====================================================================

        % The constant b' in eq. 6.32 (net mass imbalance of the cell)
        b(I,J) = F_u(i,J)*AREAw - F_u(i+1,J)*AREAe + F_v(I,j)*AREAs - F_v(I,j+1)*AREAn;

        % [B] transient compressible continuity: the cell may also ACCUMULATE
        % mass at rate (rho-rho_old)*V/Dt. Moving it to the source side:
        % [B2-4] ... and the IMPLICIT part of the same term: a pressure
        % correction pc changes the cell density through the EOS,
        % drho = pc/(R*T), i.e. the cell stores an extra (pc/(R*T))*V/Dt of
        % mass. This enters aP through the standard SP slot. Without it the
        % rho(p) feedback is only explicit (via density() one iteration
        % later) and the pc<->rho loop has gain ~ 1/Dt^2: at Dt=2e-5 it rode
        % a kPa limit cycle (iter pinned at 40), at Dt=1e-5 it diverged to
        % NaN within 3 steps (pc sign-flipping and growing each outer
        % iteration — see results/xKN065/attempt3_debug/). Standard
        % pressure-based compressible practice (V&M ch. 8; Karki & Patankar
        % 1989). NOTE FOR DESIGNER REVIEW: this is the only [B2] change that
        % touches a discretised coefficient; it is the implicit twin of the
        % [B] storage source above and is REQUIRED for the V4 Dt-refinement
        % run to exist at all.
        SP(I,J) = -AREAe*AREAn/(R_GAS*max(T(I,J),SMALL)*Dt);
        Su(I,J) = (rho_old(I,J) - rho(I,J))*AREAe*AREAn/Dt;

        b(I,J) = b(I,J) + Su(I,J);

        SMAX = max([SMAX,abs(b(I,J))]);
        SSUM = SSUM + abs(b(I,J));
        ncell = ncell + 1;                                          % [B]

        % The coefficients
        aE(I,J) = 0.5*(rho(I,J) + rho(I+1,J))*d_u(i+1,J)*AREAe;
        aW(I,J) = 0.5*(rho(I-1,J) + rho(I,J))*d_u(i,J)*AREAw;
        aN(I,J) = 0.5*(rho(I,J) + rho(I,J+1))*d_v(I,j+1)*AREAn;
        aS(I,J) = 0.5*(rho(I,J-1) + rho(I,J))*d_v(I,j)*AREAs;

        aP(I,J) = aE(I,J) + aW(I,J) + aN(I,J) + aS(I,J) - SP(I,J);

        pc(I,J) = 0.;

        % note: At the points nearest the boundaries, some coefficients are
        % necessarily zero (d_u/d_v = 0 there) — the same mechanism that now
        % isolates the solid region and the prescribed vent/inlet faces.
    end
end
% Average error in mass balance: summed error over the GAS cells only     [B]
SAVG = SSUM/max(ncell,1);

end
