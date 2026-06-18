Stefan
|               | Sotoudeh   | Roya  |             | Kaustubh    |         |                 |
| ------------- | ---------- | ----- | ----------- | ----------- | ------- | --------------- |
|               |            |       | Koen Mulder |             | Andi Li | Nicola Vanzetto |
| van Laarhoven | Heidarpour |       |             | Thakurdesai |         |                 |
Jamshidian
Introduction to CFD (4RC30)
Planning
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
|     |     |     | Niels Deen |     | Yali Tang |     |
| --- | --- | --- | ---------- | --- | --------- | --- |
Dr. Yali Tang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

“Boundary conditions”
• Needed knowledge: Introduction transport phenomena / Heat and flow
• 8 lectures & 7 practice sessions with CFD code
• Examination:
• CFD assignment (in groups of 2 or 3) → paper
Deadline: Sunday 21 June 2026
• Oral exam about paper and theory
• Book:
An Introduction to Computational Fluid Dynamics:
The Finite Volume Method (2nd edition),
H.K. Versteeg, W. Malalasekera
Image credit: bol.com
2 Introduction to CFD (4RC30)

Timetable
| • Mon | 20-04-2026, 1-4  | lecture 1 (ND)                         | + tutorial1 |
| ----- | ---------------- | -------------------------------------- | ----------- |
| • Thu | 23-04-2026, 5-8  | lecture 2 (YT)                         | + tutorial2 |
| • Mon | 27-04-2026       | NO lecture (King’s day)                |             |
| • Thu | 30-04-2026, 5-8  | lecture 3 (ND)                         | + tutorial3 |
| • Mon | 04-05-2026       | NO lecture (bridge day -> TU/e closed) |             |
| • Thu | 07-05-2026, 5-8  | lecture 4 (YT)                         | + tutorial4 |
• Mon 11-05-2026, 1-4  lecture 5 (ND) + instruction on final assignment
| • Thu | 14-05-2026       | NO lecture (Ascension day)  |             |
| ----- | ---------------- | --------------------------- | ----------- |
| • Mon | 18-05-2026, 1-4  | lecture 6 (ND)              | + tutorial5 |
• Thu 21-05-2026, 5-8  lecture 7 (YT) + tutorial6 (start of final assignment)
| • Mon | 25-05-2026       | NO lecture (Whit Monday) |               |
| ----- | ---------------- | ------------------------ | ------------- |
| • Thu | 28-05-2026, 5-8  | lecture 8 (YT)           | + no tutorial |
ND = Niels Deen
| • Sun | 21-06-2026  | DEADLINE PAPER on final assignment |     |
| ----- | ----------- | ---------------------------------- | --- |
YT = Yali Tang
3 Introduction to CFD (4RC30)

Course planning
• Lecture 1a: conservation equations (Chapter 2)
• Mass conservation
• Momentum conservation
• Internal conservation
• General variable conservation
• Lecture 1b: diffusion problems (Chapter 4)
• Discretization diffusion equation
• Worked example: heat conduction
• Basics of programming in Matlab
• Lecture 2: convection-diffusion problems (Chapter 5)
• Discretization convection-diffusion equation
• Discretization schemes and their properties
4 Introduction to CFD (4RC30)

Course planning continued
• Lecture 3: solving PDE’s (Chapters 6+7)
• SIMPLE algorithm (SIMPLER, PISO: stud.)
• TDMA
• Lecture 4: unsteady flow problems (Chapter 8)
• Implicit/explicit schemes
• Discretization
• Lecture 5: turbulence (Chapter 3)
• Qualitative description of turbulence
• Boundary layer flows
• k-epsilon model
5 Introduction to CFD (4RC30)

Course planning continued
• Lecture 6: chemical reactions (Chapter 10)
• Simple chemical reacting system
• Eddy break-up model
• Lecture 7: boundary conditions (Chapter 9)
• Law of the wall, etc.
• Lecture 8: outlook
• Advanced modelling of multiphase flows
6 Introduction to CFD (4RC30)

Introduction to CFD (4RC30)
Conservation laws
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. Yali Tang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

Outline
• What is CFD? Why use CFD?
• Conventions on notation
• Conservation laws
• 1D steady diffusion problems + example
8 Introduction to CFD (4RC30)

What is CFD?
Inflow
Inflow Inflow
Black Box
Input is
converted
into output
Control
Control Outflow
Outflow
Outflow
Volumes
Volume
zero-dimensional multi-dimensional
Image credit:
9 Introduction to CFD (4RC30)
https://doi.org/10.3390/pr8111511

Image credit: https://doi.org/10.3390/pr13061876
https://dx.doi.org/10.1080/09715010.2020.1830000
https://help.sim-flow.com/tutorials/heat-exchanger
Why use CFD?
• To understand non-uniformities in flow, temperatures and/or concentrations
• Dead zones
• Mixing performance
• Performance heat transfer (cooling pipes, heat exchangers)
10 Introduction to CFD (4RC30)

What do we need?
Inflow
• A description of primary processes at micro level:
microbalances or conservation equations
• Boundary conditions
• Physical and chemical properties of the fluids in the system
• Good numerical tools
Control
Outflow
Volumes
11 Introduction to CFD (4RC30)

