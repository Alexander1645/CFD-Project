# Smoke grenade combustion model (4RC30 final assignment)

2-D transient simulation of the combustion of a KNO3/sucrose ("KNSu") smoke
composition inside a grenade canister, and of the hot smoke venting through
the hole in the left wall. Built on the course base code
(`ProjectInfo/code_final_assignment`, transient SIMPLE of Versteeg &
Malalasekera ch. 8.7.1) — **not** on the earlier `smoke_grenade` attempt.

```
   ______________________________
  |##############################|      # = solid KNO3/sugar composition
 =| hole                         |      (fills the canister, x > XGAP)
 =| ->out   ignition kernel      |
  |______________________________|      left gap = igniter pocket
```

Domain: 0.12 m x 0.06 m canister interior, hole (12 mm) in the left wall
near the top, per the problem-description sketch.

## Physics

| Ingredient | Treatment | Source |
|---|---|---|
| Flow | **Laminar**, transient SIMPLE, staggered grid, hybrid scheme, TDMA | base code `code_final_assignment` (k-eps removed) |
| Heat transfer | Transport eq. for T with Gamma = k/cp, harmonic-mean conduction | base `Tcoeff.m`, extended with reaction heat source |
| Species | Transport eqs. for m_fu (sucrose), m_ox (KNO3), m_k2 (K2CO3); product gas m_pr = 1 - sum | Lecture 6 species framework |
| Reaction rate | Single-step **kinetic (Arrhenius)** rate — the correct choice for laminar flow: Lecture 6 says the slowest timescale governs, and without turbulence there is no eddy break-up (micro-mixing) timescale | Lecture 6, "eddy break-up with reaction" limit `-R_fu,kinetic` |
| Solid before combustion | **One-phase** pseudo-solid: velocity faces **between two solid cells** (both with sf = m_fu+m_ox above `SFPIN`) get SP = -LARGE (pinned to 0) and the viscosity blends to `MUSOLID` = 1e3 Pa s, so the "gas" behaves as a solid. Faces between a burning cell and a gas cell stay free, so the produced gas can vent through the burning surface against the large viscosity — pinning them too would leave the expansion no escape path and the pressure correction would diverge | user requirement |
| Gas generation | Mixture density rho = sf·RHOS + (1-sf)·rho_ga, with the gas/aerosol share rho_ga mixed volumetrically (1/rho_ga from m_k2/RHOP and m_pr/rho_gas(T)). The **linear** blend in sf releases the ~150x expansion evenly over the burn of a cell (a strict volume-weighted mix would release it all at the first whiff of gas and destabilise the solver; physically, the gas stays compact in the pores of the char until the matrix is consumed). The change `(rho_old - rho)/Dt * V` enters the pc equation as a mass source. The hole velocity follows from global continuity (all generated gas must leave) — there is no prescribed inlet — and is under-relaxed (`relax_uh`), because it is a stiff global feedback between every cell's density and one boundary condition | continuity, `pccoeff.m`/`bound.m` |
| Ignition | Initial hot pocket (`TIGN` = 1300 K) at the propellant surface **next to the hole** — the igniter charge. **No forced combustion**: at 300 K the Arrhenius factor is ~1e-16, the reaction only runs where the mixture has been heated, and the front self-propagates by conduction | user requirement |
| Walls | **Conducting, NOT adiabatic**: every casing segment is a lumped thermal mass (steel, 1 mm) heated by conduction from the adjacent cell and cooled by external natural convection (`walltemp.m`). The T boundary nodes carry the casing temperatures | user requirement (deviates deliberately from the "adiabatic right wall" in the original problem sketch) |

### Chemistry

Balanced smoke reaction (mass-checked):

```
48 KNO3 + 5 C12H22O11 -> 24 K2CO3 + 36 CO2 + 55 H2O + 24 N2
```

Per kg sucrose: consumes s = 2.836 kg KNO3, produces 1.938 kg K2CO3 (the
smoke particulate) + 1.898 kg gas (mean molar mass 28.2 g/mol).
Stoichiometric composition = 73.9 wt% KNO3; commercial smoke mixes are
fuel-rich (60-65 wt%) precisely to keep the flame below the K2CO3
vaporisation limit of 891 C = 1164 K — that is research question 2.

