Transparent Presentation title with
image behind title.
Choose this slide model if the image is
large enough to be used full-screen and
essential image information remains
visible.
Choose image by clicking on image icon
or
Replace an existing image with right
mouse button and choose Change
image.
Introduction to CFD (4RC30)
Boundary conditions (section 2.10 & 2.11, Chapter 9)
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. Yali Tang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

What/where are the BC’s
Text format by
Increase / decrease list level
Place cursor in text hot
and use these 2 buttons (tab Start -
group Paragraph) • inlet
• outlet
• wall
• internal wall
cold
1 = Normal text
hot
2 = Paragraph text
3 = • text
BC for every
4 = • text
5 = • text
solving variables!
y
x
hot
2 Introduction to CFD (4RC30)

BC’s: overview
Text format by Commonly used BC Feature
Increase / decrease list level
Place cursor in text Dirichlet Boundary Condition Fixed value of the solution (e.g. T = A)
and use these 2 buttons (tab Start -
group Paragraph) No-slip BC is a Dirichlet application
Neumann Boundary Condition Fixed derivative of the solution (e.g. 𝜕𝑢Τ𝜕𝑛 = B)
Free-slip BC is a Neumann application
Mixed Boundary Condition Combined use of Dirichlet and Neumann BC
1 = Normal text
2 = Paragraph text (example next slide)
3 = • text
4 = • text
Robin Boundary Condition Setting a linear combination of both the value and its derivative
5 = • text
(e.g. heat loss through a surface (derivative) depends directly on
the surface's actual temperature (value))
• Initial conditions (t = 0): special BC
Everywhere in solution region given 𝜌,𝒖,𝑇,𝑘,𝜀,…
3 Introduction to CFD (4RC30)

BC’s: overview
• BC’s on solid walls:
Text format by
Increase / decrease list level
| • 𝒖 | = 𝒖  (no slip condition, mostly 𝒖 | = 0) |
| --- | --------------------------------- | ---- |
| 𝑡   | 𝑤                                 | 𝑤    |
Place cursor in text
and use these 2 buttons (tab Start -
| • 𝑇 = | 𝑇  (fixed wall temperature) |     |
| ----- | --------------------------- | --- |
group Paragraph) 𝑤
| • 𝑘 𝜕𝑇Τ𝜕𝑛 | = −𝑞  (fixed heat flux) |     |
| --------- | ----------------------- | --- |
𝑤
• BC’s on free surfaces:
1 = Normal text
| • 𝑢 | = 0 (no fluid cross the boundary) |     |
| --- | --------------------------------- | --- |
2 = Paragraph text 𝑛
3 = • text
| • 𝜕𝑢 | Τ𝜕𝑛 = 0 (frictionless “wall”, free slip condition) |     |
| ---- | -------------------------------------------------- | --- |
4 =    • text
𝑡
5 =       • text n
     t
4 Introduction to CFD (4RC30)

BC’s at inlet
|     | •   | Given profiles of 𝒖, |     |     |     | 𝑇, 𝑘, | 𝜀, … |     |
| --- | --- | -------------------- | --- | --- | --- | ----- | ---- | --- |
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
| group Paragraph) | •   | Example: |     |     |     |     |     |     |
| ---------------- | --- | -------- | --- | --- | --- | --- | --- | --- |
R
▪ Constant profile for 𝑇
𝑖𝑛
t
▪ Parabolic or plug flow profile for 𝑢
𝑖𝑛,𝑛      n
| 1 = Normal text    |     | ▪ Straight inflow: 𝑢 |     |     |      | = 0 |       |     |
| ------------------ | --- | -------------------- | --- | --- | ---- | --- | ----- | --- |
| 2 = Paragraph text |     |                      |     |     | 𝑖𝑛,𝑡 |     |       |     |
| 3 = • text         |     |                      |     |     |      |     | 3 / 2 |     |
k
| 4 =    • text |     |        |     | 2       |     | 3 / | 4         |       |
| ------------- | --- | ------ | --- | ------- | --- | --- | --------- | ----- |
|               |     | k = 32 | ( u | T ) ;  | =   | C   | ; l = 0 . | 0 7 R |
5 =       • text
|     |     | in  | in  | i   | in  |    | l   |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
    𝑇
 is turbulence intensity (1-6%)