Conventions on notation
• Most theory explained in 1D or 2D (see book* for 3D)
• Symbols:
| • u, v, w | velocity components       |                 |
| --------- | ------------------------- | --------------- |
| • T       | temperature               |                 |
| • Y       | mass fraction component j | (see lecture 7) |
j
| • ξ | mixture fraction | (see lecture 7) |
| --- | ---------------- | --------------- |
• Computer programs written in Matlab,
v
with references to notation and equations to:
An Introduction to Computational Fluid Dynamics:  u
The Finite Volume Method, H.K. Versteeg, W. Malalasekera
Control volume
Image credit:
12 Introduction to CFD (4RC30)
https://web1.eng.famu.fsu.edu/~shih/succeed/cylinder/cylinder.htm

Control volume notation
Six faces: n, s, e, w, t, b
δx
δx n
t
w e δy
δy
δz
(x, y)
y
z
x
y b
s
x
13 Introduction to CFD (4RC30)

Conservation of mass
• Accumulation of mass
| ∂   |     | ∂ρ  |     |     |     |
| --- | --- | --- | --- | --- | --- |
ρv δxδz
| (ρδxδyδz) |     | = δxδyδz |     | n   |     |
| --------- | --- | -------- | --- | --- | --- |
| ∂t        |     | ∂t       |     | n   |     |
• Net mass inflow
| (ρu | −ρu | )δyδz + |         |     |         |
| --- | --- | ------- | ------- | --- | ------- |
|     | e   | w       | ρu δyδz |     | ρu δyδz |
|     |     |         | w       |     | e       |
w e
| (ρv | −ρv | )δxδz |     |     |     |
| --- | --- | ----- | --- | --- | --- |
(x, y)
|     | n   | s   |     |     |     |
| --- | --- | --- | --- | --- | --- |
y
| • Divide by control volume ( |     | )   |     |     |     |
| ---------------------------- | --- | --- | --- | --- | --- |
x s
∂ρu ∂ρv
ρvδxδz
= + 𝛿𝛿𝛿𝛿 𝛿𝛿𝛿𝛿 𝛿𝛿𝛿𝛿
| Net mass inflow |     |     |     | s   |     |
| --------------- | --- | --- | --- | --- | --- |
∂x ∂y
14 Introduction to CFD (4RC30)

Conservation of mass
• Microbalance for mass, 2D:
| ∂ρ ∂(ρu) | ∂(ρv) |     |     |
| -------- | ----- | --- | --- |
| +        | +     | =   |     |
0
| ∂t ∂x | ∂y  |     |     |
| ----- | --- | --- | --- |
• Microbalance for mass, 3D:
| ∂ρ ∂(ρu) | ∂(ρv) | ∂(ρw) |     |
| -------- | ----- | ----- | --- |
| +        | +     | +     | = 0 |
| ∂t ∂x    | ∂y    | ∂z    |     |
• General notation with divergence operator div:
∂ρ
| + div(ρu) | =   |     |     |
| --------- | --- | --- | --- |
0
∂t
15 Introduction to CFD (4RC30)

Conservation of x-momentum
• Accumulation + net inflow of momentum = surface forces + body forces
∂ρu
+ div(ρuu)
ρv u δxδz
∂t
n n
n
• Surface forces act on the cell surfaces
• Viscous forces
• Pressure forces ρu u δyδz ρu u δyδz
w w e e
w e
(x, y)
• Body forces act on the cell volume
y
• Gravity, centrifugal, magnetic, etc. x s
ρv u δxδz
s s
16 Introduction to CFD (4RC30)

Surface forces: viscous stress
• Viscous stress = Normal stress + Shear stress
τ
yy
τ
yx
τ τ τ τ
xx xy xy xx
y τ
yx
x
τ
yy
Image credit:
17 Introduction to CFD (4RC30)
https://www.xometry.com/resources/materials/shear-stress/

Surface forces, x-direction
• Net surface force on the side faces (e,w):
|       |            |          | ∂(−pτ | )         |     |     |
| ----- | ---------- | -------- | ----- | --------- | --- | --- |
| (p −τ | )δyδz +(−p | +τ )δyδz | =     | xx δxδyδz |     |     |
τ
| w xx,w |     | e xx,e | ∂x  |     |     |     |
| ------ | --- | ------ | --- | --- | --- | --- |
yx,n
• Net surface force on the upper/lower faces (n,s): n
|     |     |     |     |     | p   | p   |
| --- | --- | --- | --- | --- | --- | --- |
|     |     |     |     |     | w   | e   |
∂τ
| −τ δxδz | +τ δxδz | = yx δxδyδz |     |     |     |     |
| ------- | ------- | ----------- | --- | --- | --- | --- |
w e
| yx,w | yx,e |     |     |     |      |      |
| ---- | ---- | --- | --- | --- | ---- | ---- |
|      |      | ∂y  |     |     | τ    | τ    |
|      |      |     |     |     | xx,w | xx,e |
y
s
| • Add all faces and divide by control volume ( |     |     |     |     | ):  |     |
| ---------------------------------------------- | --- | --- | --- | --- | --- | --- |
x
τ
yx,s
|       | ∂τ  |     |     | 𝛿𝛿𝛿𝛿 𝛿𝛿𝛿𝛿 𝛿𝛿𝛿𝛿 |     |     |
| ----- | --- | --- | --- | -------------- | --- | --- |
| ∂(−pτ | )   |     |     |                |     |     |
yx
xx +
| ∂x  | ∂y  |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- |
18 Introduction to CFD (4RC30)

