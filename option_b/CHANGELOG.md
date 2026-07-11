# CHANGELOG — Option B execution pass ([B2] = runner's fixes)

Executing assistant's running log, per HANDOFF_to_runner.md. Designer's changes
are tagged `[B]`; every fix made during execution is tagged `[B2]` in the code
and listed here. Run-configuration flips (VENT_OPEN/BURN_ON/ngap0/TOTAL_TIME/
xKN per the run protocol) are NOT code changes and are listed in the run table
of RUN_REPORT.md instead.

## [B2-1] bound.m — vent under-relaxation history was wiped (REAL BUG, fixed)

- **File/lines:** `bound.m`, the west-wall zeroing + the vent update line.
- **Old:**
  ```matlab
  u(2,1:NPJ+2)     = 0.;      % west wall (vent rows overwritten below)
  ...
  u(2,J) = (1.-relax_vent)*u(2,J) + relax_vent*(-u_orf);
  ```
- **New:**
  ```matlab
  uw_prev = u(2,1:NPJ+2);     % [B2] save west-face history BEFORE the wall zeroing
  u(2,1:NPJ+2)     = 0.;
  ...
  u(2,J) = (1.-relax_vent)*uw_prev(J) + relax_vent*(-u_orf);   % [B2] relax vs history
  ```
