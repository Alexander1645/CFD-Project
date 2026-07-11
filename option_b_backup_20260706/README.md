# Option B — advancing burning-surface smoke-grenade model

UNTESTED skeleton (built without MATLAB). Strictly follows the supplied
`final_assignment` solver structure; every deviation is tagged `[B]`
(`grep -n "\[B\]" *.m`).

- Run: open MATLAB in this folder, run `grenade06.m` (set `xKN` at line 61).
- BEFORE the first burn run, do the verification protocol:
  `optionB_walkthrough.md` §8 (sealed-box test, blow-down test).
- Design and reasoning: `optionB_design.md`
- How the files work together (study guide, diagrams, line refs):
  `optionB_walkthrough.md`

| file | role |
|---|---|
| grenade06.m | driver (from transient05.m) |
| front.m | NEW — moves the burning surface at r = a·Pⁿ |
| chemistry.m | composition closure (yields, flame T) — reused |
| density.m | ideal-gas EOS (from wc3) |
| init/bound/ucoeff/vcoeff/pccoeff/Tcoeff | supplied files + marked [B] edits |
| YK2coeff.m | NEW — smoke scalar, clone of Tcoeff |
| convect/derivatives/solve/velcorr/viscosity | supplied, byte-identical |
