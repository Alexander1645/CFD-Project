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
Convection-diffusion problems;
Discretization schemes
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. YaliTang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

Summary of last lecture
|     | • Rate of change + convection |     |     |     |     | = diffusion |     | + (source – |     | sink) |
| --- | ----------------------------- | --- | --- | --- | --- | ----------- | --- | ----------- | --- | ----- |
Text format by
Increase / decrease list level
Place cursor in text
|     |     |  (  | )   |     |     |     |     |     |     |     |
| --- | --- | ------ | --- | --- | --- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
|     |     |     | + d i | v (  | u ) = | d i v (  | g r a d  | ) + S |     |     |
| --- | --- | --- | ----- | ------ | ----- | --------- | --------- | ----- | --- | --- |
group Paragraph)

 t
• General form of discretized equations:
1 = Normal text
2 = Paragraph text
3 = • text
|                  |                                       |     |    |     |     |     |     |      |     |     |
| ---------------- | ------------------------------------- | --- | --- | --- | --- | --- | --- | ----- | --- | --- |
| 4 =    • text    |                                       | a  | =   | a  | +   | S   | a   | =     | a − | S   |
| 5 =       • text |                                       | P P |     | n b | n b | u   | P   |       | n b | P   |
|                  | • Source terms are included through S |     |     |     |     |     |     | and S |     |     |
|                  |                                       |     |     |     |     |     | u   |       | P   |     |
2 Introduction to CFD (4RC30)

Content of this lecture (chapter 5)
Text format by • Discretization 1D steady convection-diffusion equation
Increase / decrease list level
Place cursor in text • Discretization schemes and their properties
and use these 2 buttons (tab Start -
group Paragraph)
▪ Central differencing scheme
▪ Upwind differencing scheme
▪ Hybrid differencing scheme
1 = Normal text Learningoutcomesofthissession
2 = Paragraph text
1. Formulateaconservationequationforconvectivetransport,
3 = • text ▪ Other schemes
4 = • text 2. Explain the central, upwind, and hybrid discretization schemes
5 = • text
usingownwords,
3. Motivate the choice for a discretization scheme for convective
transport foragivingphysicalproblem.
3 Introduction to CFD (4RC30)

Steady convection-diffusion
 (  )
|                |              |             |             |       |     | + d i v | (  u ) = | d i v (  g | r a d  ) + | S   |
| -------------- | ------------ | ----------- | ----------- | ----- | --- | ------- | ---------- | ----------- | ----------- | --- |
|                | • convection | = diffusion | + (source – | sink) |     |         |            |             |             |     |
| Text format by |              |             |             |       |  t |         |            |             |             |    |
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start - d i v (  u ) = d i v (  g r a d  ) + S
| group Paragraph) |     |     |    |     |          |            |           |     |     |     |
| ---------------- | --- | --- | --- | --- | -------- | ---------- | --------- | --- | --- | --- |
|                  |     |     |     |     | V d i v | a d V = A | n  a d A |     |     |     |
• Integration over control volume:
C
1 = Normal text
|     | n(u)dA | = n(grad)dA+ |     |  S | dV  |     |     |     |     |     |
| --- | ---------- | ---------------- | --- | --- | --- | --- | --- | --- | --- | --- |
2 = Paragraph text

3 = • text
| 4 =    • text | A   | A   |     | CV  |     |     |     |     |     |     |
| ------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
5 =       • text
• Assumptions:
• 𝒖 is known (computation of 𝒖 is explained in lecture 3)
• No sources or sinks
4 Introduction to CFD (4RC30)

Steady 1D convection-diffusion
• Transport equation:
Text format by
Increase / decrease list level
| Place cursor in text | d   | d  | d   |
| -------------------- | --- | ----- | ------- |
and use these 2 buttons (tab Start -
|     | (  u  ) | =  |     |
| --- | --------- | --- | --- |
group Paragraph)
|     | d x | d x | d x |
| --- | --- | --- | --- |
• Continuity equation (mass balance):
1 = Normal text
2 = Paragraph text
d (  u )
3 = • text
= 0
4 =    • text
| 5 =       • text | d x |     |     |
| ---------------- | --- | --- | --- |
5 Introduction to CFD (4RC30)

Steady 1D convection-diffusion
Step 1: Grid generation
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
6 Introduction to CFD (4RC30)

Steady 1D convection-diffusion
Step 2: Integration
Text format by
|                                |     |     | d   |       |     | d   | d  |     |     |
| ------------------------------ | --- | --- | --- | ----- | --- | --- | --- | --- | --- |
| Increase / decrease list level |     |     |     |       |     |  |  |     |     |
|                                |     |     |     | (  u |  ) | =  |     |     |     |
Place cursor in text • Transport equation:
| and use these 2 buttons (tab Start - |     |     | d x |     |     | d x | d x |     |     |
| ------------------------------------ | --- | --- | --- | --- | --- | --- | --- | --- | --- |
group Paragraph)
|     |     |     |  n  | (  u | ) d A | =  n  (  | g r a d  ) d A | +  | S d V |
| --- | --- | --- | ----- | ------ | ----- | ----------- | --------------- | --- | ----- |