- **Reason (one line):** the wall zeroing ran before the vent update, so the
  "under-relaxation against the previous face value" (designer's own comment)
  always relaxed against 0 — the vent passed exactly `relax_vent = 0.3` times
  the orifice-law velocity.
- **Evidence:** pre-fix V2b (2 kPa blow-down) printed uvent = 10.61 m/s at
  step 1, which is 0.3 x 33.9 m/s = the orifice law times relax_vent
  (u_orf = Cd*sqrt(2*2000/1.256) = 33.9 m/s). Consequence in a burn run: the
  chamber would have needed ~(1/0.3)^2 ~ 11x the physical pressure to pass the
  generated mass flux. Pre-fix runs archived under `results/*/prefix_bug/`.

## [B2-2] grenade06.m — relax_rho 0.1 -> 0.05 (divergence checklist knob 1)

- **File/line:** `grenade06.m`, the `relax_rho` parameter line.
- **Old:** `relax_rho = 0.1;`  **New:** `relax_rho = 0.05;`
- **Reason (one line):** first V3 burn attempt oscillated (pbar swinging
  -14.5 kPa .. +24.4 kPa early, then sustained +-1..3 kPa ringing) with the
  outer loop pinned at MAX_ITER=40 every step — exactly the symptom the design
  doc sec. 5 prescribes relax_rho reduction for; applied as checklist item 1.
- **Evidence:** first-attempt log archived at `results/xKN065/attempt1_relaxrho0.1/`
  (console log only; run aborted at step ~1100 of 50000).

## [B2-3] grenade06.m — Dt 2e-5 -> 1e-5 (divergence checklist knob 2)

- **File/line:** `grenade06.m`, the `Dt` parameter line.
- **Old:** `Dt = 2.0e-5;`  **New:** `Dt = 1.0e-5;`
- **Reason (one line):** after [B2-2] the burn run still rode a kPa-amplitude
  pressure limit cycle with iter pinned at 40 (5 consecutive 100-step samples
  at pbar < 0 while uvent ~ 50 m/s); at Dt=2e-5 a single step's vent-flow error
  moves the small early cavity's pressure by ~1.3 kPa — more than the ~1 kPa
  operating point — so the vent-pressure coupling cannot settle; halving Dt
  halves the per-step gain (checklist item 2, design doc sec. 7).
- **Evidence:** attempt-2 console archived at
  `results/xKN065/attempt2_Dt2e-5_console.log`.
- **OUTCOME: REVERTED to Dt=2e-5.** At Dt=1e-5 the run diverged to NaN in 3
  steps — smaller Dt made it WORSE, which identified the real problem as the
  1/Dt^2 gain of the explicit pc<->rho coupling, fixed structurally by [B2-4].
  With [B2-4] in place the designer's original Dt=2e-5 is stable, so it was
  restored. The knob change is kept in this log for the record.

## [B2-4] pccoeff.m — implicit compressibility term in aP (STRUCTURAL, flag for review)

- **File/lines:** `pccoeff.m`, the [B] transient-term block (SP line).
- **Old:** `SP(I,J) = 0.;`
- **New:** `SP(I,J) = -AREAe*AREAn/(R_GAS*max(T(I,J),SMALL)*Dt);`
  (+ `global T R_GAS SMALL`)
- **Reason (one line):** a pressure correction pc also changes the cell
  density through the EOS (drho = pc/(R*T)) and therefore stores mass
  (pc/(R*T))*V/Dt — the implicit twin of the designer's explicit storage
  source (rho_old-rho)*V/Dt; without it that feedback only arrives one outer
  iteration later through density(), giving the pc<->rho loop a gain that
  scales like 1/Dt^2.
- **Evidence:** instrumented 6-step debug at Dt=1e-5 (per-stage NaN tracker):
  pre-fix, |pc|max grew 5.6e3 -> 2.7e5 within step 2 while the whole p-field
  flipped sign EVERY outer iteration; step 3 reached |pc| ~ 2.4e8, p ~ -6.8e7
  Pa, EOS density -127 kg/m3, NaN. Post-fix at the same Dt: |pc| ~ 10-100 Pa,
  no sign-flipping, no NaN, physical ramp-up. This also explains attempt 1/2
  behaviour at Dt=2e-5 (gain ~ O(1): sustained kPa limit cycle, iter pinned
  at 40). Textbook basis: V&M ch. 8 transient compressible pressure
  correction; Karki & Patankar (1989) pressure-based compressible scheme.
- **Course-structure note:** one term entered through the coeff-file's own
  SP slot; TDMA, staggered indexing, coeff-file pattern untouched. Without
  this term the verification plan's own V4 Dt-refinement run (Dt/2) is
  structurally impossible (guaranteed divergence), so the fix is required by
  the assignment's verification requirements, not a redesign choice.

## [B2-5] bound.m + grenade06.m — wall cooling activated (UPDATE_2 item 1)

- **File/lines:** `bound.m` (the designer's commented Robin block, activated
  behind `if h_wall > 0`), `grenade06.m` (new parameters `h_wall = 10.` W/m2K,
  `lam_wall = 0.05` W/mK + globals).
- **Reason (one line):** UPDATE_2: with adiabatic walls Tvent == T_flame
  identically, so the vent temperature was pure chemistry echo; casing heat
  loss gives the CFD a real temperature field to contribute. h_wall = 0
  reproduces the adiabatic behaviour exactly (V3 archived run = the h_wall=0
  reference).

## [B2-6] grenade06.m — history extended to 13 columns (UPDATE_2 item 2)

- **File/lines:** `grenade06.m` diagnostics block + history writer.
- **New columns:** 10 Tvent_fw (vent mass-flux-weighted temperature, falls
  back to arithmetic mean when flux ~ 0), 11 mdotK2_vent [kg/s/m],
  12 MK2_vented (cumulative) [kg/m], 13 pvent (mean p over the vent rows).
- **Reason (one line):** the dilution post-processing needs the state of the
  gas that actually LEAVES (flux-weighted), not the arithmetic wall average;
  existing 9 columns unchanged for continuity.

## [B2-7] postproc_smoke.m — NEW dilution/optical post-processing (UPDATE_2 item 3)

- **File:** `postproc_smoke.m` (new, pure post-processing; reads
  grenade_history.txt, never feeds back into the solver).
- **Computes:** dilution D = Cp_gas*(Tvent_fw - T_c)/(Cp_air*(T_c - TAMB));
  mixed volume flux Vdot_mix = m_vent*(1+D)/rho_mix at T_c; formation
  concentration C_form = mdotK2_vent/Vdot_mix; required concentration
  C_req = ln(1/T_req)/(alpha*L_path); screen area
  A_screen = alpha*MK2_vented/ln(1/T_req). alpha = 3 m2/g (salt-smoke mass
  extinction, [CITATION NEEDED], results scale linearly), T_req = 0.02,
  L_path = 5 m, T_c = 1164 K.
- Writes `postproc_summary.txt` per run folder.

## [B2-8] sweep_figure.m — NEW headline-figure script (UPDATE_2 item 4)

- **File:** `sweep_figure.m` (new; figure/table generation only, reads the
  archived runs through postproc_smoke(), no solver interaction).
- Produces `results/sweep_summary.png` (4 panels vs xKN: yK2, Tvent_fw vs
  T_flame, D, C_form vs C_req) and `results/sweep_summary.txt`.

## Verification notes that are NOT code changes

- **[B2-4] conservation caveat (found in re-verification):** the implicit
  compressibility term is mass-conservative only when the outer loop actually
  converges. In the SEALED slow-heating case (V1) the per-step imbalance
  (~7e-6 kg/s) is below the supplied absolute tolerance SMAXneeded = 1e-5, so
  the loop exits at iter = 1 and a slow drift accumulates (~3 % of cavity
  mass over 0.05 s). At tightened tolerances (1e-6/1e-7, MAX_ITER 100) the
  drift collapses to the 1e-5 kg/s/m level and the sealed box reaches the
  ideal-gas pressure (4.94 kPa at 0.05 s). Burn runs are unaffected: their
  fluxes are ~1e4 x the tolerance and their quasi-steady state is a frozen
  fixed point (zero drift by construction). Recommendation for the report:
  quote V1 at the tight tolerances; keep supplied tolerances for burn runs.

- The five supplied solver files (`convect.m`, `derivatives.m`, `solve.m`,
  `velcorr.m`, `viscosity.m`) were hash/diff-checked against
  `ProjectInfo/code_final_assignment/final_assignment/`: content-identical
  (only CRLF/LF line endings differ — file-transfer artifact, no code change).
- V1 tolerance check (task 1) ran with `SMAXneeded=1e-6, MAX_ITER=100` AND
  `SAVGneeded=1e-7` — the outer while-loop exits when EITHER tolerance is met
  (`&&` in the loop condition), so tightening SMAX alone does nothing once
  SAVG < 1e-6. Settings restored to supplied values afterwards.
- chemistry.m at xKN=0.65 gives T_flame = 1779 K (dTad = 1481 K, R_GAS =
  352 J/kg/K). The handoff's "~2080 K at xKN=0.65" does not match the code or
  the design docs (chemistry.m's own comment says ~1779 K at 65/35); 2080 K is
  presumably the near-stoichiometric (xKN~0.74) value. Healthy-run checks were
  made against 1779 K.