𝑖

5 Introduction to CFD (4RC30)

BC’s at outlet
• Stress continuity:
Text format by
Increase / decrease list level
|     |     |   u |     | u |     |     |     |     |
| --- | --- | ----- | --- | --- | --- | --- | --- | --- |
Place cursor in text
|     | - p + | n = | F   |     | t = F |     |     |     |
| --- | ----- | --- | --- | --- | ----- | --- | --- | --- |
and use these 2 buttons (tab Start -
|                  |     |     | n   |     |     | t   |     |     |
| ---------------- | --- | --- | --- | --- | --- | --- | --- | --- |
| group Paragraph) |     |  n |     |     | n  |     |     |     |
• In fully developed flow:
|     |  u |  u   |     |     |     |       |     |     |
| --- | --- | ----- | --- | --- | --- | ----- | --- | --- |
|     | n   | = t = | 0  | F = | − p | F = 0 |     |     |
1 = Normal text
|                    |     |     |     | n   |     | t   |     |     |
| ------------------ | --- | --- | --- | --- | --- | --- | --- | --- |
| 2 = Paragraph text |  n |  n |     |     |     |     |     |     |
3 = • text
4 =    • text
5 =       • text
• Most used: outflow pressure BC (flow finish developing)
|     |     |           |  u |     |  T |     |  k |   |
| --- | --- | --------- | --- | --- | --- | --- | --- | --- |
|     | p = | p         | n = | 0   | =   | 0   | = 0 | = 0 |
|     |     | o u tle t |     |     |     |     |     |     |
|     |     |           |  n |     |  n |     |  n |  n |
6 Introduction to CFD (4RC30)

BC’s at outlet
• In real-world simulations, outlet often suffer from reverse flow (backflow), a strict static
Text format by
Increase / decrease list level
condition can easily crash the solver.
Place cursor in text
and use these 2 buttons (tab Start -
• Sometimes not a prior known if flow in or out (e.g. windows in a room)
group Paragraph)
Use a dynamic BC: e.g. inletOutlet Boundary Condition (in OpenFOAM)
1 = Normal text • reads the direction of the local fluid flux (Φ) at grids face the boundary
2 = Paragraph text
3 = • text
4 = • text • If Φ > 0, fluid leaving the domain (outflow): Neumann/zero-gradient condition
5 = • text
• If Φ < 0, fluid entering the domain (inflow/backflow): Dirichlet/fixedValue condition using
a user-defined inletValue
7 Introduction to CFD (4RC30)

Overall mass balance
The overall mass balance can be satisfied by:
Text format by
Increase / decrease list level
Place cursor in text
J in ,m a x
and use these 2 buttons (tab Start -
|     | M = |  A |  u |     |
| --- | --- | --- | --- | --- |
group Paragraph)
|     | in  |     | c e ll |     |
| --- | --- | --- | ------ | --- |
bound.m
j = J
|     |     | in ,m in |     | for J = 2:NPJ+1 |
| --- | --- | -------- | --- | --------------- |
      j = J;
     AREAw = y_v(j+1) - y_v(j);
J
|     |     | out,max |     |      m_in      = m_in  + F_u(2,J)*AREAw; |
| --- | --- | ------- | --- | ---------------------------------------- |
1 = Normal text
|     | M   | =  | A u |     |
| --- | --- | --- | ---- | --- |
2 = Paragraph text      m_out    = m_out + F_u(NPI+1,J)*AREAw;
|     | out |     | cell |     |
| --- | --- | --- | ---- | --- |
3 = • text
j=J
| 4 =    • text |     | out,min |     | end |
| ------------- | --- | ------- | --- | --- |
5 =       • text
u(NPI+2,2:NPJ+1) = u(NPI+1,2:NPJ+1)*m_in/m_out;
M
|     | u       | = u   |  in |     |
| --- | ------- | ----- | ---- | --- |
|     | NPI+1,J | NPI,J | M    |     |
out
8 Introduction to CFD (4RC30)