|                    |         |     | A     |       |     | A     |         | C V |     |
| ------------------ | ------- | --- | ----- | ----- | --- | ----- | ------- | --- | --- |
|                    |         |     |       |       |     |       | d      | d   |    |
|                    |         |     |       |       |     |    |   |     |  |
| 1 = Normal text    | (  u A |  ) | − (  | u A  | )   | =  A | −       |  A |     |
| 2 = Paragraph text |         |     | e     |       | w   |       |         |     |     |
|                    |         |     |       |       |     |       | d x     | d   | x   |
3 = • text
|     |     |     |     |     |     |     | e   |     | w   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
4 =    • text
• Continuity equation (mass balance):
5 =       • text
d(u)
= 0
dx
|     | (uA) |     | −(uA) |     |     | = 0 |     |     |     |
| --- | ----- | --- | ------ | --- | --- | --- | --- | --- | --- |
|     |       |     | e      |     | w   |     |     |     |     |
7 Introduction to CFD (4RC30)

Definition of F, D and Pe
|     |     |     |     |     | F =  | u   |
| --- | --- | --- | --- | --- | ----- | --- |
• We define the convective mass flux per unit area F:
Text format by
Increase / decrease list level

| Place cursor in text | the diffusion conductance D: |     |     |     | D = |     |
| -------------------- | ---------------------------- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
|     |     |     |     |     |    | x   |
| --- | --- | --- | --- | --- | --- | --- |
group Paragraph)
 u
|     |     | the Peclet | number Pe: |     | P e = | F / D = |
| --- | --- | ---------- | ---------- | --- | ----- | ------- |
 /  x
•
At the cell faces e and w:
1 = Normal text
2 = Paragraph text
3 = • text
|     | F = | (u) | F = (u) |     |     |     |
| --- | --- | ---- | -------- | --- | --- | --- |
4 =    • text
|     | w   | w   | e   | e   |     |     |
| --- | --- | --- | --- | --- | --- | --- |
5 =       • text
|     |     |    |     |    |     |     |
| --- | --- | --- | --- | --- | --- | --- |
|     | D   | = w | D = | e   |     |     |
|     | w   |     | e   |     |     |     |
|     |     |  x |    | x   |     |     |
|     |     | W P |     | P E |     |     |
8 Introduction to CFD (4RC30)

Steady 1D convection-diffusion
• Integrated convection-diffusion equation:
Text format by
Increase / decrease list level
|                      |     |     |     |     |     |  d  |  |   | −    | d   |   −  |  |
| -------------------- | --- | --- | --- | --- | --- | ------- | --- | ----- | ----------- | ------- | --------- | --- |
| Place cursor in text |     |     |     |     |     |  A     | =  | A E   | P          | A =    | A P       | W   |
|                      |     |     | d  |     | d  |         |     |       |             |         |           |     |
and use these 2 buttons (tab Start -     d x e e  x d x w w  x
group Paragraph) (  u A  ) − (  u A  ) =  A −  A e P E w W P
|     |     | e   | w   |       |       |            |       |       |       |     |     |     |
| --- | --- | --- | --- | ----- | ----- | ---------- | ----- | ----- | ----- | --- | --- | --- |
|     |     |     | d x |       | d x   |            |       |       |       |     |     |     |
|     |     |     |     |       |       | Assuming 𝐴 |       | = 𝐴   | = 𝐴   |     |     |     |
|     |     |     |     | e     | w     |            |       | 𝑒 𝑤   |       |     |     |     |
|     |     |     |     | F  − | F  = | D (  −    |  ) − | D (  | −  ) |     |     |     |
|     |     |     |     | e e   | w w   | e E        | P     | w     | P W   |     |     |     |
1 = Normal text
2 = Paragraph text
• Integrated continuity equation:
3 = • text
4 =    • text
5 =       • text
|     | (  u                                   | A ) − (  u | A ) = 0 | F − F | = 0   |            |          |     |     |     |     |     |
| --- | --------------------------------------- | ----------- | ------- | ----- | ----- | ---------- | -------- | --- | --- | --- | --- | --- |
|     |                                         |             |         |       |       | Assuming 𝑢 | is known |     |     |     |     |     |
|     |                                         | e           | w       | e     | w     |            |          |     |     |     |     |     |
|     | • We need a discretization scheme for 𝜙 |             |         |       | and 𝜙 |            |          |     |     |     |     |     |
|     |                                         |             |         |       | 𝑒     | 𝑤          |          |     |     |     |     |     |
(Interpolation of transport property to cell face)
9 Introduction to CFD (4RC30)

