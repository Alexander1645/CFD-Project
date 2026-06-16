function [] = Tcoeff()
% Purpose: To calculate the coefficients for the T equation.

% constants
global NPI NPJ LARGE Dt TAMB
% variables
global x x_u y y_v T Gamma SP Su F_u F_v relax_T T_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP Rk Yfu dTad

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
        % note:  F = rho*u but Fw = (rho*u)w = rho*u*AREAw per definition.    
        Fw = F_u(i,J)*AREAw;
        Fe = F_u(i+1,J)*AREAe;
        Fs = F_v(I,j)*AREAs;
        Fn = F_v(I,j+1)*AREAn;
        
        % The transport by diffusion defined in eq. 5.8b
        % note: D = mu/Dx but Dw = (mu/Dx)*AREAw per definition
        % The conductivity, Gamma, at the interface is calculated with the use of a harmonic mean.       
        Dw = ((Gamma(I-1,J)*Gamma(I,J))/(Gamma(I-1,J)*(x(I) - x_u(i)) ...
            + Gamma(I,J)*(x_u(i) - x(I-1))))*AREAw;
        De = ((Gamma(I,J)*Gamma(I+1,J))/(Gamma(I,J)*(x(I+1) - x_u(i+1)) ...
            + Gamma(I+1,J)*(x_u(i+1) - x(I))))*AREAe;
        Ds = ((Gamma(I,J-1)*Gamma(I,J))/(Gamma(I,J-1)*(y(J) - y_v(j)) ...
            + Gamma(I,J)*(y_v(j) - y(J-1))))*AREAs;
        Dn = ((Gamma(I,J)*Gamma(I,J+1))/(Gamma(I,J)*(y(J+1) - y_v(j+1)) ...
            + Gamma(I,J+1)*(y_v(j+1) - y(J))))*AREAn;
        
        % Combustion heat release (temperature-driven burn source), written
        % as a relaxation of T toward the adiabatic flame temperature
        % Tad = TAMB + dTad where unburnt fuel is present:
        %   reaction term = Rk*rho*Yfu*(Tad - T)   [K*kg/m3/s] * volume
        % Split implicitly: SP = -Rk*rho*Yfu*Vol (sink on T),
        %                   Su = +Rk*rho*Yfu*Tad*Vol (source).
        % This is bounded (T cannot overshoot Tad) and unconditionally stable
        % (SP<0). dTad and TAMB come from chemistry.m / the driver, anchored
        % to the literature flame temperature. See docs/design-decisions.md.
        Tad     = TAMB + dTad;
        SP(I,J) = -Rk(I,J)*rho(I,J)*Yfu(I,J)*AREAe*AREAn;
        Su(I,J) =  Rk(I,J)*rho(I,J)*Yfu(I,J)*Tad*AREAe*AREAn;
        
        % The coefficients (hybrid differencing scheme)
        aW(I,j) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,j) = max([-Fe, De - Fe/2, 0.]);
        aS(I,j) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,j) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = rho(I,J)*AREAe*AREAn/Dt;
        
%         if I > ceil(11*(NPI+1)/200) && I < ceil(18*(NPI+1)/200) && ...
%                 J > ceil(2*(NPJ+1)/5) && J < ceil(3*(NPJ+1)/5)
%             SP(I,J) = -LARGE;
%        