What are the BC’s
Text format by
Increase / decrease list level
Place cursor in text hot
and use these 2 buttons (tab Start -
group Paragraph)
cold
1 = Normal text
hot
2 = Paragraph text
3 = • text
4 = • text
5 = • text
y
x
hot
9 Introduction to CFD (4RC30)

What are the BC’s
Text format by
Increase / decrease list level
Place cursor in text T = T u=v=0
and use these 2 buttons (tab Start - w
group Paragraph)
u = 0
T = T
1 = Normal text s
2 = Paragraph text
3 = • text u=v=0
4 = • text
5 = • text
y
x
T = T u=v=0
w
10 Introduction to CFD (4RC30)
T
u
v
=
=
=
T
f
0
in
( y )
bound.m
% Fixed temperature at the upper and lower wall
T(1:NPI+2,1) = 373.; % lower wall
T(1:NPI+2,NPJ+2) = 373.; % upper wall
% Fixed temperature/velocity of the incoming fluid
T(1,2:NPJ+1) = 273.;
u(2,2:NPJ+1) = U_IN;
% outlet boundary conditions
u(NPI+2,2:NPJ+1) = u(NPI+1,2:NPJ+1)*m_in/m_out;
v(NPI+2,2:NPJ+1) = v(NPpI+=1,2p:NPJ+1);
T(NPI+2,2:NPJ+1) = T(NPI+1,2:oNuPtleJt+1);
u
n = 0
n
T
= 0
n

BC’s internal walls
• Internal walls are inside solution domain, all the equations are solved
Text format by
Increase / decrease list level
Place cursor in text •
Use source terms to set variables to fixed value:
and use these 2 buttons (tab Start -
group Paragraph)
| S = −1030 |     | S   | =1030 |     |     |          |
| --------- | --- | --- | ------ | --- | --- | -------- |
| P         |     |     | u      | fix |     | ucoeff.m |
LARGE  = 1E30;
1 = Normal text
if  i == NPI/5 && J < NPJ/3
2 = Paragraph text
| (a − | S ) | = a |    | + S |     |     |
| ---- | ---- | ---- | --- | --- | --- | --- |
3 = • text     SP[i][J] = -LARGE;
| P   | P P |     | nb nb | u   |     |     |
| --- | --- | --- | ----- | --- | --- | --- |
4 =    • text
5 =       • text     Su[i][J] = LARGE*u_fix;
| (a +1030) |     | = a |    | +1030 |     |     |
| ---------- | --- | ---- | --- | ------ | --- | --- |
| P          |     | P    | nb  | nb     | fix | end |
 =
| P   | fix |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- |
11 Introduction to CFD (4RC30)

| Boundary conditions 𝒌 | − 𝜺 at walls |     |
| --------------------- | ------------ | --- |
• On solid walls high shear stress
Text format by
Increase / decrease list level
Place cursor in text • Equilibrium between 𝒌 and 𝜺
and use these 2 buttons (tab Start -
group Paragraph)
1 / 2
|                              |  |   |
| ---------------------------- | --- | ----- |
|                              | u = | w     |
| • Friction or shear velocity |    |       |

1 = Normal text
2 = Paragraph text
|     |     | u y |
| --- | --- | ---- |
3 = • text
| • Dimensionless wall distance | y+ = |    |
| ----------------------------- | ---- | --- |
4 =    • text
5 =       • text 
U
|     | u + = | = f ( y + ) |
| --- | ----- | ----------- |
• Dimensionless velocity
u

12 Introduction to CFD (4RC30)

