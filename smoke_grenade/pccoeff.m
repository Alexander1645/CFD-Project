function [] = pccoeff()
% Purpose: To calculate the coefficients for the pc equation.

% constants
global NPI NPJ
% variables
global x_u y_v pc rho SP Su F_u F_v d_u d_v Istart Iend Jstart Jend ...
    b aE aW aN aS aP SMAX SAVG rho_old Dt

Istart = 2;
Iend = NPI+1;
Jstart = 2;
Jend = NPJ+1;

SMAX = 0.;
SSUM = 0.;
SAVG = 0.;

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
        
        % The constant b' in eq. 6.32
        b(I,J) = F_u(i,J)*AREAw - F_u(i+1,J)*AREAe + F_v(I,j)*AREAs - F_v(I,j+1)*AREAn;
        
        % Transient compressible continuity (v3): net mass flux in must equal
        % the rate of mass accumulation from the density change. Continuity
        %   (rho-rho_old)/Dt*Vol + (Fe-Fw+Fn-Fs) = 0
        % so the source added to the imbalance b' is (rho_old-rho)*Vol/Dt.
        % When a cell heats, rho drops -> source>0 -> the pressure field pushes
        % the expanding gas out the vent. This IS the thermal-expansion venting
        % (it replaces the old constant-density mass-source hack). See density.m.
        % Thermal-expansion mass source (stable). The chamber pressure / orifice
        % venting is handled by the robust 0-D model in run_grenade (the
        % solid-density source here made the 2-D venting supersonic -> unstable).
        SP(I,J) = 0.;
        Su(I,J) = (rho_old(I,J) - rho(I,J))*AREAe*AREAn/Dt;

        b(I,J) = b(I,J) + Su(I,J);
        
        SMAX = max([SMAX,abs(b(I,J))]);
        SSUM = SSUM + abs(b(I,J));
        
        % The coefficients
        aE(I,J) = 0.5*(rho(I,J) + rho(I+1,J))*d_u(i+1,J)*AREAe;
        aW(I,J) = 0.5*(rho(I-1,J) + rho(I,J))*d_u(i,J)*AREAw;
        aN(I,J) = 0.5*(rho(I,J) + rho(I,J+1))*d_v(I,j+1)*AREAn;
        aS(I,J) = 0.5*(rho(I,J-1) + rho(I,J))*d_v(I,j)*AREAs;
        
        aP(I,J) = aE(I,J) + aW(I,J) + aN(I,J) + aS(I,J) - SP(I,J);

        pc(I,J) = 0.;
        
        % note: At the points nearest the boundaries, some coefficients are
        % necessarily zero. For instance at I = 1 and J = 1, the coefficients
        % aS and aW are zero since they are on the outside of the calculation
        % domain. This is automatically satisfied through the initialisation
        % where d_u(i,J) and d_v(I,j) are set to zero at these points.        
    end
end
% Average error in mass balance is summed error divided by number of internal grid points
SAVG = SSUM/((Iend - Istart)*(Jend - Jstart));

end

