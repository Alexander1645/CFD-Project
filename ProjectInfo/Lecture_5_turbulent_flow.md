Introduction to CFD (4RC30)
Turbulent flows
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. YaliTang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

10
8
6
0.2
4
0.18 2
0
0.16
-2
0.14
-4
0.12
-6
0.1
-8
0.0 8 -10
0.06
0.04
0.02
0
0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
2 Introduction to CFD (4RC30) Video credit: https://youtu.be/3mULL6O6f38?si=49NQMJvmXV3_6dFp

Von Karman vortex street
183 km
(picture: NASA)
158 km
Beerenberg volcano
Jan Mayen Island
Height 2.2 km
Image credit: Wikipedia,
3 Introduction to CFD (4RC30)
NASA, Google Maps

Outline
Content of this lecture (Chapter 3)
• Qualitative description of turbulence
• Reynolds averaging
• Prandtl mixing length model
• k-ɛ model
• Large eddy simulations (LES)
Wrap up
4 Introduction to CFD (4RC30)

What is turbulence?
• Definition 1:
• Laminar flow: flow in ‘lamina’
• Turbulent flow: flow with ‘eddies’
• Problem: laminar vortex shedding
• Definition 2:
• Laminar flow: dampens instabilities
• Turbulent flow: enhances instabilities
• Characterized by:
Convective forces
Re =
Viscous forces
Image credit: https://mriquestions.com/laminar-v-turbulent.html
5 Introduction to CFD (4RC30) https://commons.wikimedia.org/wiki/File:Convecting-candles-.jpg
https://thiele.au.dk/fileadmin/www.thiele.au.dk/Events/2015/Aarhus/Birnir.pdf

Role of Reynolds number
• Re < 2000: laminar flow
viscous forces dampen instabilities
• For Re > 2300: turbulent flow
convective forces enhance instabilities
• Transition starts at Re ~ 2000 differing from problem to problem!
6 Introduction to CFD (4RC30)

Turbulence scales
• Scale of interest
Production of energy   → Transport of energy  → Viscous energy dissipation
| O(m)               | O(cm-mm)        | O(µm)     |
| ------------------ | --------------- | --------- |
| Macroscopic models | Typical CFD     | DNS       |
| 1 cell             | (102-103) cells | 106 cells |
7 Introduction to CFD (4RC30)

Reynolds averaging
| • Solve | the large scales and model |     | the small scales | u =U +u' |     |
| ------- | -------------------------- | --- | ---------------- | -------- | --- |
• Steady problems: • Unsteady problems:
|     | • Time averaging |     | • Ensemble averaging |     |     |
| --- | ---------------- | --- | -------------------- | --- | --- |
V
u u
Tt
U
U
t
|     |     | t   | U+u' |     | U+u' |
| --- | --- | --- | ---- | --- | ---- |
8 Introduction to CFD (4RC30)

Examples
•
| • Instantaneous flow field | Reynolds averaged | flow field |
| -------------------------- | ----------------- | ---------- |
Image credit: https://mriquestions.com/laminar-v-turbulent.html
9 Introduction to CFD (4RC30)

Reynolds averaging equations
• Decompose variables in mean and fluctuations:
| u =U | +u'; | v =V | +v'; | w =W | + w'; | p = P + | p'  |     |
| ---- | ---- | ---- | ---- | ---- | ----- | ------- | --- | --- |
• Definition of mean and fluctuation velocities:
∆t
|     |     | ∆t  |     |     |     |     | 1   |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
1
|     | =   | ∫      |     |     |     | u' = | ∫ u'(t)dt | ≡ 0 |
| --- | --- | ------ | --- | --- | --- | ---- | --------- | --- |
|     | U   | u(t)dt |     |     |     |      |           |     |
∆t
∆t
|     |     | 0   |     |     |     |     | 0   |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
1/2
|     |     |       |  ∆t       |    |     |       |          |     |
| --- | --- | ----- | ---------- | --- | --- | ----- | -------- | --- |
|     |     |       | 1          |     |     |       | (        | )   |
|     |     |       |            |     |     |       | u'2 +v'2 | w'2 |
|     | u = | u'2 = | ∫ (u')2dt |     | ≥ 0 | k = 1 |          | +   |