Image credit:
https://web1.eng.famu.fsu.edu/~shih/succeed/cylinder/cylinder.htm
| Conservation of x- |     |     | and y-momentum |     |     |     |     |
| ------------------ | --- | --- | -------------- | --- | --- | --- | --- |
• Accumulation + net inflow of momentum = surface forces + body forces
∂τ
|     | ∂ρu |     | ∂(−p | +τ  | )   |     |     |
| --- | --- | --- | ---- | --- | --- | --- | --- |
yx
| Horizontal: |                                    | + div(ρuu) | =   |     | xx + |     | + S |
| ----------- | ---------------------------------- | ---------- | --- | --- | ---- | --- | --- |
|             | ∂t                                 |            |     | ∂x  |      | ∂y  | Mx  |
|             | ∂ρv                                |            | ∂τ  |     | ∂(−p | +τ  | )   |
|             |                                    |            |     | xy  |      | yy  |     |
| Vertical:   |                                    | + div(ρvu) | =   | +   |      |     | + S |
|             | ∂t                                 |            | ∂x  |     | ∂y   |     | My  |
| with S      | a body force, for example gravity: |            |     |     |      |     |     |
M
S = 0
Mx
S = −ρg
My
v
u
Control volume
19 Introduction to CFD (4RC30)

Stress terms
• Stress terms are function of deformation rate
∂u
• Stresses in many fluids behave Newtonian ( τ  ) and isotropic (no directional
xx ∂x
dependence)
• Stresses in polymers are non-Newtonian and non-isotropic → not considered here
20 Introduction to CFD (4RC30) Image credit: https://doi.org/10.1039/b916049n

Newtonian stress
• Newtonian stress  deformation rate
∂u
|     |     | τ = 2µ | +λdivu |     |
| --- | --- | ------ | ------ | --- |
• molecular viscos≅ity:
xx
∂x
∂v
• dilatational viscosity:
| 𝜇𝜇  |     | τ = 2µ | +λdivu |     |
| --- | --- | ------ | ------ | --- |
yy
∂y
| •𝜆𝜆 Gases:  = -2/3 |       |      |       |      |
| ------------------ | ----- | ---- | ----- | ---- |
|                    |       |      |  ∂u  | ∂v  |
|                    |       | τ =τ | =µ   | +   |
|                    |       | xy   | yx ∂y | ∂x   |
| • Liquids:𝜆𝜆 div u | = 0𝜇𝜇 |      |      |     |
21 Introduction to CFD (4RC30)

Conservation of momentum
• Substituting stress terms gives:
| ∂ρu |            |     | ∂p  | ∂             |     | ∂u   |        |     | ∂   |   ∂u | ∂v     |   |     |
| --- | ---------- | --- | --- | ------------- | --- | ---- | ------ | --- | --- | ------ | ------ | --- | --- |
|     |            |     |     |               |    |      |        |    |     |        |        |     |     |
|     | + div(ρuu) | =   | −   | +             | 2µ  |      | +λdivu |     | +   | µ      | +      |     | +   |
|     |            |     |     |               |     |      |        |     |     |      |        |   | S   |
|     |            |     |     |               |    |      |        |    |     |        |        |     | Mx  |
| ∂t  |            |     | ∂x  | ∂x            |    | ∂x   |        |    | ∂y  | ∂y     | ∂x     |     |     |
|     |            |     |     |               |     |      |        |     |     |      |        |   |     |
| ∂ρu |            |     | ∂p  |               |     |      |        |     |     |        |        |     |     |
|     | + div(ρuu) | =   | −   | + div(µgradu) |     |      | +      | S   |     |        |        |     |     |
| ∂t  |            |     | ∂x  |               |     |      |        | Mx  |     |        |        |     |     |
|     |            |     |     |               |    |      |        |   |     |        |        |     |     |
| ∂ρv |            |     | ∂p  | ∂             |     |  ∂u | ∂v     |     | ∂  | ∂v     |        |    |     |
|     | + div(ρvu) | =   | −   | +             | µ   |      | +      | +   | 2µ  |        | +λdivu | +   | S   |
|     |            |     |     |               |    |     |        |   |    |        |        |    |     |
| ∂t  |            |     | ∂y  | ∂x            |     | ∂y   | ∂x     |     | ∂y  | ∂y     |        |     | My  |
|     |            |     |     |               |    |     |        |   |    |        |        |    |     |
| ∂ρv |            |     | ∂p  |               |     |      |        |     |     |        |        |     |     |
|     | + div(ρvu) | =   | −   | + div(µgradv) |     |      | +      | S   |     |        |        |     |     |
| ∂t  |            |     | ∂y  |               |     |      |        | My  |     |        |        |     |     |
22 Introduction to CFD (4RC30)

