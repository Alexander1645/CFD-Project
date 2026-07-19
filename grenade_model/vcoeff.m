function [] = vcoeff()
% Purpose: To calculate the coefficients for the v equation (laminar).
% Based on ProjectInfo/code_final_assignment/vcoeff.m with the same
% modifications as ucoeff.m (laminar, variable density in time, solid
% pinning) plus laminar wall shear at the left/right casing, which the
% base code did not need (it had an inlet and an outlet there).

% constants
global NPI NPJ Dt LARGE SFPIN JH1 JH2
% variables
global x x_u y y_v v p mu SP Su F_u F_v d_v relax_v v_old rho rho_old sf ...
    Istart Iend Jstart Jend b aE aW aN aS aP dvdy dudy

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
        Dw = 0.25*(mu(I-1,J-1) + mu(I,J-1) + mu(I-1,J) + mu(I,J))/(x(I) - x(I-1))*AREAw;
        De = 0.25*(mu(I,J-1) + mu(I+1,J-1) + mu(I,J) + mu(I+1,J))/(x(I+1) - x(I))*AREAe;
        Ds = mu(I,J-1)/(y_v(j) - y_v(j-1))*AREAs;
        Dn = mu(I,J)/(y_v(j+1) - y_v(j))*AREAn;

        % The source terms
        muw = 0.25*(mu(I-1,J-1) + mu(I,J-1) + mu(I-1,J) + mu(I,J));
        mue = 0.25*(mu(I,J-1) + mu(I+1,J-1) + mu(I,J) + mu(I+1,J));

        % laminar wall shear at the left casing (not at the hole) and at
        % the right casing
        SP(I,j) = 0.;
        if I == 2 && ~(j >= JH1 && j <= JH2+1)
            SP(I,j) = SP(I,j) - mu(I,J)*AREAw/(0.5*AREAs);
        end
        if I == NPI+1
            SP(I,j) = SP(I,j) - mu(I,J)*AREAw/(0.5*AREAs);
        end

        Su(I,j) = (mu(I,J)*dvdy(I,J) - mu(I,J-1)*dvdy(I,J-1)) / (y(J) - y(J-1)) + ...
            (mue*dudy(i+1,j) - muw*dudy(i,j)) / (x_u(i+1) - x_u(i));
        Su(I,j) = Su(I,j)*AREAw*AREAs;

        % unburnt composition behaves as a solid: pin faces BETWEEN two
        % solid cells to zero (see ucoeff.m for the reasoning)
        if min(sf(I,J-1),sf(I,J)) > SFPIN
            SP(I,j) = SP(I,j) - LARGE;
            Su(I,j) = 0.;
        end

        % The coefficients (hybrid differencing scheme)
        aW(I,j) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,j) = max([-Fe, De - Fe/2, 0.]);
        aS(I,j) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,j) = max([-Fn, Dn - Fn/2, 0.]);

        % unsteady terms: new-level mass in aP, old-level mass in b
        aPt  = 0.5*(rho(I,J-1)     + rho(I,J))*AREAe*AREAn/Dt;
        aPt0 = 0.5*(rho_old(I,J-1) + rho_old(I,J))*AREAe*AREAn/Dt;

        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(I,j) = aW(I,j) + aE(I,j) + aS(I,j) + aN(I,j) + Fe - Fw + Fn - Fs - SP(I,j) + aPt;

        % d_v for the pressure correction equation (eq. 6.23)
        d_v(I,j) = AREAs*relax_v/aP(I,j);

        % pressure gradient and old time level in the source term
        b(I,j) = (p(I,J-1) - p(I,J))*AREAs + Su(I,j) + aPt0*v_old(I,j);

        % relaxation (eq. 6.37)
        aP(I,j) = aP(I,j)/relax_v;
        b(I,j)  = b(I,j) + (1.0 - relax_v)*aP(I,j)*v(I,j);
    end
end
end
