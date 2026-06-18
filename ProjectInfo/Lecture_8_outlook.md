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
Outlook
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, Vec-3.202
Dr. Yali Tang, y.tang2@tue.nl, Tel. 8052, Vec-3.106
Department of Mechanical Engineering

Outline
Content of this lecture
Text format by
Increase / decrease list level
Place cursor in text • Multiphase flow modelling
and use these 2 buttons (tab Start -
group Paragraph)
• Multiscale modelling strategy
• Examples
• Commercial CFD packages
1 = Normal text
2 = Paragraph text • Pro’s and con’s
3 = • text
4 = • text • Examples
5 = • text
Wrap up
2 Introduction to CFD (4RC30)

Multiphase flows: Multiscale
Text format by
Increase / decrease list level
Place cursor in text Fluidized bed reactor:
and use these 2 buttons (tab Start -
group Paragraph)
• Fluid Catalytic Cracking
• Granulation
• Combustion
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
Global electrolyzer capacity could
reach 134 GW by 2030
3 Introduction to CFD (4RC30)

Multiscale Modelling
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
larger geometry, less details
4 Introduction to CFD (4RC30)

Multiscale Modelling
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
The resolution of DNS must be 50 times higher than E-L
𝐷 = 0.8∆ 𝐷 ~ 40∆
𝑏 𝑏
The time step of DNS must be 50 times smaller than E-L
∆𝑡 ~ 1×10−3s ∆𝑡 ~ 2×10−5s
The computation of DNS is about 6.25 million times larger than the cost of E-L !!!
5 Introduction to CFD (4RC30)
p a
a
th
v e lo
d d m
p r e
b
c ity
a s s a n
s s u r e
u
d
o y a n c y
lif t
d r a g
E-L DNS

Why Direct Numerical Simulations?
DNS Approach and Role
Text format by
Increase / decrease list level
• Fully resolve all continuum scales without using sub-grid models
Place cursor in text
and use these 2 buttons (tab Start - or major assumptions
group Paragraph)
• Clear definition of all conditions (initial, boundary and forcing)
and the production of data for every single variable
• DNS is (currently) limited to small domains due to large
1 = Normal text
computational requirements. Device-scale simulations are out
2 = Paragraph text
3 = • text
of reach.
4 = • text
5 = • text
• A tool for fundamental studies of the small scale physics of
multiphase flows
• A tool for the development and validation of reduced model
descriptions used in meso- and macro- scale CFD simulations
6 Introduction to CFD (4RC30)

DNS: drag force on particles
Definition of drag coefficient C :
Text format by D
Increase / decrease list level
A fluid with (relative) approach velocity v exerts a force F on the object:
Place cursor in text rel
and use these 2 buttons (tab Start -
group Paragraph)
F = C A(1 v2 ) [N]
D D 2 rel
Buoyancy Drag
1 = Normal text
2 = Paragraph text Kinetic energy
3 = • text Drag coefficient
4 = • text per unit volume
5 = • text
Projected area
Gravity
7 Introduction to CFD (4RC30)
C
D
= f ( g e o m e t r y , R e ) where [-]

DNS: drag force on particles
Drag coefficient on a spherical particle
Text format by
Increase / decrease list level
• Stokes flow:
Place cursor in text
and use these 2 buttons (tab Start -  C  ~ 1/Re
D
|     | F group3 Paragvraph)d |     |    |     | 24  |     |     |
| --- | ----------------------- | --- | --- | --- | --- | --- | --- |
rel p
| C =     | D =       | = 24  |         |    | C = |     |     |
| ------- | --------- | ----- | ------- | --- | --- | --- | --- |
| D A1v2 | 1d2 1v2 |       |         |     | D   |     |     |
|         |           |       |  v d   |     | Re  |     |     |
|         | 2 f 4 p 2 | f rel | f rel p |     | p   |     |     |
• Correlation valid for finite Reynolds number
C   0.44
1 = Normal text D
2 = Paragraph text
|     | 3 = • text       |     |     |     |  2 4     |                  |             |
| --- | ---------------- | --- | --- | --- | ------------- | ---------------- | ----------- |
|     |                  |     |     |     | ( 1 + 0 . 1 5 | R e 0 .6 8 7 ) R | e  1 0 0 0 |
|     | 4 =    • text    |     |     |     |               | p                | p           |
|     |                  |     |     |     | C = R e       |                  |             |
|     | 5 =       • text |     |     |     | p             |                  |             |
D
|     |     |     |     |     | 0 . 4 4 | R   | e  1 0 0 0 |
| --- | --- | --- | --- | --- | ------- | --- | ----------- |
p
8 Introduction to CFD (4RC30)