Conservation of energy
• Derivation of energy equation for incompressible flows leads to:
|     | ∂T           |         |        |     | ∂u    | ∂u    |     | ∂v    | ∂v    |     |
| --- | ------------ | ------- | ------ | --- | ----- | ----- | --- | ----- | ----- | --- |
| ρC  | [ + div(Tu)] | = div(k | gradT) | +τ  | +τ    |       | +τ  | +τ    |       | + S |
|     | p ∂t         |         |        |     | xx ∂x | yx ∂y |     | xy ∂x | yy ∂y | i   |
Heating by viscous dissipation ≈
0
23 Introduction to CFD (4RC30)

General transport equation
• Rate of change + convection = diffusion + (source – sink)
∂(ρφ)
+ div(ρφu) = div(Γgradφ) + S
φ
∂t
• is the diffusion/conduction coefficient
• is a general variable (1, u, v, w, T, m, …)
Γ j
• Note: diffusion and conduction are analogous processes!
𝜙𝜙
24 Introduction to CFD (4RC30)

General transport equation
∂(ρφ)
|        | +div(ρφu) | =   | div(Γgradφ)+ | S       |        |        |     |
| ------ | --------- | --- | ------------ | ------- | ------ | ------ | --- |
| ∂t     |           |     |              |         | φ      |        |     |
| 𝜙𝜙     | Γ         |     |              |         | 𝑆𝑆 𝜙𝜙  |        |     |
| 1(one) | 0         |     |              |         | 0      |        |     |
|        |           |     | ∂p           | ∂  ∂u  |        |  ∂   | ∂v |
| u      |           |     | − +          | µ       | +λdivu | +      | µ   |
|        |           |     |              |        |        |      |    |
|        |           |     | ∂x           | ∂x  ∂x |        |  ∂y  | ∂x |
𝜇𝜇
|     |     |     | ∂p  | ∂  ∂u |      | ∂  ∂v   |    |
| --- | --- | --- | --- | ------- | ---- | -------- | --- |
| v   |     |     | − + | µ       | +    | µ +λdivu |     |
|     |     |     |     |        |     |         |    |
|     |     |     | ∂y  | ∂x  ∂y |  ∂y |  ∂y     |    |
𝜇𝜇
T
|     | 𝑝𝑝    |     |     |     | 𝑖𝑖  |     |     |
| --- | ----- | --- | --- | --- | --- | --- | --- |
|     | 𝑘𝑘⁄𝐶𝐶 |     |     |     | 𝑆𝑆  |     |     |
25 Introduction to CFD (4RC30)

Integral general transport equation
• To solve the general transport equation we integrate over control volume CV
∂(ρφ)
| ∫   | dV  | + ∫ div(ρφu)dV | = ∫ div(Γgradφ)dV | + ∫ S dV |
| --- | --- | -------------- | ----------------- | -------- |
φ
∂t
| CV  |     | CV  | CV  | CV  |
| --- | --- | --- | --- | --- |
• We use Gauss’ divergence theorem
|     |      | ∫ divadV      | = ∫n⋅adA         |        |
| --- | ---- | ------------- | ---------------- | ------ |
|     |      | CV            | A                |        |
| ∂  |      |              |                  |        |
| ∫   | ρφdV | + ∫n⋅(ρφu)dA | = ∫n⋅(Γgradφ)dA+ | ∫ S dV |

φ
∂t
|    |     |    |     |     |
| --- | --- | --- | --- | --- |
| CV  |     | A   | A   | CV  |
26 Introduction to CFD (4RC30)

Integral general transport equation
|     |    |    |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- |
∂
|                           |  ∫ ρφdV | + ∫n⋅(ρφu)dA | =     | ∫n⋅(Γgradφ)dA+ | ∫ S | dV  |
| ------------------------- | -------- | ------------- | ----- | -------------- | --- | --- |
| ∂t                        |          |               |       |                |     | φ   |
|                           |         |              |       |                |     |     |
|                           | CV       | A             |       | A              | CV  |     |
| • Steady state problems ( |          |               | = 0): |                |     |     |
|                           |          | ∫n⋅(ρφu)dA    |       | ∫n⋅(Γgradφ)dA+ | ∫   |     |
|                           |          |               | =     |                | S   | dV  |
𝝏𝝏⁄𝝏𝝏𝝏𝝏
φ
|     |     | A   |     | A   | CV  |     |
| --- | --- | --- | --- | --- | --- | --- |
• Time-dependent problems:
|     |    |    |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- |
∂
| ∫   | ∫ ρφdV | dt + ∫ ∫n⋅(ρφu)dAdt |     | =   |     |     |
| --- | ------ | -------------------- | --- | --- | --- | --- |

∂t
|     |    |     |                   |     |       |        |
| --- | --- | ---- | ----------------- | --- | ----- | ------ |
| ∆t  | CV  | ∆t A |                   |     |       |        |
|     |     |      | ∫ ∫n⋅(Γgradφ)dAdt |     | + ∫ ∫ | S dVdt |
φ
|     |     |     | ∆t A |     | ∆tCV |     |
| --- | --- | --- | ---- | --- | ---- | --- |
27 Introduction to CFD (4RC30)

