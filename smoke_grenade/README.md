# Smoke-grenade reacting-flow model (v1)

Laminar, transient 2-D model of a premixed **KNO₃/sugar (KNSu)** smoke charge
burning inside a closed box. It outputs the **temperature distribution** and the
**K₂CO₃ field** (the smoke-forming solid) as functions of the KNO₃/sugar ratio —
research questions 1 and 2.

Built by adapting the supplied `final_assignment` solver (Versteeg & Malalasekera
staggered-grid, transient SIMPLE). Reuses the proven flow machinery and adds the
chemistry.

## How to run (MATLAB)
Single run:
```
cd smoke_grenade
smoke_grenade          % set xKN at the top, runs one ratio (plots + GIF)
```
Ratio sweep (research questions 1 & 2):
```
sweep_xKN              % runs xKN = 0.55 / 0.65 / 0.75, plots K2CO3 & T vs ratio
```
Each run saves a timestamped folder under `results/` with `fields.png`,
`temperature.gif`, `grenade_output.txt`, `grenade_history.txt`, `params.txt`.
The sweep also writes `results/sweep_xKN.png` and `results/sweep_xKN.txt`.

To study the ratio: change `xKN` (KNO₃ mass fraction) in `smoke_grenade.m`, or
edit the `xlist` in `sweep_xKN.m`.

## Files
| file | role |
|------|------|
| `smoke_grenade.m` | thin single-run wrapper (set `xKN`, calls `run_grenade`) |
| `run_grenade.m` | the simulation core as a function `run_grenade(xKN,doPlots,doGif)` |
| `sweep_xKN.m` | loops over a few ratios, plots K₂CO₃ and escaping-gas T vs composition |
| `chemistry.m` | K₂CO₃ yield + **peaked** flame-temperature rise dTad(xKN) |
| `reaction.m` | Arrhenius rate coefficient `Rk` (temperature-driven, capped) |
| `Yfucoeff.m` | unburnt-fuel transport (reaction sink) |
| `YK2coeff.m` | K₂CO₃ transport (reaction source) |
| `Tcoeff.m` | energy eq. + combustion heat source (edited) |
| `init.m` | initialisation: quiescent, ambient T, fuel field (edited) |
| `bound.m` | closed-box BCs + igniter wall (rewritten) |
| `viscosity.m` | laminar (mut = 0) (edited) |
| `ucoeff/vcoeff/pccoeff/velcorr/solve/convect/derivatives` | supplied flow code (unchanged) |
| `kcoeff/epscoeff/calculateuplus` | supplied k-ε code, **not called** in v1 (kept for v2) |

## Model summary
- **Geometry:** closed 2-D box, dimensions `XMAX`,`YMAX` (handheld scale, variable).
- **Flow:** laminar; turbulence (k-ε) switched off (`k=0`, `mut=0`). v1 has no vent,
  so velocities stay ≈0 and transport is reaction + conduction.
- **Ignition:** west wall held at `TIGN` (hot fuse end); drives a combustion front
  that propagates across the charge (slow start → accelerating).
- **Combustion:** temperature-driven (Arrhenius) rate `Rk=A·exp(−Ea/RuT)`, capped at
  `0.5/Dt`. Heat release written as relaxation of T toward the adiabatic flame
  temperature `Tad=TAMB+ΔT_ad` (bounded, can't overshoot).
- **Chemistry:** per the balanced reaction, K₂CO₃ mass yield ≈ `0.683·xKN`
  (= 44 wt% at 65/35, matching TU Delft/Nakka). ΔT_ad anchored to ~1600 K flame temp.
- **Thermal BCs:** east wall adiabatic (problem's "no heat transfer" wall); top/bottom
  adiabatic in v1 (placeholder for the gentle convective flux); west = igniter.

## Verification status
The **chemistry and reaction numerics were verified in Python** (`chem_verify.py`,
`box_verify.py` — not part of the MATLAB deliverable) on the same grid/formulation:
- K₂CO₃ yield reproduces the literature **44 wt% at 65/35**;
- the front **ignites, propagates, and burns** the charge over the simulated time;
- peak temperature stays **bounded below `Tad`** (numerically stable).

The MATLAB files mirror those verified formulas exactly, but **have not been run in
MATLAB** in this environment (no MATLAB/Octave available). First MATLAB run: check it
executes and the printed `Tmax`/`K2CO3` trends match the Python check.

## Planned v2 (not yet implemented)
- Pressure-driven **vent** (outlet per the sketch) + gasification **mass source** in
  the pressure-correction equation, to capture escaping-gas velocity.
- **Convective heat-flux** wall BCs instead of adiabatic.
- Optional **k-ε turbulence** (re-enable the supplied modules).
- **Loop over `xKN`** to locate the optimum (max K₂CO₃ with gas < 891 °C).
