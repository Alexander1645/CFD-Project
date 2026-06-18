Introduction to CFD (4RC30)
Unsteady flow problems
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. YaliTang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

Summary of last lecture
| • convection |          | = diffusion   | + (source – |     | sink) |     |     |
| ------------ | -------- | ------------- | ----------- | --- | ----- | --- | --- |
|              | div(ρφu) | = div(Γgradφ) |             | + S |       |     |     |
φ
•
General form of discretized equations:
|     |       | ∑     |     |     | ∑   |        |     |
| --- | ----- | ----- | --- | --- | --- | ------ | --- |
|     | a φ = | a φ   | + S |     | a = | a + ∆F | − S |
|     | P P   | nb nb | u   |     | P   | nb     | P   |
• Spatial discretization schemes: CDS, UDS and Hybrid
•
Momentum equations: SIMPLE algorithm
2 Introduction to CFD (4RC30)

Content of this lecture (Chapter 8)
• Unsteady heat conduction
• Time discretization schemes
• Unsteady convection-diffusion
• Transient SIMPLE
• Example: Vortex Shedding
3 Introduction to CFD (4RC30)

Unsteady flows
• Unsteady transport equation:
∂(ρφ)
+div(ρφu) = div(Γgradφ)+ S
φ
∂t
• Integrated form:
𝑡𝑡+∆𝑡𝑡 𝑡𝑡+Δ𝑡𝑡 𝑡𝑡+Δ𝑡𝑡 𝑡𝑡+Δ𝑡𝑡
𝜕𝜕
� � 𝜌𝜌𝜌𝜌 𝑑𝑑𝑡𝑡𝑑𝑑𝑑𝑑 + � � 𝐧𝐧 � 𝜌𝜌𝜌𝜌𝐮𝐮 𝑑𝑑𝑑𝑑𝑑𝑑𝑡𝑡 = � � 𝐧𝐧� Γgrad𝜌𝜌 𝑑𝑑𝑑𝑑𝑑𝑑𝑡𝑡 + � � 𝑆𝑆𝜙𝜙𝑑𝑑𝑑𝑑𝑑𝑑𝑡𝑡
𝜕𝜕𝑡𝑡
𝐶𝐶𝑉𝑉 𝑡𝑡 𝑡𝑡 𝐴𝐴 𝑡𝑡 𝐴𝐴 𝑡𝑡 𝐶𝐶𝑉𝑉
4 Introduction to CFD (4RC30)

