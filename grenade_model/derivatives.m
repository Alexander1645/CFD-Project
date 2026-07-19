function [] = derivatives()
% Purpose: To calculate the velocity derivatives used in the viscous
% source terms of the momentum equations. Taken from
% ProjectInfo/code_final_assignment/derivatives.m; the turbulence
% production terms E and E2 are dropped (laminar flow).

% variables
global x x_u y y_v u v dudx dudy dvdx dvdy
% constants
global NPI NPJ

for I = 2:NPI+1
    i = I;
    for J = 2:NPJ+1
        j = J;
        dudx(I,J) = (u(i+1,J) - u(i,J)) / (x_u(i+1) - x_u(i));
        dudy(i,j) = (u(i,J) - u(i,J-1)) / (y(J) - y(J-1));
        dvdx(i,j) = (v(I,j) - v(I-1,j)) / (x(I) - x(I-1));
        dvdy(I,J) = (v(I,j+1) - v(I,j)) / (y_v(j+1) - y_v(j));
    end
end
end
