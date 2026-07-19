function [] = pccoeff()
% Purpose: To calculate the coefficients for the pc equation.
% Based on ProjectInfo/code_final_assignment/pccoeff.m with one addition:
% the mass storage term (rho_old - rho)/Dt * V enters the source b'. When
% solid composition burns to gas, rho drops by orders of magnitude, so
% this term acts as a volumetric gas source that drives the outflow
% through the hole. In unburnt or inert regions rho = rho_old and the
% base-code behaviour is recovered.

% constants
global NPI NPJ Dt
% variables
global x_u y_v pc rho rho_old SP Su F_u F_v d_u d_v Istart Iend Jstart Jend ...
    b aE aW aN aS aP SMAX SAVG

Istart = 2;
Iend = NPI+1;
Jstart = 2;
Jend = NPJ+1;

SMAX = 0.;
SSUM = 0.;
SAVG = 0.;

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        % Geometrical parameters: Areas of the cell faces
        AREAw = y_v(j+1) - y_v(j); % See fig. 6.2 or fig. 6.5
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i);
        AREAn = AREAs;

        % The constant b' in eq. 6.32, extended with the mass storage
        % change of the compressible/reacting mixture
        b(I,J) = F_u(i,J)*AREAw - F_u(i+1,J)*AREAe + F_v(I,j)*AREAs - F_v(I,j+1)*AREAn ...
            + (rho_old(I,J) - rho(I,J))/Dt*AREAw*AREAs;

        SP(I,J) = 0.;
        Su(I,J) = 0.;

        b(I,J) = b(I,J) + Su(I,J);

        % The coefficients
        aE(I,J) = 0.5*(rho(I,J) + rho(I+1,J))*d_u(i+1,J)*AREAe;
        aW(I,J) = 0.5*(rho(I-1,J) + rho(I,J))*d_u(i,J)*AREAw;
        aN(I,J) = 0.5*(rho(I,J) + rho(I,J+1))*d_v(I,j+1)*AREAn;
        aS(I,J) = 0.5*(rho(I,J) + rho(I,J-1))*d_v(I,j)*AREAs;

        aP(I,J) = aE(I,J) + aW(I,J) + aN(I,J) + aS(I,J) - SP(I,J);

        % Guard for cells fully enclosed by pinned (solid-solid) faces:
        % all coefficients are ~0 there, and any mass source (a cell that
        % ignites below the surface before the front opens a face) would
        % produce an unbounded pressure correction. Defer that source:
        % the gas is released once the front reaches the cell; the hole
        % outflow in bound() uses the global density change and is not
        % affected. Deferred sources are excluded from the residuals.
        if aP(I,J) < 1e-15
            aP(I,J) = 1.;
            b(I,J)  = 0.;
        end

        SMAX = max([SMAX,abs(b(I,J))]);
        SSUM = SSUM + abs(b(I,J));

        pc(I,J) = 0.;
    end
end
% Average error in mass balance is summed error divided by number of internal grid points
SAVG = SSUM/((Iend - Istart)*(Jend - Jstart));
end
