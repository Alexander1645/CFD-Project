function [] = scacoeff(phi, phi_old, SPvol, Suvol)
% Purpose: To calculate the coefficients for a species mass-fraction
% equation (Lecture 6 species transport):
%   d(rho*Y)/dt + div(rho*u*Y) = div(GammaY*grad Y) + S
% The discretisation is identical to Tcoeff.m, with the diffusion
% coefficient GammaY = rho*D and volumetric source linearisation
%   S*V = Suvol*V + SPvol*V*phi,   SPvol <= 0  [kg/(m3 s)]
% so that species consumption by the reaction is treated implicitly
% (guarantees boundedness of the mass fractions).
%
% phi     : current field (only used for the relaxation term)
% phi_old : field at the old time level
% SPvol   : implicit source coefficient per unit volume [kg/(m3 s)]
% Suvol   : explicit source per unit volume [kg/(m3 s)]

% constants
global NPI NPJ Dt
% variables
global x x_u y y_v GammaY F_u F_v relax_Y rho rho_old ...
    Istart Iend Jstart Jend b aE aW aN aS aP

Istart = 2;
Iend = NPI+1;
Jstart = 2;
Jend = NPJ+1;

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        % Geometrical parameters: Areas of the cell faces
        AREAw = y_v(j+1) - y_v(j);
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i);
        AREAn = AREAs;

        % The convective mass flux defined in eq. 5.8a
        Fw = F_u(i,J)*AREAw;
        Fe = F_u(i+1,J)*AREAe;
        Fs = F_v(I,j)*AREAs;
        Fn = F_v(I,j+1)*AREAn;

        % The transport by diffusion (harmonic mean of GammaY)
        Dw = ((GammaY(I-1,J)*GammaY(I,J))/(GammaY(I-1,J)*(x(I) - x_u(i)) ...
            + GammaY(I,J)*(x_u(i) - x(I-1))))*AREAw;
        De = ((GammaY(I,J)*GammaY(I+1,J))/(GammaY(I,J)*(x(I+1) - x_u(i+1)) ...
            + GammaY(I+1,J)*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((GammaY(I,J-1)*GammaY(I,J))/(GammaY(I,J-1)*(y(J) - y_v(j)) ...
            + GammaY(I,J)*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((GammaY(I,J)*GammaY(I,J+1))/(GammaY(I,J)*(y(J+1) - y_v(j+1)) ...
            + GammaY(I,J+1)*(y_v(j+1) - y(J))))*AREAn;

        % The source terms (integrated over the cell volume)
        SPc = SPvol(I,J)*AREAw*AREAs;
        Suc = Suvol(I,J)*AREAw*AREAs;

        % The coefficients (hybrid differencing scheme)
        aW(I,J) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,J) = max([-Fe, De - Fe/2, 0.]);
        aS(I,J) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,J) = max([-Fn, Dn - Fn/2, 0.]);

        % unsteady terms: new-level mass in aP, old-level mass in b
        aPt  = rho(I,J)*AREAe*AREAn/Dt;
        aPt0 = rho_old(I,J)*AREAe*AREAn/Dt;

        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SPc + aPt;

        b(I,J) = Suc + aPt0*phi_old(I,J);

        % Introducing relaxation
        aP(I,J) = aP(I,J)/relax_Y;
        b(I,J)  = b(I,J) + (1.0 - relax_Y)*aP(I,J)*phi(I,J);
    end
end
end