Central differencing scheme
• Substitute in transport equation:
Text format by
Increase / decrease list level
Place cursor in text
|     |  = (  | +   |    | ) / 2 |    | =   | (  + |    | ) / 2 |     |     |     |
| --- | ------- | --- | --- | ----- | --- | --- | ----- | --- | ----- | --- | --- | --- |
and use these 2 buttons (tab Start -
|     | e   | P   | E   |     |     | w   | W   | P   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
group Paragraph)
• Rearrangement leads to CDS:
|     | F   |     |     | F   |     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
1 = Normal text F e  (  − + F   ) − = D w ( (   − +   ) ) − = D D ( (   − −   ) ) − D (  −  )
| 2 = Paragraph text | e e P | w   | E w | e W E | P P |     | w e P E |     | W P | w P | W   |     |
| ------------------ | ----- | --- | --- | ----- | --- | --- | ------- | --- | --- | --- | --- | --- |
|                    | 2     |     |     | 2     |     |     |         |     |     |     |     |     |
3 = • text
4 =    • text
| 5 =       • text |     |     |     |       |     | a   |     |     | a   |     | a   |           |
| ---------------- | --- | --- | --- | ----- | --- | --- | --- | --- | --- | --- | --- | --------- |
|                  |     |     |     |       |     |     | W   |     | E   |     | P   |           |
|                  | a  | = a |    | + a  |     |     |     |     |     |     |     |           |
|                  | P P |     | W W | E E   |     |     |     |     |     |     |     |           |
|                  |     |     |     |       |     |     | F   |     | F   |     |     |           |
|                  |     |     |     |       | D   | +   | w   | D   | − e | a + | a + | ( F − F ) |
|                  |     |     |     |       |     | w   |     | e   |     | W   | E   | e w       |
|                  |     |     |     |       |     |     | 2   |     | 2   |     |     |           |
Solved for all grid nodes to obtain the distribution of 𝜙
10 Introduction to CFD (4RC30)

1D convection-diffusion of 𝜙
u
Text format by
|     | A   |     |     |     | B   |
| --- | --- | --- | --- | --- | --- |
Increase / decrease list level
| Place cursor in text                 |  = 1 |      |         |     |  = 0 |
| ------------------------------------ | ----- | ---- | ------- | --- | ----- |
| and use these 2 buttons (tab Start - | A     |      |         |     | B     |
| group Paragraph)                     |       | Xmax | = 0.5 m |     |       |
x
1 = Normal text
2 = Paragraph text
| 3 = • text |     | u   |     | u   |     |
| ---------- | --- | --- | --- | --- | --- |
4 =    • text
5 =       • text
|     | W     w |     | P   | e      E |     |
| --- | ------- | --- | --- | -------- | --- |
x_u
11 Introduction to CFD (4RC30)

Numerical Solution
Text format by
Increase / decrease list level
%% CONSTANTS /* define all the constants */
Place cursor in text
%% INIT /* initialize variables */
and use these 2 buttons (tab Start -
group Paragraph)
%% BOUNDARY /* apply boundary conditions */
%% phi-EQUATION /* calculate coefficients aE, aW, aP, b */
%% SOLVE /* solver iteration loop */
for iter= 0:OUTER_ITER
1 = Normal text
2 = Paragraph text … /* solve1D(T, b, aE, aW, aP)*/
3 = • text
4 = • text fprintf(…); /* write convergence to screen */
5 = • text
end
%% OUTPUT /* write output to file */
12 Introduction to CFD (4RC30)

Calculation of coefficients a , a , b
nb P
for I = Istart:Iend
Text format by
Increase / decrease list level i = I;
Place cursor in text Fw = 0.5*(rho(I-1) + rho(I))*u(i); /* convective flux */
and use these 2 buttons (tab Start -
group Paragraph) Fe = 0.5*(rho(I+1) + rho(I))*u(i+1); /* convective flux */
Dw= 0.5*(Gamma(I-1) + Gamma(I))/(x(I) -x(I-1)); /* diffusion */
De = 0.5*(Gamma(I+1) + Gamma(I))/(x(I+1) -x(I)); /* diffusion */
SP(I) = 0.; /* coefficient of the linearisedsource term */
1 = Normal text
Su(I) = 0.; /* constant part of the source term */
2 = Paragraph text
3 = • text
4 = • text
5 = • text aW(I) = Dw+ 0.5*Fw; /* coefficient for TW using CDS */
aE(I) = De -0.5*Fe; /* coefficient for TE using CDS */
aP(I) = aW(I) + aE(I) + Fe -Fw-SP(I); /* coefficient for TP */
b(I) = Su(I); /* constant term in the discretisation equation */
end
13 Introduction to CFD (4RC30)
D
w
a
W
+
F
2
w D
e
a
−
E
F
2
e a
W
+ a
E
a
+
P
( F
e
− F
w
)