DNS: drag force on particles
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
e
c
r
1 = Normal text o
2 = Paragraph text f
g
3 = • text a
4 = • text r D
5 = • text
Gas fraction
𝐹 = 𝐹 𝜀,Re
𝑑
9 Introduction to CFD (4RC30)

DNS: drag force on particles
Text format by
Increase / decrease list level
Place cursor in text Standard drag law
and use these 2 buttons (tab Start -
group Paragraph)
n
o
i
t
a
g
e
r
g
e
s Experiments
e
v
1 = Normal text it
2 = Paragraph text a
3 = • text
le
R
Bi-disperse drag model
4 = • text
5 = • text
d
F = F(,Re) with y = i
i s i d
10
Introduction to CFD (4RC30)

DNS: drag force on bubbles
Experiment Simulation
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
C = 24/Re
D
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
C = 0.44 (Particles)
D
11 Introduction to CFD (4RC30)

DNS: drag force on bubbles
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
12 Introduction to CFD (4RC30)
C
D ,
C
(
D
1 − )
= 1 +
1
E
8
o


Roghair et al. Chem. Eng. Sci. 2011

DPM
Experiment Simulation
Simulation
Gas phase: Navier-Stokes eq.
Text format by
Increase / decrease list level
Solid phase: Newton’s 2nd law
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph) Require (DNS-based) drag correlation
1 = Normal text Experiment
2 = Paragraph text
3 = • text
4 = • text
5 = • text
14 Introduction to CFD (4RC30)

DPM: steady spouted bed
Experiment Simulation
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
16 Introduction to CFD (4RC30)

DPM: effect of operation pressure
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
1 bar 2 bar 4 bar 8 bar 16 bar 32 bar 64 bar
17 Introduction to CFD (4RC30)

DPM: packed bed reactor
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
u = 2.5 u u = 6.0 u
x 0 z 0
u Obtained pressure drop complies with Ergun equation within 10%
0
19 Introduction to CFD (4RC30)

Two-Fluid Model (TFM)
Gas phase and solid phase: Volume-averaged Navier-Stokes eqs.
Text format by
Increase / decrease list level
Require drag correlation for gas-solid interaction Simulation
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph) Require model to describe particle-particle interactions
• Bubble size in a bubbling fluidized bed:
| dV     |      |       |        |
| ------ | ---- | ------ | ------ |
| B =Q−U | A    | V = d3 | A =d2 |
| dt     | ex B | B 6 B  | B B    |
1 = Normal text
2 = Paragraph text • Two simple models:
3 = • text Experiment
4 =    • text
| U = 0 | U = | U   |     |
| ----- | --- | --- | --- |
5 =       • text
| e x | e x | m f |     |
| --- | --- | --- | --- |
• … and a multiphase CFD model
           Kinetic theory of granular flow (KTGF)
20 Introduction to CFD (4RC30)

TFM: bubbling fluidized bed
Small particles (100 µm)
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
21 Introduction to CFD (4RC30)
U
e x
= U
m f
U = 0
ex

TFM: bubbling fluidized bed
Large particles (1 mm)
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
22 Introduction to CFD (4RC30)
U
e x
= 0
U =U
ex mf

