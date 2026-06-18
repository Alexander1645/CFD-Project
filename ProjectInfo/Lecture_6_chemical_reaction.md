Introduction to CFD (4RC30)
Chemical reactions
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. YaliTang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

Outline
Summary of previous lectures
Content of this lecture (Chapter 12)
• Simple chemical reacting system (SCRS)
• Eddy break-up model of combustion
Wrap up
2 Introduction to CFD (4RC30)

Summary of previous lectures
| • Rate of change + | convection | = diffusion | + (source – | sink) |     |     |
| ------------------ | ---------- | ----------- | ----------- | ----- | --- | --- |
∂(ρφ)
|     | +div(ρφu) | = div(Γgradφ)+S |     |     |     |     |
| --- | --------- | --------------- | --- | --- | --- | --- |
φ
∂t
|     |     |     | ∑   |     | ∑   |     |
| --- | --- | --- | --- | --- | --- | --- |
• General form of discretized equations: a φ = a φ +S a = a +∆F −S
|     |     |     | P P | nb nb u | P nb | P   |
| --- | --- | --- | --- | ------- | ---- | --- |
• Steady flows
Spatial discretization scheme: CDS, UDS, Hybrid
Algorithm: SIMPLE
• Unsteady flows
Time discretization scheme: Explicit, Crank-Nicolson, Implicit
Algorithm: transient SIMPLE, pseudo transient simulations
• Turbulence models
k-ɛmodel
Large eddy simulations (LES)
• Algebraic slip model
3 Introduction to CFD (4RC30)

Timescales in reacting flows
| • Three timescales (Westerterp, van Swaaij |     |     |     | and Beenackers): |
| ------------------------------------------ | --- | --- | --- | ---------------- |
l2
V 1
|     |     | t = r ; | t = ;     | t =     |
| --- | --- | ------- | --------- | ------- |
|     |     | macro Φ | micro 12ν | r kcn−1 |
V A0
• Slowest timescale determines reaction rate:
t
| •   |     | : Simple chemical reacting system |     |     |
| --- | --- | --------------------------------- | --- | --- |
macro
| • t |     | : Eddy break-up model |     |     |
| --- | --- | --------------------- | --- | --- |
micro
| • t   | ~ t | : Eddy break-up model with reaction  |     |     |
| ----- | --- | ------------------------------------ | --- | --- |
| micro | r   |                                      |     |     |
| • t   |     | : kinetic model (+simple flow model) |     |     |
r
4 Introduction to CFD (4RC30)

Chemical reactions
• Suppose combustion reaction:
1 kg of fuel+ s kg of oxygen → (1+ s) kg of products
Fuel
Y =1;Y = 0
• In mass fractions (Y):
fu ox
Y + s⋅Y → (1+ s)Y
fu ox pr
• Total mass fraction:
Y =Y +Y +Y ≡1
total fu ox pr
Oxygen
Y =1;Y = 0
ox fu
𝑗𝑗
𝑚𝑚
𝑌𝑌 =
𝑡𝑡𝑡𝑡𝑡𝑡𝑡𝑡𝑡𝑡
s is stoichiomet𝑚𝑚ric ratio
𝑜𝑜𝑜𝑜𝑜𝑜𝑜𝑜𝑜𝑜𝑜𝑜
𝑓𝑓𝑓𝑓𝑜𝑜𝑓𝑓
5 Introduction to CFD (4RC30)

Species equations
• Transport equations for mass fractions oxygen and fuel
∂(ρY )
|     | fu  | +div(ρY | = div(Γ |       | )+  |     |
| --- | --- | ------- | ------- | ----- | --- | --- |
|     |     |         | u)      | gradY |     | S   |
|     |     |         | fu      | fu    | fu  | fu  |
∂t
| ∂(ρY |     | )       |            |       |     |      |
| ---- | --- | ------- | ---------- | ----- | --- | ---- |
|      | ox  | +div(ρY | u) = div(Γ | gradY |     | )+ S |
|      |     |         | ox         | ox    | ox  | ox   |
∂t
• In order to reduce number of eqs. we assume:
| φ=  | sY  | −Y  |     | Γ   | =   | Γ = Γ |
| --- | --- | --- | --- | --- | --- | ----- |
φ
|     |     | fu ox |     |     | fu  | ox  |
| --- | --- | ----- | --- | --- | --- | --- |
6 Introduction to CFD (4RC30)

