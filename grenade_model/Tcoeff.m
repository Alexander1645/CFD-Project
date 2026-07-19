function [] = Tcoeff()
% Purpose: To calculate the coefficients for the T equation.
% Based on ProjectInfo/code_final_assignment/Tcoeff.m (harmonic-mean
% conduction coefficients) with:
%  - the reaction heat release as a source: Su = DHFU*Rfu*V/cp
%    (the transported variable is T, so the volumetric heat source
%    [W/m3] is divided by cp, consistent with Gamma = k/cp);
%  - variable density in time: aP carries rho*V/Dt, b carries
%    rho_old*V/Dt*T_old (see ucoeff.m);
%  - boundary nodes hold the conducting casing temperatures (bound.m),
%    so the wall links model conduction into the casing, not adiabatic
%    walls.

% constants
global NPI NPJ Dt DHFU CPMIX
% variables
global x x_u y y_v T Gamma SP Su F_u F_v relax_T T_old rho rho_old Rfu ...
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
        AREAw = y_v(j+1) - y_v(j); % See fig. 6.2 or fig. 6.5
        AREAe = AREAw;
        AREAs = x_u(i+1) - x_u(i);
        AREAn = AREAs;

        % The convective mass flux defined in eq. 5.8a
        Fw = F_u(i,J)*AREAw;
        Fe = F_u(i+1,J)*AREAe;
        Fs = F_v(I,j)*AREAs;
        Fn = F_v(I,j+1)*AREAn;

        % The transport by diffusion defined in eq. 5.8b
        % Gamma at the interface is calculated with the harmonic mean
        Dw = ((Gamma(I-1,J)*Gamma(I,J))/(Gamma(I-1,J)*(x(I) - x_u(i)) ...
            + Gamma(I,J)*(x_u(i) - x(I-1))))*AREAw;
        De = ((Gamma(I,J)*Gamma(I+1,J))/(Gamma(I,J)*(x(I+1) - x_u(i+1)) ...
            + Gamma(I+1,J)*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((Gamma(I,J-1)*Gamma(I,J))/(Gamma(I,J-1)*(y(J) - y_v(j)) ...
            + Gamma(I,J)*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((Gamma(I,J)*Gamma(I,J+1))/(Gamma(I,J)*(y(J+1) - y_v(j+1)) ...
            + Gamma(I,J+1)*(y_v(j+1) - y(J))))*AREAn;

        % The source terms: heat release of the KNSu reaction
        SP(I,J) = 0.;
        Su(I,J) = DHFU*Rfu(I,J)/CPMIX*AREAw*AREAs;

        % The coefficients (hybrid differencing scheme)
        aW(I,J) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,J) = max([-Fe, De - Fe/2, 0.]);
        aS(I,J) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,J) = max([-Fn, Dn - Fn/2, 0.]);

        % unsteady terms: new-level mass in aP, old-level mass in b
        aPt  = rho(I,J)*AREAe*AREAn/Dt;
        aPt0 = rho_old(I,J)*AREAe*AREAn/Dt;

        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPt;

        % Setting the source term equal to b
        b(I,J) = Su(I,J) + aPt0*T_old(I,J);

        % Introducing relaxation
        aP(I,J) = aP(I,J)/relax_T;
        b(I,J)  = b(I,J) + (1.0 - relax_T)*aP(I,J)*T(I,J);
    end
end
end