Rate: `R_fu = AK * rho * m_fu * m_ox * exp(-EA/(R T))`, saturated at
`RMAXF*rho` (a *fractional* ceiling [1/s] — an absolute ceiling would keep
heating a nearly burnt-out, low-density cell at full power and run its
temperature away) and limited to the reactants available in a cell per
time step. Fuel and oxidiser consumption are treated implicitly (SP < 0)
so mass fractions stay bounded. Reported K2CO3 production = domain
inventory + what has vented through the hole (both from the transported
mk2 field, so it is consistent with the species equations).

## Deliberate simplifications (state these in the report)

* **RHOS = 50 kg/m3 is scaled down** from the real pressed density
  (~1900 kg/m3). Real KNSu burns at mm/s, i.e. a ~1 minute burn — unreachable
  with an explicit-in-time SIMPLE code at CFL-limited time steps. Scaling the
  solid density shortens the burn to O(seconds) while keeping the physics
  (density collapse -> gas generation -> venting) intact. Burn duration and
  absolute K2CO3 masses scale ~linearly with RHOS; *trends vs. composition do
  not*, which is what the research questions ask.
* Kinetic parameters (AK, EA, RMAXF) are order-of-magnitude/tuned, not
  measured; EA = 80 kJ/mol gives an ignition threshold around 700 K and,
  with the fractional rate ceiling RMAXF = 4 1/s, a cell burn time of
  ~70-90 ms.
* **KSOL = 4 W/(m K) is an *effective* solid conductivity** (real pressed
  KNSu: ~0.4). The laminar flame thickness sqrt(alpha·t_burn) must span
  >~ 1 grid cell or the front quenches numerically; the raised value keeps
  the front resolvable on a 2-3 mm grid (front speed ~2-3 cm/s) and can be
  read as lumping radiative/dispersive preheating into conduction.
* Density and hole-velocity updates are under-relaxed (`relax_rho`,
  `relax_uh`) — both couple back into the pressure correction and
  oscillate if applied unrelaxed.
* Low-Mach: density from p_atm (pressure only appears via gradients).
* Single cp for solid/gas/particulate; no radiation; K2CO3 aerosol moves
  with the gas; 2-D planar (quantities are per metre of depth).
* Laminar assumption: Re at the hole ~ O(1000) based on the vent velocity
  and hole size — reasonable, and required by the assignment scope.

## Files

| File | Provenance |
|---|---|
| `grenade.m` | main script — structure of `transient05.m` |
| `init.m`, `convect.m`, `derivatives.m`, `velcorr.m`, `solve.m` | base code (derivatives: turbulence terms dropped; solve: identical copy) |
| `ucoeff.m`, `vcoeff.m` | base code, laminar + solid pinning + variable-density time terms |
| `pccoeff.m` | base code + mass-storage source `(rho_old-rho)/Dt*V` |
| `Tcoeff.m` | base code + reaction heat source, conducting-wall boundary nodes |
| `scacoeff.m` | new, but discretisation identical to `Tcoeff.m` (Lecture 6 species eq.) |
| `reaction.m` | Arrhenius kinetics (Lecture 6) |
| `mixprops.m` | replaces `viscosity.m`: one-phase mixture properties |
| `bound.m` | walls + hole outflow from global continuity |
| `walltemp.m` | lumped conducting casing |
| `plotresults.m` | style of `ProjectInfo/contourfplots.m` |
| `sweep_composition.m` | runs research-question sweep over x_KN |

## Running

Single run (defaults: x_KN = 0.65, 60x30 grid, Dt = 2e-5 s, 0.5 s):

```matlab
cd grenade_model
grenade
```

Any knob can be set beforehand (the script does not clear the workspace):

```matlab
clear; xKN = 0.739; TOTAL_TIME = 1.0; NPI_in = 60; NPJ_in = 30; grenade
```

Quick look (~minutes): `clear; NPI_in = 40; NPJ_in = 20; Dt_in = 6e-5; TOTAL_TIME = 0.1; MAXIT_in = 12; PCIT_in = 10; grenade`

Overridable knobs: `xKN`, `TOTAL_TIME`, `Dt_in`, `NPI_in`, `NPJ_in`,
`MAXIT_in` (outer iterations), `PCIT_in` (pc inner iterations), `RUNTAG`,
`PLOTS`.

Composition sweep for the research questions: `sweep_composition`.

Outputs land in `runs/<RUNTAG>/`: `results.mat` (history + final fields),
`fields.png`, `history.txt` (per-step: outlet velocity, outlet gas
temperature vs. the 1164 K limit, K2CO3 produced, solid remaining, casing
temperature).

Note: the full default run is ~25k time steps of a MATLAB SIMPLE loop —
expect it to take on the order of an hour. Use the coarse settings above for
shakedown tests.