Mixture faction
| • Take s⋅fuel | equation and subtract oxygen |     |     | equation: |
| ------------- | ---------------------------- | --- | --- | --------- |
∂(ρφ)
|     | +div(ρφu) | = div(Γ | gradφ)+(sS | −   |
| --- | --------- | ------- | ---------- | --- |
S )
|     |     |     | φ   | fu ox |
| --- | --- | --- | --- | ----- |
∂t
= 0
• For supposed stoichiometry:
∂(ρφ)
|     | +div(ρφu) | = div(Γ | gradφ) |     |
| --- | --------- | ------- | ------ | --- |
φ
∂t
| • No source term, so  |     | is a so-called passive scalar |     |     |
| --------------------- | --- | ----------------------------- | --- | --- |
𝜙𝜙
7 Introduction to CFD (4RC30)

Mixture faction
• Mixture fraction, ξ:
|     |     |     |     |     | −Y    | )−(sY | −Y  |        |        | Note: in the code  |
| --- | --- | --- | --- | --- | ----- | ----- | --- | ------ | ------ | ------------------ |
|     |     | φ−φ |     | (sY |       |       |     | )      |        |                    |
|     | ξ=  |     | 0   | =   | fu ox |       | fu  | ox 0 ; | 0 ≤ξ≤1 |                    |
ξ is called f
|     |     | φ   | −φ  | (sY | −Y    | ) −(sY | −Y  | )    |     |     |
| --- | --- | --- | --- | --- | ----- | ------ | --- | ---- | --- | --- |
|     |     | 1   | 0   |     | fu ox | 1      | fu  | ox 0 |     |     |
|     |     |     | Y   | =1; |       | Y      | = 0 |      |     |     |
• Pure fuel:
|                |     |     |     | fu,1 |     | ox,1 |     |     |     |     |
| -------------- | --- | --- | --- | ---- | --- | ---- | --- | --- | --- | --- |
|                |     |     |     | =    |     |      | =1  |     |     |     |
| • Pure oxygen: |     |     | Y   |      | 0;  | Y    |     |     |     |     |
|                |     |     |     | fu,0 |     | ox,0 |     |     |     |     |
• Substitute to get:
|     |     |     |     |     |     | −Y  | +Y  |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
sY
|     |     |     |     |     | fu  | ox  | ox,0 |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | ---- | --- | --- | --- |
ξ=
+Y
sY
|     |     |     |     |     |     | fu,1 | ox,0 |     |     |     |
| --- | --- | --- | --- | --- | --- | ---- | ---- | --- | --- | --- |
8 Introduction to CFD (4RC30)

Mixture faction
• Mixture fraction:
|     | −Y +Y |     |     |
| --- | ----- | --- | --- |
sY
| ξ=  | fu ox | ox,0 |     |
| --- | ----- | ---- | --- |
sY +Y
|                                    | fu,1 ox,0 |        |       |
| ---------------------------------- | --------- | ------ | ----- |
| • Stoichiometric mixture fraction: |           | (sY −Y | ) ≡ 0 |
|                                    |           | fu     | ox    |
Y
ξ = ox,0
st
sY +Y
|     | fu,1 ox,0 |     |     |
| --- | --------- | --- | --- |
• Transport equation of mixture fraction:
∂(ρξ)
|     | +div(ρξu) | = div(Γ | gradξ) |
| --- | --------- | ------- | ------ |
| ∂t  |           |         | ξ      |
9 Introduction to CFD (4RC30)

What are the mass fractions?
• Suppose you have a given ξfield
• Assume “mixed is burnt” concept
• Derive expressions for the mass fractions:
• Y in terms of: ξ, ξ and Y
fu st fu,1
• Y in terms of: ξ, ξ and Y
ox st ox,0
• Y in terms of: Y and Y
pr fu ox
sY −Y +Y Y
ξ= fu ox ox,0 ξ = ox,0
sY +Y st sY +Y
fu,1 ox,0 fu,1 ox,0
10 Introduction to CFD (4RC30)

What are the mass fractions?
• The mass fractions for fuel and oxygen, using “mixed is burnt” concept:
ξ−ξ
| ξ ≤ξ<1 | ⇒   | =    |     | =   | st  |     |
| ------ | --- | ---- | --- | --- | --- | --- |
|        |     | Y 0; |     | Y   | Y   |     |
Fuel rich
| st  |     | ox  |     | fu 1−ξ | fu,1 |     |
| --- | --- | --- | --- | ------ | ---- | --- |
st
|      |     | ξ −ξ |      |     |     |             |
| ---- | --- | ---- | ---- | --- | --- | ----------- |
| <ξ<ξ | ⇒   | = st |      | =   |     | Oxygen rich |
| 0    |     | Y    | Y ;  | Y 0 |     |             |
|      | st  | ox   | ox,0 | fu  |     |             |
ξ
st
• The mass fractions for the product:
| Y =1−(Y | +Y )  |     |     |     |     |     |
| ------- | ----- | --- | --- | --- | --- | --- |
| pr      | fu ox |     |     |     |     |     |
11 Introduction to CFD (4RC30)

Mass fraction vs. mixture fraction
Oxygen Fuel rich
Fuel
rich
Oxygen
12 Introduction to CFD (4RC30)

Simple chemical reacting system (SCRS)
SCRS model:
• PDE for mixture fraction,ξ:
∂(ρξ)
| +div(ρξu)                 | = div(Γ | gradξ) |     |
| ------------------------- | ------- | ------ | --- |
| ∂t                        |         | ξ      |     |
| Algebraic equations for Y |         | and Y  |     |
•
ox pr
| sY    | −Y +Y   |       |       |
| ----- | ------- | ----- | ----- |
| ξ= fu | ox ox,0 | =1−(Y | +Y    |
|       |         | Y     | )     |
|       |         | pr    | fu ox |
sY +Y
fu,1 ox,0
13 Introduction to CFD (4RC30)

Temperature
Mixture fraction equation has the same form as the enthalpy equation *)
∂(ρξ) ∂(ρh)
| +div(ρξu) | = div(Γ | gradξ) | +div(ρhu) | = div(Γ |     |
| --------- | ------- | ------ | --------- | ------- | --- |
gradh)
ξ h
| ∂t  |     | ∂t  |     |     |     |
| --- | --- | --- | --- | --- | --- |
So, the enthalpy can be related to the
Fuel
mixture fraction and to the temperature for free!
Y =1
fu
h−h
ξ= h*=1
| ξ= h*= | ox,in |     |     |     |     |
| ------ | ----- | --- | --- | --- | --- |
h −h
fu,in ox,in
| = +Y  | (∆h   |     |     |     | Y = 0 |
| ----- | ----- | --- | --- | --- | ----- |
| h C T | )     |     |     |     |       |
| p     | fu fu |     |     |     | fu    |
ξ= h*= 0
| h−Y  | (∆h ) |     |     |     |     |
| ---- | ----- | --- | --- | --- | --- |
| = fu | fu    |     |     |     |     |
T
Oxygen
C
p
*) Assuming no heat transport through
radiation and adiabatic walls, see p. 373
14 Introduction to CFD (4RC30)