Example: steady state conduction
2r = 0.01 m
A B
T = 300 K T = 500 K
A B
Xmax = 0.5 m
28 Introduction to CFD (4RC30)

Conduction or diffusion problems
• General transport equation:
∂(ρφ)
+div(ρφu) = div(Γgradφ)+ S
φ
∂t
• Steady diffusion (no convection):
0 = div(Γgradφ)+ S
φ
• 1D steady diffusion:
d  dφ
Γ + S = 0
 
φ
dx  dx 
29 Introduction to CFD (4RC30)

Diffusion problems
Step 1: Grid generation
Control volume boundaries,
Cell faces
| tnatsnoc = |     |     | tnatsnoc = |
| ---------- | --- | --- | ---------- |
| A W        | P   | E   | B          |
| φ A        |     |     | φ B        |
Grid points,
Control volume,
Nodal points,
Grid cell,
Mesh points, …
Mesh cell, …
30 Introduction to CFD (4RC30)

Diffusion problems
Step 1: Grid generation
Dx= XMAX/NPI; % length of volume element
% length variable for the scalar points in the x direction
x = zeros(1,NPI+2);
x(1) = 0.;
x(2) = 0.5*Dx;
for i = 3:NPI+1
x(i) = x(i-1) + Dx;
end
x(NPI+2) = x(NPI+1) + 0.5*Dx;
31 Introduction to CFD (4RC30)

Diffusion problems
Step 2: Discretization
|     | d  | dφ |     |        |    | dφ |     |     | dφ |     |       |     |
| --- | --- | --- | --- | ------ | --- | --- | --- | ---- | --- | --- | ----- | --- |
| ∫   | Γ   | dV  | +   | ∫ S dV | =   | ΓA  |     | − ΓA |     |     | + S∆V | = 0 |
|     |    |    |     |        |    |     |    |     |     |    |       |     |
φ
|                                  | dx  | dx  |     |     |    | dx             |    |    | dx  |    |     |     |
| -------------------------------- | ---- | ---- | --- | --- | --- | -------------- | --- | --- | --- | --- | --- | --- |
| ∆V                               |      |      |     | ∆V  |     |                | e   |     |     | w   |     |     |
| • Diffusion coefficients; linear |      |      |     |     |     | interpolation: |     |     |     |     |     |     |
|                                  | Γ    | +Γ   |     |     |     | Γ              | +Γ  |     |     |     |     |     |
| Γ                                | =    | W P  |     |     | Γ   | =              | P   | E   |     |     |     |     |
|                                  | w    |      |     |     |     | e              |     |     |     |     |     |     |
|                                  |      | 2    |     |     |     |                | 2   |     |     |     |     |     |
• Diffusive fluxes:
|     | dφ |     |     | φ −φ |    |     | dφ |     |     | φ  | −φ  |    |
| --- | --- | --- | --- | ----- | --- | --- | --- | --- | --- | --- | --- | --- |
|    |     |     |     |       |     |    |     |     |     |     |     |     |
| ΓA  |     | = Γ |     | E     | P   | ΓA  |     | =   | Γ   |     | P   | W   |
|    |     |    | A   |      |    |    |     |    | A   |    |     |    |
|    | dx  |    | e e | δx    |     |    | dx  |    | w   | w   | δx  |     |
|     |     |     |     |      |    |     |     |     |     |    |     |    |
|     |     | e   |     | PE    |     |     |     | w   |     |     | WP  |     |
32 Introduction to CFD (4RC30)

Diffusion problems
• Source term linearization:
| S∆V | =   | + φ |     |     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     | S   | S   |     |     |     |     |     |     |     |     |     |
|     |     | u P | P   |     |     |     |     |     |     |     |     |
• Substitute diffusive fluxes and source term:
|     | φ     | −φ  |     | φ −φ |      |     |     |     |     |     |     |
| --- | ------ | ---- | --- | ----- | ----- | --- | --- | --- | --- | --- | --- |
|     | E      | P    |     | P     | W     |     |     |     |     |     |     |
| Γ   | A     |     | −Γ  | A    |  +(S | +   | S φ | ) = | 0   |     |     |
|     | e e δx |      | w   | w δx  |       | u   | P   | P   |     |     |     |
|     |       |     |     |      |      |     |     |     |     |     |     |
|     |        | PE   |     | WP    |       |     |     |     |     |     |     |
• Rearrange:
|    | Γ   | Γ   |     |    |  Γ |     |    |    | Γ   |    |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     | e   | + w |     | − φ | =   | w   | φ   | +   | e   | φ + |     |
|    | A   |     | A   | S  |    | A   |    |    |     | A  | S   |
| δx  | e   | δx  | w   | P P | δx  | w   | W   | δx  |     | e E | u   |
|    |     |     |     |    |    |     |    |    |     |    |     |
|     | PE  | WP  |     |     |     | WP  |     |     | PE  |     |     |
33 Introduction to CFD (4RC30)

