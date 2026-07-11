function [] = ucoeff()
% Purpose: To calculate the coefficients for the u equation.
% Cloned from final_assignment/ucoeff.m; the ONLY change is the [B] pin block
% (solid region + burning-surface inlet), inserted between the supplied source
% terms and the coefficient assembly — the same place the supplied Tcoeff.m
% keeps its commented-out SP=-LARGE example (its lines 57-61).

% constants
global NPI NPJ Dt Cmu LARGE SMALL
% variables
global x x_u y y_v u p mu mueff SP Su F_u F_v d_u relax_u u_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP yplus uplus k dudx dvdx
% [B] Option B: front index + inlet mass flux
global Ifr mdotpp

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
        Dw = (mueff(I-1,J)/(x_u(i) - x_u(i-1)))*AREAw;
        De = (mueff(I,J)/(x_u(i+1) - x_u(i)))*AREAe;
        Ds = 0.25*(mueff(I-1,J) + mueff(I,J) + mueff(I-1,J-1) + mueff(I,J-1))/(y(J) - y(J-1))*AREAs;
        Dn = 0.25*(mueff(I-1,J+1) + mueff(I,J+1) + mueff(I-1,J) + mueff(I,J))/(y(J+1) - y(J))*AREAn;

        % The source terms
        mus = 0.25*(mueff(I-1,J) + mueff(I,J) + mueff(I-1,J-1) + mueff(I,J-1));
        mun = 0.25*(mueff(I-1,J+1) + mueff(I,J+1) + mueff(I-1,J) + mueff(I,J));

        if J==2 || J==NPJ+1
            if yplus(I,J) < 11.63
                SP(i,J) = -mu(I,J)*AREAs/(0.5*AREAw);   % laminar wall shear
            else
                SP(i,J) = -rho(I,J) * Cmu^0.25 * k(I,J)^0.5 / uplus(I,J) *AREAs;
            end
        else
            SP(i,J) = 0.;
        end

        Su(i,J) = (mueff(I,J)*dudx(I,J) - mueff(I-1,J)*dudx(I-1,J)) / (x(I) - x(I-1)) + ...
            (mun*dvdx(i,j+1) - mus*dvdx(i,j)) / (y_v(j+1) - y_v(j)) - ...
            2./3. * (rho(I,J)*k(I,J) - rho(I-1,J)*k(I-1,J))/(x(I) - x(I-1));
        Su(i,J) =  Su(i,J)*AREAw*AREAs;

        % [B] ===== solid region + burning-surface inlet =====================
        % Faces east of the front are inside the unburnt charge: pinned u=0
        % (blocked cells). The face AT the front (i == Ifr) is the moving
        % inlet: pinned to carry exactly the generated mass flux,
        % u = -mdotpp/rho_face (negative = into the cavity, westward).
        % aP becomes ~LARGE, so d_u = AREAw*relax_u/aP -> ~0 below, which
        % keeps velcorr from "correcting" prescribed faces (same reason the
        % supplied code zeroes boundary d_u, see pccoeff.m note lines 70-74).
        if i > Ifr
            SP(i,J) = -LARGE;
            Su(i,J) = 0.;
        elseif i == Ifr
            rho_f   = 0.5*(rho(I-1,J) + rho(I,J));
            SP(i,J) = -LARGE;
            Su(i,J) = -LARGE*mdotpp/max(rho_f,SMALL);
        end
        % ====================================================================

        % The coefficients (hybrid differencing scheme)
        aW(i,J) = max([ Fw, Dw + Fw/2, 0.]);
        aE(i,J) = max([-Fe, De - Fe/2, 0.]);
        if J==2
            aS(i,J) = 0.;
        else
            aS(i,J) = max([ Fs, Ds + Fs/2, 0.]);
        end

        if J==NPJ+1
            aN(i,J) = 0.;
        else
            aN(i,J) = max([-Fn, Dn - Fn/2, 0.]);
        end
        aPold   = 0.5*(rho(I-1,J) + rho(I,J))*AREAe*AREAn/Dt;

        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(i,J) = aW(i,J) + aE(i,J) + aS(i,J) + aN(i,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;

        % d_u for the pressure-correction equation (eq. 6.23); ~0 at pinned
        % faces because aP ~ LARGE there.
        d_u(i,J) = AREAw*relax_u/aP(i,J);

        % Putting the integrated pressure gradient into the source term b
        b(i,J) = (p(I-1,J) - p(I,J))*AREAw + Su(I,J) + aPold*u_old(i,J);

        % Introducing relaxation by eq. 6.36
        aP(i,J) = aP(i,J)/relax_u;
        b(i,J)  = b(i,J) + (1.0 - relax_u)*aP(i,J)*u(i,J);
    end
end
end
