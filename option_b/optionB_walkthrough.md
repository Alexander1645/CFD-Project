# Option B walkthrough — how the code snippets work together

Companion to `optionB_design.md`. This explains every file, where it came
from, what changed, and — most importantly — how the pieces cooperate. Read it
top to bottom once, then use the line references while stepping through the
code. Every deviation from the supplied course code is tagged `[B]`:

    grep -n "\[B\]" *.m        % lists every single change

---

## 0. The one-paragraph version

The supplied solver already knows how to do everything we need — move gas
(SIMPLE), carry heat and scalars (Tcoeff-style equations), take inlets
(bound.m), and exclude cells (SP=-LARGE). Option B adds no new physics *inside*
the equations. It only (1) lets cells store mass so pressure can build
(`pccoeff.m` + `density.m`), and (2) moves an inlet through the domain at the
measured burn rate (`front.m` + pin blocks). Combustion is 100 % a boundary
condition.

---

## 1. File map — what came from where

| File | Origin | Changed? |
|---|---|---|
| `grenade06.m` | `final_assignment/transient05.m` | driver: params, front() call, store-old moved, density()+YK2 solve added |
| `init.m` | `final_assignment/init.m` | quiescent start, ideal-gas rho, YK2/rho_old arrays, laminar k=0 |
| `bound.m` | `final_assignment/bound.m` | rewritten: sealed walls + orifice vent + inlet face (see §5, §6) |
| `ucoeff.m` | `final_assignment/ucoeff.m` | + pin block lines 64–80 only |
| `vcoeff.m` | `final_assignment/vcoeff.m` | + pin block lines 52–59 only |
| `pccoeff.m` | `final_assignment/pccoeff.m` | + transient term line 60, + solid exclusion lines 45–51 |
| `Tcoeff.m` | `final_assignment/Tcoeff.m` | + pin block lines 59–67 (their own commented idiom), rho_old line 74 |
| `YK2coeff.m` | **new**, structural clone of `Tcoeff.m` | smoke scalar (Γ=μ/Sc, inlet loading Y_in) |
| `front.m` | **new** (only genuinely new logic, 60 lines) | moves the burning surface |
| `density.m` | `wc3/convdiff03.m` lines 71–83 | loop limited to gas region; R_GAS from chemistry |
| `chemistry.m` | previous project work | reused as-is (yields, flame T, gas fraction) |
| `convect.m`, `derivatives.m`, `solve.m`, `velcorr.m`, `viscosity.m` | `final_assignment/` | **byte-identical copies, zero changes** |

Five of sixteen files are untouched course code; four have only a marked
insert; two are new and small. That is the "strictly follow the structure"
claim, and you can defend it file by file.

---

## 2. The grid — read this first, everything indexes off it

The staggered grid (V&M fig. 6.5). Scalars (p, T, rho, YK2) live at cell
CENTRES, indexed by capital `I,J` = 2..NPI+1 (1 and NPI+2/NPJ+2 are ghost
cells outside the walls). u lives on VERTICAL faces, indexed by small `i`:
`u(i,J)` is the face between cells `I-1` and `I` (so `u(2,J)` is ON the west
wall). v lives on horizontal faces likewise.

```
        J+1 |    .        .        .
            |         v(I,j+1)
            |    .    ---^---   .
         J  | u(i,J) [ T(I,J) ] u(i+1,J)      cell I,J
            |    .    ---^---   .             west face = u(i,J), i = I
            |          v(I,j)                 east face = u(i+1,J)
        J-1 |    .        .        .
            +--------------------------
                I-1       I       I+1
```

The whole trick of Option B is choosing WHICH of these nodes get solved and
which get pinned:

```
   I:   1    2    3    4    5=Ifr  6    7   ...  NPI+1  NPI+2
      ghost|gas  gas  gas |GHOST| solid solid ... solid |ghost
           |              |     |
   vent -> u(2,J)         u(Ifr,J) = INLET face (pinned -u_in)
   (rows Jv1..Jv2)        column Ifr: T pinned T_flame, YK2 pinned Y_in
                          columns > Ifr: u=v=0, T=TAMB, YK2=0, pc=0
```

`Ifr` = index of the first solid column = the "ghost column" of the moving
inlet. It starts at 5 (three gas columns of initial gap) and marches east.

---

## 3. One time step, end to end