Example 1: low speed, CDS
u
|     | A   |     |     | B   |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Text format by
| Increase / decrease list level |       |     |     |     |     | u = 0.1 m/s, NPI |     | = 5 |     |
| ------------------------------ | ----- | --- | --- | --- | --- | ---------------- | --- | --- | --- |
|                                |  = 1 |     |     |    | = 0 |                  |     |     |     |
| Place cursor in text           | A     |     |     |     | B   |                  |     |     |     |
and use these 2 buttons (tab Start -
|     |     | Xmax | = 1.0 m |     |     |     | F = u | = 0.1 |     |
| --- | --- | ---- | ------- | --- | --- | --- | ------ | ----- | --- |
group Paragraph)
|     |     |     |      |     |     |     | D = /x | = 0.1/0.2   | = 0.5 |
| --- | --- | --- | ---- | --- | --- | --- | -------- | ----------- | ----- |
|     | 1.0 |     | 0.12 |     |     |     |          |             |       |
|     |     |     |      |     |     |     | Pe =     | F / D = 0.2 |       |
|     | 0.8 |     | 0.08 | ]   |     |     |          |             |       |
%
1 = Normal text
|                    |     |     |      | [   | Fi theor. |     |     |     |     |
| ------------------ | --- | --- | ---- | --- | --------- | --- | --- | --- | --- |
| 2 = Paragraph text | 0.6 |     | 0.04 | e   |           |     |     |     |     |
]
| 3   =   •   t e x t            | -     |     |      | c   |              |                        |     |     |     |
| ------------------------------ | ----- | --- | ---- | --- | ------------ | ---------------------- | --- | --- | --- |
|                                | [     |     |      | n   | F i   n u m. |                        |     |     |     |
| 4   =         •   t e x t      |   i   |     |      |     |              |                        |     |     |     |
|                                | F 0.4 |     | 0.00 | e   |              | Good predictions with  |     |     |     |
| 5   =               •   t e xt |       |     |      | r   |              |                        |     |     |     |
|                                |       |     |      | e   | D i f f  %   |                        |     |     |     |
f
f
|     | 0.2 |     | -0.04 | i D |     | only 5 grid points! |     |     |     |
| --- | --- | --- | ----- | --- | --- | ------------------- | --- | --- | --- |
|     | 0.0 |     | -0.08 |     |     |                     |     |     |     |
|     | 0.0 | 0.5 | 1.0   |     |     |                     |     |     |     |
x [m]
14 Introduction to CFD (4RC30)

Example 2: high speed, CDS
u
|     | A   |     |     | B   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
Text format by
Increase / decrease list level u = 2 . 5   m / s ,   N P I = 5
|                      |  = 1 |     |     |  = 0 |     |     |     |     |
| -------------------- | ----- | --- | --- | ----- | --- | --- | --- | --- |
| Place cursor in text | A     |     |     | B     |     |     |     |     |
and use these 2 buttons (tab Start -
|     |     | Xmax | = 1.0 m |     | F =  | u = 2 . | 5   |     |
| --- | --- | ---- | ------- | --- | ----- | ------- | --- | --- |
group Paragraph)
|     |     |     |     |     | D =  | /  x = | 0 . 1 / 0 | . 2 = 0 . 5 |
| --- | --- | --- | --- | --- | ----- | ------- | --------- | ----------- |
|     |     |     |     |     | P e = | F / D = | 5 . 0     |             |
1 = Normal text
2 = Paragraph text
3 = • text
4 =    • text
Reasonable predictions.
5 =       • text
CDS gives overshoots!
15 Introduction to CFD (4RC30)

Properties of discretization schemes
1. Conservative
Text format by
Increase / decrease list level
Place cursor in text 2. Boundedness
and use these 2 buttons (tab Start -
group Paragraph)
3. Transportiveness
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
16 Introduction to CFD (4RC30)

Properties discretization schemes
1. Conservative:
Text format by
Increase / decrease list level
Consistent treatment of fluxes through nodal faces
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
|     |         | d   |        | d  |     | (  − |  ) |
| --- | ------- | --- | ------- | --- | --- | ----- | --- |
|     |         |  |   |     |  |       |     |
|     | f l u x | =  | =       |    | =   |  3   | 2   |
(Same expression!)
|     |     | d   | x   | d x |     |    | x   |
| --- | --- | --- | --- | --- | --- | --- | --- |
|     |     |     | e   |     | w   |     |     |
1 = Normal text
2 = Paragraph text

| 3 = • text |     |     |    |     |     |     | 4   |
| ---------- | --- | --- | --- | --- | --- | --- | --- |

| 4 =    • text |     |     | 2   |     |     |     |     |
| ------------- | --- | --- | --- | --- | --- | --- | --- |
|               |    |     |     |     | 3   |     |     |
5 =       • text
1
|     | 1   |     | 2   |     | 3   |     | 4   |
| --- | --- | --- | --- | --- | --- | --- | --- |
17 Introduction to CFD (4RC30)

Properties discretization schemes
2. Boundedness:
Text format by
Increase / decrease list level
• property  is bounded by values of at the boundaries, i.e. no overshoots or
Place cursor in text P
and use these 2 buttons (tab Start -
undershoots:
group Paragraph)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
• we need to satisfy:
18
|

n
a
S
a
b
P
P
P
| a
−

, a
n b
S
0
n b
P
|

|

0


1
1
a
a
t
t
a
o
l
n
l
e
n o
n
d
o
e
d
s
e a t l e a s t
Introduction to CFD (4RC30)

Properties discretization schemes
3. Transportiveness:
Text format by
 u
Increase / decrease list level
|     | • Direction of influence = f(Pe) |     | P e = | F / D = |
| --- | -------------------------------- | --- | ----- | ------- |
Place cursor in text
and use these 2 buttons (tab Start -  /  x
| group Paragraph) | • No convection and pure diffusion (Pe | = 0) |     |     |
| ---------------- | -------------------------------------- | ---- | --- | --- |
|                  | • No diffusion and pure convection (Pe | → ∞) |     |     |
Flow direction
1 = Normal text
| 2 = Paragraph text | Pe = 0 |     |     |     |
| ------------------ | ------ | --- | --- | --- |
| 3 = • text         |        | P e |  2 |     |
4 =    • text
Pe →
5 =       • text
W                   P E
Area of influence of variable  as function of Pe
P
19 Introduction to CFD (4RC30)

Assessment CDS
• Conservativeness satisfied
Text format by
Increase / decrease list level
• Boundedness not always satisfied
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph) F
|     | a = D | − e | = 0 . 5 | − 1 . 2 5  0 | !   |
| --- | ----- | --- | ------- | ------------- | --- |
• Example 2:
|     | E   | e   |     |     |     |
| --- | --- | --- | --- | --- | --- |
2
| • CDS only satisfactory if |     | a   |  0  | F / D = | P e  2 |
| -------------------------- | --- | --- | ----- | ------- | ------- |
|                            |     | E   |       | e e     | e       |
1 = Normal text
2 = Paragraph text
3 = • text
| • Transportiveness | not always satisfied |     |     |     |     |
| ------------------ | -------------------- | --- | --- | --- | --- |
4 =    • text
5 =       • text
| • Example 1: Pe | = 0.2 → CDS works well       |     |     |     |     |
| --------------- | ---------------------------- | --- | --- | --- | --- |
| • Example 2: Pe | = 5.0 → CDS gives overshoots |     |     |     |     |
• CDS scheme does not recognize flow direction!
20 Introduction to CFD (4RC30)

