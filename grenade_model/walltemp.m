function [] = walltemp()
% Purpose: lumped-capacity model of the conducting casing (the walls are
% NOT adiabatic). Each wall segment of thickness TWTH is a thermal mass
% per unit area C = RHOW*CPW*TWTH that is
%   - heated by conduction from the adjacent interior cell:
%       q_in = k_cell * (T_cell - T_wall) / (half cell distance)
%     (k_cell = Gamma*cp; this is the same flux the T equation exchanges
%     with the Dirichlet boundary node, which bound() sets to T_wall);
%   - cooled by natural convection on the outside:
%       q_out = HEXT * (T_wall - TAMB).
% Explicit update once per time step (the wall time constant is orders of
% magnitude larger than Dt).

% constants
global NPI NPJ Dt CPMIX RHOW CPW TWTH HEXT TAMB JH1 JH2
% variables
global x y T Gamma TwB TwT TwL TwR

CW  = RHOW*CPW*TWTH;        % casing heat capacity per unit area [J/(m2 K)]
dyb = y(2) - y(1);          % half-cell distance to the bottom wall
dyt = y(NPJ+2) - y(NPJ+1);  % ... top wall
dxl = x(2) - x(1);          % ... left wall
dxr = x(NPI+2) - x(NPI+1);  % ... right wall

for I = 2:NPI+1
    q      = Gamma(I,2)*CPMIX*(T(I,2) - TwB(I))/dyb;
    TwB(I) = TwB(I) + Dt*(q - HEXT*(TwB(I) - TAMB))/CW;

    q      = Gamma(I,NPJ+1)*CPMIX*(T(I,NPJ+1) - TwT(I))/dyt;
    TwT(I) = TwT(I) + Dt*(q - HEXT*(TwT(I) - TAMB))/CW;
end

for J = 2:NPJ+1
    q      = Gamma(NPI+1,J)*CPMIX*(T(NPI+1,J) - TwR(J))/dxr;
    TwR(J) = TwR(J) + Dt*(q - HEXT*(TwR(J) - TAMB))/CW;

    if J < JH1 || J > JH2   % no casing at the hole
        q      = Gamma(2,J)*CPMIX*(T(2,J) - TwL(J))/dxl;
        TwL(J) = TwL(J) + Dt*(q - HEXT*(TwL(J) - TAMB))/CW;
    end
end
end
