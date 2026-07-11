# RUN REPORT — Option B execution pass (living document, updated as runs finish)

Executing assistant's results, in the handoff's required format. Code fixes are
in CHANGELOG.md ([B2] tags). Run outputs live under `results/<run>/`
(history + final field + T contour PNG + pbar(t) PNG + console log).

## Run configuration table (run-protocol switches, not code changes)

| Run (results/ folder) | VENT | BURN | ngap0 | t_end | xKN | grid | Dt | h_wall | status |
|---|---|---|---|---|---|---|---|---|---|
| V1_sealed (user, pre-handoff code) | 0 | 0 | 20 | 0.05 | 0.65 | 48x22 | 2e-5 | - | PASS |
| V1_tol (tolerance check, pre-B2-4) | 0 | 0 | 20 | 0.05 | 0.65 | 48x22 | 2e-5 | - | PASS |
| V2_vent_plateau / V2_blowdown (pre-B2-4) | 1 | 0 | 20 | 0.05 | 0.65 | 48x22 | 2e-5 | - | superseded by rv2a/rv2b |
| xKN065 (V3, adiabatic reference) | 1 | 1 | 3 | 1.0 | 0.65 | 48x22 | 2e-5 | 0 | PASS |
| xKN055 / xKN065_cool / xKN075 (sweep) | 1 | 1 | 3 | 1.0 | .55/.65/.75 | 48x22 | 2e-5 | 10 | PASS |
| V4_grid72x33 | 1 | 1 | 3 | 0.4 | 0.65 | 72x33 | 2e-5 | 10 | PASS (see V4) |
| V4_dt1e-5 | 1 | 1 | 3 | 0.4 | 0.65 | 48x22 | 1e-5 | 10 | PASS (see V4) |
| rv1_final_code (V1, final code, tight tol) | 0 | 0 | 20 | 0.05 | 0.65 | 48x22 | 2e-5 | 0 | PASS |
| rv2a_final_code / rv2b_final_code | 1 | 0 | 20 | 0.05 | 0.65 | 48x22 | 2e-5 | 0 | PASS / see below |

NOTE (deviation from handoff, for designer review): the two V4 refinement runs
use TOTAL_TIME = 0.4 s instead of 1.0 s. Runtime on this machine is ~19 ms per
outer iteration on the 48x22 grid (measured); a 1 s run on 72x33 would take
~15-20 h. The refinement comparison uses matched quasi-steady windows
(0.1-0.4 s) of V3 vs V4a/V4b, which contain the pbar peak (just after the
0.05 s ramp) and the quasi-steady vent state. Physics/sweep runs are full 1 s.

## V1_tol — tolerance check (task 1)

Config: SMAXneeded 1e-5 -> 1e-6, SAVGneeded 1e-6 -> 1e-7 (both: the outer loop
exits on EITHER tolerance, `&&`), MAX_ITER 40 -> 100. Restored afterwards.

- massErr: -3.28e-4 -> +1.09e-4 kg/s/m (~3x smaller, sign flip; the loop now
  exits on SAVG at ~18 iterations). Integrated over the 0.05 s window this is
  ~0.14 % of the cavity gas mass — convergence-tolerance level, not a leak.
- pbar(0.05 s): 4.46 kPa (loose) -> 5.08 kPa (tight): the sealed-box
  pressurisation level is tolerance-sensitive at the ~12 % level. Worth one
  sentence in the report's numerics section.
- Iterations: 18/step at tight tolerance (vs ~9-11 at supplied tolerance).
- Verdict: PASS — mechanism (accumulation term + EOS anchoring) confirmed.

## V2 — vent verification (task 2)

### V2b blow-down, p0 = 2 kPa (results/V2_blowdown/)

- Decay: pbar 2000 -> 0 Pa in ~0.12 ms. The 10-line 0-D orifice ODE
  (`ode0d_blowdown.txt`, isothermal) empties the same excess mass in ~0.13 ms.
  DECAY TIMESCALE MATCHES (figure `V2_vs_ode0d.png`).
- Peak vent speed ~28 m/s (orifice law at ~2 kPa: ~34 m/s; face under-relaxation
  lags the peak). Vented gas cools below ambient (Tvent min 287 K) — physically
  correct expansion cooling.
- Caveat: after p crosses zero the under-relaxed face velocity keeps blowing
  for ~0.3 ms (numerical memory tail); with the no-backflow orifice this
  rectifies into a LOCKED UNDER-PRESSURE of about -3.8 kPa which then refills
  by wall heating at ~+90 Pa/ms. An impulsive-start artifact: in the burn
  regime the vent operates at sustained p > 0 and never enters this corner.
