12-8-2019
IntroductiontoCFD(4RM00)
THE LID-DRIVEN CAVITY PROBLEM
Marie CURIE1, Albert EINSTEIN2
1student ID: 123456 E-mail: M.Curie@student.tue.nl
2student ID: 789012 E-mail: A.Einstein@student.tue.nl
GROUP NUMBER: 42
ABSTRACT
The lid-driven cavity is a benchmark problem for incompressible
viscousflowsexhibitingboundarydrivenshear,recirculation,sec-
ondaryvorticesandtransitiontoturbulence.Thisstudyimplements
alowRek–turbulencemodelwithinafinitevolumeframeworkus-
ingastaggeredgridandtheSIMPLEpressurevelocitycoupling.A
hybriddifferencingschemeandthenear-wallregionisresolveddi-
rectlywiththefirstgridpointplacedaty+ 0.67. Simulationswere
performedforRe=100,10005000,andadditionalcasesexplored
parallelandanti-parallelwallmotion.Resultsshowtheexpectedre-
sultsthattheprimaryvortexshiftsandstrengthenswithincreasing
Re,secondaryandtertiaryeddiesintensify.Centerlinevelocitypro-
filesarecomparedwithbenchmarkdatafromGhiaetal.tovalidate
themodel.
Keywords: Liddrivencavity,Reynoldsnumber,Vortices,Turbu-
lence.
Figure1:Thelid-drivencavityproblem.
INTRODUCTION
The lid-driven cavity is a well-known benchmark problem ofroughwallsandsurfacemassinjectionwhichcanbeused
for viscous incompressible fluid flow, which deals with a in the new model without change. The k–omega model,
square cavity consisting of three rigid walls with no-slip likemanyturbulencemodels,hasbeencriticizedfornotac-
conditions and a lid moving with a tangential unit velocity. curately reproducing the asymptotic behavior of turbulence
Sincethelid-drivencavityproblemisextensivelystudied,it near walls. However, the Taylor series expansion underly-
can be used to validate other CFD methods. Theoretically, ingtheanalysisisvalidonlyintheimmediatewallvicinity,
(Batchelor,1956)pointedoutthatlid-drivencavityflowsex- whereeddyviscosityismuchsmallerthanmolecularviscos-
hibitalmostallthephenomenathatcanoccurinincompress- ity.Consequently,themeanflowprofileandwallshearstress
ible flows: eddies, secondary flows, complex flow patterns, remainlargelyunaffected,evenifthemodellacksasymptotic
chaotic particle motions, instability, and turbulence. Prac- consistency. Anotherlimitationofthek–omegamodelisits
tical applications are in material processing, metal casting, imperfect prediction of k and ε distributions compared with
galvanizing,andinsomefoodprocessingindustries. DNS data. It can be argued, however, that since mean flow
Figure1showsthelid-drivencavityproblem. Inthebaseline solver depends primarily on the eddy viscosity, improved
case, top wall, i.e. the lid, is moved with velocity U, while DNS fitting of k and ε does not necessarily yield a better
other walls of the cavity remain stagnant. The characteris- eddy-viscositydistribution. Thus,agreementwithDNSdata
ticformationofeddiesinthecornersofthecavityisshown may only be up for interpretation. In the viscous sublayer,
(Poochinapan, 2012) Differently to other two-equation tur- Wilcoxinterpretedkasproportionaltothewall-normalcom-
bulence models, the k-omega model does not use damping ponent of the turbulent kinetic energy, producing excellent
functions and enables simple Dirichlet boundary conditions agreement with experimental and DNS results. When DNS
tobeimplemented. Thek-omegamodelissuperiortoother conformityisrequired,thedampingfunctionsdevelopedby
modelsinitssimplicityandthattranslatesintoitsnumerical Wilcox may be applied to enhance the model’s accuracy.
stability. Ithasbeenshownthatthek-omegamodelisasac- (Menter,1994)Thestandardk-omegamodelcanbeusedall
curate as any other model at predicting mean flow profiles. thewaytothewallwithoutanymodifications. However,the
Wilcoxhasdevelopedmodificationsthatallowthetreatment boundary condition for omega at walls is a problem since
1

