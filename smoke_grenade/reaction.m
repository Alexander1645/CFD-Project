function [] = reaction()
% REACTION  Rate-anchored, ISOTROPIC regressing-front burn model for the
% KNO3/sugar charge. Replaces the temperature-driven Arrhenius rate.
%
% The burn is a regressing FRONT travelling at the MEASURED regression rate
%   r = a_burn * (P_chamber[MPa])^n_burn      (Saint-Robert / Vieille law).
%
% WHY AN ARRIVAL-TIME (EIKONAL) FRONT.  The previous version lit a cell when a
% FACE-neighbour was burnt. Spreading through 4 face-neighbours only is motion
% in +-x / +-y, i.e. the Manhattan (L1) metric, whose "ball" is a DIAMOND - so
% the burnt region came out diamond-shaped. That shape was a GRID ARTEFACT, not
% physics: a real deflagration front from a point ignition is CIRCULAR (it moves
% normal to itself at speed r in every direction). To recover that we solve a
% small Eikonal problem for the ignition-arrival time tig(x):
%   |grad tig| = 1/r ,  tig = t_now at freshly-ignited cells,
% using the 8-neighbourhood with the TRUE spacings (dx, dy, diagonal = hypot).
% The 8-neighbour stencil makes the arrival-time front ISOTROPIC (circular) to
% within the usual ~few-% grid anisotropy, so the diamond disappears. A cell
% then burns once the clock reaches its arrival time. (For perfect isotropy a
% fast-marching solve would be used; a couple of alternating Gauss-Seidel sweeps
% per step is ample here because the front is slow - cell burn-time dx/r ~ 0.5 s
% >> Dt = 1e-3 s, so tig is fully relaxed long before the front reaches a cell.)
%
% Output (global): wburn(I,J) = local fractional consumption rate [1/s], driving
% the heat (Tcoeff), K2CO3 (YK2coeff), gas (pccoeff/bound) and Yfu update.

% constants
global NPI NPJ Dt XMAX YMAX SMALL a_burn n_burn P_chamber P_ATM T_ign
% variables
global T Yfu wburn tig_cell TIME_NOW

dx = XMAX/NPI;  dy = YMAX/NPJ;  dd = hypot(dx,dy);
r_burn = a_burn*(max(P_chamber,P_ATM)/1.0e6)^n_burn / 1000.;   % regression rate [m/s]
Rreg   = r_burn/dx;                                           % cell-consumption rate [1/s]

% lazy init / resize of the arrival-time field
if isempty(tig_cell) || ~isequal(size(tig_cell), size(Yfu))
    tig_cell = inf(size(Yfu));
end

% --- seed ignitions: igniter kernel / any cell that has reached T_ign, and any
%     cell already burning (latched: a finite arrival time is never raised) -----
seed = (~isfinite(tig_cell)) & ((T >= T_ign) | (Yfu < 0.999));
tig_cell(seed) = TIME_NOW;

% --- Eikonal update of the arrival-time front (8-neighbour, true distances) ----
% Two alternating-direction Gauss-Seidel sweeps reduce sweep-order bias.
for pass = 1:2
    if mod(pass,2)==1, Ir = 2:NPI+1; Jr = 2:NPJ+1; else, Ir = NPI+1:-1:2; Jr = NPJ+1:-1:2; end
    for I = Ir
        for J = Jr
            % nothing left to time once a cell is fully gas
            if Yfu(I,J) <= SMALL, continue; end
            % 8-neighbour Eikonal update: arrival time = min over neighbours of
            % (neighbour arrival time + travel time across the gap = distance/r).
            cand = min([ tig_cell(I-1,J)   + dx/r_burn, tig_cell(I+1,J)   + dx/r_burn, ...
                         tig_cell(I,J-1)   + dy/r_burn, tig_cell(I,J+1)   + dy/r_burn, ...
                         tig_cell(I-1,J-1) + dd/r_burn, tig_cell(I+1,J-1) + dd/r_burn, ...
                         tig_cell(I-1,J+1) + dd/r_burn, tig_cell(I+1,J+1) + dd/r_burn ]);
            if cand < tig_cell(I,J)
                tig_cell(I,J) = cand;        % only ever lower it (front never recedes)
            end
        end
    end
end

% --- consumption: a cell burns once the clock reaches its arrival time --------
% Consume at the regression rate Rreg, capped so Yfu cannot go negative in one
% step. Cells the front has not reached yet (TIME_NOW < tig) do not burn.
wburn = zeros(NPI+2,NPJ+2);
lit   = isfinite(tig_cell) & (TIME_NOW >= tig_cell) & (Yfu > SMALL);
wburn(lit) = min(Rreg, Yfu(lit)/Dt);
end