Micro mixing timescale
l2 ρl2
| • Micro mixing timescale: | t =       | =   |
| ------------------------- | --------- | --- |
|                           | micro 12ν | 12µ |
eff
k3/2
l =
• Eddy length scale:
ε
k2
|     | µ = ρC |     |
| --- | ------ | --- |
• Effective dynamic viscosity:
|     | eff | µ   |
| --- | --- | --- |
ε
1 k k
|                       | =          | = = |
| --------------------- | ---------- | --- |
| • Substitution gives: | t t        |     |
|                       | micro eddy |     |
12C ε ε
µ
15 Introduction to CFD (4RC30)

Eddy Dissipation Concept
Magnussen’s original hand sketch of the reactive zones (left),
subsequent confirmation using laser photography (right)
16 Introduction to CFD (4RC30) Magnussen and Hjertager, 1976

Eddy break-up model
• Reaction rate depends on speed of mixing of the species:
|     |     | ε   |     |     |     | ε   |     |     | Y ε |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Y
pr
| R = −C | ρY  | ;    |     | R = −C | ρ   | ox ; | R = −C' | ρ   |          |
| ------ | --- | ---- | --- | ------ | --- | ---- | ------- | --- | -------- |
| fu     | R   | fu k |     | ox     | R   | s k  | pr      | R   | (1+ s) k |
• Turbulent combustion:
′
|     |     |     |     | 𝑅𝑅  | 𝑅𝑅  |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
• Species with lowest spe 𝐶𝐶 e d  = of 1  m ; 𝐶𝐶 ix in = g  0 d . e 5 termines sink in PDE fuel fraction, Y :
fu
|     | ε   |    |     |     |     | Y  |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Y
pr
| S = −ρ |     | min  | C Y  | ,C ox | ,C' |      |     |     |     |
| ------ | --- | ----- | ---- | ----- | --- | ----- | --- | --- | --- |
| fu     | k   |       | R fu | R s   | R   | 1+ s |     |     |     |