|     | rms |     | ∆t  |     |     | 2   |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     |     |     |    |    |     |     |     |     |
0
10 Introduction to CFD (4RC30)

Reynolds averaging equations
| ∂u  |     | ∂p  |     |     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
1
| +div(uu) |     | = − | +νdiv(gradu) |     |     |     |     |     |     |     |     |
| -------- | --- | --- | ------------ | --- | --- | --- | --- | --- | --- | --- | --- |
| ∂t       |     | ρ∂x |              |     |     |     |     |     |     |     |     |
• Average the x momentum equation using:
∂U ∂u'
| +   | +div(UU)+div(u'u') |     |     | =   |     |      |     |      |     |        | ′ ′   |
| --- | ------------------ | --- | --- | --- | --- | ---- | --- | ---- | --- | ------ | ----- |
|     |                    |     |     |     |     | 𝑢𝑢𝐮𝐮 | =   | 𝑢𝑢𝐮𝐮 | =   | 𝑈𝑈𝑈𝑈 + | 𝑢𝑢 𝐮𝐮 |
∂t ∂t
|     |     |        |                           |     |     |     | 𝑈𝑈  | = 𝑈𝑈, | 𝑈𝑈 = | 𝑈𝑈, 𝑃𝑃 = | 𝑃𝑃  |
| --- | --- | ------ | ------------------------- | --- | --- | --- | --- | ----- | ---- | -------- | --- |
|     | 1   | ∂P 1 ∂ | p'                        |     |     |     |     |       |      |          |     |
|     | −   | −      | +νdiv(gradU)+νdiv(gradu') |     |     |     |     |       |      |          |     |
|     | ρ   | ∂x ρ   | ∂x                        |     |     |     |     |       |      |          |     |
• Average of fluctuations are zero, hence:
| ∂U                 |     |     |     | ∂P   |              |     |     |      |      |         |     |
| ------------------ | --- | --- | --- | ---- | ------------ | --- | --- | ---- | ---- | ------- | --- |
|                    |     |     |     | 1    |              |     | ′   |      | ′    | ′       |     |
| +div(UU)+div(u'u') |     |     | =   | −    | +νdiv(gradU) |     |     |      |      |         |     |
|                    |     |     |     |      |              |     | 𝑢𝑢  | = 0, | 𝐮𝐮 = | 0, 𝑝𝑝 = | 0   |
| ∂t                 |     |     |     | ρ ∂x |              |     |     |      |      |         |     |
11 Introduction to CFD (4RC30)

Reynolds averaging equations
| ∂U  |     |     |     |     |     | ∂P  |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
1
|     | +div(UU)+div(u'u') |     |     |     | = − |      | +νdiv(gradU) |     |     |     |
| --- | ------------------ | --- | --- | --- | --- | ---- | ------------ | --- | --- | --- |
| ∂t  |                    |     |     |     |     | ρ ∂x |              |     |     |     |
• Convective momentum transport due to velocity fluctuations:
|            |     |     | ∂(ρu'2) |     | ∂(ρu'v') |     | ∂(ρu'w') |     |     |     |
| ---------- | --- | --- | ------- | --- | -------- | --- | -------- | --- | --- | --- |
| div(ρu'u') |     | =   |         | +   |          |     | +        |     |     |     |
|            |     |     | ∂x      |     | ∂y       |     | ∂z       |     |     |     |
• Definition of ‘Reynolds stresses’:
−ρu'2;
| τ   | =   |     | τ = | −ρu'v'; |     | τ   | = −ρu'w' | ⇒   | τ = −ρu | 'u ' |
| --- | --- | --- | --- | ------- | --- | --- | -------- | --- | ------- | ---- |
| xx  |     |     | xy  |         |     | xz  |          |     | ij      | i j  |
12 Introduction to CFD (4RC30)

Closures for Reynolds stresses
• Boussinesq approximation (1877): turbulent fluctuations ~ shear stress
|     |     |  ∂U | ∂U  |    |
| --- | --- | ---- | --- | --- |
2
| τ = −ρu | =µ |     | i + | j + ρkδ |
| ------- | --- | --- | --- | -------- |
'u '
|     |     |    |       |     |
| --- | --- | --- | ----- | ---- |
| ij  | i j | t   | ∂x ∂x | 3 ij |
|     |     |    |       |     |
|     |     |     | j     | i    |
1, 𝑖𝑖 = 𝑗𝑗
𝑖𝑖𝑖𝑖
𝛿𝛿 = �
0, 𝑖𝑖 ≠ 𝑗𝑗
• Closure models for  :
| • Zero equation models: Prandtl |     |     | mixing length |     |
| ------------------------------- | --- | --- | ------------- | --- |
𝑡𝑡
𝜇𝜇
| • Two-equation models: k-ɛ |     | model |     |     |
| -------------------------- | --- | ----- | --- | --- |
• Reynolds stress model and algebraic stress model (see book)
13 Introduction to CFD (4RC30)

Mixing length model
|     |     |     |    |     | ∂U  |     |     |
| --- | --- | --- | --- | --- | ---- | --- | --- |
∂U
j
|     | τ = −ρu | 'u  | ' =µ | i   | +  |     |     |
| --- | ------- | --- | ----- | --- | --- | --- | --- |
|     |         |     |      |     |    |     |     |
|     | ij      | i   | j t   | ∂x  | ∂x  |     |     |
|     |         |     |      | j   | i  |     |     |
• Dimensional analysis yields:
| dynamic viscosity = density |     |     |          |     | · velocity | · length; |     |
| --------------------------- | --- | --- | -------- | --- | ---------- | --------- | --- |
|                             |     |     | µ = Cρ |     |            |           |     |
t
|     |     |     |      | ∂U  |     |     | ∂U    |
| --- | --- | --- | ---- | --- | --- | --- | ----- |
|     |     |     |  = |     | ⇒   | µ   | = ρl2 |
|     |     |     |      |     |     | t   | m     |
|     |     |     |      | ∂y  |     |     | ∂y    |
∂U ∂U
|     |     |     | ⇒   | τ   | =τ = −ρu |     | = ρl2 |
| --- | --- | --- | --- | --- | -------- | --- | ----- |
'u '
|     |     |     |     | xy  | yx  | x   | y m ∂y ∂y |
| --- | --- | --- | --- | --- | --- | --- | --------- |
14 Introduction to CFD (4RC30)

Assessment mixing length model
• Assumption made:
Turbulence is characterized by one velocity scale and one length scale, that need to be
known a priori (see book for table)
• Easy to implement and cheap in calculation
• Fails for complex flows (e.g. with separation and circulation)
15 Introduction to CFD (4RC30)

k-ɛ model
|     |     |     |  ∂U |     | ∂U  |    |     |     |     |     |
| --- | --- | --- | ---- | --- | --- | --- | --- | --- | --- | --- |
|     |     |     |      |     |     | 2   |     |     | 2   |     |
j
| τ   | = −ρu | 'u ' =µ |     | i   | +   | − ρkδ |     | = 2µE | −    | ρkδ |
| --- | ----- | -------- | --- | --- | --- | ------ | --- | ----- | ---- | --- |
|     |       |          |    |     |     |       |     |       |      |     |
| ij  |       | i j      | t   | ∂x  | ∂x  |        | ij  |       | t ij | ij  |
|     |       |          |     |     |     | 3      |     |       | 3    |     |
|     |       |          |    | j   |     | i     |     |       |      |     |
• Two-equation model based on:
|                             |     |     |     |     |     | (     |      |     | )   |         |
| --------------------------- | --- | --- | --- | --- | --- | ----- | ---- | --- | --- | ------- |
|                             |     |     |     |     |     | u'2   | +v'2 |     | w'2 |         |
| • Turbulent kinetic energy: |     |     |     |     |     | k = 1 |      | +   |     | [m2/s2] |
2
| • Viscous dissipation of turbulent kinetic energy:   |     |     |     |     |     |     |     |     |     | [m2/s3] |
| ---------------------------------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ------- |
𝜀𝜀
|     |     |         | k3/2 |     |     |     |       |     | k2  |     |
| --- | --- | ------- | ---- | --- | --- | --- | ----- | --- | --- | --- |
|     | =   | k1/2;= |      |     | ⇒   | µ = | Cρ= |     | ρC  |     |

|     |     |     |     |     |     | t   |     |     | µ   |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     |     |     | ε   |     |     |     |     |     | ε   |     |
16 Introduction to CFD (4RC30)

k equation
|     |     | (            |     | )   |     |        |     |
| --- | --- | ------------ | --- | --- | --- | ------ | --- |
|     | =   | 1 u'2 +v'2 + | w'2 |     | u ' | = u −U |     |
k
|     |     |     |     |     | i   | i i |     |
| --- | --- | --- | --- | --- | --- | --- | --- |
2
| •   | Multiply Navier-Stokes equations with u |           |     |                |     | ': u     | u ' |
| --- | --------------------------------------- | --------- | --- | -------------- | --- | -------- | --- |
|     |                                         |           |     |                |     | i i      | i   |
| •   | Multiply Reynolds equations with u      |           |     |                |     | ': U u ' |     |
|     |                                         |           |     |                |     | i i i    |     |
|     | Calculate Σ                             |           | Σ   |                |     |          |     |
| •   |                                         | u u ' -   | U   | u ' to obtain: |     |          |     |
|     |                                         | i i       | i   | i              |     |          |     |
|     | ∂(ρk)                                   |           |     | µ              |     |          |     |
|     |                                         | +div(ρku) | =   | div( t gradk)+ |     | 2µE ⋅E   | −ρε |
|     | ∂t                                      |           |     | σ              |     | t ij     | ij  |
k
|     | accu-    | convective |     | diffusive  |     | production | dissipation |
| --- | -------- | ---------- | --- | ---------- | --- | ---------- | ----------- |
|     | mulation | transport  |     | transport  |     |            |             |
17 Introduction to CFD (4RC30)

ɛ equation
• The production and dissipation of turbulent kinetic energy are closely linked:
The source and sink terms in the ɛ equation are proportional to those in the k equation
| ∂(ρk) |           |     |        | µ   |           |     |      |     |     |     |
| ----- | --------- | --- | ------ | --- | --------- | --- | ---- | --- | --- | --- |
|       | +div(ρku) |     | = div( |     | t gradk)+ | 2µE | ⋅E   | −ρε |     |     |
|       |           |     |        |     |           |     | t ij | ij  |     |     |
| ∂t    |           |     |        | σ   |           |     |      |     |     |     |
k
| ∂(ρε) |           |     |     | µ   |            |     | ε   |     |     | ε2  |
| ----- | --------- | --- | --- | --- | ---------- | --- | --- | --- | --- | --- |
|       | +div(ρεu) |     | =   |     | t gradε)+C |     | 2µE | ⋅E  | −C  | ρ   |
div(
|     |     |     |     |     |     | 1ε  |     | t ij | ij  | 2ε  |
| --- | --- | --- | --- | --- | --- | --- | --- | ---- | --- | --- |
| ∂t  |     |     |     | σ   |     |     | k   |      |     | k   |
ε
| C = | 0.09; | σ   | =1.00; |     | σ =1.30; |     | C   | =1.44; |     | C =1.92 |
| --- | ----- | --- | ------ | --- | -------- | --- | --- | ------ | --- | ------- |
| µ   |       |     | k      |     | ε        |     |     | 1ε     |     | 2ε      |
18 Introduction to CFD (4RC30)

ε
|     | Implementation k- |     |     |     |     | model in CFD codes |     |     |     |     |     |     |     |     |
| --- | ----------------- | --- | --- | --- | --- | ------------------ | --- | --- | --- | --- | --- | --- | --- | --- |
Source term linearization (remember:  S∆V = S + S φ with S > 0, S < 0)
|       |       |     |      |          |     |     |     |     |     |     | u     | P   |         |      |
| ----- | ----- | --- | ---- | -------- | --- | --- | --- | --- | --- | --- | ----- | --- | ------- | ---- |
|       |       |     |      |          |     |     |     |     | u P | P   |       |     |         |      |
| ∂(ρk) |       |     |      |          |     |     |     |     |     |     |       |     |         | ε    |
|       | +Conv | =   | Diff | + 2µE ⋅E | −ρε |     |     |     | S = | 2µE | ⋅E    |     | S = −ρ( | )old |
|       | ∂t    |     |      | t ij     | ij  |     |     |     | u   | t   | ij ij |     | p       |      |
|       |       |     |      |     |   |     |     |     |     |     |       |     |         | k    |
S∆V
| ∂(ρε) |     |     |     | ε   |     |     |     | ε2  |     |     | ε   |     |     | ε   |
| ----- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
+Conv = Diff +C 2µE ⋅E −C ρ S = C ( )old 2µE ⋅E S = −C ρ( )old
|     |     |     |     | 1ε  | t ij | ij  | 2ε  |     | u   | 1ε  |     | t ij ij | p   | 2ε  |
| --- | --- | --- | --- | --- | ---- | --- | --- | --- | --- | --- | --- | ------- | --- | --- |
|     | ∂t  |     |     | k   |      |     |     | k   |     |     | k   |         |     | k   |

S∆V
Discretization of convection and diffusion using standard form:
|     | φ =                            | ∑   | φ   | +    |     |     | = ∑ |     | + ∆F | −   |     |     |     |     |
| --- | ------------------------------ | --- | --- | ---- | --- | --- | --- | --- | ---- | --- | --- | --- | --- | --- |
|     | a                              |     | a   | S    |     | a   |     | a   |      | S   |     |     |     |     |
|     | P P                            |     | nb  | nb u |     | P   |     |     | nb   | P   |     |     |     |     |
|     | 19 Introduction to CFD (4RC30) |     |     |      |     |     |     |     |      |     |     |     |     |     |

Assessment k-ɛ model
• Simplest turbulence model without a priori knowledge of velocity and length
scales
• Successfully and widely applied in industry
• Most widely validated turbulence model
• More expensive than mixing length model (2 extra PDE’s)
• Isotropic turbulence assumption not valid for swirling flows, buoyant flows, etc.
20 Introduction to CFD (4RC30)

Implementation momentum equations
| ∂(ρu)     | ∂p               |     |     |     |     |
| --------- | ---------------- | --- | --- | --- | --- |
| +div(ρuu) | = − +div(µgradu) |     |     |     |     |
| ∂t        | ∂x               |     |     |     |     |
Reynolds averaging gives:
| ∂(ρU)     | ∂P                          |     |     |         |     |
| --------- | --------------------------- | --- | --- | ------- | --- |
| +div(ρUU) | = − +div(µgradU)−div(ρu'u') |     |     |         |     |
| ∂t        | ∂x                          |     |     |         |     |
| ∂(ρU)     | ∂P                          |     |     |         |     |
| +div(ρUU) | = − +div(µgradU)+div(µgradU |     |     | − 2 ρkδ | )   |
|           |                             |     | t   | 3       | ij  |
| ∂t        | ∂x                          |     |     |         |     |
| ∂(ρU)     | ∂P                          |     |     |         |     |
Reynolds stresses: modelled
| +div(ρUU) | = − +div(µ |       | − 2 ρkδ |     |     |
| --------- | ---------- | ----- | ------- | --- | --- |
|           |            | gradU | )       |     |     |
|           |            | eff   | ij      |     |     |
| ∂t        | ∂x         |       | 3       |     |     |
k2
|     |     | µ =µ+µ | =µ+ρC |     |     |
| --- | --- | ------ | ----- | --- | --- |
µ
|     |     | eff | t   | ε   |     |
| --- | --- | --- | --- | --- | --- |
21 Introduction to CFD (4RC30)

Large Eddy Simulations (LES)
| • Navier-Stokes equations are filtered: |     |     |     |     |     | u   | =U +u' |
| --------------------------------------- | --- | --- | --- | --- | --- | --- | ------ |
• Resolve the flow on grid scales (the large eddies) and model the flow on sub-grid
scales
| ∂(ρU)         |           |              |      | ∂P       |       |     |           |
| ------------- | --------- | ------------ | ---- | -------- | ----- | --- | --------- |
|               | +div(ρUU) |              | =    | − +div(µ | gradU |     | − 2 ρkδ ) |
|               |           |              |      |          | eff   |     | 3 ij      |
| ∂t            |           |              |      | ∂x       |       |     |           |
| • Smagorinsky |           | model (1963) |      |          |       |     |           |
|               |           | µ            | =µ+µ | =µ+ρl2   |       | ⋅E  |           |
E
|      |      | eff |                  | t   | m   | ij ij |          |
| ---- | ---- | --- | ---------------- | --- | --- | ----- | -------- |
| l2 = | ∆)2; |     | ∆ = (∆x∆y∆z)1/3; |     |     | =     | 0.08−0.2 |
|      | (C   |     |                  |     |     | C     |          |
| m    | S    |     |                  |     |     | S     |          |
22 Introduction to CFD (4RC30)

Assessment LES
• Zero-equation SGS model easy to implement
• Captures dynamics of the flow
• Fine grid needed, so very expensive
• Probably best suited for chemically reacting flows and turbulent multiphase
flows
23 Introduction to CFD (4RC30)

Example: stirred tank
Sliding interface
• Sliding grid
• 180° geometry
• CFX 4.3
• k-εmodel
N N N N
r z q tot
Coarse 46 56 36 105
Fine 92 112 36 4·105
Baffles
Deen et al. (2002), Can. J. Chem. Eng. 80, 1-15
24 Introduction to CFD (4RC30)

Deen et al. (2002), Can. J. Chem. Eng. 80, 1-15
Results: stirred tank
Gas pockets
Region with high
turbulence level
Region with high (k = 0.2 m2/s2)
turbulence level
Gas inlet
(k = 0.065 m2/s2)
(α = 0.2)
G
Liquid only Gas-liquid
25 Introduction to CFD (4RC30)

Results: stirred tank
PIV
PIV
Wu and Patterson (1989)
|     | Costes and Couderc (1988) |     |     | Simulation, fine grid |     |
| --- | ------------------------- | --- | --- | --------------------- | --- |
Derksen et al. (1998)
| 4   |     |     | 4   | Simulation, coarse grid |     |
| --- | --- | --- | --- | ----------------------- | --- |
Simulation, fine grid
| 3   |     |     | 3   |     |     |
| --- | --- | --- | --- | --- | --- |
Simulation, coarse grid
| 2   |     |     | 2   |     |     |
| --- | --- | --- | --- | --- | --- |
+1
| 1      |     |     | 1      |     |     |
| ------ | --- | --- | ------ | --- | --- |
| w / z2 |     |     | w / z2 |     |     |
2z/w
| 0   |     |     | 0   |     |     |
| --- | --- | --- | --- | --- | --- |
-1
| -1-0.1 0.1 | 0.3 0.5 | 0.7 0.9 | -1-0.1 | 0.1 0.3 | 0.5 0.7 |
| ---------- | ------- | ------- | ------ | ------- | ------- |
| -2         |         |         | -2     |         |         |
| -3         |         |         | -3     |         |         |
| -4         |         |         | -4     |         |         |
|            | u  / u  |         |        | u  / u  |         |
|            | r,L tip |         |        | r,L tip |         |
Deen et al. (2002), Can. J. Chem. Eng. 80, 1-15
26 Introduction to CFD (4RC30)

Wrap up
Turbulence modelling through: µ = Cρ
t
• No model: Direct Numerical Simulations (DNS)
• Filtering: Large Eddy Simulations (LES)
Averaging: k-ɛ
• model, RSM, ASM
| RANS           | LES            | DNS            |
| -------------- | -------------- | -------------- |
| 100% modelled  | ~90% resolved  | 100% resolved  |
| turbulence     | turbulence     | turbulence     |
Increasing computational cost and method accuracy
27 Introduction to CFD (4RC30)

| Extended Boussinesq |     |     |     |     |     | approximation |     |     |     |     |     |     |     |
| ------------------- | --- | --- | --- | --- | --- | ------------- | --- | --- | --- | --- | --- | --- | --- |
|                     |     |     |     |     |    | ∂U            | ∂U  |    |     |     |     |     |     |
j
|                                             | τ = | −ρu | 'u  | ' =µ |     | i   | +   |  =   | 2µE |     |     |     |     |
| ------------------------------------------- | --- | --- | --- | ----- | --- | --- | --- | ----- | --- | --- | --- | --- | --- |
|                                             |     |     |     |       |    |     |     |      |     |     |     |     |     |
|                                             | ij  |     | i   | j     | t   | ∂x  | ∂x  |       | t   | ij  |     |     |     |
|                                             |     |     |     |       |    | j   |     | i    |     |     |     |     |     |
| Only consider normal stresses (i = 1,2,3; i |     |     |     |       |     |     |     | = j): |     |     |     |     |     |
•
|     |     |     |     | ∂U |     | ∂V  |     | ∂W  |        |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | ---- | ------ | --- | --- | --- | --- |
|     | ∑   | 2µE | =   | 2µ  |     | +   | +   | =    | 2µdivU |     | =   |     |     |
|     |     |     |     |    |     |     |     |     |        |     | 0   |     |     |
|     |     | t   | ii  | t   | ∂x  | ∂y  |     | ∂z   |        | t   |     |     |     |
|     |     |     |     |    |     |     |     |     |        |     |     |     |     |
i
• However:
|     |     |     |      |     |     |     | (   |        |     | )   |      |     |     |
| --- | --- | --- | ---- | --- | --- | --- | --- | ------ | --- | --- | ---- | --- | --- |
|     | ∑τ  | =   | ∑−ρu |     | =   | −ρ  | u'2 | +v'2 + | w'2 | =   | −2ρk |     |     |
'u '
|             |          | ii  |            | i    | i    |               |     |     |     |     |     |       |     |
| ----------- | -------- | --- | ---------- | ---- | ---- | ------------- | --- | --- | --- | --- | --- | ----- | --- |
|             | i        |     | i          |      |      |               |     |     |     |     |     |       |     |
| • Define: ( | = 1 if i |     | = j) and ( |      |      | = 0 if i ≠ j) |     |     |     |     |     |       |     |
|             |          |     |            |      |     |               | ∂U  |    |     |     |     |       |     |
|             | 𝒊𝒊𝒊𝒊     |     |            |      | 𝒊𝒊𝒊𝒊 | ∂U            |     |     | 2   |     |     | 2     |     |
|             | 𝜹𝜹       |     |            |      | 𝜹𝜹   |               |     | j   |     |     |     |       |     |
|             | τ =      | −ρu | 'u         | ' =µ |     | i             | +   | −  | ρkδ | =   | 2µE | − ρkδ |     |
|             | ij       |     | i          | j    | t   | ∂x            | ∂x  |    |     | ij  | t   | ij    | ij  |
|             |          |     |            |      |      |               |     |     | 3   |     |     | 3     |     |
|             |          |     |            |      |     | j             |     | i  |     |     |     |       |     |
28 Introduction to CFD (4RC30)