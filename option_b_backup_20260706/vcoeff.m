function [] = vcoeff()
% Purpose: To calculate the coefficients for the v equation.
% Cloned from final_assignment/vcoeff.m; the ONLY change is the [B] pin block
% (v = 0 in the solid region).

% constants
global NPI NPJ Dt LARGE
% variables
global x x_u y y_v v p mueff SP Su F_u F_v d_v relax_v v_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP dvdy dudy k
% [B] Option B: front index
global Ifr

Istart = 2;
Iend = NPI+1;
Jstart = 3;
Jend = NPJ+1;

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        % Geometrical parameters: Areas of the cell faces
        AREAw = y(J) - y(J-1); % See fig. 6.4
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i);
        AREAn = AREAs;

        % eq. 6.11a-6.11d - the convective mass flux defined in eq. 5.8a
        Fw = 0.5*(F_u(i,J)   + F_u(i,J-1))*AREAw;
        Fe = 0.5*(F_u(i+1,J) + F_u(i+1,J-1))*AREAe;
        Fs = 0.5*(F_v(I,j)   + F_v(I,j-1))*AREAs;
        Fn = 0.5*(F_v(I,j)   + F_v(I,j+1))*AREAn;

        % eq. 6.11e-6.11h - the transport by diffusion defined in eq. 5.8b
        Dw = 0.25*(mueff(I-1,J-1) + mueff(I,J-1) + mueff(I-1,J) + mueff(I,J))/(x(I) - x(I-1))*AREAw;
        De = 0.25*(mueff(I,J-1) + mueff(I+1,J-1) + mueff(I,J) + mueff(I+1,J))/(x(I+1) - x(I))*AREAe;
        Ds = mueff(I,J-1)/(y_v(j) - y_v(j-1))*AREAs;
        Dn = mueff(I,J)/(y_v(j+1) - y_v(j))*AREAn;

        % The source terms
        muw = 0.25*(mueff(I-1,J-1) + mueff(I,J-1) + mueff(I-1,J) + mueff(I,J));
        mue = 0.25*(mueff(I,J-1) + mueff(I+1,J-1) + mueff(I,J) + mueff(I+1,J));
        SP(I,j) = 0.;
        Su(I,j) = (mueff(I,J)*dvdy(I,J) - mueff(I,J-1)*dvdy(I,J-1)) / (y(J) - y(J-1)) + ...
            (mue*dudy(i+1,j) - muw*dudy(i,j)) / (x_u(i+1) - x_u(i)) - ...
            2./3. * (rho(I,J)*k(I,J) - rho(I,J-1)*k(I,J-1))/(y(J) - y(J-1));
        Su(i,J) =  Su(i,J)*AREAw*AREAs;

        % [B] ===== solid region: no vertical flow in/behind the charge ======
        % Column I >= Ifr is the ghost/inlet column or deeper solid; its v
        % faces are pinned to zero (blocked cells). Same SP=-LARGE idiom as
        % the supplied Tcoeff.m lines 57-61.
        if I >= Ifr
            SP(I,j) = -LARGE;
            Su(I,j) = 0.;
        end
        % ====================================================================

        % The coefficients (hybrid differencing scheme)
        aW(I,j) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,j) = max([-Fe, De - Fe/2, 0.]);
        aS(I,j) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,j) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = 0.5*(rho(I,J-1) + rho(I,J))*AREAe*AREAn/Dt;

        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(I,j) = aW(I,j) + aE(I,j) + aS(I,j) + aN(I,j) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;

        % d_v for the pressure-correction equation (eq. 6.23); ~0 at pinned
        % faces because aP ~ LARGE there.
        d_v(I,j) = AREAs*relax_v/aP(I,j);

        % Putting the integrated pressure gradient into the source term b
        b(I,j) = (p(I,J-1) - p(I,J))*AREAs + Su(I,j) + aPold*v_old(I,j);

        % Introducing relaxation by eq. 6.37
        aP(I,j) = aP(I,j)/relax_v;
        b(I,j)  = b(I,j) + (1.0 - relax_v)*aP(I,j)*v(I,j);
    end
end
end
