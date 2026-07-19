function [] = velcorr()
% To correct the pressure and the velocities by eq. 6.24, 6.25 and a
% modified version of eq. 6.33 (unchanged from
% ProjectInfo/code_final_assignment/velcorr.m).

% constants
global NPI NPJ
% variables
global u v pc p d_u d_v relax_pc

for I = 2:NPI+1
    i = I;
    for J = 2:NPJ+1
        j = J;
        p(I,J) = p(I,J) + relax_pc*pc(I,J); % equation 6.33

        % Velocity correction
        if (i ~= 2)
            u(i,J) = u(i,J) + d_u(i,J)*(pc(I-1,J) - pc(I,J)); % eq. 6.24
        end

        if (j ~= 2)
            v(I,j) = v(I,j) + d_v(I,j)*(pc(I,J-1) - pc(I,J)); % eq. 6.25
        end
    end
end
end