Unsteady heat conduction
Unsteady 1D heat conduction:
Specific heat [J/(kg K)]
|     |     |     |     |     | ∂T   | ∂   |  ∂T |    |     |     |
| --- | --- | --- | --- | --- | ---- | --- | ---- | --- | --- | --- |
|     |     |     |     | ρC  |      | =   | k    | + S |     |     |
|     |     |     |     |     |      |     |     |    |     |     |
|     |     |     |     |     | P ∂t | ∂x  | ∂x   |     |     |     |
|     |     |     |     |     |      |     |     |    |     |     |
Thermal conductivity [W/(m K)]
|     |     | t+∆t   | ∂T  |      | t+∆t |       | ∂T  |       | t+∆t |       |
| --- | --- | ------ | --- | ---- | ---- | ----- | --- | ----- | ---- | ----- |
|     |     | ∫ ∫ ρC |     |      | = ∫  | ∫n⋅(k |     |       | + ∫  | ∫     |
|     |     |        |     | dtdV |      |       |     | )dAdt |      | SdVdt |
P
|         |     |        | ∂t  |        |        |     | ∂x  |      |      |           |
| ------- | --- | ------ | --- | ------ | ------ | --- | --- | ---- | ---- | --------- |
|         |     | CV t   |     |        | t      | A   |     |      | t    | CV        |
|         |     |        |     | t+∆t  |        | −T  |     |      | −T  | t+∆t      |
|         |     |        |     |        | T      |     |     | T    |      |           |
| ρC      |     | −T0)∆V | =   | ∫      |        | E P | −k  | P    | W    | + ∫ S∆Vdt |
|         | (T  |        |     | k     | A      |     | A   |      | dt  |           |
|         | P   | P P    |     |        | e e δx |     | w   | w δx |      |           |
|         |     |        |     |       |        |     |     |      |     |           |
|         |     |        |     | t      |        | PE  |     |      | WP   | t         |
| At t+Δt |     | At t   |     |        |        |     |     |      |      |           |
Central differencing
5 Introduction to CFD (4RC30)

Treatment temperature in time
|       |        | t+∆t |     | −T   |     |     | −T  |    | t+∆t |       |     |     |     |
| ----- | ------ | ---- | ---- | ---- | --- | --- | --- | --- | ---- | ----- | --- | --- | --- |
|       |        |      |      | T    |     |     | T   |     |      |       |     |     |     |
|       | −T0)∆V | ∫    |      | E    | P   |     | P   | W   |      | ∫     |     |     |     |
| ρC (T |        | =    | k A |      | −k  | A   |     | dt | +    | S∆Vdt |     |     |     |
| P     | P P    |      | e    | e δx |     | w w | δx  |     |      |       |     |     |     |
|       |        |      |     |      |     |     |     |    |      |       |     |     |     |
|       |        | t    |      | PE   |     |     | WP  |     |      | t     |     |     |     |
Temperatures can be evaluated at different time:
t+∆t
|     |     |     |     |     | ∫ T dt | = θT | +(1−θ)T0∆t |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | ------ | ----- | ----------- | --- | --- | --- | --- | --- | --- |
|     |     |     |     |     |        |      |             |     |     |    |     |     |     |
|     |     |     |     |     | P      |       | P           |     |     | P   |     |     |     |
t
t+∆t
=T0∆t
|     |     | explicit  |     | θ=  | 0   | ∫   | T dt |     |     |     | T at old time level t | only |     |
| --- | --- | --------- | --- | --- | --- | --- | ---- | --- | --- | --- | --------------------- | ---- | --- |
|     |     |           |     |     |     |     | P    | P   |     |     |                       |      |     |
t
t+∆t
|     |     |     |     | θ=  |     | ∫   |      | =    | +T0)∆t |     |                 |     |     |
| --- | --- | --- | --- | --- | --- | --- | ---- | ---- | ------ | --- | --------------- | --- | --- |
|     |     |     |     |     | 1   |     | T dt | 1 (T |        |     | T at t and t+Δt |     |     |
|     |     |     |     |     | 2   |     | P    | 2    | P      | P   |                 |     |     |
t
implicit
t+∆t
|     |     |     |     | θ=1 |     | ∫   | T dt | =T  | ∆t  |     | T at new time level t+Δt |     | only |
| --- | --- | --- | --- | --- | --- | --- | ---- | --- | --- | --- | ------------------------ | --- | ---- |
|     |     |     |     |     |     |     | P    | P   |     |     |                          |     |      |
t
6 Introduction to CFD (4RC30)

Treatment temperature in time
|             |        |     | t+∆t       |    |     | −T  |     |     | −T   |    | t+∆t |       |     |     |     |     |
| ----------- | ------ | --- | ---------- | --- | --- | --- | --- | --- | ---- | --- | ---- | ----- | --- | --- | --- | --- |
|             |        |     |            |     |     | T   |     |     | T    |     |      |       |     |     |     |     |
|             | −T0)∆V |     |            | ∫   |     | E   | P   |     | P    | W   |      | ∫     |     |     |     |     |
| ρC (T       |        |     | =          | k  | A   |     | −k  | A   |      | dt | +    | S∆Vdt |     |     |     |     |
| P           | P      | P   |            |     | e e | δx  |     | w   | w δx |     |      |       |     |     |     |     |
|             |        |     |            |    |     |     |     |     |      |    |      |       |     |     |     |     |
|             |        |     |            | t   |     |     | PE  |     |      | WP  |      | t     |     |     |     |     |
| Divided by  |        |     | to obtain: |     |     |     |     |     |      |     |      |       |     |     |     |     |
𝑑𝑑∆𝑡𝑡
|     |     | 0   |     |     |     |     |     |     |     |     |     |     | 0   | 0   | 0   | 0   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
(𝑇𝑇 𝑃𝑃 − 𝑇𝑇𝑃𝑃) 𝑇𝑇 𝐸𝐸 − 𝑇𝑇 𝑃𝑃 𝑇𝑇 𝑃𝑃 − 𝑇𝑇 𝑊𝑊 𝑇𝑇𝐸𝐸 − 𝑇𝑇𝑃𝑃 𝑇𝑇𝑃𝑃 − 𝑇𝑇𝑊𝑊
| 𝑃𝑃   |     |     |       |     | 𝑒𝑒  |      |     | 𝑤𝑤  |      |     |     | 𝑒𝑒    |      | 𝑤𝑤   |      | ̅       |
| ---- | --- | --- | ----- | --- | --- | ---- | --- | --- | ---- | --- | --- | ----- | ---- | ---- | ---- | ------- |
| 𝜌𝜌𝐶𝐶 |     |     | Δ𝑥𝑥 = | 𝜃𝜃  | 𝑘𝑘  |      | −   | 𝑘𝑘  |      | +   | 1 − | 𝜃𝜃 𝑘𝑘 |      | − 𝑘𝑘 |      | + 𝑆𝑆Δ𝑥𝑥 |
|      |     |     |       |     |     | 𝑃𝑃𝐸𝐸 |     |     | 𝑊𝑊𝑃𝑃 |     |     |       | 𝑃𝑃𝐸𝐸 |      | 𝑊𝑊𝑃𝑃 |         |
|      | Δ𝑡𝑡 |     |       |     |     | 𝛿𝛿𝑥𝑥 |     |     | 𝛿𝛿𝑥𝑥 |     |     |       | 𝛿𝛿𝑥𝑥 |      | 𝛿𝛿𝑥𝑥 |         |
|      |     |     |       |     |     | 0    |     |     |      |     | 0   | 0     |      |      |      | 0       |
𝑎𝑎 𝑃𝑃 𝑇𝑇 𝑃𝑃 = 𝑎𝑎 𝑊𝑊 𝜃𝜃𝑇𝑇 𝑊𝑊 + 1 − 𝜃𝜃a 𝑇𝑇𝑊𝑊 + 𝑎𝑎 𝐸𝐸 𝜃𝜃𝑇𝑇a 𝐸𝐸 0+ 1 −a𝜃𝜃 𝑇𝑇𝐸𝐸 +a 𝑎𝑎𝑃𝑃 −b1 − 𝜃𝜃 𝑎𝑎 𝑊𝑊 − 1 − 𝜃𝜃 𝑎𝑎 𝐸𝐸 𝑇𝑇𝑃𝑃 + 𝑏𝑏
|     |     |     |     |     | P   |     |     | P   |     | W   |     | E   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
∆x
|     |     |     |     |     |     |     |     |     |     | k   | k   |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
a0
|     |     |     | θ(a |     | + a | )+  |     | ρC  |     | w   |     | e   | S∆x |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     |     |     |     | W   |     | E   | P   | P   | ∆t  | δx  | δx  |     |     |     |     |     |
|     |     |     |     |     |     |     |     |     |     | WP  |     | PE  |     |     |     |     |
7 Introduction to CFD (4RC30)

Explicit scheme
Linearize source term:
| 𝜽𝜽  | = 𝟎𝟎 |     |     |     |     |     |
| --- | ---- | --- | --- | --- | --- | --- |
| = + | T0   |     |     |     |     |     |
| b S | S    |     |     |     |     |     |
| u   | P P  |     |     |     |     |     |
All temperatures are evaluated at the old time:
| a T = | a T0 + a | T0 +[a0 | −(a | + a − | S )]T0 + | S   |
| ----- | -------- | ------- | --- | ----- | -------- | --- |
| P P   | W W      | E E     | P   | W E   | P P      | u   |
0
| 𝑎𝑎 𝑃𝑃 | 𝑎𝑎𝑃𝑃    |     | 𝑎𝑎 𝑊𝑊 | 𝑎𝑎 𝐸𝐸 |     |     |
| ----- | ------- | --- | ----- | ----- | --- | --- |
|       |         |     | 𝑤𝑤    | 𝑒𝑒    |     |     |
| 0     | Δ𝑥𝑥     |     | 𝑘𝑘    | 𝑘𝑘    |     |     |
| 𝑎𝑎𝑃𝑃  | 𝜌𝜌𝐶𝐶 𝑃𝑃 |     |       |       |     |     |
|       |         |     | 𝑊𝑊𝑃𝑃  | 𝑃𝑃𝐸𝐸  |     |     |
|       | Δ𝑡𝑡     |     | 𝛿𝛿𝑥𝑥  | 𝛿𝛿𝑥𝑥  |     |     |
8 Introduction to CFD (4RC30)

Assessment explicit scheme
|       | T0  | T0 +[a0 |     |       | )]T0 |     |     |     |
| ----- | --- | ------- | --- | ----- | ---- | --- | --- | --- |
| a T = | a + | a       | −(a | + a − | S    | + S |     |     |
| P P   | W W | E E     | P   | W E   | P    | P u |     |     |
• Backward differencing scheme O(1)
• All coefficients should be positive:
|     |     |     |     | a0  | −a −a | > 0 |     |     |
| --- | --- | --- | --- | --- | ----- | --- | --- | --- |
|     |     |     |     | P   | W     | E   |     |     |
In case of uniform grid and constant k:
|     |        |     |     |     | ∆x  | 2k  |         | (∆x)2 |
| --- | ------ | --- | --- | --- | --- | --- | ------- | ----- |
|     | a0 > a | + a | ⇒   | ρC  | >   | ⇒   | ∆t < ρC |       |
|     | P      | W E |     | P   |     |     |         | P     |
|     |        |     |     |     | ∆t  | ∆x  |         | 2k    |
• Efficient for simple conduction calculations
9 Introduction to CFD (4RC30)

Fully implicit scheme
Linearize source term:
|     |     |     | 𝜽𝜽  | =   | 𝟏𝟏  |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|     |     | 𝑢𝑢  | 𝑃𝑃  | 𝑃𝑃  |     |     |     |     |
All temperatures are eva𝑏𝑏lu=ate𝑆𝑆d +at 𝑆𝑆th𝑇𝑇e new time:
|     | =   |     | +   | + a0T0 |     | +   |     |     |
| --- | --- | --- | --- | ------ | --- | --- | --- | --- |
| a   | T   | a T | a   | T      |     | S   |     |     |
| P   | P   | W W |     | E E    | P P | u   |     |     |
0
|      |     | 𝑎𝑎 𝑃𝑃 |     |      |      | 𝑎𝑎𝑃𝑃 | 𝑎𝑎 𝑊𝑊 | 𝑎𝑎 𝐸𝐸 |
| ---- | --- | ----- | --- | ---- | ---- | ---- | ----- | ----- |
|      |     |       |     |      |      |      | 𝑤𝑤    | 𝑒𝑒    |
|      | 0   |       |     |      |      | Δ𝑥𝑥  | 𝑘𝑘    | 𝑘𝑘    |
| 𝑎𝑎𝑃𝑃 |     | 𝑊𝑊    | 𝐸𝐸  | 𝑃𝑃   |      | 𝑃𝑃   |       |       |
|      | +   | 𝑎𝑎 +  | 𝑎𝑎  | − 𝑆𝑆 | 𝜌𝜌𝐶𝐶 |      |       |       |
|      |     |       |     |      |      |      | 𝑊𝑊𝑃𝑃  | 𝑃𝑃𝐸𝐸  |
|      |     |       |     |      |      | Δ𝑡𝑡  | 𝛿𝛿𝑥𝑥  | 𝛿𝛿𝑥𝑥  |
10 Introduction to CFD (4RC30)

Assessment Implicit scheme
| a T = | a T + a | T + a0T0 | + S   |     |
| ----- | ------- | -------- | ----- | --- |
| P P   | W W     | E E      | P P u |     |
• Forward differencing scheme O(1)
• Stability guaranteed: all coefficients are positive
| • Accuracy ensured by choosing small  |     |       |     | :   |
| ------------------------------------- | --- | ----- | --- | --- |
|                                       |     | ∆t |u | |   |     |
Courant-Friedrichs-Lewy stability
|     | =   | max | <1  | ∆𝒕𝒕 |
| --- | --- | --- | --- | --- |
N
CFL
|     |     | ∆x  |     | condition: Courant number ≤ 1 |
| --- | --- | --- | --- | ----------------------------- |
min
• Recommended for general-purpose transient calculations
11 Introduction to CFD (4RC30)

Crank-Nicolson scheme
Linearize source term:
|     |     |     |     |     |     | 𝜽𝜽 = | 𝟏𝟏⁄𝟐𝟐 |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | ---- | ----- | --- | --- | --- | --- | --- |
|     |     |     |     |     | 1   | 1    | 0     |     |     |     |     |     |
All temperatures are eva𝑏𝑏lu=at𝑆𝑆e𝑢𝑢d+ at b𝑆𝑆o𝑃𝑃t𝑇𝑇h𝑃𝑃 t+he o𝑆𝑆 𝑃𝑃ld𝑇𝑇 𝑃𝑃time and the new time:
|       |      |     |      |      | 2   | 2            |     |      |       |       |       |         |
| ----- | ---- | --- | ---- | ---- | --- | ------------ | --- | ---- | ----- | ----- | ----- | ------- |
|       |      |     |      | 0    |     |              | 0   |      |       |       |       |         |
|       |      | 𝑇𝑇  | 𝑊𝑊 + | 𝑇𝑇𝑊𝑊 |     | 𝑇𝑇 𝐸𝐸 + 𝑇𝑇𝐸𝐸 |     | 0    | 𝑎𝑎 𝑊𝑊 | 𝑎𝑎 𝐸𝐸 | 𝑆𝑆 𝑃𝑃 | 0       |
| 𝑃𝑃 𝑃𝑃 | 𝑊𝑊   |     |      |      | 𝐸𝐸  |              |     | 𝑎𝑎𝑃𝑃 |       |       |       | 𝑇𝑇𝑃𝑃 𝑢𝑢 |
| 𝑎𝑎 𝑇𝑇 | = 𝑎𝑎 |     |      | +    | 𝑎𝑎  |              | +   | −    |       | −     | +     | + 𝑆𝑆    |
|       |      |     | 2    |      |     | 2            |     |      | 2     | 2     | 2     |         |
0
|         |         | 𝑃𝑃  |          |     |      |      |      | 𝑊𝑊   |     | 𝐸𝐸        |     |     |
| ------- | ------- | --- | -------- | --- | ---- | ---- | ---- | ---- | --- | --------- | --- | --- |
|         | 𝑎𝑎      |     |          |     |      | 𝑎𝑎𝑃𝑃 |      | 𝑎𝑎   |     | 𝑎𝑎        |     |     |
|         |         |     |          |     |      |      |      | 𝑤𝑤   |     | 𝑒𝑒        |     |     |
| 1       |         |     | 0        | 1   |      | Δ𝑥𝑥  |      | 𝑘𝑘   |     | 𝑘𝑘        |     |     |
| 2 𝑎𝑎 𝑊𝑊 | + 𝑎𝑎 𝐸𝐸 | +   | 𝑎𝑎𝑃𝑃−2𝑆𝑆 | 𝑃𝑃  | 𝜌𝜌𝐶𝐶 | 𝑃𝑃   |      |      |     |           |     |     |
|         |         |     |          |     |      | Δ𝑡𝑡  | 𝛿𝛿𝑥𝑥 | 𝑊𝑊𝑃𝑃 |     | 𝛿𝛿𝑥𝑥 𝑃𝑃𝐸𝐸 |     |     |
12 Introduction to CFD (4RC30)

Assessment Crank-Nicolson scheme
|       |      |     |     | 0    |     |      | 0    |      |     |     |     |      |      |
| ----- | ---- | --- | --- | ---- | --- | ---- | ---- | ---- | --- | --- | --- | ---- | ---- |
|       |      |     | 𝑊𝑊  | 𝑇𝑇𝑊𝑊 |     | 𝐸𝐸   | 𝑇𝑇𝐸𝐸 | 0    | 𝑊𝑊  | 𝐸𝐸  | 𝑃𝑃  | 0    |      |
|       |      | 𝑇𝑇  | +   |      |     | 𝑇𝑇 + |      |      | 𝑎𝑎  | 𝑎𝑎  | 𝑆𝑆  |      |      |
| 𝑃𝑃 𝑃𝑃 | 𝑊𝑊   |     |     |      | 𝐸𝐸  |      |      | 𝑎𝑎𝑃𝑃 |     |     |     | 𝑇𝑇𝑃𝑃 | 𝑢𝑢   |
| 𝑎𝑎 𝑇𝑇 | = 𝑎𝑎 |     |     | +    | 𝑎𝑎  |      |      | +    | − − |     | +   |      | + 𝑆𝑆 |
|       |      |     | 2   |      |     | 2    |      |      | 2   | 2   | 2   |      |      |
• Central differencing scheme O(2)
• All coefficients should be positive:
|     |     |     |     |     |     |     |      | a   | a   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | ---- | --- | --- | --- | --- | --- | --- |
|     |     |     |     |     |     |     | a0 − | W − | E > |     |     |     |     |
0
P
|     |     |     |     |     |     |     |     | 2   | 2   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
In case of uniform grid and constant k:
|     |     |      | a + | a   |     |     | ∆x  | k   |     |     |      |     | (∆x)2 |
| --- | --- | ---- | --- | --- | --- | --- | --- | --- | --- | --- | ---- | --- | ----- |
|     |     | a0 > | W   | E   | ⇒   | ρC  |     | >   | ⇒   | ∆t  | < ρC |     |       |
|     |     | P    |     |     |     |     | P   |     |     |     |      | P   |       |
|     |     |      | 2   |     |     |     | ∆t  | ∆x  |     |     |      |     | k     |
• Usually used in conjunction with spatial central differencing
13 Introduction to CFD (4RC30)

| Steady vs. |     | Unsteady |     |     |     |     |     |     |     |     |     |
| ---------- | --- | -------- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
For pure-diffusion problems:
Steady                                                                 Unsteady
|       |         |         |      | a T | = a T | + a | T   | + a0T0 | + S |     |     |
| ----- | ------- | ------- | ---- | --- | ----- | --- | --- | ------ | --- | --- | --- |
|       |         |         |      | P P | W     | W   | E E | P P    | u   |     |     |
| 𝑃𝑃 𝑃𝑃 | 𝑊𝑊 𝑊𝑊   | 𝐸𝐸 𝐸𝐸   | 𝑢𝑢   |     |       |     |     |        |     |     |     |
| 𝑎𝑎 𝑇𝑇 | = 𝑎𝑎 𝑇𝑇 | + 𝑎𝑎 𝑇𝑇 | + 𝑆𝑆 |     |       |     |     |        |     |     |     |
a0
|            |            |           |           |     | a   |       |     |      | a   | a   | b   |
| ---------- | ---------- | --------- | --------- | --- | --- | ----- | --- | ---- | --- | --- | --- |
|            |            |           |           |     | P   |       |     | P    | W   | E   |     |
|            |            |           |           |     |     |       |     | ∆x   | k   | k   |     |
| 𝑃𝑃         |            | 𝑊𝑊        | 𝐸𝐸        | a0  |     |       |     |      |     |     |     |
| 𝑎𝑎         |            | 𝑎𝑎        | 𝑎𝑎        | +   | a + | a − S | ρC  |      | w   | e   | S   |
|            |            |           |           | P   | W   | E     | P   | P ∆t | δx  | δx  | u   |
|            |            | 𝑤𝑤        | 𝑒𝑒        |     |     |       |     |      | WP  | PE  |     |
|            |            | 𝑘𝑘        | 𝑘𝑘        |     |     |       |     |      |     |     |     |
| 𝑎𝑎 𝑊𝑊 + 𝑎𝑎 | 𝐸𝐸 − 𝑆𝑆 𝑃𝑃 |           |           |     |     |       |     |      |     |     |     |
|            |            | 𝛿𝛿𝑥𝑥 𝑊𝑊𝑃𝑃 | 𝛿𝛿𝑥𝑥 𝑃𝑃𝐸𝐸 |     |     |       |     |      |     |     |     |
14 Introduction to CFD (4RC30)

Convection-diffusion equation
• Unsteady convection-diffusion equation:
∂(ρφ)
|     |     | +div(ρφu) |     | = div(Γgradφ)+ |     |     |     |     |
| --- | --- | --------- | --- | -------------- | --- | --- | --- | --- |
S
φ
∂t
• Discretized form (implicit):
|     | steady |     | transient contribution |     |     | unsteady |     |     |
| --- | ------ | --- | ---------------------- | --- | --- | -------- | --- | --- |
ρ0∆V
|     |     |     | a0 = | P   |       |       |        |     |
| --- | --- | --- | ---- | --- | ----- | ----- | ------ | --- |
|     |     |     |      |     | a φ = | ∑ a φ | + a0φ0 | + S |
P
|          |               |        |     | ∆t  | P P | nb nb | P P       | u   |
| -------- | ------------- | ------ | --- | --- | --- | ----- | --------- | --- |
| 𝑎𝑎𝑃𝑃𝜌𝜌𝑃𝑃 | �𝑎𝑎𝑛𝑛𝑛𝑛𝜌𝜌𝑛𝑛𝑛𝑛 | 𝑆𝑆𝑢𝑢   |     |     |     |       |           |     |
|          | =             | +      |     |     | a = | ∑ a + | a0 + ∆F − | S   |
|          |               |        |     |     | P   | nb    | P         | P   |
| 𝑎𝑎𝑃𝑃 =   | �𝑎𝑎𝑛𝑛𝑛𝑛 + ∆𝐹𝐹 | − 𝑆𝑆𝑃𝑃 |     |     |     |       |           |     |
15 Introduction to CFD (4RC30)

Transient SIMPLE
|     | START | Semi-Implicit Method for Pressure-Linked Equations  |     |     |     |     |
| --- | ----- | --------------------------------------------------- | --- | --- | --- | --- |
(SIMPLE)
|             |     | •   | Solve discretized equations for   |     | and  |     |
| ----------- | --- | --- | --------------------------------- | --- | ---- | --- |
|             |     | •   | Solve discretized equation for    |     | ∗    | ∗   |
| Initialize  |     | and |                                   |     |      |     |
|             |     |     | Correct pressure and velocities𝑢𝑢 |     | 𝑣𝑣   |     |
|             |     | •   |                                   |     | ′    |     |
• Solve any other discretized equ𝑝𝑝ations for
|     | 𝑢𝑢,𝑣𝑣,𝑝𝑝 | 𝜌𝜌  |     |     |     |     |
| --- | -------- | --- | --- | --- | --- | --- |
• Convergence?
|     | Set time step  |     |  Yes:   stop |                   |                 | 𝜌𝜌   |
| --- | -------------- | --- | ------------- | ----------------- | --------------- | ---- |
| and |                |     |  No:   set   |                   |                 |      |
|     |                | ∆𝑡𝑡 |               | repe∗at seque∗nce | ∗               | ∗    |
|     |                |     |               | 𝑝𝑝 = 𝑝𝑝,𝑢𝑢        | = 𝑢𝑢,𝑣𝑣 = 𝑣𝑣,𝜌𝜌 | = 𝜌𝜌 |
𝑢𝑢,𝑣𝑣,𝑝𝑝 𝜌𝜌
| 𝑡𝑡 = 𝑡𝑡 +  | ∆𝑡𝑡     |              |     |     |     |     |
| ---------- | ------- | ------------ | --- | --- | --- | --- |
| 0          | 0 0     | 0            |     |     |     |     |
| 𝑢𝑢 = 𝑢𝑢,𝑣𝑣 | = 𝑣𝑣,𝑝𝑝 | = 𝑝𝑝,𝜌𝜌 = 𝜌𝜌 |     |     |     |     |
SIMPLE algorithm to get
| converged   |          | and |     |     |     |     |
| ----------- | -------- | --- | --- | --- | --- | --- |
|             | 𝑢𝑢,𝑣𝑣,𝑝𝑝 | 𝜌𝜌  |     |     |     |     |
NO YES
|     |     | ?   | STOP |     |     |     |
| --- | --- | --- | ---- | --- | --- | --- |
𝑡𝑡 > 𝑡𝑡𝑒𝑒𝑛𝑛𝑒𝑒
16 Introduction to CFD (4RC30)

Pseudo transient simulations
• Under-relaxed x-momentum equation:
Previous
|     |     |     |       |     |     |     |     |      |     |     |      |           |
| --- | --- | --- | ----- | --- | --- | --- | --- | ----- | --- | --- | ----- | --------- |
|     | a   |     |       |     |     |     |     |       |     | a   |       | iteration |
|     | P = | ∑   |       | +(p | −   |     | +b+ | (1−α |     | P   | un−1 |           |
|     | u   |     | a u   |     | p   | )A  |     |       |     | )   |       |           |
|     | α P |     | nb nb | w   |     | e P |     |       | u   | α   | P     |           |
|     |     |     |       |     |     |     |     |      |     |     |      |           |
|     | u   |     |       |     |     |     |     |       |     | u   |       |           |
• Transient x-momentum equation:
Previous
time step
|     | ρ0∆V |     |     |     |     |     |     |     |     | ρ0∆V |     |     |
| --- | ---- | --- | --- | --- | --- | --- | --- | --- | --- | ---- | --- | --- |
|     | + P  |     | = ∑ |     | +(p |     | −   | +b+ |     | P    | u0  |     |
| (a  |      | )u  |     | a u |     |     | p   | )A  |     |      |     |     |
|     | P    |     | P   | nb  | nb  | w   | e   | P   |     |      |     |     |
|     | ∆t   |     |     |     |     |     |     |     |     | ∆t   | P   |     |
• Pseudo transient simulations:
(stabilizing iteration with faster convergence for buoyant flows, compressible flows with shocks)
ρ0∆V
a
|     |     |     | (1−α |     | P   | =   | P   |     |     |     |     |     |
| --- | --- | --- | ---- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
)
|     |     |     |     | u   | α   |     | ∆t  |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
u
17 Introduction to CFD (4RC30)

Example: vortex shedding
X = 1.0 m
MAX
T = 273 K
373 K D = 0.04 m
u = 0.04 m/s
∞
18 Introduction to CFD (4RC30)
YMAX
=
0.2
m
ρu D 1.0⋅0.04⋅0.04
Re = ∞ = =80
µ 2⋅10 −5
T = 273 K
y
x
T = 273 K

Example: vortex shedding
Flow field
| • Grid: 200 × | 40 cells        |     |
| ------------- | --------------- | --- |
| • Δx = Δy     | = 0.005 m       |     |
| ρu            | D 1.0⋅0.04⋅0.04 |     |
| = ∞           | =               | =80 |
Re
−5
µ 2⋅10
∆t |u | 0.1⋅0.04
| N = | max = | = 0.8 |
| --- | ----- | ----- |
CFL
∆x 0.005
min
19 Introduction to CFD (4RC30)

Results: vortex shedding
|      | fD 0.04⋅0.133 |         |
| ---- | ------------- | ------- |
| St = | =             | = 0.133 |
| u    | 0.04          |         |
∞
1
𝑓𝑓 = = 0.133
7.5
20 Introduction to CFD (4RC30)

Results: streamlines
21 Introduction to CFD (4RC30)

Results: temperature
22 Introduction to CFD (4RC30)

Experiments: vortex shedding
23 Introduction to CFD (4RC30) Park, Dabiriand Gharib, Exp. in Fluids (2001)

Wrap up
• Unsteady convection-diffusion equation:
∂(ρφ)
| +div(ρφu) | = div(Γgradφ)+ | S   |
| --------- | -------------- | --- |
| ∂t        |                | φ   |
• Explicit scheme O(1), Crank-Nicolson scheme O(2), Implicit scheme O(1)
• Transient SIMPLE
• Pseudo transient simulations
24 Introduction to CFD (4RC30)

Solution - Convergence errors / Residuals
∑
Numerical solution of     a   φ     =         a    φ      +   b    requires an iterative process (SIMPLE)
|                                         |     | P P | nb nb              |     |     |     |     |     |
| --------------------------------------- | --- | --- | ------------------ | --- | --- | --- | --- | --- |
| • Error (residual) for control volume i |     |     | after iteration k: |     |     |     |     |     |
k
|     |     | (R φ )k | = ∑ a φ | +b−a | φ   |     |     |     |
| --- | --- | ------- | ------- | ---- | --- | --- | --- | --- |
|     |     | i       | nb      | nb   | P P |     |     |     |
i
Normalized error:
| • Total error: |     | Maximum error:  |       |      |     | •   |     |     |
| -------------- | --- | --------------- | ----- | ---- | --- | --- | --- | --- |
|                |     | ˆφ              | )k =  | φ )k |     |     |     |     |
|                |     | (R              | max(R |      |     |     |     |     |
|                | 𝑁𝑁  |                 |       |      |     |     | 𝑁𝑁  |     |
|                |     | max             |       | i    |     |     |     |     |
𝑘𝑘
| 𝜙𝜙 𝑘𝑘  | 𝜙𝜙 𝑘𝑘      |     |     |     |     | 𝜙𝜙 𝑘𝑘   | 𝜙𝜙 𝑘𝑘       |             |
| ------ | ---------- | --- | --- | --- | --- | ------- | ----------- | ----------- |
| (𝑅𝑅� ) | = �(𝑅𝑅𝑖𝑖 ) |     |     |     |     | (𝑅𝑅�𝑁𝑁) | = (𝑅𝑅� ) �� | 𝑎𝑎𝑝𝑝𝜌𝜌𝑝𝑝 𝑖𝑖 |
• Convergence criteria when solving:
|     | 𝑖𝑖=1 |     |     |     |     |     | 𝑖𝑖=1 |     |
| --- | ---- | --- | --- | --- | --- | --- | ---- | --- |
see book for different choices
SMAXneeded= 1E-8;  % maximum accepted error in mass balance [kg/s]
SAVGneeded= 1E-9;  % maximum accepted average error in mass balance [kg/s]
while (iter<= MAX_ITER && SMAX > SMAXneeded&& SAVG > SAVGneeded) % check convergence
…
25 Introduction to CFD (4RC30)

Solution - Convergence errors / Residuals
• Decreasing residuals means the solution may not yet be converged
• Increasing residuals is normally a bad sign
• Correct residuals only mean that the solution has been converged (convergence), not that
the solution is correct (accuracy)
• Different variables should be monitored to judge convergence (e.g. forces, moment,
temperature, pressure, mass balance)
26 Introduction to CFD (4RC30)