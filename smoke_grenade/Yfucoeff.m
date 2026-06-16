function [] = Yfucoeff()
% Purpose: coefficients for the unburnt-fuel mass-fraction (Yfu) equation.
% Mirrors Tcoeff.m (hybrid differencing, transient) but:
%   - diffusion uses the (laminar) viscosity mu as the species diffusion
%     coefficient (Schmidt number ~ 1),
%   - includes the reaction SINK  -Rk*rho*Yfu  (implicit, via SP).
% See docs/design-decisions.md for the combustion-model reasoning.

% constants
global NPI NPJ Dt
% variables
global x x_u y y_v Yfu mu SP Su F_u F_v relax_T Yfu_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP Rk

Istart = 2; Iend = NPI+1;
Jstart = 2; Jend = NPJ+1;

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        AREAw = y_v(j+1) - y_v(j);
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i);
        AREAn = AREAs;

        Fw = F_u(i,J)*AREAw;   Fe = F_u(i+1,J)*AREAe;
        Fs = F_v(I,j)*AREAs;   Fn = F_v(I,j+1)*AREAn;

        % diffusion (harmonic mean of mu at the faces)
        Dw = ((mu(I-1,J)*mu(I,J))/(mu(I-1,J)*(x(I) - x_u(i)) ...
            + mu(I,J)*(x_u(i) - x(I-1))))*AREAw;
        De = ((mu(I,J)*mu(I+1,J))/(mu(I,J)*(x(I+1) - x_u(i+1)) ...
            + mu(I+1,J)*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((mu(I,J-1)*mu(I,J))/(mu(I,J-1)*(y(J) - y_v(j)) ...
            + mu(I,J)*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((mu(I,J)*mu(I,J+1))/(mu(I,J)*(y(J+1) - y_v(j+1)) ...
            + mu(I,J+1)*(y_v(j+1) - y(J))))*AREAn;

        % Reaction sink: omega = Rk*rho*Yfu  ->  implicit in SP
        SP(I,J) = -Rk(I,J)*rho(I,J)*AREAe*AREAn;
        Su(I,J) = 0.;

        aW(I,J) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,J) = max([-Fe, De - Fe/2, 0.]);
        aS(I,J) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,J) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = rho(I,J)*AREAe*AREAn/Dt;

        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;
        b(I,J)  = Su(I,J) + aPold*Yfu_old(I,J);

        aP(I,J) = aP(I,J)/relax_T;
        b(I,J)  = b(I,J) + (1.0 - relax_T)*aP(I,J)*Yfu(I,J);
    end
end
end