17 Introduction to CFD (4RC30)

Eddy break-up model Practical tip: it requires non-zero initial values of
|     |     |     |     |     |     |     |     | m_fu, m_ox |     | and m_pr | to “ignite” the reaction |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | ---------- | --- | -------- | ------------------------ | --- | --- |
|     |     |     |     |     |     |     |     |            |     | ε        |                         |     | m  |
m
|                               |     |     |     |     |                          |     |     |     | S =−ρ | min | C m ,C | ox ,C' | pr     |
| ----------------------------- | --- | --- | --- | --- | ------------------------ | --- | --- | --- | ----- | ---- | ------ | ------ | ------ |
| • Complete model:             |     |     |     |     |                          |     |     |     |       |      |        |        |       |
|                               |     |     |     |     |                          |     |     |     | fu    | k    | R fu   | R s    | R 1+ s |
|                               |     |     |     |     |                          |     |     |     |       |      |       |        |       |
| • PDEs for mixture fraction ξ |     |     |     |     | and fuel mass fraction Y |     |     |     |       | :    |        |        |        |
fu
|     | ∂(ρY | )   |     |     |     |     |     |     |     |     |     |     |     |
| --- | ---- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
fu
|     |     | +div(ρY |     | u)  | = div(Γ | gradY | )+  | S   |     |     |     |     |     |
| --- | --- | ------- | --- | --- | ------- | ----- | --- | --- | --- | --- | --- | --- | --- |
|     | ∂t  |         |     | fu  |         | fu    | fu  | fu  |     |     |     |     |     |
∂(ρξ)
|     |     | +div(ρξu) |     | =   | div(Γ | gradξ) |     |     |     |     |     |     |     |
| --- | --- | --------- | --- | --- | ----- | ------ | --- | --- | --- | --- | --- | --- | --- |
ξ
∂t
| • Algebraic equations for other mass fractions, Y |     |     |     |      |     |         |     |     | and Y | :   |     |     |     |
| ------------------------------------------------- | --- | --- | --- | ---- | --- | ------- | --- | --- | ----- | --- | --- | --- | --- |
|                                                   |     |     |     |      |     |         |     | ox  |       | pr  |     |     |     |
|                                                   |     | sY  | −Y  | +Y   |     |         |     |     |       |     |     |     |     |
|                                                   |     | fu  | ox  | ox,0 |     |         |     |     |       |     |     |     |     |
|                                                   | ξ=  |     |     |      |     | Y =1−(Y |     | +Y  | )     |     |     |     |     |
|                                                   |     |     | +Y  |      |     | pr      |     | fu  | ox    |     |     |     |     |
sY
|     |     |     | fu,1 | ox,0 |     |     |     |     |     |     |     |     |     |
| --- | --- | --- | ---- | ---- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
18 Introduction to CFD (4RC30)