Diffusion problems
|    | Γ                        |     | Γ   |     |    |     |  Γ   |     |    |    | Γ   |    |     |
| --- | ------------------------ | --- | --- | --- | --- | --- | ----- | --- | --- | --- | --- | --- | --- |
|     | e                        | +   | w   | −   |     | φ = |       | w   | φ   | +   | e   | φ + |     |
|    |                          | A   |     | A   | S  |     |      | A   |    |    |     | A  | S   |
|     |                          | e   |     | w   | P   | P   |       | w   | W   |     |     | e E | u   |
| δx  |                          |     | δx  |     |     |     | δx    |     |     |     | δx  |     |     |
|    |                          |     |     |     |    |     |      |     |    |    |     |    |     |
|     | PE                       |     | WP  |     |     |     |       | WP  |     |     | PE  |     |     |
| •   | Introduce coefficients a |     |     |     |     |     | , a   | , a |     |     |     |     |     |
|     |                          |     |     |     |     | P   | W     | E   |     |     |     |     |     |
|     |                          |     |     |     | a   | φ   | = a φ | + a | φ   | + S |     |     |     |
|     |                          |     |     |     |     | P P | W     | W   | E E |     | u   |     |     |
•
where
|     |     |     |     |     |     | a   |     | a   |     |     | a   |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     |     |     |     |     |     | W   |     | E   |     |     | P   |     |     |
|     |     |     |     |     |     | Γ   |     | Γ   |     |     |     |     |     |
|     |     |     |     |     |     | w   | A   | e   | A   | a   | + a | − S |     |
|     |     |     |     |     | δx  |     | w   | δx  | e   | W   | E   | P   |     |
|     |     |     |     |     |     | WP  |     | PE  |     |     |     |     |     |
34 Introduction to CFD (4RC30)

Diffusion problems
Step 3: Solution of equations
• An equation solver is treated in HC 3
• Solver considered a black box for the moment
35 Introduction to CFD (4RC30)

Example: steady state conduction
2r = 0.01 m
A B
T = 300 K T = 500 K
A B
Xmax = 0.5 m
36 Introduction to CFD (4RC30)

Numerical solution
%% CONSTANTS /* define all the constants */
%% INIT /* initialize variables */
%% BOUNDARY /* apply boundary conditions */
%% T-EQUATION /* calculate coefficients of T equation aE, aW, aP, b */
%% SOLVE /* solver iteration loop */
for iter = 0:OUTER_ITER
… /* solve1D(T, b, aE, aW, aP)*/
fprintf(…); /* write convergence to screen */
end
%% OUTPUT /* write output to file */
37 Introduction to CFD (4RC30)

Output on the command window
0 T[1] = 305.556 T[2] = 316.667 T[3] = 333.333 T[4] = 366.667 T[5] = 433.333
1 T[1] = 311.121 T[2] = 333.362 T[3] = 361.169 T[4] = 402.894 T[5] = 462.731
2 T[1] = 314.931 T[2] = 344.792 T[3] = 378.463 T[4] = 420.780 T[5] = 472.042
3 T[1] = 317.201 T[2] = 351.602 T[3] = 388.274 T[4] = 429.851 T[5] = 475.963
4 T[1] = 318.477 T[2] = 355.431 T[3] = 393.661 T[4] = 434.585 T[5] = 477.876
5 T[1] = 319.177 T[2] = 357.530 T[3] = 396.583 T[4] = 437.097 T[5] = 478.867
6 T[1] = 319.556 T[2] = 358.668 T[3] = 398.160 T[4] = 438.441 T[5] = 479.393
7 T[1] = 319.761 T[2] = 359.283 T[3] = 399.010 T[4] = 439.162 T[5] = 479.674
8 T[1] = 319.871 T[2] = 359.614 T[3] = 399.467 T[4] = 439.549 T[5] = 479.825
9 T[1] = 319.931 T[2] = 359.792 T[3] = 399.713 T[4] = 439.757 T[5] = 479.906
10 T[1] = 319.963 T[2] = 359.888 T[3] = 399.846 T[4] = 439.869 T[5] = 479.949
11 T[1] = 319.980 T[2] = 359.940 T[3] = 399.917 T[4] = 439.930 T[5] = 479.973
12 T[1] = 319.989 T[2] = 359.968 T[3] = 399.955 T[4] = 439.962 T[5] = 479.985
13 T[1] = 319.994 T[2] = 359.983 T[3] = 399.976 T[4] = 439.980 T[5] = 479.992
14 T[1] = 319.997 T[2] = 359.991 T[3] = 399.987 T[4] = 439.989 T[5] = 479.996
15 T[1] = 319.998 T[2] = 359.995 T[3] = 399.993 T[4] = 439.994 T[5] = 479.998
16 T[1] = 319.999 T[2] = 359.997 T[3] = 399.996 T[4] = 439.997 T[5] = 479.999
17 T[1] = 320.000 T[2] = 359.999 T[3] = 399.998 T[4] = 439.998 T[5] = 479.999
18 T[1] = 320.000 T[2] = 359.999 T[3] = 399.999 T[4] = 439.999 T[5] = 480.000
19 T[1] = 320.000 T[2] = 360.000 T[3] = 399.999 T[4] = 440.000 T[5] = 480.000
20 T[1] = 320.000 T[2] = 360.000 T[3] = 400.000 T[4] = 440.000 T[5] = 480.000
38 Introduction to CFD (4RC30)

