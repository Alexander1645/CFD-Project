# UPDATE 2 — course correction: vent outputs for the dilution/smoke analysis

Context: the report's end metric changed. The 891 °C criterion is now read as a
CONDENSATION TRIGGER, not pass/fail: hot vent gas must entrain ambient air to
cool below T_c = 1164 K, and that dilution thins the smoke. The CFD's job is to
deliver the vent state (T, p, u, smoke flux) that feeds a small 0-D optical
post-processing layer. V3 as run (PASS, good work — [B2-1..4] acknowledged,
[B2-4] accepted pending designer review) exposed one physics gap: with
adiabatic walls Tvent == T_flame identically, so the vent temperature is pure
chemistry echo and the CFD contributes nothing to the dilution result.

## Changes (tag all as [B2], log in CHANGELOG.md)

1. WALL COOLING ON for all physics/sweep runs: uncomment the Robin block in
   bound.m (declare its globals; move h_wall/lam to grenade06.m parameters).
   Baseline h_wall = 10 W/m2K. Keep ONE adiabatic run (V3 as-is) as the
   h_wall = 0 sensitivity reference. Expect Tvent to drop only modestly below
   T_flame — that margin IS the CFD's contribution; report it either way.

2. History columns (append, keep existing 9):
   - col10 Tvent_fw: mass-flux-weighted vent temperature
     sum(rho(2,Jv)*max(-u(2,Jv),0).*T(2,Jv)) / sum(rho(2,Jv)*max(-u(2,Jv),0))
     (fall back to arithmetic mean when flux ~ 0). Use THIS, not the
     arithmetic Tvent, for all dilution math.
   - col11 mdotK2_vent = sum(rho(2,Jv).*max(-u(2,Jv),0).*YK2(2,Jv))*Dy  [kg/s/m]
   - col12 MK2_vented  = cumulative integral of col11 [kg/m]
   - col13 pvent = mean(p(2,Jv1:Jv2)) [Pa] (the pressure actually driving the
     orifice; pbar stays as the cavity mean).

3. NEW small file postproc_smoke.m (pure post-processing, reads
   grenade_history.txt — no solver changes): constants at top with citations
   needed: alpha = 3 m2/g (mass extinction, salt-type smoke — find/cite a
   source, note results scale linearly), Ttrans_req = 0.02, L_path = 5 m,
   Cp_gas = 1200, Cp_air = 1005, T_c = 1164 K. Compute per timestep:
   - D(t)      = Cp_gas*(Tvent_fw - T_c) / (Cp_air*(T_c - TAMB)),  D>=0
   - Vdot_mix  = m_vent*(1+D)/rho_mix,  rho_mix = P_ATM/(287*T_c)
   - C_form(t) = mdotK2_vent / Vdot_mix          [kg/m3] (also print g/m3)
   - A_screen  = alpha*MK2_vented(end)/log(1/Ttrans_req)   [m2 per m depth]
   Print a per-run summary block + save postproc_summary.txt in the run folder.

4. Sweep (with cooling ON): xKN = 0.55 / 0.65(rerun) / 0.75, 1 s each. Then a
   sweep figure with FOUR curves vs xKN: yK2 (chemistry), Tvent_fw
   (quasi-steady value), D, and C_form; plus A_screen in a table. This figure
   is the paper's headline result.

5. V4 refinement runs as already staged, but with cooling ON so the refined
   quantity matches the physics runs. Compare Tvent_fw, pbar, uvent, C_form.

## Unchanged
Everything else stays per HANDOFF_to_runner.md: [B2] tagging + CHANGELOG,
minimal diffs, no 0-D models inside the solver (postproc_smoke.m is
post-processing, it never feeds back), report format, don't touch docs/backup.