Upwind differencing scheme
UDS resembles CISTRs (Continuous Ideally Stirred-Tank Reactor) in series
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
“upwind” “downwind”
1 = Normal text
| W   | P   | E   |     |     |     |
| --- | --- | --- | --- | --- | --- |
2 = Paragraph text
3 = • text
 
4 =    • text 
W w
5 =       • text E
 
P e
|            |                           |     | u  | 0   | =  |
| ---------- | ------------------------- | --- | --- | ----- | --- |
|            |                           |     | w   | w     | W   |
| u          | u                         |     |     |       |     |
| w          | e                         |     |     |       |     |
|            |                           |     | u  | 0   | =  |
|            |                           |     | e   | e     | P   |
| W        w | P          e            E |     |     |       |     |
21 Introduction to CFD (4RC30)

Upwind differencing scheme
UDS resembles CISTRs in series
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
“downwind” “upwind”
1 = Normal text
| W   | P   | E   |     |     |     |
| --- | --- | --- | --- | --- | --- |
2 = Paragraph text
3 = • text
 
4 =    • text 
e E
5 =       • text W
 
w P
|     |     |     | u  | 0   | =  |
| --- | --- | --- | --- | ----- | --- |
|     |     |     | w   | w     | P   |
| u   | u   |     |     |       |     |
w e
|            |                         |     | u  | 0   | =  |
| ---------- | ----------------------- | --- | --- | ----- | --- |
|            |                         |     | e   | e     | E   |
| W        w | P          e            | E   |     |       |     |
22 Introduction to CFD (4RC30)

