# Review: accuracy of the 2-D KNSu burn model

Scope: the `smoke_grenade/` model (laminar transient SIMPLE + KNSu combustion). No
code was changed. Findings are grounded in the source files and the saved runs in
`results/`.

## Does the model do what it's supposed to?

Intended: canister starts full of solid charge, ignited at the west tip, burn front
travels east to the adiabatic east wall.

What the code sets up is directionally correct — `init.m` packs the whole interior
with fuel (`Yfu = 1`), the igniter kernel sits on the west wall (`Iig = 2`), the east
wall is adiabatic, and the front in the saved fields does move west→east.

**But the run does not actually show the charge burning to the east wall.** In the
latest 1 s run (`run_20260619_183750_879_xKN65`), at `t = 1.0 s`:

- mean `Yfu` ≈ **0.91** — only ~9% of the charge has burned;
- the front (the T ≈ 600–900 K transition) sits at **x ≈ 0.007–0.013 m** out of
  `XMAX = 0.08 m` — it has crossed ~12% of the canister;
- everything east of x ≈ 0.015 m is still `T = 301 K`, `Yfu = 1.0` — untouched;
- the model's own projected burn time is **~20 s**, but `TOTAL_TIME = 1 s`.

So the simulated window captures only the ignition transient, not the full traverse.
This is the most important accuracy issue: the headline behaviour ("burns toward the
east wall") is asserted but not reached in the run.

## Principal weaknesses

**1. The 2-D "solid" charge is actually modelled as a low-density ideal gas.**
`init.m`/`density.m` give the burning medium `rho ≈ P/RT ≈ 1.18 kg/m³`, `Cp = 1200`,
and gas conductivity (`λ ≈ 0.05 W/m/K`), while the real propellant is `rho_solid =
1800 kg/m³`. The thermal mass, conductivity and density of the charge in the 2-D field
are therefore those of air, not KNSu — off by ~1000× in density. Front speed,
heat-up rate and conduction ahead of the front have no quantitative connection to the
real solid.

**2. Two disconnected burn models.** The 2-D thermal field is driven by a *volumetric
gas-phase Arrhenius* reaction, whereas the gas-generation, chamber pressure and exit
velocity are driven by a *separate 0-D empirical burn-rate law* `r = a·Pⁿ`. By the
author's own note, coupling them makes the 2-D flow blow up, so they're left
decoupled. The smoke/temperature results come from one model and the pressure/venting
from another — they can (and do) tell different stories, and there's no guarantee of
mass/energy consistency between them.

**3. The front speed is set by numerics, not chemistry.** `reaction.m` caps `Rk` at
`0.5/Dt`. In hot cells the reaction is *cap-limited*, so the local burn rate is fixed
by `Dt`, the grid, and the (air) conductivity — not by the kinetics. The Arrhenius
constants (`A = 5e6`, `Ea = 8e4`) are uncalibrated; the docs concede the resulting
rate is "10–20× too fast." Consequence: change `Dt` or the mesh and the burn speed
changes. No grid- or timestep-independence study is included.

**4. Surface deflagration is replaced by a volumetric thermal wave.** A real KNSu
charge burns at a thin regressing surface; here the entire solid is a stationary
reacting continuum with no surface, no regression, and no separate solid/gas energy
equations. This is the root cause of items 1–3 and of why the empirical burn-rate law
had to be bolted on separately.

**5. Flame temperature is imposed, not predicted.** `chemistry.m` computes a raw ΔT_ad
then *rescales it to 1300 K at xKN = 0.65* and caps at 1450 K. So the
temperature-vs-ratio trend — central to the research question about composition — is
largely a modelling choice (anchor + cap), not an independent prediction. Separately,
the field never approaches `Tad = 1598 K` anyway: peak T settles around ~940–960 K
because the rate cap throttles release while conduction and the convective wall losses
bleed heat from a front only ~1 cm wide.

**6. Unphysical diffusion of the solid fuel.** `Yfucoeff.m` zeroes convection of `Yfu`
(correct — solid is stationary) but keeps Fickian *diffusion* of `Yfu` using gas
viscosity (Schmidt ≈ 1). A solid shouldn't diffuse; this artificially smears the front
and adds to the numerical front-thickening from the hybrid scheme.

**7. Within-step convergence and scheme.** Scalars are solved with a single TDMA sweep
per step (`T_ITER = YFU_ITER = YK2_ITER = 1`) and an explicit (lagged) reaction
source, so each step is not converged — accuracy leans entirely on small `Dt`. Hybrid
differencing adds numerical diffusion that further thickens an already marginally
resolved front (~2–3 cells across at dx = 2 mm).

**8. Geometry/dimensionality.** A 2-D Cartesian slab (8×5 cm) can't represent the
cylindrical canister; an end-burner is essentially 1-D axial, a core-burner is radial.
The slab is a reasonable teaching abstraction but limits quantitative transfer.

**9. Tunable smoke metric.** The condensed-smoke estimate uses a fixed air-entrainment
factor `ENTRAIN = 0.5`; the author flags it as a knob chosen to keep the metric
temperature-sensitive. The reported smoke mass therefore depends on an arbitrary
parameter.

**10. Doc/code drift and stale claims.** README says top/bottom walls are adiabatic in
v1, but `bound.m` now applies convective (Robin) loss on west/top/bottom. README also
says "not run in MATLAB," yet `results/` is full of completed MATLAB runs. Exit-velocity
reporting is inconsistent between logs (~40 m/s in the history vs a 0.11 m/s
`UEXIT_PEAK` in another log) — worth reconciling.

## What is done well

- Reuses the validated Versteeg & Malalasekera staggered-grid SIMPLE machinery.
- K₂CO₃ yield (44 wt% at 65/35) matches the literature (Nakka / TU Delft).
- Energy-conserving heat-source form with a sensible stability cap.
- Variable-density low-Mach coupling with under-relaxation; analytically-computed
  (not guessed) natural-convection coefficients; finite casing thermal mass.
- Fixed colour/arrow scales for honest frame-to-frame animation; clear in-code
  documentation of limitations; versioned archive.

## Suggested improvements (highest leverage first)

1. **Match the simulated time to the physics.** Either run to ~20–25 s so the front
   actually reaches the east wall, or shrink `XMAX` to a few mm so a full traverse
   fits in ~1 s. As-is, the run only shows ignition.

2. **Pick one burn model and make it consistent.** Preferred: a *surface-regression
   (deflagration) front* driven by the empirical `r = a·Pⁿ` law, advancing a level-set
   / VOF interface between solid and product gas, with the heat and K₂CO₃ released at
   the moving surface. This removes the need for the decoupled 0-D pressure model and
   ties front speed to measured data.

3. **If keeping the volumetric Arrhenius wave, calibrate it.** Fit `A`, `Ea` (and the
   medium's `ρ`, `Cp`, `λ`) so the *uncapped* front speed reproduces the measured KNSu
   regression rate (~4 mm/s near 1 atm from `a_burn = 8.26`, `n = 0.319`). Then verify
   the cap is not active at steady propagation, so kinetics — not `Dt` — set the speed.

4. **Use solid properties in the unburnt region.** Give the charge `ρ ≈ 1800`,
   solid `Cp` and `λ`, transitioning to gas properties as `Yfu → 0`. This alone will
   bring front speed and heat-up into a physical range.

5. **Remove `Yfu` diffusion** (set its Γ to ~0): the solid fuel field shouldn't spread
   by diffusion.

6. **Demonstrate numerical convergence.** Add a grid-refinement and `Dt`-refinement
   study showing front speed, peak T and total K₂CO₃ are mesh/step independent; raise
   scalar inner iterations or switch the reaction source to (partly) implicit.

7. **Let flame temperature emerge.** Reduce reliance on the 1300 K anchor/cap so the
   ratio study reflects model physics rather than an imposed curve; if anchoring is
   kept, report results as relative trends, not absolute temperatures.

8. **Reconcile docs and outputs.** Update the README BCs and "not run in MATLAB" note,
   and reconcile the two exit-velocity figures.

9. **Validate against data.** Compare predicted regression rate, flame temperature and
   (if possible) smoke yield to published KNSu values, not just the chemistry anchor.
