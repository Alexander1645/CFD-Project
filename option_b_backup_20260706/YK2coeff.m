function [] = YK2coeff()
% Purpose: coefficients for the smoke scalar YK2 (K2CO3 loading).   NEW FILE [B]
% Structural clone of Tcoeff.m — same grid, same hybrid scheme, same transient
% term, same pin idiom — with two substitutions:
%   - diffusion coefficient Gamma_Y = mu/Sc_Y   (Schmidt number, laminar)
%   - pin values: ghost/inlet column = Y_in (the K2CO3 loading of the product
%     stream, kg K2CO3 per kg gas), deeper solid = 0.
% No source term: K2CO3 enters by convection through the inlet face, exactly
% like the enthalpy in Tcoeff.m. YK2 is a PASSIVE loading (its mass is not in
% rho/EOS) — dilute-smoke assumption, see design doc sec. 9 item 4.

% constants
global NPI NPJ LARGE Dt
% variables
global x x_u y y_v YK2 mu SP Su F_u F_v relax_T YK2_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP
% [B] Option B: old density, front index, inlet loading, Schmidt number
global rho_old Ifr Y_in Sc_Y

Istart = 2;
Iend = NPI+1;
Jstart = 2;
Jend = NPJ+1;

convect();

for I = Istart:Iend
    i = I;
    for J = Jstart:Jend
        j = J;
        AREAw = y_v(j+1) - y_v(j);
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i);
        AREAn = AREAs;

        % Convective mass fluxes (as Tcoeff.m)
        Fw = F_u(i,J)*AREAw;
        Fe = F_u(i+1,J)*AREAe;
        Fs = F_v(I,j)*AREAs;
        Fn = F_v(I,j+1)*AREAn;

        % Diffusion with Gamma_Y = mu/Sc_Y (harmonic mean, as Tcoeff.m)
        Gw = mu(I-1,J)/Sc_Y;  Gp = mu(I,J)/Sc_Y;
        Ge = mu(I+1,J)/Sc_Y;  Gs = mu(I,J-1)/Sc_Y;  Gn = mu(I,J+1)/Sc_Y;
        Dw = ((Gw*Gp)/(Gw*(x(I) - x_u(i))   + Gp*(x_u(i) - x(I-1))))*AREAw;
        De = ((Gp*Ge)/(Gp*(x(I+1) - x_u(i+1)) + Ge*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((Gs*Gp)/(Gs*(y(J) - y_v(j))   + Gp*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((Gp*Gn)/(Gp*(y(J+1) - y_v(j+1)) + Gn*(y_v(j+1) - y(J))))*AREAn;

        % The source terms
        SP(I,J) = 0.;
        Su(I,J) = 0.;

        % [B] ===== solid region (same idiom as Tcoeff.m) ====================
        if I == Ifr                      % ghost/inlet column: product loading
            SP(I,J) = -LARGE;
            Su(I,J) = LARGE*Y_in;
        elseif I > Ifr                   % deeper unburnt charge: no smoke
            SP(I,J) = -LARGE;
            Su(I,J) = 0.;
        end
        % ====================================================================

        % The coefficients (hybrid differencing scheme)
        aW(I,j) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,j) = max([-Fe, De - Fe/2, 0.]);
        aS(I,j) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,j) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = rho_old(I,J)*AREAe*AREAn/Dt;   % [B] as Tcoeff.m

        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;

        b(I,J) = Su(I,J) + aPold*YK2_old(I,J);

        % relaxation (reuses relax_T, = 1.0 in init.m)
        aP(I,J) = aP(I,J)/relax_T;
        b(I,J)  = b(I,J) + (1.0 - relax_T)*aP(I,J)*YK2(I,J);
    end
end
end