|     |     |     | S.Hegde, | M.Rump |     |     |     |     |     |     |     |     |
| --- | --- | --- | -------- | ------ | --- | --- | --- | --- | --- | --- | --- | --- |
Table1:ListofSymbols ing it to accurately represent transition phenomena and ac-
|        |                         |     |     | countforsurfaceroughnesseffects.  |     |     |     |     |     | Thesecapabilitieshave |     |     |
| ------ | ----------------------- | --- | --- | --------------------------------- | --- | --- | --- | --- | --- | --------------------- | --- | --- |
| Symbol | Description             |     |     | beenvalidatedinsubsequentstudies. |     |     |     |     |     |                       |     |     |
| L      | Characteristiclength(m) |     |     | (refimportantpaper)               |     |     |     |     |     |                       |     |     |
| U      | Lidvelocity(m/s)        |     |     |                                   |     |     |     |     |     |                       |     |     |
MODELDESCRIPTION
| u,u | Velocitycomponents(m/s) |     |     |     |     |     |     |     |     |     |     |     |
| --- | ----------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
i j
u Maximumvelocity(m/s) Wilcox’sk-omegaModelGoverningEquations
max
| u τ | Frictionvelocity(m/s) |     |     |     |     |     |     |     |     |     |     |     |
| --- | --------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
ThegoverningequationsforWilcox’sk-omegamodel(Peng
| p   | Pressure(Pa)   |     |     |     |            |     |       |       |             |     |          |           |
| --- | -------------- | --- | --- | --- | ---------- | --- | ----- | ----- | ----------- | --- | -------- | --------- |
|     |                |     |     | et  | al., 1997) | are | given | below | considering |     | a steady | state in- |
| ρ   | Density(kg/m3) |     |     |     |            |     |       |       |             |     |          |           |
compressibleflowwithBoussinesq’shyphothesis.
| µ   | Dynamicviscosity(Pa·s)       |     |     | Masscontinuity |     |     |     |       |     |     |     |     |
| --- | ---------------------------- | --- | --- | -------------- | --- | --- | --- | ----- | --- | --- | --- | --- |
| µ   | Turbulenteddyviscosity(Pa·s) |     |     |                |     |     |     | ∂(ρu) |     |     |     |     |
| t   |                              |     |     |                |     |     |     |       | i   |     |     |     |
| ν   | Kinematicviscosity(m2/s)     |     |     |                |     |     |     |       | =0  |     |     | (3) |
∂x
|     | Turbulentkineticenergy(m2/s2) |     |     |     |     |     |     |     | i   |     |     |     |
| --- | ----------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
k
Momentumequation
| ω   | Specificdissipationrate(1/s)     |     |     |     |     |       |     |     |     |          |     |          |
| --- | -------------------------------- | --- | --- | --- | --- | ----- | --- | --- | --- | -------- | --- | -------- |
| ε   | Turbulencedissipationrate(m2/s3) |     |     |     |     |       |     |     |     |          |     |          |
|     |                                  |     |     |     |     | ∂(ρuu | )   | ∂p  | ∂   | (cid:20) | ∂u  | (cid:21) |
|     |                                  |     |     |     |     |       | i j |     |     |          | i   |          |
| τ w | Wallshearstress(Pa)              |     |     |     |     |       | =−  |     | +   | (µ+µ     | t ) | (4)      |
|     |                                  |     |     |     |     | ∂x    |     | ∂x  | ∂x  |          | ∂x  |          |
| y   | Wall-normaldistance(m)           |     |     |     |     |       | j   | i   | j   |          | j   |          |
| y+  | Non-dimensionalwalldistance(-)   |     |     |     |     |       |     |     |     |          |     |          |
Turbulentkineticenergy,k
| x,x | Spatialcoordinates(m) |     |     |     |     |     |     |     |     |     |     |     |
| --- | --------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
i j
|     |                           |     |     |     |      |     |            |     |     | (cid:20)(cid:18) | (cid:19) | (cid:21) |
| --- | ------------------------- | --- | --- | --- | ---- | --- | ---------- | --- | --- | ---------------- | -------- | -------- |
| ∆x  | Gridspacing(m)            |     |     |     | ∂(ρu | k)  |            |     | ∂   |                  | µ        | ∂k       |
|     |                           |     |     |     |      | j   | =P −β∗ρωk+ |     |     | µ+               | t        |          |
| ∆x  | Minimumgridspacing(m)     |     |     |     |      |     | k          |     |     |                  |          | (5)      |
| min |                           |     |     |     |      | ∂x  |            |     | ∂x  |                  | σ        | ∂x       |
| ∆t  | Timestep(s)               |     |     |     |      | j   |            |     |     | j                | k        | j        |
| ∆F  | Netconvectiveflux(varies) |     |     |     |      |     |            |     |     |                  |          |          |
Specificdissipationrateofk
| Re  | Reynoldsnumber(-)                             |     |     |     |      |      |          |     |     |                  |          |          |
| --- | --------------------------------------------- | --- | --- | --- | ---- | ---- | -------- | --- | --- | ---------------- | -------- | -------- |
|     |                                               |     |     |     |      |      |          |     |     | (cid:20)(cid:18) | (cid:19) | (cid:21) |
| N   | Courant-Friedrichs-Lewynumber(-)              |     |     |     | ∂(ρu | ω)   | ω        |     | ∂   |                  | µ        | ∂ω       |
| CFL |                                               |     |     |     |      | j =α | P −βρω2+ |     |     | µ+               | t        | (6)      |
| P   | Productionofturbulentkineticenergy(kg/(m·s3)) |     |     |     |      |      | k        |     |     |                  |          |          |
| k   |                                               |     |     |     | ∂x   | j    | k        |     | ∂x  | j                | σ ω      | ∂x j     |
| S u | Sourceterm(varies)                            |     |     |     |      |      |          |     |     |                  |          |          |
S Linearizedsourcetermcoefficient(varies) ProductionofkineticenergyPk
p
| S   | Maximumresidual(-)     |     |     |     |     |     |      |          |      |          |     |     |
| --- | ---------------------- | --- | --- | --- | --- | --- | ---- | -------- | ---- | -------- | --- | --- |
| MAX |                        |     |     |     |     |     |      | (cid:18) |      | (cid:19) |     |     |
| S   | Averageresidual(-)     |     |     |     |     |     |      | ∂u       | ∂u   | ∂u       |     |     |
| AVG |                        |     |     |     |     |     | P =µ |          | i +  | j        | i   | (7) |
|     |                        |     |     |     |     |     | k    | t        |      |          |     |     |
| a p | Centralcoefficient(-)  |     |     |     |     |     |      | ∂x       | j ∂x | i ∂x     | j   |     |
| a   | Neighborcoefficient(-) |     |     |     |     |     |      |          |      |          |     |     |
nb
| a0  | Pseudo-transientcoefficient(-) |     |     | Turbulenteddyviscosityµ |     |     |     | t   |     |     |     |     |
| --- | ------------------------------ | --- | --- | ----------------------- | --- | --- | --- | --- | --- | --- | --- | --- |
p
| φ   | Generaltransportvariable(varies) |     |     |     |     |     |     |     |     |     |     |     |
| --- | -------------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
ρk
| α   | Modelconstant(-) |     |     |     |     |     |     | µ =α∗ |     |     |     | (8) |
| --- | ---------------- | --- | --- | --- | --- | --- | --- | ----- | --- | --- | --- | --- |
|     |                  |     |     |     |     |     |     | t     | ω   |     |     |     |
| α∗  | Modelconstant(-) |     |     |     |     |     |     |       |     |     |     |     |
β Modelconstant(-) The values for default Wilcox’s model constants are set as
β∗ Modelconstant(-) α∗=1.0,β∗=0.09,α=0.56,β=0.075,andσ =σ =2.0.
|     |                               |     |     |               |     |     |     |     |     |     | k   | ω   |
| --- | ----------------------------- | --- | --- | ------------- | --- | --- | --- | --- | --- | --- | --- | --- |
| σ   | TurbulentPrandtlnumberfork(-) |     |     | (refChalmers) |     |     |     |     |     |     |     |     |
k
| σ   | TurbulentPrandtlnumberforω(-) |     |     |     |     |     |     |     |     |     |     |     |
| --- | ----------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
ω
ModelImplementation
| c ω2 | Modelconstant(-) |     |     |     |     |     |     |     |     |     |     |     |
| ---- | ---------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
L Referencelengthscale(m) A Hybrid Differencing Scheme, which switches between
ref
|     |     |     |     | central      | differencing |      | for | small | Peclet | numbers |         | and upwind |
| --- | --- | --- | --- | ------------ | ------------ | ---- | --- | ----- | ------ | ------- | ------- | ---------- |
|     |     |     |     | differencing |              | when | the | local | Peclet | number  | is high | is used    |
omegaapproachesinfinity.
|     |     |     |     | in        | this study. |                   | The scheme |     | is conservative, |            | bounded, | and     |
| --- | --- | --- | --- | --------- | ----------- | ----------------- | ---------- | --- | ---------------- | ---------- | -------- | ------- |
|     |     |     |     | satisfies |             | transportiveness. |            | For | the              | lid-driven | cavity   | flow at |
ε
|     | ω=  | =O(y−2) | (1) |     |     |     |     |     |     |     |     |     |
| --- | --- | ------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
β∗k low to moderate Reynolds numbers, the flow field contains
bothdiffusion-dominatedregions(nearthewallsandwithin
|     |     |     |     | the | viscous | sublayer) |     | and | convection-dominated |     |     | regions |
| --- | --- | --- | --- | --- | ------- | --------- | --- | --- | -------------------- | --- | --- | ------- |
Near-wallboundaryconditionforomegaisderivedas.
|     |     |     |     | (such      | as  | the lid | shear | layer).   | The | HDS       | provides | a safe     |
| --- | --- | --- | --- | ---------- | --- | ------- | ----- | --------- | --- | --------- | -------- | ---------- |
|     |     | 6ν  |     | compromise |     | between |       | stability | and | accuracy, |          | being less |
|     | ω=  |     | (2) |            |     |         |       |           |     |           |          |            |
c y2 prone to numerical instabilities, and is therefore suitable
ω2
|     |     |     |     | for | establishing |     | a stable | baseline |     | case. | However, | in cells |
| --- | --- | --- | --- | --- | ------------ | --- | -------- | -------- | --- | ----- | -------- | -------- |
In standard implementations of the k-omega turbulence wherethelocalPecletnumberishigh,theschemerevertsto
model,thespecificdissipationrateωistypicallynotsolved upwind differencing, which is first-order accurate, and the
directly in the near-wall region. For y+ <1.0, ω is instead associatedtruncationerrorisalsofirstorder. Asaresult,fine
computed from the analytical relation above, thereby elim- flow features such as small vortices may be under-resolved
inating the need for an explicit boundary condition. This compared to what could be achieved using a higher-order
| approach | is particularly effective | in finite volume | methods | scheme. |     |     |     |     |     |     |     |     |
| -------- | ------------------------- | ---------------- | ------- | ------- | --- | --- | --- | --- | --- | --- | --- | --- |
(FVM).However,infiniteelementmethods(FEM),thevalue
ofωatthewallmustbeexplicitlyspecified,requiringamod- A staggered grid arrangement was used, in which velocity
ifiedtreatmenttoensurenumericalconsistencyandstability. components are stored at the cell faces and pressure at the
Wilcoxlaterproposedalow-Reynolds-numberversionofthe cellcentres,toensureproperpressure–velocitycouplingand
k-ωmodelincorporatingviscousdampingfunctions, allow- toavoidnon-physicaloscillationscommonlyassociatedwith
2

