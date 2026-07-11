function [] = Tcoeff()
% Purpose: To calculate the coefficients for the T equation.
% Cloned from final_assignment/Tcoeff.m with two [B] changes:
%   (1) the solid-region pin block — this is the supplied code's OWN
%       commented-out example (its lines 57-61) activated: the ghost/inlet
%       column is held at T_flame (the ignited surface), deeper solid at TAMB.
%       NO combustion source term exists: the burn's enthalpy enters purely by
%       CONVECTION through the inlet face (hybrid upwinding picks up the
%       pinned T_flame of the ghost column via aE).
%   (2) aPold uses rho_old (previous time level), the textbook transient
%       coefficient aP0 = rho_P^o * dV / Dt (V&M eq. 8.25-8.31). Identical to
%       the supplied form when density is constant.

% constants
global NPI NPJ LARGE Dt
% variables
global x x_u y y_v T Gamma SP Su F_u F_v relax_T T_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP
% [B] Option B: old density, front index, pin temperatures
global rho_old Ifr T_flame TAMB

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
        AREAw = y_v(j+1) - y_v(j); % = A(i,J) See fig. 6.2 or fig. 6.5
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i); % = A(I,j)
        AREAn = AREAs;

        % The convective mass flux defined in eq. 5.8a
        Fw = F_u(i,J)*AREAw;
        Fe = F_u(i+1,J)*AREAe;
        Fs = F_v(I,j)*AREAs;
        Fn = F_v(I,j+1)*AREAn;

        % The transport by diffusion defined in eq. 5.8b (harmonic mean Gamma)
        Dw = ((Gamma(I-1,J)*Gamma(I,J))/(Gamma(I-1,J)*(x(I) - x_u(i)) ...
            + Gamma(I,J)*(x_u(i) - x(I-1))))*AREAw;
        De = ((Gamma(I,J)*Gamma(I+1,J))/(Gamma(I,J)*(x(I+1) - x_u(i+1)) ...
            + Gamma(I+1,J)*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((Gamma(I,J-1)*Gamma(I,J))/(Gamma(I,J-1)*(y(J) - y_v(j)) ...
            + Gamma(I,J)*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((Gamma(I,J)*Gamma(I,J+1))/(Gamma(I,J)*(y(J+1) - y_v(j+1)) ...
            + Gamma(I,J+1)*(y_v(j+1) - y(J))))*AREAn;

        % The source terms
        SP(I,J) = 0.;
        Su(I,J) = 0.;

        % [B] ===== solid region (supplied lines 57-61 idiom, activated) =====
        if I == Ifr                      % ghost/inlet column: ignited surface
            SP(I,J) = -LARGE;
            Su(I,J) = LARGE*T_flame;
        elseif I > Ifr                   % deeper unburnt charge: cold
            SP(I,J) = -LARGE;
            Su(I,J) = LARGE*TAMB;
        end
        % ====================================================================

        % The coefficients (hybrid differencing scheme)
        aW(I,j) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,j) = max([-Fe, De - Fe/2, 0.]);
        aS(I,j) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,j) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = rho_old(I,J)*AREAe*AREAn/Dt;   % [B] aP0 = rho^o*dV/Dt (V&M 8.25)

        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;

        % Setting the source term equal to b
        b(I,J) = Su(I,J) + aPold*T_old(I,J);

        % Introducing relaxation by eq. 6.36
        aP(I,J) = aP(I,J)/relax_T;
        b(I,J)  = b(I,J) + (1.0 - relax_T)*aP(I,J)*T(I,J);
    end
end
end
