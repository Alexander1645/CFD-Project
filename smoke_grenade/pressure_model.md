# Modelling the pressure buildup (low-Mach thermodynamic-pressure closure)

This note describes how the smoke-grenade model represents the chamber
pressurisation caused by the burning charge, and how that pressure is coupled
consistently to the 2-D flow field.

## Why a special treatment is needed

The flow is strongly subsonic (Mach ≈ 0.1), so a fully compressible solver with
its acoustic time-step is unnecessary and prohibitively expensive. But the burn
converts **solid** propellant (ρ_solid ≈ 1800 kg/m³) into gas (ρ_gas ≈ 0.4 kg/m³),
an enormous volumetric source. Injecting that source directly into a standard
incompressible-projection (SIMPLE) continuity equation forces a velocity
divergence of order 5000 s⁻¹ in a single cell, which the pressure solve cannot
absorb — the field diverges. The gas must be allowed to **pressurise** the
chamber, not only to flow.

## The low-Mach pressure split

In the low-Mach (zero-Mach-number) combustion formulation the pressure separates
into two parts:

- a spatially **uniform thermodynamic pressure** `P₀(t)` — the chamber pressure
  that sets the gas density through the equation of state, and
- a small **hydrodynamic pressure** `p(x,t)` that drives the flow and is solved
  by SIMPLE.

This split is exact in the low-Mach limit; `P₀(t)` is not an add-on, it is the
thermodynamic pressure of the system. The equation of state is

    ρ(x,t) = P₀(t) / (R · T(x,t)).

## Chamber mass balance — the pressure-buildup equation

Integrating the continuity equation over the fixed chamber volume gives a single
ordinary differential equation for `P₀(t)`:

    d(M_gas)/dt = Ṡ_gen − ṁ_vent(P₀),     M_gas = P₀ · C_T,

with

    C_T      = (1/R) · Σ (V_cell / T_cell)             "gas capacity" of the box
    Ṡ_gen    = f_gas · ρ_solid · Σ (ẇ_burn · V_cell)    real solid→gas generation
    ṁ_vent   = C_d · A_vent · √(2 ρ_v (P₀ − P_atm)),   ρ_v = P₀ /(R·T_vent)

Here `ẇ_burn` is the rate-anchored regression source (the measured Saint-Robert
law `r = a·Pⁿ`), `f_gas` the gaseous mass fraction of the products (the K₂CO₃ and
soot condense and do not pressurise), and the vent is treated as an incompressible
orifice (valid while the overpressure stays well below one atmosphere). **Gas
generated faster than the orifice can vent raises `P₀` — that is the pressure
buildup.**

Because `ṁ_vent` depends on the unknown `P₀`, the equation is solved
**semi-implicitly** each time step by an under-relaxed fixed-point iteration
(`run_grenade.m`, block 1b). The iteration converges monotonically and `P₀`
stays bounded.

## Coupling to the 2-D flow, and a resolution limit

`P₀` is advanced **before** the density update, so the rising chamber pressure is
felt by the 2-D field through the EOS as a gentle bulk increase in ρ. This is a
**one-way** coupling: the chamber pressure influences the field's density, and the
field's temperature field feeds back into `C_T`.

It is tempting to also inject the full solid-density source
`f_gas·ẇ_burn·ρ_solid` directly into the 2-D continuity so the field itself shows
the pressure-driven venting. In the integral (whole-domain) sense this is
consistent — summing the source with the compression term gives exactly `ṁ_vent`.
But it **fails locally**: in each individual front cell the source is
≈ 2000 kg/m³/s, a velocity divergence of ~5000 s⁻¹ that a 2 mm cell cannot store
or resolve (the gas blowing off a regressing surface is a genuinely sub-grid
feature). The global `dP₀/dt` feedback balances the *total* mass budget but cannot
absorb a *local* cell spike, so the velocity field goes to NaN. Resolving it would
need sub-millimetre cells and `Δt ∼ 10⁻⁵ s`, which is out of scope here.

The model therefore keeps the **0-D `P₀` closure as the authoritative pressure /
venting model** (it carries the real solid-density generation safely, with no
cell-level divergence), and leaves the 2-D continuity on the gentle gas-density
source so the field stays stable and shows the internal circulation pattern.

## Numerical consequences

- The `P₀` closure is a 0-D ODE and is stable at the flow time-step (`Δt = 10⁻³ s`).
- `relax_rho = 0.05` for the gas-phase flow (its historical stable value); the
  field need not track `P₀` tightly because it no longer carries the stiff source.
- The reported **chamber pressure** and a consistent **0-D orifice exit velocity**
  come from this closure. The 2-D field's vent velocity is the internal pattern,
  not the discharge speed — these should be labelled distinctly in the report.
- A realistic absolute efflux still requires scaling the burning area to the grain
  cross-section (the present full-height slab over-generates); that is a separate,
  independent improvement.

## What is verified vs. what needs a MATLAB run

Verified independently (Python, `lowmach_verify.py`): the fixed-point pressure
solve converges and is bounded; the chamber pressure builds modestly (≈1.4 atm
peak for the test case) and then vents; and the closure identity
`net 2-D source = ṁ_vent` holds to ~1e-16. The full 2-D field stability at the
chosen `Δt` and `relax_rho` should be confirmed on the first MATLAB run (watch the
first ~100 steps for oscillation; reduce `Δt` or raise `PC_ITER` if needed).