Upwind differencing scheme
• Integrated convection-diffusion equation:
Text format by
Increase / decrease list level
|     |     |     |     |     |    | d |    | d |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Place cursor in text
|                                      |                | (uA) | −(uA) |                        | = A |      | −     | A  |     |     |     |
| ------------------------------------ | -------------- | ------ | ------- | ---------------------- | ---- | ---- | ----- | --- | --- | --- | --- |
| and use these 2 buttons (tab Start - |                |        |         |                        |     |      |     |     |    |     |     |
|                                      |                |        | e       | w                      |      |      |       |     |     |     |     |
| group Paragraph)                     |                |        |         |                        |      | dx   |       | dx  |     |     |     |
|                                      |                |        |         |                        |     |      |     |     |    |     |     |
|                                      |                |        |         |                        |      |      | e     |     | w   |     |     |
|                                      |                | F −   | F  =   | D (                   | −   | )− D | ( − | )   |     |     |     |
|                                      |                | e e    | w w     | e E                    | P    |      | w P   | W   |     |     |     |
|                                      | • Substitute 𝜙 |        | and 𝜙   | in transport equation: |      |      |       |     |     |     |     |
1 = Normal text
|     |     |     | 𝑒   | 𝑤   |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
2 = Paragraph text
3 = • text
|     |     | u  0,u |  0 |    | F   |  0,F |    | 0  |     |  = | , = |
| --- | --- | ------- | --- | --- | --- | ----- | --- | --- | --- | ---- | ----- |
4 =    • text
|     |     | w   | e   |     |     | w   | e   |     |     | w   | W e P |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ----- |
5 =       • text
|     |     |         | F − | F  | = D | (    | − )− | D ( | −  | )    |       |
| --- | --- | ------- | ---- | --- | --- | ----- | ----- | ---- | --- | ---- | ----- |
|     |     |         | e P  | w W |     | e E   | P     | w    | P   | W    |       |
|     |     | u  0,u |  0  |    | F   |  0,F |      | 0   |     |  = | , = |
|     |     | w       | e    |     |     | w     | e     |      |     | w    | P e E |
|     |     |         | F − | F  | = D | ( − | )−    | D ( | −  | )    |       |
|     |     |         | e E  | w P | e   | E     | P     | w    | P   | W    |       |
23 Introduction to CFD (4RC30)

Upwind differencing scheme
• Rewrite convection-diffusion equation in general form:
Text format by
Increase / decrease list level
Place cursor in text
|     |     | a  | = a |  + a  | + S |     |     |     |     |     |
| --- | --- | --- | --- | ------- | --- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
|     |     | P P | W   | W E | E   | u   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
group Paragraph)
|     | • Coefficients for all 𝑢 |     |     | (𝑢  | < 0 | and 𝑢 | > 0): |     |     |     |
| --- | ------------------------ | --- | --- | --- | --- | ----- | ----- | --- | --- | --- |
|     |                          |     | a   |     |     | a     |       |     | a   |     |
1 = Normal text
| 2 = Paragraph text |     |     | W   |     |     | E   |     |     | P   |     |
| ------------------ | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
3 = • text
D + m a x ( F , 0 ) D + m a x ( − F , 0 ) a + a + ( F − F ) − S
4 =    • text
|     |     | w   |     | w   | e   |     | e   | W E | e w | P   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
5 =       • text
24 Introduction to CFD (4RC30)

Calculation of coefficients a , a , b
nb P
for I = Istart:Iend
Text format by i = I;
Increase / decrease list level
Fw = 0.5*(rho(I-1) + rho(I))*u(i); /* convective flux */
Place cursor in text Fe = 0.5*(rho(I+1) + rho(I))*u(i+1); /* convective flux */
and use these 2 buttons (tab Start -
group Paragraph) Dw = 0.5*(Gamma(I-1) + Gamma(I))/(x(I) -x(I-1)); /* diffusion */
De = 0.5*(Gamma(I+1) + Gamma(I))/(x(I+1) -x(I)); /* diffusion */
SP(I) = 0.; /* coefficient of the linearised source term */
Su(I) = 0.; /* constant part of the source term */
1 = Normal text
2 = Paragraph text
aW(I) = Dw + max( Fw, 0.);/* coefficient for TW using UDS */
3 = • text
4 = • text aE(I) = De + max(-Fe, 0.); /* coefficient for TE using UDS */
5 = • text
aP(I) = aW(I) + aE(I) + Fe -Fw-SP(I); /* coefficient for TP */
b(I) = Su(I); /* constant term in the discretisation equation */
end
25 Introduction to CFD (4RC30)
D
w
+ m
a
W
a x ( F
w
, 0 ) D
e
+ m
a
a
E
x ( − F
e
, 0 ) a
W
+ a
E
+ (
a
F
P
e
− F
w
) − S
P