TFM: effect of pressure on bed dynamics
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
23 Introduction to CFD (4RC30)

Commercial CFD packages
CFX, FLUENT, Star CCM+, COMSOL, etc.
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start - Advantages Disadvantages
group Paragraph)
• Easy pre-processing (grid generation) • Difficult to include user models
• Easy post-processing • Flow solver is mostly a black box
• Multi-purpose (?) • Solvers not optimized for flow problems
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
25 Introduction to CFD (4RC30)

Commercial CFD packages
CFD process
Text format by
Increase / decrease list level
• Geometry description
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph) • Grid generation, transformation, refinement
• Specification of flow conditions and properties
• Selection of models
1 = Normal text
2 = Paragraph text • Specification of initial and boundary conditions
3 = • text
4 = • text
• Specification of numerical parameters
5 = • text
• Flow solution
• Post processing: Analysis and visualization
26 Introduction to CFD (4RC30)

Example: slurry control valve
• Step 1: Import CAD design data into CFX-5 Valve
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
1 = Normal text
2 = Paragraph text
Flow out
3 = • text
4 = • text
5 = • text
Flow in
27 Introduction to CFD (4RC30)

Example: slurry control valve
• Step 2: grid generation
Text format by
Increase / decrease list level
|     |     | Automatic grid refinement at important locations |
| --- | --- | ------------------------------------------------ |
Place cursor in text
and use these 2 buttons (tab Start -
| group Paragraph) |     | Structured grids (simple geometry) or |
| ---------------- | --- | ------------------------------------- |
|                  |     | Unstructured grids (complex geometry) |
|                  |     | more information see chapter 11       |
1 = Normal text
2 = Paragraph text
3 = • text
4 =    • text
5 =       • text
28 Introduction to CFD (4RC30)

Example: slurry control valve
>>CFX5
• Step 3: Solve the model
Text format by >>OPTIONS
Increase / decrease list level
THREE DIMENSIONS
Problem-description in command language
Place cursor in text END
and use these 2 buttons (tab Start - >>MODEL DATA
group Paragraph)
>>PHYSICAL PROPERTIES
>>FLUID PARAMETERS
VISCOSITY 1.0E-3
DENSITY 1.0E3
END
>>MODEL BOUNDARY CONDITIONS
1 = Normal text
>>INLET BOUNDARIES
2 = Paragraph text
PATCH NAME 'INLET'
3 = • text
4 = • text U VELOCITY 0.707
5 = • text V VELOCITY 0.707
W VELOCITY 0.0
END
>>PRESSURE BOUNDARIES
PATCH NAME 'PRESSURE BOUNDARY'
PRESSURE 0.0
END
>>STOP
29 Introduction to CFD (4RC30)

Example: slurry control valve
• Step 4: post-processing
Text format by 2D view (streamlines) 2D view (flow field)
Increase / decrease list level
3D view
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
30 Introduction to CFD (4RC30)

More information
CFX https://www.ansys.com/products/fluids/ansys-cfx
Text format by
Increase / decrease list level
FLUENT https://www.ansys.com/products/fluids/ansys-fluent
Place cursor in text
and use these 2 buttons (tab Start - Star CCM+ https://mdx.plm.automation.siemens.com/star-ccm-plus
group Paragraph)
COMSOL https://www.comsol.nl/
1 = Normal text Open-sourced CFD codes
2 = Paragraph text
3 = • text
OpenFOAM https://www.openfoam.com/
4 = • text
5 = • text
CFDEM https://www.cfdem.com/
• News, forums, wiki, links, jobs, books, events
CFD-online https://www.cfd-online.com/
31 Introduction to CFD (4RC30)

Wrap up
• Multiphase flows: multiscale modelling • Commercial CFD packages
Text format by
Increase / decrease list level
Place cursor in text Easy to use
and use these 2 buttons (tab Start -
group Paragraph) Good knowledge of CFD is still necessary
• Open-sourced codes
Large user community
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
32 Introduction to CFD (4RC30)