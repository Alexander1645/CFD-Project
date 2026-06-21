function [] = Tcoeff()
% Purpose: To calculate the coefficients for the T equation.

% constants
global NPI NPJ LARGE Dt TAMB rho_solid_th
% variables
global x x_u y y_v T Gamma SP Su F_u F_v relax_T T_old rho Istart Iend ...
    Jstart Jend b aE aW aN aS aP wburn Yfu dTad

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
        % GAS-FRACTION WEIGHTING: heat is convected only by actually-flowing
        % PRODUCT GAS, not through the stationary unburnt solid charge. Each face
        % flux is scaled by the face gas fraction (1-Yfu): solid-fuel cells move
        % heat by CONDUCTION only, so the front advances into the charge as a
        % self-sustaining conduction wave, while burnt gas convects and vents
        % normally. Without this the gas-generation flow (which exits the west
        % vent, next to the igniter) strips heat off the front and the flame
        % convectively extinguishes - the documented gas-phase-flame limitation.
        % This mirrors the solid (no-convection) treatment already used for Yfu.
        fgw = 1. - 0.5*(Yfu(I-1,J) + Yfu(I,J));     % gas fraction, west face
        fge = 1. - 0.5*(Yfu(I,J)   + Yfu(I+1,J));   % east face
        fgs = 1. - 0.5*(Yfu(I,J-1) + Yfu(I,J));     % south face
        fgn = 1. - 0.5*(Yfu(I,J)   + Yfu(I,J+1));   % north face
        Fw = F_u(i,J)*AREAw*fgw;
        Fe = F_u(i+1,J)*AREAe*fge;
        Fs = F_v(I,j)*AREAs*fgs;
        Fn = F_v(I,j+1)*AREAn*fgn;
        
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
        
        % Combustion heat release (energy-conserving form): the charge consumed
        % per second is wburn (fraction/s, from the rate-anchored front), and
        % each unit released enthalpy Q = Cp*dTad, so the source is
        %   q'''/Cp = wburn*rho_th*dTad   [K*kg/m3/s]
        % integrated over the cell volume. Consuming a whole cell raises it by
        % dTad (-> adiabatic flame temperature Tad = TAMB+dTad).
        %
        % SOLID THERMAL MASS: rho_th is the thermal density of the cell - solid
        % charge (rho_solid_th, literal KNSu) while unburnt, product gas once
        % burnt, blended by Yfu. It multiplies BOTH the storage term (aPold) and
        % the heat-release source, so the peak temperature is unchanged (rho_th
        % cancels -> still dTad) but the unburnt charge has the solid's large
        % thermal inertia, so it stays cold until the front (set by wburn, NOT by
        % conduction) arrives. rho_th appears ONLY in the energy eq - the flow
        % uses the gas density, so nothing diverges.
        rho_th  = Yfu(I,J)*rho_solid_th + (1.0 - Yfu(I,J))*rho(I,J);   % thermal density
        SP(I,J) = 0.;
        Su(I,J) = wburn(I,J)*rho_th*dTad*AREAe*AREAn;

        % The coefficients (hybrid differencing scheme)
        aW(I,j) = max([ Fw, Dw + Fw/2, 0.]);
        aE(I,j) = max([-Fe, De - Fe/2, 0.]);
        aS(I,j) = max([ Fs, Ds + Fs/2, 0.]);
        aN(I,j) = max([-Fn, Dn - Fn/2, 0.]);
        aPold   = rho_th*AREAe*AREAn/Dt;
        
%         if I > ceil(11*(NPI+1)/200) && I < ceil(18*(NPI+1)/200) && ...
%                 J > ceil(2*(NPJ+1)/5) && J < ceil(3*(NPJ+1)/5)
%             SP(I,J) = -LARGE;
%             Su(I,J) = LARGE*373.;
%         end
        
        % eq. 8.31 without time dependent terms (see also eq. 5.14):
        aP(I,J) = aW(I,J) + aE(I,J) + aS(I,J) + aN(I,J) + Fe - Fw + Fn - Fs - SP(I,J) + aPold;
        
        % Setting the source term equal to b        
        b(I,J) = Su(I,J) + aPold*T_old(I,J);
        
        % Introducing relaxation by eq. 6.36 . and putting also the last
        % term on the right side into the source term b(i,J)       
        aP(I,J) = aP(I,J)/relax_T;
        b(I,J)  = b(I,J) + (1.0 - relax_T)*aP(I,J)*T(I,J);
        
        % now the TDMA algorithm can be called to solve the equation.
        % This is done in the next step of the main program.        
    end
end
end

