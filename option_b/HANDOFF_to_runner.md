# HANDOFF — run & verify the Option B smoke-grenade CFD (for the executing assistant)

You are taking over EXECUTION of a MATLAB CFD model that another assistant
designed and wrote but could not run. Your job: run it, verify it, apply
minimal fixes, and produce results + a change log that the designer (via the
user) will review. You are NOT asked to redesign anything.

## Context (30 seconds)
TU/e course 4RC30 group project: 2-D CFD of a KNO3/sucrose (KNSu) smoke
grenade. Research questions: effect of KNO3 mass fraction xKN on (1) K2CO3
(smoke) production and (2) temperature distribution, with the 891 °C K2CO3
melting point as the criterion for escaping gas. Course rule: the code must
strictly follow the supplied course solver (`final_assignment/`, V&M staggered
grid transient SIMPLE). A previous attempt failed by restructuring the solver
and outsourcing pressure to a 0-D side model — do not repeat that.

## Where things live
- Code to run: `ProjectCode/CFD-Project/option_b/` — driver `grenade06.m`.
- Read FIRST: `optionB_design.md` (model + verification plan V1–V5),
  `optionB_walkthrough.md` (file-by-file, mechanisms, §8 run protocol).
- Supplied course code (reference, do not modify):
  `ProjectInfo/code_final_assignment/final_assignment/` and `ProjectInfo/wc3/`.
- Backup of the untouched skeleton: `option_b_backup_20260706/`.

## The model in ten lines
Gas cavity west of a moving burning surface; unburnt charge = blocked cells
(SP=-LARGE pins, the supplied code's own idiom); the surface is a moving INLET
(mass flux mdotpp = f_gas*rho_solid*r, temperature T_flame, smoke loading
Y_in) advancing east at the measured burn law r = a*P^n, with P read from the
2-D field (front.m) — the burn/pressure feedback closes in-field. Vent = west
wall orifice, u = -Cd*sqrt(2*max(p,0)/rho), from the LOCAL field pressure.
Pressure buildup is resolved by the field: transient compressible continuity
term (rho_old-rho)*V/Dt in pccoeff.m + ideal-gas density.m (from wc3) inside
the SIMPLE loop. NO reaction source terms in any transport equation. NO 0-D
chamber model. Combustion is 100 % boundary conditions.

## Hard constraints (course-driven — violating these fails the project)
1. Keep the supplied solver structure: driver loop layout, coeff-file pattern,
   TDMA solve, staggered indexing. convect/derivatives/solve/velcorr/viscosity
   are byte-identical supplied files — keep them so.
2. Every code change must be tagged. Existing designer changes are `[B]`.
   Tag YOUR fixes `[B2]` with a one-line reason. Keep a running CHANGELOG.md.
3. No global mass-rescaling outlet (the supplied m_in/m_out trick) — it
   forbids pressurisation. No volumetric combustion sources. No 0-D pressure
   ODE. If something diverges, fix stability (knobs below), not the physics.
4. Minimal-diff mindset: prefer parameter changes > one-line fixes > blocks.

## Status: V1 PASSED (already run by the user, 2500 steps, no NaN)
Sealed box (VENT_OPEN=0, BURN_ON=0, ngap0=20, TOTAL_TIME=0.05): pressure rose
0 -> 4.46 kPa and levelled (the ghost column is pinned at T_flame even with
BURN_ON=0, so it acts as a hot wall — physically consistent); massErr steady
at ~-3.3e-4 kg/s/m ≈ convergence-tolerance level (~0.3 % of cavity mass over
the window); uvent=0, front frozen, K2=0 as required.
NOTE: `grenade06.m` currently still has the V1 switches set
(TOTAL_TIME=0.05, ngap0=20, VENT_OPEN=0, BURN_ON=0).

## Your task list, in order
1. V1 tolerance check (optional, 2 min): SMAXneeded=1e-6, MAX_ITER=100,
   rerun V1 — massErr should shrink ~10x. Restore afterwards.
2. V2 blow-down: VENT_OPEN=1, BURN_ON=0 (keep ngap0=20, TOTAL_TIME=0.05).
   Expect pbar to peak far below 4.5 kPa and plateau while uvent > 0.
   Stronger variant: also init p(2:20,2:NPJ+1)=2000 in init.m and compare the
   decay against the 10-line 0-D orifice ODE dM/dt = -Cd*A*sqrt(2*rho*p).
3. THE BURN (V3): restore ngap0=3, VENT_OPEN=1, BURN_ON=1, TOTAL_TIME=1.0.
   ~50k steps. Healthy run: after the 0.05 s ramp, pbar ~ O(1 kPa), uvent
   tens of m/s, Tvent -> approaching T_flame (~2080 K at xKN=0.65; that value
   is a no-dissociation upper bound, expected), xf advancing ~4 mm/s (~4 mm
   over the second), massErr << m_in, iter well under MAX_ITER, smooth cell
   flips every ~0.5 s (0.146/48/0.004). Watch the first flip closely (~t
   where xf crosses 4*Dx) — a few rough iterations are OK, NaN is not.
4. If divergence, apply IN ORDER, one at a time, rerun: relax_rho 0.1->0.05;
   Dt 2e-5->1e-5; PC_ITER 30->50; then inspect u(2,Jv1:Jv2) sign (must be <=0)
   and the inlet face u(Ifr,J) (must be <0, magnitude mdotpp/rho_f ~ 15-20).
5. V4: grid/Dt refinement — 72x33 grid and Dt/2; compare pbar peak, mean
   uvent, Tvent (want within a few %). Report the table.
6. Sweep: xKN = 0.55 / 0.65 / 0.75 (line 61), 1 s each; collect Tvent, pbar,
   uvent, K2prod histories. Save each run's grenade_history.txt +
   grenade_output.txt into results/<xKN>/ (create folders).
7. Known soft spots the designer flagged: (a) hist variable shadows MATLAB
   hist() — harmless, rename only if it errors; (b) yplus=1 keeps ucoeff's
   wall branch on laminar shear — verify no NaN from k=0; (c) Y_in ≈ 0.9 is a
   loading (can exceed... it is per kg gas), not a mass fraction — do not
   "fix" it; (d) massErr jumps slightly at cell flips (new cell's gas mass
   appears) — expected, note magnitude.

## Report back in this exact format (the designer will review it)
1. CHANGELOG.md: every [B2] edit — file, line, old->new, one-line reason.
2. Per run: the last ~10 lines of console output + min/max/final of each
   grenade_history.txt column + iter statistics (mean/max outer iterations).
3. The two quick-look figures per run (T contour, pbar(t)) saved as PNG.
4. One paragraph: does the physics look right vs the "healthy run" numbers
   above; anything anomalous.
5. Do NOT touch: optionB_design.md, optionB_walkthrough.md, the backup
   folder, or anything outside option_b/ (except creating results/).