Comparison with analytical results
2r = 0.01 m
A B
T = 300 K T = 500 K
A B
Xmax = 0.5 m
39 Introduction to CFD (4RC30)

2D and 3D problems
• Step 1: Grid generation
• Six faces: n, s, e, w, t, b
• Step 2: Discretization
•
∆𝑉𝑉 = 𝛿𝛿𝛿𝛿 𝛿𝛿𝛿𝛿 𝛿𝛿𝛿𝛿
• Step 3: Solution of equations
• Treated in HC 3 or Chapter 6
• See book for detailed description
40 Introduction to CFD (4RC30)

Wrap up
| •   | Rate of change + convection |     |     |     | = diffusion |     | + (source – |     | sink) |
| --- | --------------------------- | --- | --- | --- | ----------- | --- | ----------- | --- | ----- |
∂(ρφ)
|     |     |     | +div(ρφu) |     | = div(Γgradφ)+ |     |     | S   |     |
| --- | --- | --- | --------- | --- | -------------- | --- | --- | --- | --- |
φ
∂t
• General form of discretized equations:
|     | φ = ∑                               | φ   | +   |     |     |       | = ∑ | −   |     |
| --- | ----------------------------------- | --- | --- | --- | --- | ----- | --- | --- | --- |
|     | a                                   | a   |     | S   |     | a     |     | a S |     |
|     | P P                                 | nb  | nb  | u   |     | P     |     | nb  | P   |
| •   | Source terms are included through S |     |     |     |     | and S |     |     |     |
|     |                                     |     |     |     |     | u     |     | P   |     |
41 Introduction to CFD (4RC30)

Introduction to CFD (4RC30)
Basics of programming in Matlab
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. Yali Tang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

Variables
• Script/Function file: .m extension
function [] = init()
% This function is to initialise all parameters.
• Variables: every variable is an array or matrix.
%% constants
NPI = 5; % number of grid cells in x-direction [-]
XMAX = 1.0; % width of the domain [m]
Dx = XMAX / NPI; % length of volume element
x = zeros(1,NPI+2); % x coordinate on pressure points [m]
r = [7 8 9 10 11]; % row vectors
c = [7; 8; 9; 10; 11]; % column vectors
45 Introduction to CFD (4RC30)

Operators
• Arithmetic operators                      Relational operators                        Logical operators
| •Symbol | Role        | Symbol Role     | Symbol Role   |
| ------- | ----------- | --------------- | ------------- |
| +       | Addition    | == Equal to     | & Logical AND |
| -       | Subtraction | ~= Not equal to | | Logical OR  |
.* Element-wise multiplication > Greater than && Logical AND (with short-circuiting)
* Matrix multiplication >= Greater than or equal to || Logical OR (with short-circuiting)
| ./  | Element-wise right division | < Less than              | ~ Logical NOT |
| --- | --------------------------- | ------------------------ | ------------- |
| /   | Matrix right division       | <= Less than or equal to |               |
| .^  | Element-wise power          |                          |               |
| ^   | Matrix power                |                          |               |
•
Functions
| Function   | Explanation                                         |     |     |
| ---------- | --------------------------------------------------- | --- | --- |
| sum(A,dim) | Sums along the dimension ofAspecified by scalardim. |     |     |
rounds the elements of A to the nearest integers greater than or equal to A.
ceil(A)
| floor(A) | rounds the elements of A to the nearest integers less than or equal to A. |     |     |
| -------- | ------------------------------------------------------------------------- | --- | --- |
| Round(A) | rounds the elements of A to the nearest integers.                         |     |     |
46 Introduction to CFD (4RC30)

Decisions (if statement)
• if... elseif ... else ... end statement
• if ... else … end statement
• if ... end statement
if <expression>
if <expression>
<statement(s)>
<statement(s)>
else
end
<statement(s)>
end
a = 10;
if a < 20 % check the condition a = 100;
% if condition is true then print the following if a < 20 % check the boolean condition
% if condition is true then print the following
fprintf('a is less than 20\n' );
fprintf('a is less than 20\n' );
end
else
% if condition is false then print the following
fprintf('a is not less than 20\n' );
end
a is less than 20 a is not less than 20
47 Introduction to CFD (4RC30)

Loop
• for … end statement • while… end statement
for index = values while <expression>
<program statements> <statements>
…
...
end end
a = 10;
for i = 1:NPI+2
% while loop execution
fprintf(fp,'%11.4e\t%11.4e\n',x(i),T(i));
while( a < 20 )
end
fprintf('value of a: %d\n', a);
a = a + 1;
end
48 Introduction to CFD (4RC30)

Import and Output
• Data import • Output
A = importdata(filename) Many options
% Loads data into array A from the file
denoted by filename. % write output to txt file
if iter == OUTER_ITER
fp= fopen('output.txt','w');
for i = 1:NPI+2
filename = ‘output.dat';
fprintf(fp,'%11.4e\t%11.4e\n',x(i),T(i));
A = importdata(filename);
end
fclose(fp);
end
49 Introduction to CFD (4RC30)

