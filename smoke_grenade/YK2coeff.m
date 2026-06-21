function [] = YK2coeff()
% Purpose: coefficients for the K2CO3 mass-fraction (YK2) equation.
% Same transport template as Yfucoeff, but with a PRODUCTION SOURCE
%       +yK2 * omega = +yK2 * Rk * rho * Yfu      [kg/m3/s]
% i.e. K2CO3 is generated in proportion to the fuel burned (yK2 = kg K2CO3
% per kg propellant, from chemistry.m). K2CO3 is the smoke-forming solid we
% track per cell (RQ1). See docs/design-decisions.md.

% constants
global NPI NPJ Dt
% variables
global x x_u y y_v YK2 Yfu mu SP Su F_u F_v relax_T YK2_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP wburn yK2

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

        Dw = ((mu(I-1,J)*mu(I,J))/(mu(I-1,J)*(x(I) - x_u(i)) ...
            + mu(I,J)*(x_u(i) - x(I-1))))*AREAw;
        De = ((mu(I,J)*mu(I+1,J))/(mu(I,J)*(x(I+1) - x_u(i+1)) ...
            + mu(I+1,J)*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((mu(I,J-1)*mu(I,J))/(mu(I,J-1)*(y(J) - y_v(j)) ...
            + mu(I,J)*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((mu(I,J)*mu(I,J+1))/(mu(I,J)*(y(J+1) - y_v(j+1)) ...
            + mu(I,J+1)*(y_v(j+1) - y(J))))*AREAn;

        % Production source (explicit): K2CO3 made = yK2 * (charge consumed).
        % Charge consumed per second = wburn*rho (wburn from the rate-anchored
        % front in reaction.m), so the source is +yK2*wburn*rho*Volume.
        SP(I,J) = 0.;
        Su(I,J) = yK2 * wburn(I,J) * rho(I,J) * AREAe * AREAn;

        aW(I,J) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,J) = max([-Fe, De - Fe/2, 0.]);
        aS(I,J) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,J) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = rho(I,J)*AREAe*AREAn/Dt;

        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;
        b(I,J)  = Su(I,J) + aPold*YK2_old(I,J);

        aP(I,J) = aP(I,J)/relax_T;
        b(I,J)  = b(I,J) + (1.0 - relax_T)*aP(I,J)*YK2(I,J);
    end
end
end