|     | Law of the wall |     |     |     |     | 4 0 |     |     |
| --- | --------------- | --- | --- | --- | --- | --- | --- | --- |
3 0
Boundary layer exists of:
| Text format by |     |     |     |     |     | +u 2 0 |     |     |
| -------------- | --- | --- | --- | --- | --- | ------ | --- | --- |
Increase / decrease list level
• Viscous sub-layer (thin!)
Place cursor in text
1 0
and use these 2 buttons (tab Start -
group Paragraph)       Physical viscosity of the fluid kills the turbulence
0
|     |     | +     |           | + +   |     |            |            |            |
| --- | --- | ----- | --------- | ----- | --- | ---------- | ---------- | ---------- |
|     |     | y  1 | 1 . 6 3 ; | u = y |     | 0 .E + 0 0 | 5 .E + 0 4 | 1 .E + 0 5 |
y +
•
Turbulent layer: log-law region
1 = Normal text
|                    |     |       |           | 1       |         | 40  |     |     |
| ------------------ | --- | ----- | --------- | ------- | ------- | --- | --- | --- |
| 2 = Paragraph text |     | +     |           | +       | +       |     |     |     |
|                    |     | y  1 | 1 . 6 3 ; | u = l n | ( E y ) |     |     |     |
3 = • text

| 4 =    • text |     |     |     |     |     | 30  |     |     |
| ------------- | --- | --- | --- | --- | --- | --- | --- | --- |
5 =       • text
|     |     | Von Kármán constant 𝜅 |     |     | = 0.4184,  |     |     |     |
| --- | --- | --------------------- | --- | --- | ---------- | --- | --- | --- |
+
u 20
1
|     |     | Wall roughness constant 𝐸 |     |     | = 9.793 | u+ = | ln(Ey+) |     |
| --- | --- | ------------------------- | --- | --- | ------- | ---- | ------- | --- |

10
Avoiding extreme fine mesh down to the wall, wall functions  u+ = y+
are used with the first grid cell placed in the turbulent layer. 0
|     |     |     |     |     |     | 0 1 | 2 3 | 4 5 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
log y+

13 Introduction to CFD (4RC30)
|     |     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

Implementation law of the wall (1)
Velocity (𝑼) Wall Function
Text format by
Increase / decrease list level
• 𝑢 velocity parallel to wall (governed by the log-law):
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
|                               | 1       |     | 1 / 4 | 1 / 2 |
| ----------------------------- | ------- | --- | ----- | ----- |
|                            𝑢+ | ln(𝐸𝑦+) |     |  C   | k u   |
| =                             |         |     |      | P     |
|                               |         |    | =     |       |
|                               | 𝜅       | w   |       |       |
u +
1 = Normal text
• Implementation as source terms:
2 = Paragraph text
3 = • text
4 =    • text
5 =       • text
C1/4k1/2

|     | a = 0; | S = | −   | A    |
| --- | ------ | --- | --- | ---- |
|     | S      | P,u |     | Cell |
u+
At the wall, no-slip or zero velocity.
14 Introduction to CFD (4RC30)

Implementation law of the wall (2)
Turbulent Kinetic Energy (𝒌) Wall Function (cells adjacent to the wall)
Text format by
Increase / decrease list level
• 𝒌 is calculated dynamically, but its production and dissipation are assumed to be
Place cursor in text
and use these 2 buttons (tab Start -
in a state of local equilibrium.
group Paragraph)
• The friction velocity 𝑢  is linked to 𝒌:
𝜏
3
|     | 1/4   |                                 | 𝑤𝑎𝑙𝑙 |     | 𝜌𝑢  |
| --- | ----- | ------------------------------- | ---- | --- | --- |
|     | 𝑢 = 𝐶 | 𝑘                             𝑃 |      | =   | 𝜏   |
|     | 𝜏     |                                 | 𝑘    |     |     |
|     | 𝜇     |                                 |      |     | 𝜅𝑦  |
1 = Normal text
2 = Paragraph text
• Implementation as source terms:
3 = • text
4 =    • text
5 =       • text
|         |      | 3 / 4 | 1o / 2 + |      |           |
| ------- | ---- | ----- | -------- | ---- | --------- |
|         |      |  C k | u        |      |  u       |
| a = 0 ; | S    | = −  | ld  V ; | S    | = w P  V |
| S       | P ,k |       |          | u ,k |           |
|         |      |  y   |          |      |  y       |
|         |      |       | P        |      | P         |
At the wall, apply a zero-gradient (Neumann) condition: 𝜕𝑘Τ𝜕𝑛 = 0
15 Introduction to CFD (4RC30)

