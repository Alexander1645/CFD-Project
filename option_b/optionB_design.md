# Option B — Advancing burning-surface model (design document)

Smoke-grenade KNSu combustion in the supplied 4RC30 solver, with the burning
surface modelled as a **moving inlet boundary** and the unburnt charge as
**excluded (blocked) cells**. No reaction source terms appear in any transport
equation. The pressure buildup, venting and burn-rate feedback are all resolved
**in the 2-D field** — there is no 0-D side model.

Status: design + untested skeleton (no MATLAB available in this environment).
Read together with `optionB_walkthrough.md` (file-by-file explanation).

---

## 1. Concept

```
        west                                                east
   y=YMAX +--------+----------------------------------------------+
          | wall   |g g g g g|S S S S S S S S S S S S S S S S S S |
          |        |g g g g g|S S S S S S S S S S S S S S S S S S |
   vent-> ~ OUT    |g g g g g|S S S S  unburnt charge  S S S S S S |
   vent-> ~ OUT    |g g g g g|S S S S  (blocked cells) S S S S S S |
          |        |g g g g g|S S S S S S S S S S S S S S S S S S |
          | wall   |g g g g g|S S S S S S S S S S S S S S S S S S |
      y=0 +--------+---------+--------------------------------------+
          x=0      ^         ^ x_f(t)  --> front moves east at r(P)
                gas cavity   burning surface = INLET of hot product gas
```

- The **gas cavity** (west of the front) is the only region where the flow
  equations are solved. It grows as the charge burns — this is the "moving
  wall" volume increase: each consumed cell converts from blocked to gas.
- The **burning surface** is a full-height vertical interface at `x_f(t)`.
  It acts as an *inlet*: product gas enters the cavity at the measured mass
  flux and at the adiabatic flame temperature.
- The **unburnt charge** is inert blocked cells. Its interior temperature is
  not solved: the conductive preheat layer ahead of a KNSu front is
  δ ≈ α/r ≈ (0.3/(1800·1200))/0.004 ≈ **35 µm**, two orders below the cell
  size, so the solid is cold until the front arrives (this also justifies the
  adiabatic east wall).
- The **vent** (west wall) is an orifice: outflow velocity follows from the
  *local field pressure*, so pressure and venting stay coupled.

### The feedback loop (all in-field)

```
        r = a·P^n  (burn law)
   +-------------------------------------------+
   |                                           |
   v                                           |
 front speed  -->  inlet mass flux         P (field pressure
 x_f advance       m'' = f_gas·rho_s·r      at the front, from
                        |                    the pc/SIMPLE solve)
                        v                        ^
                 gas accumulates in cavity       |
                 (compressible continuity) ------+
                        |
                        v
                 vent outflow  u_vent = Cd·sqrt(2·p_gauge/rho)
```

Gas generated faster than the orifice passes it → density/pressure rise in the
cavity (transient compressible continuity) → vent speed rises AND the burn rate
rises. Every arrow is computed from the 2-D field.

---

## 2. What is solved where

| Region | u, v | p / pc | T | Y_K2 |
|---|---|---|---|---|
| Gas cells `I = 2..If-1` | solved | solved | solved | solved |
| Front ghost column `I = If` | inlet face `u(If,J) = -u_in` | pinned pc=0 | pinned `T_flame` | pinned `Y_in` |
| Deep solid `I = If+1..NPI+1` | pinned 0 | pinned pc=0 | pinned `TAMB` | pinned 0 |

Pinning uses the supplied code's own mechanism (`SP = -LARGE`,
`Su = LARGE·value` — see the commented-out block in the supplied `Tcoeff.m`,
lines 57–61). Blocked cells are excluded from the flow exactly the way the
supplied code excludes ghost cells: pinned values + `d_u = 0` so `velcorr`
never touches them.

`If` (first solid column) follows the continuous front position:
`If = 2 + floor(x_f/Dx)`. When `x_f` crosses a cell boundary the ghost column
becomes a gas cell (it already carries inlet values `T_flame`, `Y_in`, so the
flip is smooth) and the inlet face moves one column east.

---

## 3. Governing equations (for the report)

Solved in the gas cavity only, laminar, 2-D planar:

- Continuity (transient, compressible):
  ∂ρ/∂t + ∇·(ρ**u**) = 0    — no source; gas enters through the inlet *boundary*.
- Momentum: standard, as supplied (V&M eq. 6.9/6.11 discretisation).
- Energy (Cp-divided form, as supplied): ∂(ρT)/∂t + ∇·(ρ**u**T) = ∇·(Γ∇T),
  Γ = λ(T)/Cp — no combustion source; enthalpy enters via the inlet at `T_flame`.