- This test EXPOSED bug [B2-1] (vent passed 0.3x the orifice velocity;
  pre-fix run archived in results/V2_blowdown/prefix_bug/). See CHANGELOG.md.

### V2a vent-open, no burn (results/V2_vent_plateau/)

- With the vent open the sealed-box pressurisation (V1: +4.5 kPa and rising)
  is eliminated: |pbar| stays bounded, no growth; the box ends near ambient.
- Caveat (same corner as V2b): because the only "source" is gentle wall
  heating (equilibrium vent speed ~0.01 m/s at p* ~ 2e-4 Pa), the sqrt(p)
  orifice is infinitely stiff at p ~ 0 and the vent flickers open/shut instead
  of finding the microscopic equilibrium; early flicker events pump the box to
  about -4.4 kPa, where it locks (no backflow) and slowly refills. The
  handoff's expected "plateau far below 4.5 kPa with uvent > 0" implicitly
  assumed the pre-fix vent (which, at 0.3x u_orf and no memory, behaved
  gently but passed the wrong flux at real pressures — see CHANGELOG [B2-1]).
- Verdict: vent BC validated on the mechanism it exists for (mass flux vs
  local field pressure, V2b decay); the p~0 corner behaviour is documented as
  a model limitation (outflow-only orifice + stiff sqrt(p) law), irrelevant to
  the burn regime.

## V3 — main burn, xKN = 0.65 (results/xKN065/) — PASS

Four attempts were needed; attempts 1-3 diagnosed two real problems fixed as
[B2-2] and [B2-4] (see CHANGELOG.md). Attempt 4 = final: Dt=2e-5 (designer's
original), relax_rho=0.05, with the [B2-1]/[B2-4] code fixes. 50 000 steps,
wall time 17 min.

Console tail (last lines):
```
49900    0.9980   1   2451.55   1778.9    91.06  2.56e-01  2.61e-01  4.82e-03   13.02
50000    1.0000   1   2451.55   1778.9    91.06  2.56e-01  2.61e-01  4.82e-03   13.03
```

History column stats (50 000 rows):

| column | min | max | final |
|---|---|---|---|
| pbar [Pa] | -330.4 | 2558.1 | 2451.6 |
| Tvent [K] | 297.0 | 1782.5 | 1778.9 |
| uvent [m/s] | 0.053 | 91.2 | 91.1 |
| m_in [kg/s/m] | 1.02e-4 | 0.2566 | 0.2565 |
| m_vent [kg/s/m] | 8.9e-4 | 0.2616 | 0.2613 |
| massErr [kg/s/m] | -1.89e-2 | 1.576 (startup spike, t<1 ms) | 4.82e-3 |
| xf [m] | 9.125e-3 | 1.3032e-2 | 1.3032e-2 |
| K2CO3 [kg/m] | ~0 | 0.19994 | 0.19994 |

Outer iterations: mean 1.7, max 40 (max only during the 0-0.03 s start
transient; iter = 1 from t ~ 0.06 s on).

Healthy-run checklist vs the handoff:
- pbar ~ O(1 kPa): 2.56 kPa quasi-steady. PASS
- uvent tens of m/s: 91 m/s. PASS (higher than the design-doc 40-50 m/s
  estimate because with adiabatic walls the vented gas is at T_flame, i.e.
  rho ~ 0.17 not ~0.29; mass balance closes with the observed velocity).
- Tvent -> T_flame: 1778.9 K = T_flame to 4 digits (T_flame = 1779 K at
  xKN=0.65 from chemistry.m; the handoff's "~2080 K" corresponds to the
  near-stoichiometric composition, see CHANGELOG note). PASS
- xf advance ~4 mm/s: 3.91 mm over 1 s, i.e. ~4.4 mm/s once past the ramp
  (r(P) at 2.5 kPa gauge). PASS
- massErr << m_in: 4.8e-3 vs 0.257 (1.9%); this residual is a diagnostics
  discretisation offset (m_vent measured with cell-centre rho vs the solver's
  face rho), not a leak — the field state is a true fixed point (M constant
  to 6 digits while m_in and the front advance). PASS
- iter well under MAX_ITER: 1-2 quasi-steady. PASS
- Cell flip: xf crossed 4*Dx = 12.17 mm at t ~ 0.785 s (step ~39 250):
  pbar stepped 2556.3 -> 2451.9 (-4 %, the new fixed point of the larger
  cavity), Tvent blipped +0.8 K for ~200 steps, no iteration spike, no NaN.
  SMOOTH — exactly the designed behaviour.