Implementation law of the wall (3)
Turbulence Dissipation Rate (𝜺) Wall Function (cells adjacent to the wall)
Text format by
Increase / decrease list level
• 𝜺 is explicitly overwriten
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
• fixed with a Dirichlet value calculated directly from the cell's local kinetic energy :
𝐶 3/4 𝑘3/2
𝜇
𝜀 =
𝜅𝑦
1 = Normal text
2 = Paragraph text • Implementation as source terms:
3 = • text
4 = • text
5 = • text
C3/4k3/2
S = −1030; S =  P 1030
P, u,
y
P
16 Introduction to CFD (4RC30)

Implementation law of the wall
• 𝒖 velocity parallel to wall:
Text format by
Increase / decrease list level
|                                       |     |     |      |     | 1 / 4 | 1 / 2  |     |     |
| ------------------------------------- | --- | --- | ---- | --- | ----- | ------ | --- | --- |
| Place cursor in text                  |     |     |      |  C | k     |        |     |     |
| and use these 2 buttons (tab Start -  | a = | 0 ; | S =  | −   |      | A      |     |     |
| group Paragraph)                      | S   |     | P ,u |     | +     | C e ll |     |     |
u
• 𝒌 equation:
|     |     |     |     |     | 3 / 4 | 1o / 2 + |     |           |
| --- | --- | --- | --- | --- | ----- | -------- | --- | --------- |
|     |     |     |     |  C | k     | u        |     |  u       |
|     | a = | 0 ; | S = | −   |      | ld  V ; | S   | = w P  V |
1 = Normal text
|                    | S   |     | P ,k |     |     |     | u ,k |     |
| ------------------ | --- | --- | ---- | --- | --- | --- | ---- | --- |
| 2 = Paragraph text |     |     |      |     |  y |     |      |  y |
| 3 = • text         |     |     |      |     | P   |     |      | P   |
4 =    • text
5 =       • text
• 𝜺 equation:
C 3 / 4 k 3 / 2
|     |       | 3 0     |       |    | P   | 3 0 |     |     |
| --- | ----- | ------- | ----- | --- | --- | --- | --- | --- |
|     | S =   | − 1 0 ; | S =   |     |    | 1 0 |     |     |
|     | P ,  |         | u ,  |   | y   |     |     |     |
P
17 Introduction to CFD (4RC30)

What does NOT work?
• One inlet, but no outlets
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
• No developed/circulating flow at the outlet (unless a dynamic BC used)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
18 Introduction to CFD (4RC30)
Image credit: H.K. Versteeg, W. Malalasekera

What does NOT work?
Over-constrained BCs
Text format by
Increase / decrease list level
• Example 1:
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
An incompressible fluid flows through a pipe with constant diameter:
• Inlet: Dirichlet BC. 𝑢 = 5 m/s
• Outlet: Dirichlet BC. 𝑢 = 3 m/s
Mass conservation failed
1 = Normal text
2 = Paragraph text • Example 2: The Pressure-Velocity Conflict
3 = • text
4 = • text
5 = • text Air flows through a high-speed converging nozzle:
• Inlet: Dirichlet BC. 𝑢 = 50 m/s, p = 101Pa
• Outlet: open BC
Velocity and pressure are linked by momentum conservation. You can specify the velocity or you can
specify the pressure, but you cannot dictate both.
19 Introduction to CFD (4RC30)