- Smoke transport: ∂(ρY)/∂t + ∇·(ρ**u**Y) = ∇·((μ/Sc)∇Y) — no source; K2CO3
  enters via the inlet at loading `Y_in`.
- EOS: ρ = (p + P_ATM)/(R_gas·T), with p the gauge pressure solved by SIMPLE.
  The absolute pressure level is anchored by the total gas mass through the
  EOS + transient continuity (see §5).

Boundary conditions:

| Boundary | Flow | Thermal | Species |
|---|---|---|---|
| Burning surface (moving) | inlet: `u = -m''/ρ_face`, `m'' = f_gas·ρ_s·r(P)` | inlet at `T_flame = TAMB + dTad(xKN)` | inlet at `Y_in = y_K2/f_gas` |
| Vent (west wall, rows Jv1..Jv2) | orifice outflow `u_vent = -Cd·√(2·max(p,0)/ρ)`, under-relaxed | zero gradient | zero gradient |
| All other walls | no-slip | adiabatic (default; optional Robin `q = h(T-T_amb)` block provided, commented) | zero flux |

Closure data (all literature, none fitted):
- Burn law: r = a·(P[MPa])^n mm/s, a = 8.26, n = 0.319 (KNSu, Nakka/Foltran).
- Chemistry (`chemistry.m`, per composition xKN): K2CO3 yield y_K2 = 0.683·xKN
  (44 wt% at 65/35, matches Nakka/TU Delft); gas fraction f_gas; adiabatic rise
  dTad from heats of formation (no dissociation → upper bound, report caveat);
  R_gas computed from the product-gas mean molar mass (≈270–280 J/kg/K).
- Solid density ρ_s = 1800 kg/m³.

---

## 4. The three structural additions to the supplied code

Everything else is the supplied `final_assignment` code, unchanged.

**(1) Transient compressible continuity** — `pccoeff.m` gains one source term
in `b`: `(rho_old − rho)·V/Δt` (V&M ch. 8: the transient term of continuity).
This is what lets a cell *store* mass, i.e. pressurise, instead of being forced
to pass every injected kilogram on instantly. It is the single change that
makes in-field pressure buildup possible — its absence is why the previous
model's volumetric source NaN'd.