TheLid-DrivenCavityProblem/12-8-2019
colocatedgrids.Thepressure–velocitycouplingwashandled
usingtheSIMPLE(algorithm.Inthismethod,theconvective
fluxesperunitmassthroughthecellfacesareevaluatedus-
ing guessed velocity components, while a guessed pressure
fieldisusedtosolvethemomentumequations. Apressure-
correctionequation,derivedfromthecontinuityequation,is
then solved to obtain a pressure-correction field, which is
subsequentlyusedtoupdatethevelocityandpressurefields.
Theiterativeprocessbeginswithinitialguessesfortheveloc-
ityandpressure,whichareprogressivelyimprovedastheal-
gorithmproceeds. Theiterationscontinueuntilconvergence
of the velocity and pressure fields is achieved, providing
a consistent and stable framework for solving incompress-
Figure2:Residualconvergencecomparison.
ible flows. The solver operates in a semi-implicit, pseudo-
transient manner, and the general form of the discretized
equations is given in Equation 9 and 10. The discretized
equationsaresolvedusingaTDMAsolveruntiltheconver-
L=1m, ρ=1kg/m3, µ=2×10−5Pa·s,
gencecriteriaaresatisfied. U =1m/s, y=0.003m
a p φ p =∑a nb φ nb +a0 p φ0 p +S u (9) ν= µ =2×10−5m2/s
ρ
a =∑a +a0+∆F−S (10)
p nb p p
U
LaminarFlow τ =µ =2×10−5Pa
w
L
Initially, a laminar lid-driven cavity flow was simulated at
R rie e d yn o o u l t ds fo n r u d m if b fe e r r e s n o t f w 1 a 0 l 0 lm an o d tio 1 n 00 c 0 a . se S s i — mu w la i t t i h on th s e w t e o r p e w ca a r l - l u τ = (cid:114) τ w = (cid:112) 2×10−5=4.472×10−3m/s
ρ
movingalone,withboththetopandbottomwallsmovingin
parallel and opposite directions to observe how vortices de- u y (4.472×10−3)(0.003)
velopundervaryingflowconditionsbeforemovingontothe y+= τ = =0.67
ν 2×10−5
turbulentcases. Ameshindependenceandconvergencecri-
teriastudywasconductedusingthesteady-statelaminarcode
forRe=100. Itwastestedthatneitherafurtherrefinement
Thusy+=0.67issuitableforlow-Rek−ωmodel.
of the grid nor refining the convergence criteria, i.e. reduc-
ingthesizeoferrorresidualsS andS ,wouldhavea
MAX AVG Toaccelerateconvergenceandreducecomputationalcost,a
measurableeffectontheresult,bothmathematicallyaswell
non-uniformgridwasemployed. Thetimestep(∆t=0.003)
asvisuallyintermsoftheflowprofile. Asthefirststep,the
wasdeterminedbasedontheCFLstabilitycriterion.
convergence criteria was refined from S =1×10−8 &
MAX
S =1×10−9toS =1×10−10&S =1×10−11,
AVG MAX AVG
anditwasidentifiedthatresultsdonothaveasignificantvari- u ∆t 1·∆t
ationbeyondS MAX =1×10−9&S AVG =1×10−10. Then,a N CFL = ∆ m x ax = 0.003 =1 ⇒ ∆t=0.003s (11)
gridindependencestudywasdone,increasinginincrements min
from16×16to128×128.Finally,64×64waschosenasthe Inbound.m, theparabolicinletvelocityprofile, aswellas
mesh refinement of the test domain for laminar flow cases. the definitions for k and ε, were removed, along with the
Since, no measurable change in the results was provided globalmasscontinuitycondition,sincethecavityhasnoin-
by further refinement, while it increased number of neces- let or outlet unlike the channel flow. A no-slip boundary
saryiterationsandcomputingtimesignificantly. Conversely, condition with k =0 was applied at all walls, and the top
coarser grids were not used for the visual flow profile, es- wall velocity was specified to drive the shear-induced mo-
peciallyinthecornersremainedinaccurate. Residualswere tion. In ucoeff.m, the wall functions were removed and
settoS MAX =1×10−10 &S AVG =1×10−11 astoensured thesourcetermsweremodifiedtorepresentnear-walleffects
thesmallcornervorticeswouldreachahighlevelofdetail. consistentwiththelow-Rek-ωformulation. Inkcoeff.m
For validation, a simulation in Ansys Fluent using QUICK andomegacoeff.m,thediffusiontransportequationswere
wasusedtofindagreementwithwhatcanbeconsideredthe updated, and source terms derived from the linearized k-ω
“right”result. Thegridindependenceandconvergencestudy governing equations were introduced. A near-wall approxi-
isshowninFigure??. mation of ω was also implemented using a source-term ap-
proach. Ininit.m,thegridwasinitializedwithalowtur-
TurbulentFlow
bulentkineticenergy,k=1×10−6,andεwasestimatedfrom
Following the laminar simulations, a turbulent lid-driven
therelation √
cavity flow was simulated by modifying the provided k-ε
k
codetoimplementthelow-Rek-ωmodel. Theviscositywas ε= .
β∗0.25L
updatedaccordingtoEquation8,andthespecifick-ωmodel ref
constants were defined, with the computational domain set The turbulent base case was simulated at Re = 5000 and
to a square cavity in maincode.m. Since the low-Re k- validated against results from (Ghia et al., 1982), after
ωmodelresolvesthenear-wallregiondirectly,thefirstgrid which additional simulations were performed for parallel
point was positioned within the viscous sublayer, ensuring andanti-parallelwallmotionconfigurations.
y+=0.67.
3

|     |     |     |     |     |     | S.Hegde, | M.Rump |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | -------- | ------ | --- | --- | --- | --- | --- |
RESULTS shiftoftheinflectionpoint,reflectingthinnerboundarylay-
|     |     |     |     |     |     |     | ersandadisplacedvortexcore(Fig.7). |     |     |     | AtRe=5000along |     |
| --- | --- | --- | --- | --- | --- | --- | ---------------------------------- | --- | --- | --- | -------------- | --- |
StandardLid-DrivenCavityatRe=100,1000,5000
|     |     |     |     |     |     |     | high–speed | plateau | forms | beneath | the | lid with very sharp |
| --- | --- | --- | --- | --- | --- | --- | ---------- | ------- | ----- | ------- | --- | ------------------- |
Streamlines. At Re = 100 a single primary vortex leans wallgradients,evidencingstrongconvectionandthinviscous
towards the right top corner, occupying the cavity while sublayers(Fig.8).
| corners                | remain    | weak           | as the                          | eddies      | are starting | to de-         |     |     |     |     |     |     |
| ---------------------- | --------- | -------------- | ------------------------------- | ----------- | ------------ | -------------- | --- | --- | --- | --- | --- | --- |
| velop (Fig.            | 3).       | At Re          | = 1000                          | the primary | cell         | shifts up-     |     |     |     |     |     |     |
| ward/rightward         | and       | secondary      |                                 | eddies      | strengthen,  | introduc-      |     |     |     |     |     |     |
| ing clear              | asymmetry | in             | east to west                    | (Fig.       | 4).          | At Re=5000     |     |     |     |     |     |     |
| the deformation        |           | is pronounced: |                                 | the primary |              | vortex is dis- |     |     |     |     |     |     |
| placed only            | slightly  | toward         | the                             | lid–driven  | corner       | while be-      |     |     |     |     |     |     |
| comingmoresymmetrical. |           |                | Multiplesecondary/tertiarycells |             |              |                |     |     |     |     |     |     |
| appear,                | including | at the         | north-west                      | corner,     | consistent   | with           |     |     |     |     |     |     |
inertia–dominatedrecirculation(Fig.5).
Figure6:Centerlineu-velocityprofileforRe=100.
Figure3:StreamlinecontoursforRe=100.
Figure7:Centerlineu-velocityprofileforRe=1000.
Figure4:StreamlinecontoursforRe=1000.
Figure8:Centerlineu-velocityprofileforRe=5000.
|     |     |     |     |     |     |     | Centerline      | v/U     | along x/H.       | At       | Re=100     | the vertical ve-  |
| --- | --- | --- | --- | --- | --- | --- | --------------- | ------- | ---------------- | -------- | ---------- | ----------------- |
|     |     |     |     |     |     |     | locity exhibits |         | small amplitudes |          | and an     | almost sinusoidal |
|     |     |     |     |     |     |     | variation       | across  | the cavity       | midline, | indicating | a symmetric       |
|     |     |     |     |     |     |     | recirculation   | pattern | (Fig.            | 9). At   | Re=1000    | the amplitudes    |
|     |     |     |     |     |     |     | increase        | and the | extrema          | shift,   | yielding   | a more asymmetric |
curvethatsignalsstrongerreturnflowandenhancedconvec-
|     |     |     |     |     |     |     | tive transport | (Fig. | 10). | At Re=5000 |     | the asymmetry be- |
| --- | --- | --- | --- | --- | --- | --- | -------------- | ----- | ---- | ---------- | --- | ----------------- |
Figure5:StreamlinecontoursforRe=5000.
comesmarkedwithintensifiedreturnflownearthedescend-
ingwall(Fig.11).
Centerline u/U along y/H. For Re=100 the horizontal Velocity magnitude |u|/U. The Re = 100 field shows
velocityrisessmoothlyfromthebottomwalltothelidwith smooth, broadly spaced contours with maxima confined
modestcurvature,consistentwithdiffusion-dominatedtrans- beneath the moving lid and gentle gradients in the core
port (Fig. 6). For Re=1000 the profile becomes markedly (Fig. 12). At Re=1000 high-speed regions extend fur-
non-linear with steeper near-wall gradients and an upward ther from the lid, contour distortion intensifies near the top
4

TheLid-DrivenCavityProblem/12-8-2019
| corners,      | and gradients |            | are much | sharper  | across        | the core |
| ------------- | ------------- | ---------- | -------- | -------- | ------------- | -------- |
| (Fig. 13),    | all           | consistent | with     | stronger | inertia and   | thinner  |
| shear layers. | At            | Re=5000    | sharp    | shear    | bands develop | un-      |
derthelidandalongtherightwall,andthehigh-speedpath
penetratesdiagonallyintothecore(Fig.14).
Figure9:Centerlinev-velocityprofileforRe=100.
Figure12:VelocitymagnitudecontoursforRe=100.
Figure13:VelocitymagnitudecontoursforRe=1000.
Figure10:Centerlinev-velocityprofileforRe=1000.
Figure14:VelocitymagnitudecontoursforRe=5000.
| u/U       |        | Re        | =100          | u-contours |           |          |
| --------- | ------ | --------- | ------------- | ---------- | --------- | -------- |
| contours. |        | For       |               | the        | are       | broadly  |
| spaced    | in the | core with | near–symmetry |            | about the | vertical |
midline;contourclusteringisconfinedtothinlayersbeneath
| the lid and       | along     | the side | walls      | (Fig.      | 15). At Re   | = 1000    |
| ----------------- | --------- | -------- | ---------- | ---------- | ------------ | --------- |
| strong clustering |           | develops | under      | the moving | lid          | and adja- |
| cent to           | the right | wall;    | the high–u | section    | tilts toward | the       |
lid–drivencornerandthenear–wallgradientsintensify,con-
sistentwiththinnerboundarylayersandadisplacedprimary
| vortex (Fig. | 16). | At Re=5000 |     | a strongly | elongated | high- |
| ------------ | ---- | ---------- | --- | ---------- | --------- | ----- |
Figure11:Centerlinev-velocityprofileforRe=5000. usectionformsbeneaththelidwithintensegradientsatthe
lid–walljunction(Fig.17).
| v/U contours. |         | At Re  | = 100 | the v-field | exhibits     | weak, |
| ------------- | ------- | ------ | ----- | ----------- | ------------ | ----- |
| smoothly      | varying | upwash | on    | the left    | and downwash | on    |
5

S.Hegde, M.Rump
| the right,   | with nearly | symmetric                |     | bands           | across | the cav- |
| ------------ | ----------- | ------------------------ | --- | --------------- | ------ | -------- |
| ity (Fig.    | 18). At Re  | = 1000                   | the | upwash/downwash |        | re-      |
| gions become | more        | pronounced               |     | and localized,  |        | forming  |
| steeper jets | near the    | top corners—particularly |     |                 | the    | descend- |
ingsidewall—reflectingenhancedsecondarymotionandin-
| ertia–dominated | transport     | (Fig. | 19).       | At Re=5000 |     | narrow     |
| --------------- | ------------- | ----- | ---------- | ---------- | --- | ---------- |
| high-gradient   | jets develop, |       | especially | along      | the | descending |
sidewall,signalingvigoroussecondarycirculation(Fig.20).
Figure15:U-velocitycontoursforRe=100.
Figure18:V-velocitycontoursforRe=100.
Figure19:V-velocitycontoursforRe=1000.
Figure16:U-velocitycontoursforRe=1000.
Figure20:V-velocitycontoursforRe=5000.
| Turbulence         | diagnostics   | at                                | Re=5000. |       | Turbulent   | kinetic |
| ------------------ | ------------- | --------------------------------- | -------- | ----- | ----------- | ------- |
| energy k           | peaks beneath | the                               | moving   | lid   | and extends | diag-   |
| onally along       | the primary   | shear                             | layer,   | while | remaining   | low     |
| elsewhere(Fig.21). |               | Thespecificdissipationrateωismax- |          |       |             |         |
imalinthesameshear-dominatedregions,confirminglocal-
| ized production | and | dissipation | tied | to the | lid-driven | layer |
| --------------- | --- | ----------- | ---- | ------ | ---------- | ----- |
(Fig.22).
Figure17:U-velocitycontoursforRe=5000.
| Parallel | and Anti-Parallel |     | Lid-Driven |     | Cavity | at Re = |
| -------- | ----------------- | --- | ---------- | --- | ------ | ------- |
5000
Thelid-drivencavityconfigurationwasfurtherexaminedun-
| der two | distinct top-wall | motion |     | conditions—parallel |     | and |
| ------- | ----------------- | ------ | --- | ------------------- | --- | --- |
6

TheLid-DrivenCavityProblem/12-8-2019
Figure21:TurbulentkineticenergykcontoursforRe=5000.
Figure24:StreamlinecontoursforRe=100(Anti-Parallel).
Figure22:SpecificdissipationrateωcontoursforRe=5000.
anti-parallel—to assess the influence of opposing shear di-
rections on flow development at varying Re. This compar-
ison highlights how the interaction between multiple mov- Figure25:StreamlinecontoursforRe=1000(Parallel).
ing boundaries alters the primary recirculation pattern, ve-
locity profiles, turbulence generation and dissipation within
thecavity. ForRe=5000,thetotaltimeremainsT =50sas
for the base case, and laminar cases are run up to a limit of
2000iterations. Theresultsareshownbelow.
Figure26:StreamlinecontoursforRe=1000(Anti-Parallel).
Figure23:StreamlinecontoursforRe=100(Parallel).
ValidationagainstGhiaetal.
Tovalidatethenumericalsolver,thecomputedcenterlineu-
velocitydistributionswerecomparedwiththebenchmarkre-
sults of (Ghia et al., 1982) for the lid-driven cavity flow at
Reynolds numbers Re = 100, 1000, and 5000. The com-
parisonwasmadealongtheverticalcenterline(x/H =0.5),
whereu/U representsthenon-dimensionalvelocityandy/H
thenormalizedheightofthecavity.
Figures63–65showthatthepresentresultsexhibitveryclose
agreement with the benchmark data for all three Reynolds
numbers. Forthelow-Recase(Re=100), thevelocitydis-
Figure27:StreamlinecontoursforRe=5000(Parallel).
tribution follows the Ghia profile almost perfectly, confirm-
ing that the laminar flow regime is captured accurately. At
7

|     |     |     | S.Hegde, | M.Rump |     |     |     |
| --- | --- | --- | -------- | ------ | --- | --- | --- |
Figure33:Centerlineu-velocityprofileforRe=5000(Parallel).
Figure28:StreamlinecontoursforRe=5000(Anti-Parallel).
Figure29:Centerlineu-velocityprofileforRe=100(Parallel).
|     |     |     |     | Figure34:Centerline | u-velocity profile | for Re = 5000 | (Anti- |
| --- | --- | --- | --- | ------------------- | ------------------ | ------------- | ------ |
Parallel).
| Figure30:Centerline | u-velocity profile | for Re = | 100 (Anti- |     |     |     |     |
| ------------------- | ------------------ | -------- | ---------- | --- | --- | --- | --- |
Parallel).
Figure35:Centerlinev-velocityprofileforRe=100(Parallel).
Figure31:Centerlineu-velocityprofileforRe=1000(Parallel).
|     |     |     |     | Figure36:Centerline | v-velocity profile | for Re = | 100 (Anti- |
| --- | --- | --- | --- | ------------------- | ------------------ | -------- | ---------- |
Parallel).
| Figure32:Centerline | u-velocity profile | for Re = 1000 | (Anti- |     |     |     |     |
| ------------------- | ------------------ | ------------- | ------ | --- | --- | --- | --- |
Parallel).
Figure37:Centerlinev-velocityprofileforRe=1000(Parallel).
8

TheLid-DrivenCavityProblem/12-8-2019
| Figure38:Centerline | v-velocity profile | for Re = 1000 | (Anti- |     |     |     |     |
| ------------------- | ------------------ | ------------- | ------ | --- | --- | --- | --- |
Parallel).
|     |     |     |     | Figure42:Velocity | magnitude contours | for Re = | 100 (Anti- |
| --- | --- | --- | --- | ----------------- | ------------------ | -------- | ---------- |
Parallel).
Figure39:Centerlinev-velocityprofileforRe=5000(Parallel).
Figure43:VelocitymagnitudecontoursforRe=1000(Parallel).
| Figure40:Centerline | v-velocity profile | for Re = 5000 | (Anti- |     |     |     |     |
| ------------------- | ------------------ | ------------- | ------ | --- | --- | --- | --- |
Parallel).
|     |     |     |     | Figure44:Velocity | magnitude contours | for Re = 1000 | (Anti- |
| --- | --- | --- | --- | ----------------- | ------------------ | ------------- | ------ |
Parallel).
Figure41:VelocitymagnitudecontoursforRe=100(Parallel).
Figure45:VelocitymagnitudecontoursforRe=5000(Parallel).
9

S.Hegde, M.Rump
Figure46:Velocity magnitude contours for Re = 5000 (Anti-
Figure50:U-velocitycontoursforRe=1000(Anti-Parallel).
Parallel).
Figure51:U-velocitycontoursforRe=5000(Parallel).
Figure47:U-velocitycontoursforRe=100(Parallel).
Figure52:U-velocitycontoursforRe=5000(Anti-Parallel).
Figure48:U-velocitycontoursforRe=100(Anti-Parallel).
Figure49:U-velocitycontoursforRe=1000(Parallel). Figure53:V-velocitycontoursforRe=100(Parallel).
10

TheLid-DrivenCavityProblem/12-8-2019
Figure58:V-velocitycontoursforRe=5000(Anti-Parallel).
Figure54:V-velocitycontoursforRe=100(Anti-Parallel).
Figure59:TurbulentkineticenergykcontoursforRe=5000(Par-
Figure55:V-velocitycontoursforRe=1000(Parallel). allel).
Figure60:Turbulent kinetic energy k contours for Re = 5000
Figure56:V-velocitycontoursforRe=1000(Anti-Parallel). (Anti-Parallel).
Figure61:SpecificdissipationrateωcontoursforRe=5000(Par-
Figure57:V-velocitycontoursforRe=5000(Parallel).
allel).
11

|                   |             |                 |     | S.Hegde,  | M.Rump |     |     |     |     |     |     |
| ----------------- | ----------- | --------------- | --- | --------- | ------ | --- | --- | --- | --- | --- | --- |
| Figure62:Specific | dissipation | rate ω contours | for | Re = 5000 |        |     |     |     |     |     |     |
(Anti-Parallel). Figure65:CenterlinevelocitycomparisonforRe=5000.
Re=1000,theagreementremainsexcellent,withonlyminor and secondary vortices and showed how their position and
deviations near the center of the cavity, where the primary strengthchangedastheReynoldsnumberincreased. Theve-
vortex becomes more dominant. For the higher Reynolds locityprofilescomparedwellwiththebenchmarkresultsof
| number case | (Re = 5000), | the overall | shape | and turning |           |                   |     |     |                           |     |     |
| ----------- | ------------ | ----------- | ----- | ----------- | --------- | ----------------- | --- | --- | ------------------------- | --- | --- |
|             |              |             |       |             | Ghiaetal. | (Ghiaetal.,1982), |     |     | provingthatthesolvergives |     |     |
points of the velocity profile still match the reference, al- reliable predictions for both laminar and turbulent regimes.
thoughsmalldiscrepanciesarevisibleclosetothetopwall, AthigherReynoldsnumbers,strongercirculationandhigher
whichmayarisefromgridresolutionandnumericaldiffusion
|     |     |     |     |     | turbulenceintensitywereobservednearthemovinglid. |     |     |     |     |     | For |
| --- | --- | --- | --- | --- | ------------------------------------------------ | --- | --- | --- | --- | --- | --- |
effects. futurework,thesolvercanbeextendedtothree-dimensional
Theseresultsconfirmthatthesolverreproducesthecanoni- casesortootherwall-drivengeometriestostudymorecom-
calcavityflowcharacteristicswithgoodaccuracy,validating plexflowpatterns. Itwouldalsobeinterestingtotestdiffer-
boththespatialdiscretizationandboundary-conditionimple-
entturbulencemodels,suchasSSTk–ωorLES,tocompare
| mentation. |     |     |     |     | theiraccuracyandcomputationalcostforthisproblem. |     |     |     |     |     |     |
| ---------- | --- | --- | --- | --- | ------------------------------------------------ | --- | --- | --- | --- | --- | --- |
REFERENCES
BATCHELOR,G.K.(1956).“Onsteadylaminarflowwith
|     |     |     |     |     | closed streamlines |     | at large | Reynolds | numbers”. |     | Journal of |
| --- | --- | --- | --- | --- | ------------------ | --- | -------- | -------- | --------- | --- | ---------- |
FluidMechanics,1,177–190.
|     |     |     |     |     | GHIA, | U., GHIA, | K.N. | and | SHIN, C.T. | (1982). | “High- |
| --- | --- | --- | --- | --- | ----- | --------- | ---- | --- | ---------- | ------- | ------ |
ResolutionsforincompressibleflowusingtheNavier-Stokes
|     |     |     |     |     | equations | and a | multigrid | method”. | Journal | of  | Computa- |
| --- | --- | --- | --- | --- | --------- | ----- | --------- | -------- | ------- | --- | -------- |
tionalPhysics,48(3),387–411.
MENTER,F.R.(1994).“Two-equationeddy-viscositytur-
bulencemodelsforengineeringapplications”.AIAAJournal,
32(8),1598–1605.
|     |     |     |     |     | PENG,        | S.H.,        | DAVIDSON, |            | L. and | HOLMBERG, | S.      |
| --- | --- | --- | --- | --- | ------------ | ------------ | --------- | ---------- | ------ | --------- | ------- |
|     |     |     |     |     | (1997). “The | two-equation |           | turbulence |        | k-ω model | applied |
Figure63:CenterlinevelocitycomparisonforRe=100.
|     |     |     |     |     | to recirculating | ventilation |     | flows”. | International |     | Journal of |
| --- | --- | --- | --- | --- | ---------------- | ----------- | --- | ------- | ------------- | --- | ---------- |
HeatandFluidFlow,18(5),465–475.
|     |     |     |     |     | POOCHINAPAN, |     | K.  | (2012). | “Numerical | implementa- |     |
| --- | --- | --- | --- | --- | ------------ | --- | --- | ------- | ---------- | ----------- | --- |
tionsfor2dlid-drivencavityflowinstreamfunctionformu-
|     |     |     |     |     | lation”. ISRN | Applied | Mathematics, |     | 2012, | 871538. | Article |
| --- | --- | --- | --- | --- | ------------- | ------- | ------------ | --- | ----- | ------- | ------- |
ID871538,17pages.
Figure64:CenterlinevelocitycomparisonforRe=1000.
CONCLUSION
| The lid-driven  | cavity flow    | was simulated     | using         | the low-    |     |     |     |     |     |     |     |
| --------------- | -------------- | ----------------- | ------------- | ----------- | --- | --- | --- | --- | --- | --- | --- |
| Reynolds-number | k–ω turbulence | model             | to understand | the         |     |     |     |     |     |     |     |
| flow behavior   | at different   | Reynolds numbers. |               | The re-     |     |     |     |     |     |     |     |
| sults captured  | the main       | flow structures   | such as       | the primary |     |     |     |     |     |     |     |
12