WC6 – Boundary Condition Study for Backward-Facing Step Flow
Objective
The objective of this study is to investigate how different boundary conditions affect the
flow behavior in a backward-facing step problem using a finite-volume CFD solver.
The benchmark case is first simulated and then modified boundary conditions are
introduced. The effects on the recirculation zone, reattachment length, pressure/velocity
distributions, numerical stability, and convergence behavior are compared.
1. Benchmark Case Code Modifications
File changed: bound.m
Original code
for J = NhJ+1:NPJ+2
u(2,J) = 0; % inlet velocity
k(1,J) = 1.5*(U_IN*Ti)^2;
eps(1,J) = Cmu^0.75 *k(1,J).^1.5/(0.07*(YMAX-h)*0.5);
end
Modified code
for J = NhJ+1:NPJ+2
u(2,J) = U_IN; % uniform inlet velocity
v(1,J) = 0; % no vertical inlet velocity
k(1,J) = 1.5*(U_IN*Ti)^2;
eps(1,J) = Cmu^0.75 *k(1,J).^1.5/(0.07*(YMAX-h)*0.5);
end

2. Benchmark Results
a) Streamwise velocity contour
b) Cross-stream velocity contour
c) Velocity magnitude and streamlines
3. Modified Boundary Conditions
The following boundary conditions were modified to investigate their influence on the flow
behavior.
3.1. Parabolic inlet profile

File changed: bound.m
Beware that the given velocity profile is not directly applicable. Check the boundary
| conditions yourself:  |     |  .   |     |
| --------------------- | --- | ---- | --- |
Derive the velocity p𝑢𝑢ro(ℎfi)le= yo𝑢𝑢u(r3seℎl)f f=ro0m the plane Poiseuille equation.

2
|                              | 𝑑𝑑𝑢𝑢         | −1𝑑𝑑𝑝𝑝 |           |
| ---------------------------- | ------------ | ------ | --------- |
|                              | � 2 𝑑𝑑𝑑𝑑𝑑𝑑𝑑𝑑 | = �    |  𝑑𝑑𝑑𝑑𝑑𝑑𝑑𝑑 |
| The final equation becomes:  | 𝑑𝑑𝑦𝑦         | 𝜇𝜇     | 𝑑𝑑𝑥𝑥      |

|     |     | 2   | 2   |
| --- | --- | --- | --- |
−𝑑𝑑 +4ℎ𝑑𝑑−3ℎ
𝑈𝑈𝑚𝑚𝑚𝑚𝑥𝑥(
| Modified code  | 𝑢𝑢(𝑑𝑑) = |     | 2 ) |
| -------------- | -------- | --- | --- |
ℎ
for J = NhJ+1:NPJ+2
   u(2,J) = U_IN*(-y_v(J)^2+4*h*y_v(J)-3*h^2)/h^2; % parabolic inlet
   v(1,J) = 0;
   k(1,J) = 1.5*(U_IN*Ti)^2;
   eps(1,J) = Cmu^0.75*k(1,J).^1.5/(0.07*(YMAX-h)*0.5);
end

3.1.1. Parabolic inlet profile results
a) Streamwise velocity contour

b) Cross-stream velocity contour
c) Velocity magnitude and streamlines
3.2. Slip upper wall
File changed: bound.m
Modified code
% Case slip wall at top boundary
u(:,NPJ+2) = u(:,NPJ+1); % du/dy = 0
v(:,NPJ+2) = 0; % no penetration

3.2.1. Slip upper wall results
Streamwise velocity contour
Cross-stream velocity contour
Velocity magnitude and streamlines
3.3 Combined

File changed: bound.m
Modified code
for J = NhJ+1:NPJ+2
u(2,J) = U_IN*(-y_v(J)^2+4*h*y_v(J)-3*h^2)/h^2; % parabolic inlet
v(1,J) = 0;
k(1,J) = 1.5*(U_IN*Ti)^2;
eps(1,J) = Cmu^0.75*k(1,J).^1.5/(0.07*(YMAX-h)*0.5);
end
Modified code
% Case slip wall at top boundary
u(:,NPJ+2) = u(:,NPJ+1); % du/dy = 0
v(:,NPJ+2) = 0; % no penetration
3.3.1. Combined result
a) Streamwise velocity contour
b) Cross-stream velocity contour
c) Velocity magnitude and streamlines