Plotting & Images
Vector field
Plot Contour 3D plot
[x,y] = meshgrid(0:0.2:2,0:0.2:2);
[x,y] = meshgrid(-5:0.1:5,-3:0.1:3); [x,y] = meshgrid(-2:.2:2);
x = [0:5:100]; u = cos(x).*y;
g = x.^2 + y.^2; g = x .* exp(-x.^2 -y.^2);
y = x; v = sin(x).*y;
contour(x,y,g) surf(x, y, g)
quiver(x,y,u,v)
plot(x, y)
50 Introduction to CFD (4RC30)

Wellbeing Signal Group @ ME
INTRODUCTION SLIDES FOR COURSES
Department of Mechanical Engineering

Diversity statement of ME
“The Mechanical Engineering department at TU/e is committed to creating an inclusive and
welcoming environment that values diversity and promotes equity.
We strive to create a community where everyone feels safe, respected, and valued.
We believe that diversity is essential to our mission of educating students to become global
citizens who can thrive in an increasingly diverse world.
We are committed to fostering an environment where all members of our community -
students, faculty, and staff - can learn, grow, and succeed.”
— Dean prof.dr.ir. P. D. Anderson
52

Goal of the Wellbeing Signal Group @ ME
… reducing barriers for conversations!
Our goal is to ensure that all individuals are supported on their journey to thrive, both
professionally and personally.
We help picking up signals affecting your wellbeing as small as they might be. We take those
signals, which usually reveal a pattern, and we take actions accordingly.
Signals Patterns Actions/Response-ability

Variables at cell faces
• Control volume (grid cell, fluid element) is very small
• Taylor series for pressure at east face:
• Only use first two terms of Taylor series
|     |     | ∂p(x) |     | ∂2  |     |     |
| --- | --- | ----- | --- | --- | --- | --- |
p(x)
2
| p(x + 1δx) | = p(x) | +   | 1δx | + 1 | (1δx) | +... |
| ---------- | ------ | --- | --- | --- | ----- | ---- |
| 2          |        |     | 2   | 2 2 | 2     |      |
|            |        | ∂x  |     | ∂x  |       |      |
55 Introduction to CFD (4RC30)

Conservation of mass
• Accumulation of mass + Net mass inflow = 0
• Accumulation:
δx
∂ ∂ρ
(ρδxδy) = δxδy
∂t ∂t
δy
• Divide by area control volume ( ):
∂ρ
(x, y)
y
𝜹𝜹𝜹𝜹 𝜹𝜹𝒚𝒚
∂t
x
56 Introduction to CFD (4RC30)

Conservation of mass
• Taylor series gives for net mass inflow at faces:
∂ρv
ρv + 1δy
∂y 2
∂ρu ∂ρu
ρu − 1δx ρu + 1δx
∂x 2 ∂x 2
(x, y)
y
x
∂ρv
ρv − 1δy
∂y 2
57 Introduction to CFD (4RC30)

Conservation of mass
• Add up all mass flows into control volume:
|     | ∂ρu |     |    |     |     | ∂ρu |     |    |
| ---- | --- | --- | --- | --- | ---- | --- | --- | --- |
| ρu − |     | 1δx | δy  | −   | ρu   | +   | 1δx | δy  |
|     |     |     |    |     |     |     |     |    |
|      |     | 2   |     |     |      |     | 2   |     |
|     | ∂x  |     |    |     |     | ∂x  |     |    |
|     | ∂ρv |     |    |     |     | ∂ρv |     |    |
| + ρv | −   | 1δy |     | δx  | − ρv | +   | 1δy | δx  |
|     |     |     |    |     |     |     |     |    |
|      |     | 2   |     |     |      |     | 2   |     |
|      |     | ∂y  |     |     |      |     | ∂y  |     |
|     |     |     |    |     |     |     |     |    |
• Divide by area control volume ( ):
|                |     |     |               | ∂ρu |     | ∂ρv |     |     |
| -------------- | --- | --- | ------------- | --- | --- | --- | --- | --- |
| Net mass inflo |     |     | 𝛿𝛿 w 𝛿𝛿 𝛿𝛿=𝛿𝛿 |     | +   |     |     |     |
|                |     |     |               | ∂x  |     | ∂y  |     |     |
58 Introduction to CFD (4RC30)

Conservation of mass
• Microbalance for mass, 2D:
| ∂ρ ∂(ρu) | ∂(ρv) |     |     |
| -------- | ----- | --- | --- |
| +        | +     | = 0 |     |
| ∂t ∂x    | ∂y    |     |     |
• Microbalance for mass, 3D:
| ∂ρ ∂(ρu) | ∂(ρv) | ∂(ρw) |     |
| -------- | ----- | ----- | --- |
| +        | +     | +     | = 0 |
| ∂t ∂x    | ∂y    | ∂z    |     |
∂ρ
| + div(ρu) | = 0 |     |     |
| --------- | --- | --- | --- |
∂t
59 Introduction to CFD (4RC30)