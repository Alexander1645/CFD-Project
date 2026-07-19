function [] = ucoeff()
% Purpose: To calculate the coefficients for the u equation (laminar).
% Based on ProjectInfo/code_final_assignment/ucoeff.m with:
%  - k-eps / wall-function parts removed (laminar: mueff -> mu, no
%    turbulent kinetic energy in the source term, laminar wall shear);
%  - variable density in time: aP carries the new-level mass rho*V/Dt,
%    the source b carries the old-level mass rho_old*V/Dt*u_old;
%  - solid pinning: where the unburnt composition fraction sf exceeds
%    SFPIN the velocity is forced to zero through SP = -LARGE, so the
%    one-phase "gas" behaves as a solid there.

% constants
global NPI NPJ Dt LARGE SFPIN
% variables
global x x_u y y_v u p mu SP Su F_u F_v d_u relax_u u_old rho rho_old sf ...
    Istart Iend Jstart Jend b aE aW aN aS aP dudx dvdx

Istart = 3;
Iend = NPI+1;
Jstart = 2;
Jend = NPJ+1;

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        % Geometrical parameters: Areas of the cell faces
        AREAw = y_v(j+1) - y_v(j); % See fig. 6.3
        AREAe = AREAw;
        AREAs = x(I) - x(I-1);
        AREAn = AREAs;

        % eq. 6.9a-6.9d - the convective mass flux defined in eq. 5.8a
        Fw = 0.5*(F_u(i,J)   + F_u(i-1,J))*AREAw;
        Fe = 0.5*(F_u(i+1,J) + F_u(i,J))*AREAe;
        Fs = 0.5*(F_v(I,j)   + F_v(I-1,j))*AREAs;
        Fn = 0.5*(F_v(I,j+1) + F_v(I-1,j+1))*AREAn;

        % eq. 6.9e-6.9h - the transport by diffusion defined in eq. 5.8b
        Dw = (mu(I-1,J)/(x_u(i) - x_u(i-1)))*AREAw;
        De = (mu(I,J)/(x_u(i+1) - x_u(i)))*AREAe;
        Ds = 0.25*(mu(I-1,J) + mu(I,J) + mu(I-1,J-1) + mu(I,J-1))/(y(J) - y(J-1))*AREAs;
        Dn = 0.25*(mu(I-1,J+1) + mu(I,J+1) + mu(I-1,J) + mu(I,J))/(y(J+1) - y(J))*AREAn;

        % The source terms
        mus = 0.25*(mu(I-1,J) + mu(I,J) + mu(I-1,J-1) + mu(I,J-1));
        mun = 0.25*(mu(I-1,J+1) + mu(I,J+1) + mu(I-1,J) + mu(I,J));

        % laminar wall shear at the bottom and top casing
        if J == 2 || J == NPJ+1
            SP(i,J) = -mu(I,J)*AREAs/(0.5*AREAw);
        else
            SP(i,J) = 0.;
        end

        Su(i,J) = (mu(I,J)*dudx(I,J) - mu(I-1,J)*dudx(I-1,J)) / (x(I) - x(I-1)) + ...
            (mun*dvdx(i,j+1) - mus*dvdx(i,j)) / (y_v(j+1) - y_v(j));
        Su(i,J) = Su(i,J)*AREAw*AREAs;

        % unburnt composition behaves as a solid: pin the velocity of
        % faces BETWEEN two solid cells to zero. Faces between a burning
        % (still mostly solid) cell and a gas cell stay free, so the
        % produced gas can vent through the burning surface against the
        % large blended viscosity - otherwise the expansion of a pinned
        % cell has no escape path and the pressure correction diverges.
        if min(sf(I-1,J),sf(I,J)) > SFPIN
            SP(i,J) = SP(i,J) - LARGE;
            Su(i,J) = 0.;
        end

        % The coefficients (hybrid differencing scheme)
        aW(i,J) = max([ Fw, Dw + Fw/2, 0.]);
        aE(i,J) = max([-Fe, De - Fe/2, 0.]);
        if J == 2
            aS(i,J) = 0.;
        else
            aS(i,J) = max([ Fs, Ds + Fs/2, 0.]);
        end
        if J == NPJ+1
            aN(i,J) = 0.;
        else
            aN(i,J) = max([-Fn, Dn - Fn/2, 0.]);
        end

        % unsteady terms: new-level mass in aP, old-level mass in b
        % (the difference between them is consistent with the mass source
        % (rho_old-rho)/Dt*V in the pressure-correction equation)
        aPt  = 0.5*(rho(I-1,J)     + rho(I,J))*AREAe*AREAn/Dt;
        aPt0 = 0.5*(rho_old(I-1,J) + rho_old(I,J))*AREAe*AREAn/Dt;

        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(i,J) = aW(i,J) + aE(i,J) + aS(i,J) + aN(i,J) + Fe - Fw + Fn - Fs - SP(i,J) + aPt;

        % d_u for the pressure correction equation (eq. 6.23)
        d_u(i,J) = AREAw*relax_u/aP(i,J);

        % pressure gradient and old time level in the source term
        b(i,J) = (p(I-1,J) - p(I,J))*AREAw + Su(i,J) + aPt0*u_old(i,J);

        % relaxation (eq. 6.36)
        aP(i,J) = aP(i,J)/relax_u;
        b(i,J)  = b(i,J) + (1.0 - relax_u)*aP(i,J)*u(i,J);
    end
end
end