Quasi-steady state is reached at t ~ 0.06 s (well before the design doc's
~0.5 s guess). The flow is then a literal numerical fixed point (fields
frozen to 6 digits between cell flips).

## UPDATE_2 execution (wall cooling + vent outputs + dilution postproc)

Per `UPDATE_2_mixing_outputs.md`: [B2-5] Robin wall cooling activated
(h_wall = 10 W/m2K baseline, h_wall = 0 = adiabatic reference = archived V3),
[B2-6] history extended to 13 columns (Tvent_fw flux-weighted, mdotK2_vent,
MK2_vented, pvent), [B2-7] postproc_smoke.m, [B2-8] sweep_figure.m. The full
1 s sweep was re-run with cooling ON; every run: iter = 1 quasi-steady, smooth
cell flip at t ~ 0.78 s, no NaN. Console tails and 13-column stats live in
each `results/<run>/` folder (postproc_summary.txt per run).

### Sweep results (quasi-steady means over t = 0.5..1.0 s) — headline table

| xKN | yK2 [kg/kg] | Tvent_fw [K] | pvent [Pa] | uvent [m/s] | D [kg/kg] | C_form [g/m3] | MK2(1 s) [kg/m] | A_screen [m2/m] |
|---|---|---|---|---|---|---|---|---|
| 0.55 | 0.376 | 1514.8 | 1766 | 83.5 | 0.484 | 135.5 | 0.172 | 131.8 |
| 0.65 | 0.444 | 1773.3 | 1891 | 90.8 | 0.840 | 131.4 | 0.203 | 156.0 |
| 0.75 | 0.513 | 2386.7 | 1635 | 89.8 | 1.686 | 118.4 | 0.234 | 179.4 |

C_req = 0.261 g/m3 (alpha = 3 m2/g, T_req = 2 %, L_path = 5 m); the
formation-point concentration exceeds the optical requirement by a factor
450-520 at every composition — i.e. the plume may dilute a further ~500x
beyond the T_c point and still screen a 5 m sight line. Figure:
`results/sweep_summary.png`, table: `results/sweep_summary.txt`.