```
 grenade06.m time loop (lines 104-204)
 │
 ├─ store old fields ONCE          (L114-115)   u_old,T_old,rho_old,... = previous TIME level
 ├─ front(time)                    (L117)       burn rate r(P) -> xf += r*Dt -> mdotpp; maybe flip a cell
 ├─ bound()                        (L118)       vent + inlet faces + ghost cells set
 │
 ├─ while not converged            (L123)       <- SIMPLE outer loop, structure of transient05.m L60-99
 │    ├─ density()                 (L125)       rho = (p+P_ATM)/(R*T)      [wc3]
 │    ├─ derivatives()                          velocity gradients (unchanged)
 │    ├─ ucoeff(); solve(u)                     x-momentum   + pin block
 │    ├─ vcoeff(); solve(v)                     y-momentum   + pin block
 │    ├─ bound()                                re-assert BCs (as supplied)
 │    ├─ pccoeff(); solve(pc)                   continuity   + accumulation term + solid excluded
 │    ├─ velcorr()                              p += relax_pc*pc; u,v corrected (unchanged)
 │    ├─ Tcoeff();  solve(T)                    energy       + pin block (T_flame / TAMB)
 │    ├─ YK2coeff(); solve(YK2)                 smoke        + pin block (Y_in / 0)
 │    ├─ mu(T), Gamma(T)           (L161-163)   gas properties [wc3 correlations]
 │    └─ viscosity(); bound()                   mueff (unchanged; mut=0 laminar)
 │
 └─ diagnostics                    (L170-199)   mass balance, p̄, T_vent, u_vent, K2CO3 history
```

Two deliberate differences from `transient05.m` and why:

1. **Old-field storage moved out of the while loop** (grenade06.m L108-115;
   in the supplied driver it sits INSIDE, L100-111). "Old" must mean *previous
   time level* (V&M §8.7.1). Inside the loop it gets overwritten every outer
   iteration, and the accumulation term `(rho_old-rho)/Dt` — our entire
   pressurisation mechanism — would read ~0 forever. One sentence in the
   report covers this.
2. **`density()` runs inside the while loop** (L125). That is not our idea —
   it is where wc3 (`convdiff03.m` L71-83) puts it. p, rho and u must converge
   *together* within a time step.

---

## 4. Mechanism 1 — the pin (`SP = -LARGE`), the single trick behind blocking

Every discretised equation in this code has the form (V&M eq. 7.7):

    aP*phi_P = aE*phi_E + aW*phi_W + aN*phi_N + aS*phi_S + b
    with aP = sum(a_nb) - SP + aPold        and   b = Su + aPold*phi_old

Set `SP = -LARGE` and `Su = LARGE*value`. Then aP ≈ LARGE, b ≈ LARGE*value,
the neighbour terms become negligible, and the solver returns

    phi_P ≈ (LARGE*value)/LARGE = value        — the cell is PINNED.

This is not our invention: it sits, commented out, in the supplied
`Tcoeff.m` L57-61 (a fixed-T block — how the course does baffles/obstacles).
We activate the same idiom in four places:

| Where | Lines | Pinned to | Meaning |
|---|---|---|---|
| `ucoeff.m` | 72-79 | 0 (i>Ifr) / −mdotpp/ρ_face (i=Ifr) | solid blocks flow; front face = inlet |
| `vcoeff.m` | 56-58 | 0 (I≥Ifr) | no vertical flow in solid |
| `Tcoeff.m` | 60-66 | T_flame (I=Ifr) / TAMB (I>Ifr) | ignited surface / cold charge |
| `YK2coeff.m` | 55-61 | Y_in (I=Ifr) / 0 | product loading / no smoke in solid |

A free side effect (ucoeff.m L103): `d_u = AREA*relax_u/aP ≈ 0` at pinned
faces, so `velcorr.m` never "corrects" a prescribed velocity — the same
mechanism the supplied code uses to protect its boundary faces (see the note
at the bottom of the supplied `pccoeff.m`).

`pccoeff.m` L45-51 excludes solid cells differently (aP=1, b=0, pc=0,
`continue`) because the pc equation has no Su/SP slot — but the idea is
identical: solid cells are outside the solved system, exactly like ghost
cells.

## 5. Mechanism 2 — the moving inlet (combustion as a boundary condition)

No transport equation contains a reaction source. Trace the path of one
timestep's worth of burned propellant:

```
 front.m                         bound.m / ucoeff.m                consequence
 ────────                        ───────────────────               ───────────
 P_front = P_ATM+mean(p)  L34    u(Ifr,J) = -mdotpp/rho_f          mass enters:
 r = a*(P/1e6)^n          L35 -> (bound L43-48, pin ucoeff L75-79)  convect.m turns u into
 mdotpp = f_gas*rho_s*r   L40                                       flux F_u(Ifr,J) ->
                                                                    pccoeff b' sees it (L55)
 ghost column pinned:            Tcoeff L60-62: T(Ifr,:)=T_flame   heat enters:
 (Tcoeff/YK2coeff pins)          YK2coeff L55-57: YK2(Ifr,:)=Y_in   hybrid upwind aE of the
                                                                    LAST GAS CELL reads the
                                                                    pinned ghost values ->
                                                                    inflow carries T_flame,Y_in
 xf += r*Dt               L39    when xf crosses a cell edge:      volume grows:
                                 front.m L43-57 flips the ghost     the "moving wall" — the
                                 column to gas, Ifr += 1            cavity gains one column
```