Example 1: low speed, UDS
u
|     | A   |     |     | B   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
Text format by
| Increase / decrease list level |       |     |     |       | u = 0.1 m/s, NPI |     | = 5 |     |
| ------------------------------ | ----- | --- | --- | ----- | ---------------- | --- | --- | --- |
|                                |  = 1 |     |     |  = 0 |                  |     |     |     |
| Place cursor in text           | A     |     |     | B     |                  |     |     |     |
and use these 2 buttons (tab Start -
|     |     | Xmax | = 1.0 m |     |     | F = u | = 0.1 |     |
| --- | --- | ---- | ------- | --- | --- | ------ | ----- | --- |
group Paragraph)
|     |     |     |     |     |     | D = /x | = 0.1/0.2   | = 0.5 |
| --- | --- | --- | --- | --- | --- | -------- | ----------- | ----- |
|     |     |     |     |     |     | Pe =     | F / D = 0.2 |       |
1 = Normal text
2 = Paragraph text
3 = • text
4 =    • text
Good predictions with
5 =       • text
only 5 grid points!
26 Introduction to CFD (4RC30)

Example 2: high speed, UDS
u
|     | A   |     |     | B   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
Text format by
Increase / decrease list level u = 2 . 5   m / s ,   N P I = 5
|                      |  = 1 |     |     |  = 0 |     |     |     |     |
| -------------------- | ----- | --- | --- | ----- | --- | --- | --- | --- |
| Place cursor in text | A     |     |     | B     |     |     |     |     |
and use these 2 buttons (tab Start -
|     |     | Xmax | = 1.0 m |     | F =  | u = 2 . | 5   |     |
| --- | --- | ---- | ------- | --- | ----- | ------- | --- | --- |
group Paragraph)
|     |     |     |     |     | D =  | /  x = | 0 . 1 / 0 | . 2 = 0 . 5 |
| --- | --- | --- | --- | --- | ----- | ------- | --------- | ----------- |
|     |     |     |     |     | P e = | F / D = | 5 . 0     |             |
1 = Normal text
2 = Paragraph text
3 = • text
4 =    • text
Good predictions.
5 =       • text
UDS gives no overshoots.
27 Introduction to CFD (4RC30)

Assessment Upwind scheme
• Conservativeness satisfied
Text format by
Increase / decrease list level
Place cursor in text
| and use these 2 buttons (tab Start - | • Boundedness satisfied |     |
| ------------------------------------ | ----------------------- | --- |
group Paragraph)
|     | • All coefficients a | > 0 |
| --- | -------------------- | --- |
nb
• No restrictions on Pe
| 1 = Normal text | • Transportiveness | satisfied |
| --------------- | ------------------ | --------- |
2 = Paragraph text
3 = • text
| 4 =    • text | • UDS scheme accounts for flow direction |     |
| ------------- | ---------------------------------------- | --- |
5 =       • text
28 Introduction to CFD (4RC30)

Example 2D pure convection
100
Text format by
Increase / decrease list level
100
Place cursor in text F = u =1
and use these 2 buttons (tab Start -
group Paragraph)
100  = 0  D =  /x = 0
T(x, y) ?
Pe = F / D → 
100
1 = Normal text 100
2 = Paragraph text
3 = • text
4 = • text
5 = • text
0 0 0 0 0
y

x
29 Introduction to CFD (4RC30)

Example 2D pure convection
100
Text format by
Increase / decrease list level
100
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
100
100
1 = Normal text 100
2 = Paragraph text
3 = • text
4 = • text
5 = • text
0 0 0 0 0
y

x
30
F
P e
0
F
u
/
D
D
1
/ x 0

 
=
=
=

=
=
→


=
100
50
0
Introduction to CFD (4RC30)

Example 2D pure convection
100
Text format by
Increase / decrease list level
100
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
100
100
1 = Normal text 100 2 = Paragraph text
3 = • text
4 = • text
5 = • text
0 0 0 0 0
y

x
31
F
P e
0
F
u
/
D
D
1
/ x 0

 
=
=
=

=
=
→


=
97 89 77 64 50
94 81 66 50 36
88 69 50 34 23
75 50 31 19 11
50 25 13 6 3 “false diffusion” error
Introduction to CFD (4RC30)

Accuracy Upwind scheme
• UDS ≡ 1D interpolation
Text format by
Increase / decrease list level
Place cursor in text • In 2D or 3D when the flow is not aligned with the grid lines, UDS gives “false
and use these 2 buttons (tab Start -
group Paragraph) diffusion”
Spatial discretization error:
• False diffusion only occurs at high Pe e.g., 𝜕𝜙 = 𝜙 𝐸 −𝜙 𝑃 − 𝜕2𝜙 ∆𝑥 − ⋯
𝜕𝑥 𝑃 ∆𝑥 𝜕𝑥2 𝑃 2
• Minimize false diffusion by: Spatial convergence, grid (in)dependence,
1 = Normal text grid convergence, grid refinement
2 = Paragraph text
• Aligning grid with flow direction
3 = • text
4 = • text
Practice in tutorial
5 = • text • Using fine grids
• Using more accurate differencing schemes
32 Introduction to CFD (4RC30)