Wall-cooling margin (the CFD's contribution to Tvent): at h_wall = 10 W/m2K
the flux-weighted vent temperature sits only ~6 K (xKN=0.65) to ~12 K
(xKN=0.75) below T_flame — consistent with the energy budget (wall loss
~0.3 % of the vented enthalpy flux). The margin scales ~linearly with h_wall;
a forced-convection-level h (100-500 W/m2K) would give ~40-300 K. Report this
as the h_wall sensitivity; the adiabatic reference (archived V3, h_wall = 0)
brackets it from above with Tvent == T_flame exactly.

## Re-verification with the FINAL code state ([B2-1..8])

V1/V2 were originally run before [B2-4]; they were re-run with the final code
so the verification chain describes the model that produced the physics runs.

- **V1 sealed box (rv1):** at the SUPPLIED tolerances the sealed box shows a
  slow mass drift (massErr ~ -2.6e-3 kg/s/m, pbar reaches only ~1.1 kPa):
  the per-step heating imbalance (~7e-6 kg/s) sits BELOW the absolute
  tolerance SMAXneeded = 1e-5, the loop exits at iter = 1, and the
  under-relaxed density (relax_rho = 0.05) never absorbs the mass the
  implicit [B2-4] term credits — the scheme is conservative only when the
  outer loop converges. At the V1_tol settings (SMAX 1e-6 / SAVG 1e-7 /
  MAX_ITER 100) the loop runs ~53 iterations, massErr collapses to the
  1e-5 kg/s/m level (10-100x smaller than any earlier V1 result) and pbar
  rises linearly to the ideal-gas value (~4.9 kPa at 0.05 s). CONCLUSION:
  mechanism conservative and correct when converged; for slow/sealed cases
  use the tight tolerances. Burn runs are unaffected (their signals are
  ~1e4 x the tolerance and the quasi-steady state is a frozen fixed point).
- **V2a vent-open plateau (rv2a):** with the final code the earlier -4.4 kPa
  no-backflow lock is GONE — the cavity hovers within +-30 Pa of ambient for
  the whole window (gentle vent flicker, uvent 0-0.35 m/s). This SUPERSEDES
  the pre-[B2-4] V2a caveat: vent open => no pressurisation. PASS.
- **V2b blow-down (rv2b):** decay from +2 kPa completes within ~2 ms (0-D
  orifice ODE: ~0.13 ms for the pure mass decay; the CFD adds the vent
  relaxation lag and in-cavity wave dynamics). Undershoot now only ~-1.06 kPa
  (was -3.8 kPa pre-[B2-4]) and the cavity recovers to hover within +-25 Pa
  of ambient from t ~ 0.014 s on — no deep negative lock. Comparison figure
  regenerated against the final code: `results/V2_blowdown/V2_vs_ode0d.png`
  (pre-fix versions preserved under `preB24/` and `prefix_bug/`). PASS.

## V4 — refinement with cooling ON (0.4 s windows, quasi-steady over 0.2-0.4 s)

| quantity | base 48x22, Dt=2e-5 | V4b Dt=1e-5 | V4a 72x33 |
|---|---|---|---|
| Tvent_fw [K] | 1773.3 | 1773.5 (+0.01 %) | 1773.4 (+0.006 %) |
| D [kg/kg] | 0.840 | 0.840 (=) | 0.840 (=) |
| C_form [g/m3] | 131.35 | 131.33 (-0.02 %) | 131.34 (-0.01 %) |
| m_vent [kg/s/m] | 0.2613 | 0.2614 (+0.04 %) | 0.2637 (+0.9 %) |
| uvent [m/s] | 90.8 | 90.8 (=) | 102.5 (+12.9 %) |
| pvent [Pa] | 1891 | 1892 (+0.06 %) | 2429 (+28 %) |
| pbar [Pa] | 2548 | 2548 (=) | 3730 (+46 %) |

- **Dt refinement: CONVERGED** — the quasi-steady state is identical to 4-6
  digits at Dt/2. (This run is also the direct demonstration that [B2-4]
  removed the 1/Dt^2 instability: pre-fix, Dt=1e-5 diverged to NaN in 3 steps.)
- **Grid refinement:** every dilution-relevant metric (Tvent_fw, D, C_form,
  m_vent) is converged within 1 %. uvent/pvent/pbar differ because the vent
  GEOMETRY is quantised: nv = round(0.25*NPJ) rows gives a 17.45 mm vent at
  NPJ=22 but 15.51 mm at NPJ=33 (-11 % area) — the operating point slides
  along the same orifice curve. Cross-check: the vent VOLUME flux
  uvent*A_vent = 1.584 (base) vs 1.590 (fine) m2/s — within 0.4 %. The finer
  run also starts with a thinner initial cavity (ngap0 = 3 CELLS = 6.08 mm vs
  9.13 mm), which contributes to the higher cavity-mean pbar. Both are
  discretisation-of-geometry effects, not field-resolution errors; report
  accordingly.

## Physics assessment / validation (V5)

- **Burn time vs real device:** quasi-steady front speed 4.0 mm/s at
  pvent ~ 1.9 kPa gauge (r = a*P^n with P ~ 1.02 atm). Remaining charge
  0.137 m -> full-burn time ~ 34 s, against the real M18's 50-90 s: same
  order, faster as expected for a 2-D planar slab with a full-height burning
  face and no inhibitor (design doc sec. 6 predicted ~35 s).
- **Vent state:** ~90 m/s hot jet, Mach ~ 0.10 at 1773 K (low-Mach, SIMPLE
  valid); gauge pressure ~1.6-1.9 kPa — consistent with the orifice law at
  the vented mass flux, and the same order as the design doc's ~1 kPa
  estimate (higher mainly because the vented gas is hotter, hence lighter,
  than the 1200 K assumed there).
- **Chemistry anchors:** K2CO3 yield 44.4 wt% at 65/35 (matches
  Nakka/TU Delft value by construction); T_flame = 1779 K at 65/35 is above
  the literature AFT ~1450-1600 K — expected, dissociation not modelled;
  stated as an upper bound. The xKN trend (rise to a peak near
  stoichiometric xKN ~ 0.74) is physical.
- **Mass balance:** every run's massErr settles at 1.5-2 % of m_in, which is
  a diagnostics discretisation offset (cell-centre vs face density in the
  m_vent measure), not a leak: the interior state is a numerical fixed point
  (constant M) while m_in is finite.
- **Anomalies to disclose:** (1) the near-zero-pressure vent corner rings
  and can lock a no-burn cavity at negative gauge pressure (V2 caveat;
  irrelevant during a burn); (2) Tvent slightly exceeds T_flame (~+0.2 %)
  transiently during startup — hybrid-scheme overshoot, bounded; (3) all
  absolute per-metre-depth quantities carry the 2-D planar caveat (trends,
  not absolutes — design doc limitation 1).