Eddy break-up model with reaction
• Micro mixing/reaction determine reaction rate
• Finite reaction rate (Arrhenius equation):
| R          | =   | −Aρ−aYbYc |     | exp(−E | / RT) |     |     |     |     |     |
| ---------- | --- | --------- | --- | ------ | ----- | --- | --- | --- | --- | --- |
| fu,kinetic |     | 1         | fu  | ox     |       |     |     |     |     |     |
• Minimum of speed of mixing and reaction determines sink in PDE fuel fraction,
m
:
fu
|     |      |  ε |     | ε    | Y    | ε   |     | Y      |            |    |
| --- | ---- | --- | --- | ---- | ---- | --- | --- | ------ | ---------- | --- |
| S = | −min | ρ   | C   | Y ,ρ | C ox | ,ρ  | C'  | pr ,−R |            |     |
|     |      |    |     |      |      |     |     |        |            |    |
| fu  |      |     | R   | fu   | R    |     | R   |        | fu,kinetic |     |
|     |      | k   |     | k    | s    | k   | 1+  | s      |            |     |
|     |      |    |     |      |      |     |     |        |            |    |
19 Introduction to CFD (4RC30)

Eddy break-up model with reaction
Complete model:
• Same as standard eddy break-up model
• Note: sink term S is different
fu
20 Introduction to CFD (4RC30)

Example: chemically reacting flow
Results of the eddy break-up model: temperature field in furnace
Magnussen and Hjertager, 1976
Image credit: H.K. Versteeg, W. Malalasekera
21 Introduction to CFD (4RC30) https://www.uis.no/nb/profile/bjorn-helge-hjertager
https://www.dnv.com/news/2017/dnv-gl-acquires-specialist-in-cfd-for-fire-and-explosion-analysis-computit-102503/

Example: chemically reacting flow
Explosion of premixed propane/air
• Experiments (product fraction)
• Simulations (product fraction)
22 Introduction to CFD (4RC30) Naamansen, Solberg, Hjertager(2000)

Flame propagation
Image credits: Aalborg University Esbjerg
23 1986
https://www.nafems.org/blog/posts/analysis-origins-kfx-and-flacs/

Piper Alpha accident (1988)
Image credits: Aalborg University Esbjerg
24
https://nl.wikipedia.org/wiki/Piper_Alpha

Chemisorption process @ pH = 10.5
NaOH
solution
CO
2
Darmanaet al., WCCE7,  2005
| [CO ] | [CO 2-] | [HCO -] | pH  |
| ----- | ------- | ------- | --- |
|       | 3       | 3       |     |
25 Introduction to CFD (4RC30) 2

Chemisorption process @ pH = 14
NaOH
solution
CO
2
Darmanaet al., WCCE7,  2005
| [CO ] | [CO 2-] | [HCO -] | pH  |
| ----- | ------- | ------- | --- |
|       | 3       | 3       |     |
26 Introduction to CFD (4RC30) 2

Wrap up
Determine slowest timescale
• t simple chemical reacting system:
macro
PDE for mixture fraction ξ
• t eddy break-up model:
micro
PDEs for mixture fraction ξand fuel mass fraction Y
fu
speed of mixing in sink S
fu
• t ~ t eddy break-up model with reaction:
micro r
PDEs for mixture fraction ξand fuel mass fraction Y
fu
speeds of mixing and reaction in sink S
fu
27 Introduction to CFD (4RC30)