**(2) Ideal-gas density** — `density.m` (taken from the supplied wc3
`convdiff03.m`, lines 71–83): ρ = (p+P_ATM)/(R·T) with under-relaxation
`relax_rho`, called **inside** the outer SIMPLE loop (wc3's placement), so the
pressure–density–velocity coupling converges within each time step.

**(3) Blocked/moving solid region** — pin blocks in `ucoeff/vcoeff/Tcoeff/
YK2coeff/pccoeff` (the supplied `SP=-LARGE` idiom) keyed to the front index
`If`, plus the small new `front.m` that advances `x_f` once per step.

One deliberate deviation from the supplied driver: **storeresults moves outside
the inner while-loop** (old values = previous *time level*, held fixed during
the outer iterations, V&M §8.7.1). In the supplied driver the old values are
overwritten every outer iteration, which makes the transient terms degenerate;
for a pressurisation problem the accumulation term must be a true time
derivative. Also `rho_old` joins the stored set. This must be stated in the
report (one sentence, cite V&M 8.7.1).

The supplied outlet trick (`m_in/m_out` rescaling in `bound.m`) is **not
used**: it enforces instantaneous global mass balance, which is precisely the
physics we must NOT impose (it would forbid pressurisation). The vent responds
to pressure instead; global balance emerges with the accumulation term.

---

## 5. How the absolute pressure level is set (read this before debugging)

SIMPLE's pc equation with prescribed velocities on all boundaries fixes p only
up to a constant. Here the constant is anchored physically: ρ is tied to p by
the EOS, and total mass evolution is tied to (inlet − vent) flux by the
transient continuity. If p is too low, the accumulation term reports "mass
missing", pc rises everywhere, `velcorr` raises p, `density()` raises ρ — and
the loop converges when the stored mass matches what actually flowed in. This
is the in-field replacement for the old 0-D `P_chamber` ODE.

Consequence for debugging: the pressure level converges at a rate governed by
`relax_pc·relax_rho`. If the mean pressure oscillates, lower `relax_rho`
(0.1 → 0.05) or `Δt` first. Verification test V1 (below) isolates exactly this
mechanism — run it before any burn.

---

## 6. Sanity numbers (65/35, defaults)

| Quantity | Estimate |
|---|---|
| r at 1 atm | 8.26·(0.101)^0.319 ≈ 4.0 mm/s |
| Inlet mass flux m'' = f_gas·ρ_s·r | ≈ 0.5·1800·0.004 ≈ 3.6 kg/m²/s |
| Inlet velocity (at T_flame ≈ 1750 K, ρ ≈ 0.20) | ≈ 18 m/s |
| Total generation (front height 0.064 m) | ≈ 0.23 kg/s per m depth |
| Vent velocity (vent 0.016 m, gas ~1200 K) | ≈ 40–50 m/s |
| Gauge pressure to drive that | Δp ≈ ρu²/(2Cd²) ≈ 1 kPa |
| Mach | < 0.1 (low-Mach OK for SIMPLE) |
| Full burn time (0.14 m charge) | ≈ 35 s (M18 real: 50–90 s — same order, validation hook) |
| CFL: Δx ≈ 3 mm, u ≈ 50 m/s | Δt ≤ 6e-5 s → default Δt = 2e-5 s |

Runtime reality: full burn-out ≈ 35 s ≈ 1.75M steps at Δt = 2e-5 — do NOT try.
The flow becomes quasi-steady ~0.5 s after ignition; all RQ metrics (pressure,
vent T vs 891 °C, K2CO3 production *rate*, fields) are extractable from a 1–2 s
window, and totals scale linearly with burned mass. Report this explicitly.

## 7. Stability plan

- Startup: ramp the burn rate over `t_ramp = 0.05 s` (`min(t/t_ramp,1)`) —
  avoids a step-function inlet shock.
- Under-relaxation: `relax_u = 0.8`, `relax_pc = 1.1 − relax_u` (supplied),
  `relax_rho = 0.1` (halve if p oscillates), vent BC relaxed with
  `relax_vent = 0.3`.
- Laminar: `k = 0`, `eps` tiny at init, `kcoeff/epscoeff` not called → `mut = 0`
  through the *unchanged* `viscosity.m`. (`yplus = 1` keeps the supplied wall
  branch on its laminar wall-shear expression — physical for laminar flow.)
- Divergence checklist, in order: reduce `relax_rho` → reduce `Dt` → raise
  `PC_ITER` → check the vent BC sign/magnitude (`u(2,Jv)` must be ≤ 0).

## 8. Verification plan (maps 1:1 to the report's Validation section)

- **V1 sealed box, no burn** (`VENT_OPEN=0, BURN_ON=0`, hot initial blob):
  total mass Σρ·V constant to round-off; p̄ tracks the ideal-gas value for the
  mean T. Isolates mechanism §5.
- **V2 blow-down, no burn** (`VENT_OPEN=1`, initial overpressure): p(t) decays;
  compare to the 0-D orifice ODE solved in a 10-line script. Validates vent BC.
- **V3 burn, global balance**: |m_in − m_vent − dM/dt| small vs m_in each step
  (printed by the driver).
- **V4 grid/Δt refinement**: p_peak, ū_vent, T̄_vent within a few % between
  (NPI,NPJ) and (1.5×,1.5×), and Δt vs Δt/2.
- **V5 physics**: burn time order vs M18 (35 s vs 50–90 s); T_flame vs
  literature AFT ≈ 1450–1600 K (ours is higher — no dissociation, state as
  upper bound); K2CO3 44 wt% at 65/35 (exact by construction, cite).

## 9. Known limitations (report Discussion, stated up front)

1. 2-D planar slab of a cylindrical device (no axisymmetric terms in the
   supplied solver) — trends, not absolute magnitudes.
2. Front is flat, full-height, first-order in space (advances cell-by-cell).
3. Solid interior not thermally solved (justified by the 35 µm preheat layer).
4. K2CO3 treated as a passive scalar carried by the gas: its ~47 % mass loading
   is neglected in mixture density/EOS (dilute-smoke assumption).
5. dTad without dissociation → flame temperature is an upper bound.
6. Vent modelled as an incompressible orifice (fine while Δp ≪ 1 atm).
7. Laminar (Re argument in the report; vent jet is transitional — acknowledge).

## 10. Parameters (defaults in `grenade06.m`)

Geometry M18-based: XMAX = 0.146, YMAX = 0.064 m; NPI = 48, NPJ = 22 (dev grid;
refine for V4). Vent: middle of west wall, 25 % of height (**decide vs the
approved sketch's top-left position** — one parameter, `Jv1:Jv2`). Initial gas
gap: 3 columns. Δt = 2e-5 s, TOTAL_TIME = 1.0 s (dev). Cp = 1200 J/kg/K
(constant, supplied-code style). μ(T) and λ(T): the supplied wc3 correlations.
xKN sweep: 0.55 / 0.65 / 0.75 (rerun the script per value, course style).