Why the enthalpy needs no source term: in `Tcoeff.m` the east coefficient is
`aE = max(-Fe, De - Fe/2, 0)`. At the last gas cell, Fe < 0 (inflow from the
east face), so aE ≈ |Fe| — the discretisation itself imports `Fe*T_ghost` =
(mass flux)×(flame temperature). That IS the combustion heat release,
delivered the same way the supplied duct problem's inlet delivers its inlet
temperature. Identically for YK2 with Y_in.

Your "moving wall" question from our discussion is answered by the flip block
(`front.m` L43-57): the freed cell already sits at T_flame/Y_in (it was the
pinned ghost), gets its p copied from the west neighbour and rho from the EOS,
and the inlet face shifts one column east. Nothing is dumped instantaneously —
the cell's solid mass entered the gas gradually, over the ~0.75 s the front
spent crossing it, via mdotpp.

## 6. Mechanism 3 — in-field pressure buildup (the part the old model outsourced)

Three code fragments, one loop:

```
   pccoeff.m L55-62                        density.m L23-29
   b' = (face fluxes) +                    rho = (1-x)rho +
        (rho_old - rho)*V/Dt    <────┐     x*(p+P_ATM)/(R*T)
        "mass a cell may STORE"      │            ^
              │                      │            │
              v                      │            │
   solve(pc) -> velcorr.m L13        └────────────┘
   p += relax_pc*pc      ────────────────────┘
```

If more mass flows in than out, b' > 0 → pc rises → `velcorr` raises p →
`density()` raises rho → the accumulation term absorbs the difference. The
absolute pressure level is anchored by the total gas mass through the EOS —
this replaces the old 0-D `P_chamber` ODE, and it is why SIMPLE's usual
"pressure known only up to a constant" does not bite here.

And the loop closes back to the burn: `front.m` L36 reads that same field
pressure to set r — pressure up → burn faster → more gas → pressure up, until
the vent relieves it. All four arrows of the design-doc feedback diagram live
in these files.

## 7. Mechanism 4 — the vent (bound.m L33-38)

    u_orf  = Cd*sqrt(2*max(p(2,J),0)/rho(2,J))         orifice/Bernoulli law
    u(2,J) = (1-relax)*u(2,J) + relax*(-u_orf)         under-relaxed update

The vent speed is *pulled from the field pressure*, not prescribed. This is
the second half of the pressurisation physics: the supplied outlet trick
(`bound.m` L23-41 of the ORIGINAL, the `m_in/m_out` rescaling) is deliberately
NOT used, because it forces inflow = outflow every instant — i.e. it forbids
the chamber from ever pressurising. Say this in the report; it is the key
boundary-condition decision of the whole model.

## 8. First-run protocol (do these in order, ~30 min total)

1. `VENT_OPEN=0, BURN_ON=0`, set an initial hot blob (e.g. `T(2:6,2:NPJ+1)=600`
   in init) → run 0.05 s. PASS: total mass constant (massErr column ~1e-12),
   p̄ rises to the ideal-gas value. Tests mechanism §6 alone.
2. `VENT_OPEN=1, BURN_ON=0`, init `p(2:Ifr-1,:)=2000` → blow-down. PASS: p̄
   decays smoothly; compare to the 10-line 0-D orifice ODE. Tests §7.
3. `BURN_ON=1`, defaults → watch the printed massErr and pbar columns.
   Divergence checklist: relax_rho 0.1→0.05, then Dt 2e-5→1e-5, then
   PC_ITER 30→50, then check u(2,Jv) sign.
4. Grid/Dt refinement (V4 in the design doc) once stable.

Known soft spots to watch (honest list): the cell flip may kick pc for a few
iterations (acceptable: it happens every ~0.75 s of simulated time, ~37500
steps apart); the wall-shear SP in ucoeff.m L49-57 uses supplied wall-function
logic which at yplus=1 reduces to laminar shear (correct, but verify no NaN
from k=0); `Y_in`≈0.9 is a loading, not a mass fraction ≤1 (by design, §1 of
design doc, item 4 of limitations).

## 9. Where each research question comes out

- RQ1 (K2CO3 vs composition): `K2prod` history column (driver L184) = solid
  algebra × burned depth; PLUS the field `YK2` and the vented flux — run the
  script at xKN = 0.55/0.65/0.75 and compare.
- RQ2 (temperature vs composition): `T` field, `Tvent` history column, against
  the 891 °C (1164 K) K2CO3 melting criterion. T_flame(xKN) enters through
  `chemistry.m`; the field distribution and the vent temperature are the CFD's
  contribution.