Hybrid differencing scheme
Hybrid scheme combines both schemes:
Text format by
Increase / decrease list level
Place cursor in text • CDS is O(2) accurate for Pe < 2
and use these 2 buttons (tab Start -
group Paragraph)
• UDS is O(1) accurate and accounts for flow direction for Pe ≥ 2
Flow direction
1 = Normal text
2 = Paragraph text Pe = 0
3 = • text
4 = • text
Pe →
5 = • text
W P E
33
P e  2
Area of influence of variable  as function of Pe
P
Introduction to CFD (4RC30)

Hybrid differencing scheme
• If Pe < 2, use CDS
Text format by
Increase / decrease list level
• If Pe ≥ 2, use UDS without diffusion
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
|                 |       |     | a     |     |     |     | a   |     |
| --------------- | ----- | --- | ----- | --- | --- | --- | --- | --- |
|                 |       |     | W     |     |     |     |     | E   |
|                 | C D S |     | D + F | / 2 |     | D   | − F | / 2 |
| 1 = Normal text |       |     | w     | w   |     |     | e   | e   |
2 = Paragraph text
|     | U D S | D   | + m a x | ( F , 0 ) | D   | +   | m a x | ( − F , 0 ) |
| --- | ----- | --- | ------- | --------- | --- | --- | ----- | ----------- |
3 = • text
|     |     | w   |     | w   |     | e   |     | e   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
4 =    • text
5 =       • text
H y b r i d m a x ( F , ( D + F / 2 ) , 0 ) m a x ( − F , ( D − F / 2 ) , 0 )
|     |     |     | w w | w   |     | e   |     | e e |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
34 Introduction to CFD (4RC30)

Assessment Hybrid scheme
• Hybrid scheme combines CDS and UDS
Text format by
Increase / decrease list level
• Conservativeness satisfied
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph) • Boundedness satisfied
✓ All coefficients a > 0
nb
✓ No restrictions on Pe
• Transportiveness satisfied
1 = Normal text
2 = Paragraph text
✓ Scheme accounts for flow direction
3 = • text
4 = • text
5 = • text
• Advantages: robust and reliable
• Disadvantage: only O(1) accuracy
35 Introduction to CFD (4RC30)

Other schemes
• QUICK O(3), higher order Upwind O(2)
Text format by
Increase / decrease list level
|                      | • Uses extra grid points 𝜙 | , 𝜙  | , 𝜙 , 𝜙 | , 𝜙 |
| -------------------- | -------------------------- | ---- | ------- | --- |
| Place cursor in text |                            | 𝑊𝑊 𝑊 | 𝑃 𝐸     | 𝐸𝐸  |
and use these 2 buttons (tab Start -
• Higher accuracy at fine grids
group Paragraph)
• Boundedness not always guaranteed: overshoots
• Total variation diminishing (TVD) scheme
1 = Normal text
2 = Paragraph text • Van Leer, Superbee, Min-Mod, MUSCL, etc.
3 = • text
| 4 =    • text | • O(2) accuracy, boundedness satisfied |     |     |     |
| ------------- | -------------------------------------- | --- | --- | --- |
5 =       • text
|     | • See also book Versteeg | and Malasekera |     |     |
| --- | ------------------------ | -------------- | --- | --- |
36 Introduction to CFD (4RC30)

Wrap up
| • convection |     | = diffusion |     | + (source – | sink) |     |     |
| ------------ | --- | ----------- | --- | ----------- | ----- | --- | --- |
Text format by
Increase / decrease list level
Place cursor in text
|     | d i v (  | u ) = | d i v (  | g r a d  ) + | S   |     |     |
| --- | ---------- | ----- | --------- | ------------- | --- | --- | --- |
and use these 2 buttons (tab Start -

group Paragraph)
•
| Differencing schemes needed for 𝜙 |     |     |     |     | and 𝜙 |     |     |
| --------------------------------- | --- | --- | --- | --- | ----- | --- | --- |
|                                   |     |     |     |     | 𝑒     | 𝑤   |     |
1 = Normal text • General purpose schemes: UDS and Hybrid
2 = Paragraph text
3 = • text Disadvantage: false or numerical diffusion in multi-dimensional flows
4 =    • text
5 =       • text
• General form of discretized equations:
|     |     |    |         |     |    |     |         |
| --- | --- | --- | ------- | --- | --- | --- | ------- |
|     | a  | = a |  +     | S   | a = | a + |  F − S |
|     | P P |     | n b n b | u   | P   | n b | P       |
37 Introduction to CFD (4RC30)