Transparent Presentation title with
image behind title.
Choose this slide model if the image is
large enough to be used full-screen and
essential image information remains
visible.
Choose image by clicking on image icon
or
Replace an existing image with right
mouse button and choose Change
image.
Introduction to CFD (4RC30)
Role of pressure;
solving PDE’s
Prof.dr.ir. Niels Deen, N.G.Deen@tue.nl, Tel. 3681, VEC 3.202
Dr. YaliTang, y.tang2@tue.nl, Tel. 8052, VEC 3.106
Department of Mechanical Engineering

Outline
Summary of last lectures
Text format by
Increase / decrease list level
Place cursor in text Content of this lecture
and use these 2 buttons (tab Start -
group Paragraph)
• Chapter 6
▪ Role of pressure; staggered grid
▪ Momentum equations
1 = Normal text ▪ SIMPLE algorithm
2 = Paragraph text
3 = • text • Chapter 7
4 = • text
5 = • text
▪ Solving the discretized equations
▪ Tri-diagonal matrix algorithm
• Examples
Wrap up
2 Introduction to CFD (4RC30)

Summary of last lectures
|     | • Rate of change + convection |     |     | = diffusion |     | + (source – | sink) |
| --- | ----------------------------- | --- | --- | ----------- | --- | ----------- | ----- |
Text format by
Increase / decrease list level
|     |     |  (  | )   |     |     |     |     |
| --- | --- | ------ | --- | --- | --- | --- | --- |
Place cursor in text
|     |     |     | + d i v | (  u ) = | d i v (  g | r a d  ) + S |     |
| --- | --- | --- | ------- | ---------- | ----------- | ------------- | --- |
and use these 2 buttons (tab Start -

| group Paragraph) |     |  t |     |     |     |     |     |
| ---------------- | --- | --- | --- | --- | --- | --- | --- |
• General form of discretized linear equations:
|                    |     |      |     |       |     |      |     |
| ------------------ | --- | ----- | --- | ----- | --- | ----- | --- |
| 1 = Normal text    |     | a  = | a  | + S   | a   | = a − | S   |
| 2 = Paragraph text |     | P P   | n b | n b u | P   | n b   | P   |
3 = • text
4 =    • text
|     | Source terms are included through S |     |     |     |     | and S |     |
| --- | ----------------------------------- | --- | --- | --- | --- | ----- | --- |
5 =       • text
|     |     |     |     |     | u   | P   |     |
| --- | --- | --- | --- | --- | --- | --- | --- |
• Spatial discretization schemes: CDS, UDS and Hybrid
3 Introduction to CFD (4RC30)

Source term linearization
• Purpose: to solve the discretized equations in a linear framework
Text format by
Increase / decrease list level
|     |     |     |     |     |     |     |     | SV = | S +S |    |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | ----- | ---- | --- | --- | --- | --- |
Place cursor in text • The source term is expressed in a linear form:
|     |     |     |     |     |     |     |     |     | u   | P P |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
group Paragraph)
• 𝑆 ҧ is the volume-averaged value, 𝑆 the constant part, 𝑆 (≤ 0) the linear component
|     |     |     |     |     | 𝑢   |     |     |     | 𝑃   |     |          |     |          |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | -------- | --- | -------- |
|     |     |     |     |     |     |     |     |     |     |     | old step |     | new step |
•
Taylor series expansion:
|     |     |     |      |     |      |     | 𝒌     |       |      |     |       |     | 𝒌     |
| --- | --- | --- | ---- | --- | ---- | --- | ----- | ----- | ---- | --- | ----- | --- | ----- |
|     |     |     |      |     |      | 𝝏𝑺  |       |       |      | 𝝏𝑺  |       | 𝝏𝑺  |       |
|     |     |     | 𝑺𝒌+𝟏 | =   | 𝑺𝒌 + |     | 𝝓 𝒌+𝟏 | − 𝝓 𝒌 | = (𝑺 | −   | 𝝓 )𝒌+ |     | 𝝓 𝒌+𝟏 |
𝑷
|                 |     |     |     |     |     |     | 𝑷   | 𝑷   |     |     |     |     | 𝑷   |
| --------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 = Normal text |     |     |     |     |     | 𝝏𝝓  |     |     |     | 𝝏𝝓  |     | 𝝏𝝓  |     |
2 = Paragraph text
| 3 = • text    |                                                            |     |     |     |     |     |     |     |     | 𝑺 /∆𝑽 |     | 𝑺 /∆𝑽 |     |
| ------------- | ---------------------------------------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | ----- | --- | ----- | --- |
|               | Examples:                                                  |     |     |     | 𝑆   |     |     | 𝑆   |     |       |     |       |     |
| 4 =    • text |                                                            |     |     |     | 𝑢   |     |     | 𝑃   |     | 𝒖     |     | 𝑷     |     |
5 =       • text
|     | uniform             | 𝑆Δ𝑉 | = 𝑞  |     | 𝑞∆𝑉  |        |     | 0    |     |     |     |     |     |
| --- | ------------------- | --- | ---- | --- | ---- | ------ | --- | ---- | --- | --- | --- | --- | --- |
|     | variable-dependent  | 𝑆Δ𝑉 | = 𝐶𝜙 | + 𝑞 | 𝑞∆𝑉  |        |     | 𝐶∆𝑉  |     |     |     |     |     |
|     |                     |     |      |     |      | 3      |     |      | 2   |     |     |     |     |
|     |                     |     | −𝜙3  |     | (2𝜙𝑘 |        |     | −3𝜙𝑘 |     |     |     |     |     |
|     | variable−dependent  | 𝑆Δ𝑉 | =    | + 𝑞 |      | + 𝑞)∆𝑉 |     |      | ∆𝑉  |     |     |     |     |
|     |                     |     |      |     |      | 𝑃      |     |      | 𝑃   |     |     |     |     |
4 Introduction to CFD (4RC30)

Role of pressure
• Complete Navier-Stokes equations:
Text format by
Increase / decrease list level
| Place cursor in text | (u) |     |     | p  |     |     |
| -------------------- | ----- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start - +div(uu) = − +div(gradu)+ S
| group Paragraph) | t    |           |     | x            |     | Mx  |
| ---------------- | ----- | --------- | --- | ------------- | --- | --- |
|                  | (v) |           | p  |               |     |     |
|                  |       | +div(vu) | = − | +div(gradv)+ |     | S   |
My
|     | t  |     | y  |     |     |     |
| --- | --- | --- | --- | --- | --- | --- |
1 = Normal text
• Steady state situation (𝜕Τ𝜕𝑡= 0):
2 = Paragraph text
3 = • text
| 4 =    • text |     |     |    | p   |     |     |
| ------------- | --- | --- | --- | --- | --- | --- |
5 =       • text d i v (  u u ) = − + d i v (  g r a d u ) + S
M x
|     |     |           |          | x       |                 |     |
| --- | --- | --------- | --------- | ------- | --------------- | --- |
|     |     |           |          | p       |                 |     |
|     |     | d i v (  | v u ) = − | + d i v | (  g r a d v ) | + S |
M y
|     |     |     |    | y   |     |     |
| --- | --- | --- | --- | --- | --- | --- |
•
Pressure gradient often driving force flow
5 Introduction to CFD (4RC30)

Collocated grid
• Pressure and velocities stored on cell centers N
Text format by
Increase / decrease list level
n
Place cursor in text
and use these 2 buttons (tab Start -
| group Paragraph) |     |     |     |     |     |     | w        e | y  |
| ---------------- | --- | --- | --- | --- | --- | --- | ---------- | --- |
W        P           E
s
S
1 = Normal text
2 = Paragraph text
3 = • text x
4 =    • text   p  p − p 1   p + p   p + p   p − p
| 5 =       • text | =   | e w | =   | E P | − P | W = | E W   |     |
| ---------------- | --- | --- | --- | --- | --- | --- | ----- | --- |
|                  |  x |  x |  x | 2   | 2   |     | 2  x |     |
P
|     |  p  | p − p |     |     |     |     |     |     |
| --- | ------ | ----- | --- | --- | --- | --- | --- | --- |
|     | =      | N S   |     |     |     |     |     |     |
 
|     |        |     | Pressure at P |     | doesn’t appear in gradients! |     |     |     |
| --- | ------ | --- | ------------- | --- | ---------------------------- | --- | --- | --- |
|     |  y  | 2y |               |     |                              |     |     |     |
P
6 Introduction to CFD (4RC30)

‘Checkerboard’ pressure field
1         10           1 10
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
10          1         10 1
group Paragraph)
1         10           1 10
1 = Normal text
2 = Paragraph text
3 = • text
4 =    • text
5 =       • text
|  p |  p − | p     |  p |  p − | p     |
| ---- | ----- | ----- | ---- | ----- | ----- |
|      | = E   | W = 0 |      | = E   | W = 0 |
|     |      |       |     |      |       |
| x   | 2x   |       |      |       |       |
|     |      |       |  x |  2x |       |
P
P
|  p |  p − | p     |  p |  p − | p     |
| ---- | ----- | ----- | ---- | ----- | ----- |
|      | = N   | S = 0 |      | = N   | S = 0 |
|     |      |       |     |      |       |
| y   | 2y   |       | y   | 2y   |       |
|     |      |       |     |      |       |
|      | P     |       |      | P     |       |
7 Introduction to CFD (4RC30)

Solution: staggered grid
| • Store pressure at cell centers (P |     |     |     |     |     |     | , P | , P , etc.) |     |
| ----------------------------------- | --- | --- | --- | --- | --- | --- | --- | ----------- | --- |
Text format by
|     |     |     |     |     |     |     | W   | P E |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Increase / decrease list level
Place cursor in text • Store velocities at cell faces (u , u , v , v )
|     |     |     |     |     |     | w   | e   | s n | N   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
group Paragraph)
| • Advantages: |     |     |     |     |     |     |     |     | n   |
| ------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
y
w e
• No checkerboard pressure field possible
W        P           E
• Velocities are stored at desired position
s
1 = Normal text
2 = Paragraph text
3 = • text S
|     |    | p   | p   | − p |   | p  | p   | − p |     |
| --- | --- | --- | --- | --- | ----- | ----- | --- | --- | --- |
4 =    • text  
|     |     |     | = P | W   |     |     | = P | S   |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
5 =       • text
|     |      | x     |    | x   |      | y     |    | y   | x  |
| --- | ----- | ----- | --- | --- | ----- | ----- | --- | --- | --- |
|     |       | w     |     | u   |       | s     |     | v   |     |
|     |   | p  | p   | − p |   | p  | p   | − p |     |
|     |       |       | = E | P   |       |       | =   | N P |     |
|     |       |       |     |     |      | y     |     |  y |     |
|     |      | x     |    | x   |       |       |     |     |     |
|     |       | e     |     |     |       |       |     | v   |     |
|     |       |       |     | u   |       | n     |     |     |     |
8 Introduction to CFD (4RC30)

Staggered grid: numbering 𝝓
𝑰,𝑱
N
Text format by
Increase / decrease list level
|     |    |    |     |    |
| --- | --- | --- | --- | --- |
Place cursor in text
|     | I-1,J+1 | I,J+1 |     | I+1,J+1 |
| --- | ------- | ----- | --- | ------- |
and use these 2 buttons (tab Start -
group Paragraph)
n
|     | W   | w     P | e   | E   |
| --- | --- | ------- | --- | --- |
1 = Normal text
|                    |      |    |     |      |
| ------------------ | ----- | --- | --- | ----- |
| 2 = Paragraph text | I-1,J | I,J |     | I+1,J |
3 = • text
4 =    • text
5 =       • text
s
|     |        |      |     |        |
| --- | ------- | ----- | --- | ------- |
|     | I-1,J-1 | I,J-1 |     | I+1,J-1 |
S
(Fig. 6.5)
9 Introduction to CFD (4RC30)

Staggered grid: numbering 𝒖
𝒊,𝑱
N
Text format by
Increase / decrease list level
|                      | u       | u     | u       |
| -------------------- | ------- | ----- | ------- |
| Place cursor in text | i-1,J+1 | i,J+1 | i+1,J+1 |
and use these 2 buttons (tab Start -
| group Paragraph) |                | n   |       |
| ---------------- | -------------- | --- | ----- |
|                  | W              | P   | E     |
|                  | u              | u   | u     |
| 1 = Normal text  | w              |     | e     |
|                  | i-1,J          | i,J | i+1,J |
2 = Paragraph text
3 = • text
4 =    • text
5 =       • text
s
|     | u       | u     | u       |
| --- | ------- | ----- | ------- |
|     | i-1,J-1 | i,J-1 | i+1,J-1 |
S
(Fig. 6.3)
10 Introduction to CFD (4RC30)

Staggered grid: numbering 𝒗
𝑰,𝒋
Text format by
Increase / decrease list level
Place cursor in text
| and use these 2 buttons (tab Start - | v       | N   v | v       |
| ------------------------------------ | ------- | ----- | ------- |
| group Paragraph)                     | I-1,j+1 | I,j+1 | I+1,j+1 |
n
| 1 = Normal text    | W   v | P   v | E v   |
| ------------------ | ----- | ----- | ----- |
|                    | w     | e     |       |
| 2 = Paragraph text | I-1,j | I,j   | I+1,j |
3 = • text
4 =    • text
5 =       • text
s
|     | v       | S   v | v       |
| --- | ------- | ----- | ------- |
|     | I-1,j-1 | I,j-1 | I+1,j-1 |
(Fig. 6.4)
11 Introduction to CFD (4RC30)

Staggered grid: overview
| Text format by |     |     | Dx= XMAX/NPI; |
| -------------- | --- | --- | ------------- |
Increase / decrease list level
Place cursor in text % Length variable for the scalar points in the x direction
and use these 2 buttons (tab Start -
x(1) = 0.;
group Paragraph)
x(2) = 0.5*Dx;
for I = 3:NPI+1
x(I) = x(I-1) + Dx;
|     | P         | P   | end |
| --- | --------- | --- | --- |
x(NPI+2) = x(NPI+1) + 0.5*Dx;
| 1 = Normal text | i,J | I,J |     |
| --------------- | --- | --- | --- |
2 = Paragraph text
% Length variable for the velocity components u(i,j) in the x direction
3 = • text
| 4 =    • text |     |     | x_u(1) = 0.; |
| ------------- | --- | --- | ------------ |
5 =       • text
|     | P   | I,j | x_u(2) = 0.; |
| --- | --- | --- | ------------ |
for i = 3:NPI+2
x_u(i) = x_u(i-1) + Dx;
end
(Fig. 6.2)
12 Introduction to CFD (4RC30)

Momentum equations

|     |     |     |     | a u | =   | a   | u + | ( p − | p ) A | + b |
| --- | --- | --- | --- | --- | --- | --- | --- | ----- | ----- | --- |
|     |     |     |     | P   | P   | n b | n b | w     | e     | P   |
N
Text format by
|     |     |     |     | flow + diffusion |     |     |     | pressure |     | other body |
| --- | --- | --- | --- | ---------------- | --- | --- | --- | -------- | --- | ---------- |
Increase / decrease list level
| Place cursor in text |     |     |     |     | forces |     |     | force |     | forces |
| -------------------- | --- | --- | --- | --- | ------ | --- | --- | ----- | --- | ------ |
and use these 2 buttons (tab Start -
| group Paragraph) |     | n   |     |     |     |         |     |       |           |     |
| ---------------- | --- | --- | --- | --- | --- | ------- | --- | ----- | --------- | --- |
|                  |     |     |     |     |     |         | F   | + F   |           |     |
|                  |     |     |     |     |     |         |     | i , J | i − 1 , J |     |
|                  |     |     |     |     | F = | (  u ) | =   |       |           |     |
|                  |     |     |     |     | w   |         | w   |       |           |     |
2
w                          e

|                 | W   | P, u | E   |     |     |     |       | I − 1 | , J |     |
| --------------- | --- | ---- | --- | --- | --- | --- | ----- | ----- | --- | --- |
| 1 = Normal text |     |      |     |     | D = |  / |  x = |       |     |     |
i,J
| 2 = Paragraph text |     |     |     |     | w   | w   |     |       |     |     |
| ------------------ | --- | --- | --- | --- | --- | --- | --- | ----- | --- | --- |
|                    |     |     |     |     |     |     |     | x − x |     |     |
3 = • text
|     |     |     |     |     |     |     |     | i   | i − 1 |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | ----- | --- |
4 =    • text
| 5 =       • text |     | s   |     |     |     |         |     |         |     |       |
| ---------------- | --- | --- | --- | --- | --- | ------- | --- | ------- | --- | ----- |
|                  |     |     |     |     | D   | =  /y |     |         |     |       |
|                  |     |     |     |     | s   | s       | v   |         |     |       |
|                  |     |     |     |     |    | +      |     | +      | +  |       |
|                  |     |     |     |     |     | I−1,J   | I,J | I−1,J−1 |     | I,J−1 |
|                  |     | S   |     |     | =   |         |     |         |     |       |
|                  |     |     |     |     |     |         | 4(y | − y     | )   |       |
|                  |     |     |     |     |     |         |     | J J−1   |     |       |
13 Introduction to CFD (4RC30)

Momentum equations
a
| Text format by                 |     | a u = | u     | +(p − | p )A +b |
| ------------------------------ | --- | ----- | ----- | ----- | ------- |
| Increase / decrease list level |     | P P   | nb nb | w     | e P     |
Place cursor in text
|     |     | a v =  | a v | + ( p − | p ) A + b |
| --- | --- | ------- | --- | ------- | --------- |
and use these 2 buttons (tab Start -
|     |     | P P | n b n b | s   | n P |
| --- | --- | --- | ------- | --- | --- |
group Paragraph)
|     | • Values of a | are function of F |     | and D:  |     |
| --- | ------------- | ----------------- | --- | ------- | --- |
nb
|     | • F and D | depend on discretization scheme |     |     |     |
| --- | --------- | ------------------------------- | --- | --- | --- |
1 = Normal text
2 = Paragraph text
|     | • F and D | need to be interpolated to cell faces |     |     |     |
| --- | --------- | ------------------------------------- | --- | --- | --- |
3 = • text
4 =    • text
5 =       • text
• Pressure gradient needs no interpolation
|     | • Now we need to solve the u |     |     | and v | equations, using special  |
| --- | ---------------------------- | --- | --- | ----- | ------------------------- |
|     | treatment of                 | p   |     |       |                           |
14 Introduction to CFD (4RC30)

|     | Solving the u |     |     | equation |     |     |     |     |     |
| --- | ------------- | --- | --- | -------- | --- | --- | --- | --- | --- |
a
|     |     | a u = |     | u   | +(p |     | − p | )A  | +b  |
| --- | --- | ----- | --- | --- | --- | --- | --- | --- | --- |
Text format by
|     |     | P P |     | nb  | nb  | w   | e   | P   |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
Increase / decrease list level
Place cursor in text
|     | • Guess u, v | and p: u*, v* |     |     | and p* |     |     |     |     |
| --- | ------------ | ------------- | --- | --- | ------ | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
group Paragraph)
|     |     | a u * = |    | a u | *n + | ( p *w | − p *e | ) A | + b |
| --- | --- | ------- | --- | --- | ---- | ------ | ------ | --- | --- |
|     |     | P       |     | n b | b    |        |        | P   |     |
P
• Define pressure and velocity corrections:
1 = Normal text
| 2 = Paragraph text |     | p = p * | + p | '   | u = | u * + | u ' |     | v = v * + v ' |
| ------------------ | --- | ------- | --- | --- | --- | ----- | --- | --- | ------------- |
3 = • text
4 =    • text
| 5 =       • text |     | p ' = p | − p | *   | u ' = | u − | u * |     | v ' = v − v * |
| ---------------- | --- | ------- | --- | --- | ----- | --- | --- | --- | ------------- |
• Subtract guessed from correct velocity eqs.:
|     |     | a u' | = a |     | u'  | +(p' | −   | p'  | )A  |
| --- | --- | ---- | ---- | --- | --- | ---- | --- | --- | --- |
|     |     | P P  |      | nb  | nb  |      | w   | e   | P   |
15 Introduction to CFD (4RC30)

Solving the u equation
Text format by
| Increase / decrease list level |       |    |     |        |       |        |     |
| ------------------------------ | ----- | --- | --- | ------ | ----- | ------ | --- |
|                                | a u ' | =   | a u | 'n + ( | p ' − | p 'e ) | A   |
| Place cursor in text           | P P   |     | n b | b      | w     |        | P   |
and use these 2 buttons (tab Start -
group Paragraph)
•
Omit correction terms of neighbors to obtain the velocity correction equation:
|     | u' = | d (p' | −   | p' ) | d   |  A | /a  |
| --- | ---- | ----- | --- | ---- | --- | --- | --- |
1 = Normal text
|     | P   | P   | w   | e   | P   | P   | P   |
| --- | --- | --- | --- | --- | --- | --- | --- |
2 = Paragraph text
3 = • text
4 =    • text
5 =       • text • Now we know how to correct the guessed u*:
|     | u = u | * + | d ( p | ' − p | 'e ) |     |     |
| --- | ----- | --- | ----- | ----- | ---- | --- | --- |
|     | P     | P   | P     | w     |      |     |     |
16 Introduction to CFD (4RC30)

Solving the v equation
• We derived an expression for u':
Text format by
Increase / decrease list level
Place cursor in text
|     | u = | u * + d ( | p ' − p 'e ) |     |
| --- | --- | --------- | ------------ | --- |
and use these 2 buttons (tab Start - P
|     | P   | P P | w   | P   |
| --- | --- | --- | --- | --- |
group Paragraph)
i,J I,J
• Analogous derivation gives expression for v':
P I,j
| 1 = Normal text    | v = v | * + d ( p | ' − p ' ) |     |
| ------------------ | ----- | --------- | --------- | --- |
| 2 = Paragraph text | P     | P P       | s n       |     |
3 = • text
4 =    • text
| 5 =       • text | d  | A /a |     |     |
| ---------------- | --- | ---- | --- | --- |
|                  | P   | P P  |     |     |
• Now we need an expression for p'
17 Introduction to CFD (4RC30)

Pressure correction equation
• We use the continuity equation:
Text format by
Increase / decrease list level
Place cursor in text
|     |     |     |     |    |     |   |     |    |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start - d i v (  u ) = 0  (  u A ) − (  u A ) + (  v A ) − (  v A ) = 0
| group Paragraph) |                  |      |             |           | e           | w   | n   | s   |
| ---------------- | ---------------- | ---- | ----------- | --------- | ----------- | --- | --- | --- |
|                  | • Substitute u = | u* + | u' and  v = | v* +      | v':         |     |     |     |
|                  |                  | (   | A ) ( u *   | + d ( p ' | − p ' ) ) − |     |     |     |
1 = Normal text
|     |     |     | e e | e P | E   |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
2 = Paragraph text
| 3 = • text    |     | (  | A ) ( u * | + d ( p 'W | − p ' ) ) + |     |     |     |
| ------------- | --- | --- | --------- | ---------- | ----------- | --- | --- | --- |
| 4 =    • text |     |     | w w       | w          | P           |     |     |     |
5 =       • text
|     |     | (  | A ) ( v * | + d ( p ' | − p ' ) ) − |     |     |     |
| --- | --- | --- | --------- | --------- | ----------- | --- | --- | --- |
|     |     |     | n n       | n P       | N           |     |     |     |
|     |     | (  | A ) ( v * | + d ( p ' | − p ' ) ) = | 0   |     |     |
|     |     |     | s s       | s S       | P           |     |     |     |
18 Introduction to CFD (4RC30)

Pressure correction equation
• Rearrange p' equation to yield:
Text format by
Increase / decrease list level
Place cursor in text
|     | a p ' | = a | p ' | + a | p 'W + | a p | ' + a p ' | + b |
| --- | ----- | --- | --- | --- | ------ | --- | --------- | --- |
and use these 2 buttons (tab Start -
|     | P P |     | E E | W   |     | N   | N S | S   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
group Paragraph)
|     | a p ' | =  | a   | p 'n | + b |     |     |     |
| --- | ----- | --- | --- | ---- | --- | --- | --- | --- |
|     | P P   |     | n   | b b  |     |     |     |     |
a = (dA)
with:
|     | E   |     | e   |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
1 = Normal text
| 2 = Paragraph text | a = | (dA) |     |     |     |     |     |     |
| ------------------ | --- | ----- | --- | --- | --- | --- | --- | --- |
| 3 = • text         | W   |       | w   |     |     |     |     |     |
4 =    • text
| 5 =       • text | a = | (dA) |     |     |     |     |     |     |
| ---------------- | --- | ----- | --- | --- | --- | --- | --- | --- |
|                  | N   |       | n   |     |     |     |     |     |
a = (dA)
|     | S          |      | s       |     |         |     |         |     |
| --- | ---------- | ---- | ------- | --- | ------- | --- | ------- | --- |
|     | a =        | a +a | +a      | +a  |         |     |         |     |
|     | P          | E    | W       | N   | S       |     |         |     |
|     | b = (u*A) |      | −(u*A) |     | +(v*A) |     | −(v*A) |     |
|     |            |      | e       |     | w       |     | s       | n   |
19 Introduction to CFD (4RC30)

Under-relaxation
• To prevent from divergence we use only part of the corrections:
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
| group Paragraph) | p = p* | + p' | pn  | = pn−1 + | p'  |     |     |     |     |
| ---------------- | ------ | ---- | --- | --------- | --- | --- | --- | --- | --- |
p
|                 | u = u*     | +u' | un =    | (u* +u')+(1−  |     | )un−1 |  un | = un−1      | +u' |
| --------------- | ---------- | --- | -------- | -------------- | --- | ----- | ---- | ----------- | ---- |
|                 |            |     |          | u              |     | u     |      |             | u    |
|                 | v = v* +v' |     | vn =(v* | +v')+(1−)vn−1 |     |       |  vn | = vn−1 +v' |      |
| 1 = Normal text |            |     |          | v              |     | v     |      |             | v    |
2 = Paragraph text
3 = • text
4 =    • text
|     |     |     | 0   | ,  ,  |  1 |     |     |     |     |
| --- | --- | --- | ----- | ------- | --- | --- | --- | --- | --- |
5 =       • text
|     |     |     |     | p u | v   |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
20 Introduction to CFD (4RC30)

Under-relaxation
| Text format by |     |    |     |         |         |     |     |     |
| -------------- | --- | --- | --- | ------- | ------- | --- | --- | --- |
|                | a   | u = | a u | + ( p − | p ) A + | b   |     |     |
Increase / decrease list level
|     | P   | P   | n b n b | w   | e P |     |     |     |
| --- | --- | --- | ------- | --- | --- | --- | --- | --- |
Place cursor in text
and use these 2 buttons (tab Start -

| group Paragraph) | a   | v = | a v     | + ( p − | p ) A + | b   |     |     |
| ---------------- | --- | --- | ------- | ------- | ------- | --- | --- | --- |
|                  | P   | P   | n b n b | s       | n P     |     |     |     |
• Applying under-relaxation gives:
|                 |     |       |     |       |         |        |         |    |
| --------------- | --- | ----- | --- | ----- | ------- | --------- | ------- | ----- |
|                 | a   |       |     |       |         |           | a       |       |
| 1 = Normal text |     |       |    |       |         |           |         | n − 1 |
|                 |     | P u = | a u | + ( p | − p ) A | + b + ( 1 | −  ) P | u     |
2 = Paragraph text
|            |    | P   | n b | n b w | e P |     | u  |     |
| ---------- | --- | --- | --- | ----- | --- | --- | --- | --- |
| 3 = • text |     |     |     |       |     |     |     | P   |
|            |     | u   |     |       |     |     | u   |     |
4 =    • text
5 =       • text
|     |     |       |       |         |         |        |    |       |
| --- | --- | ----- | ----- | ------- | ------- | --------- | ----- | ----- |
|     | a   |       |       |         |         |           | a     |       |
|     |     |       |      |         |         |           |       | n − 1 |
|     |     | P v = | a v   | + ( p − | p ) A + | b + ( 1 − |  ) P | v     |
|     |     | P     | n b n | b s     | n P     |           | v     |       |
|     |    |       |       |         |         |           |      | P     |
|     |     | v     |       |         |         |           | v     |       |
21 Introduction to CFD (4RC30)

SIMPLE
Semi-Implicit Method for Pressure-Linked Equations (SIMPLE)
Text format by
Increase / decrease list level
Place cursor in text • Solve discretized equations for u* and v*
and use these 2 buttons (tab Start -
group Paragraph)
• Solve discretized equation for p'
• Correct pressure and velocities
• Solve any other discretized equations for 𝜙
1 = Normal text
2 = Paragraph text • Convergence?
3 = • text
4 = • text
5 = • text ✓ Yes: stop
✓ No: set p* = p, u* = u, v* = v, 𝜙= 𝜙*
repeat sequence
22 Introduction to CFD (4RC30)

Other algorithms linking u, v and p
• SIMPLER: SIMPLE Revised
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start - • SIMPLEC: SIMPLE Consistent
group Paragraph)
• PISO: Pressure Implicit with Splitting of Operators
• See book Chapter 6 Versteeg and Malalasekera
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
23 Introduction to CFD (4RC30)

Solution of discretized equations
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
• Gauss-Seidel point-by-point method
1 = Normal text
2 = Paragraph text
3 = • text
• Successive over-relaxation (SOR)
4 = • text
5 = • text
24 Introduction to CFD (4RC30)
a
P P
a
n b n b
b   =  +
a  +b
 = nb nb
P
a
P
P
a
n b
a
P
n b
b
( 1 ) oP ld 1 2

     =
 +
− −  

Solution of discretized equations

|     |                                          |     |     |     |     |     |     |     |     |     | a  = | a      | + b |
| --- | ---------------------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ----- | ------- | --- |
|     | • 1D: (n+2) equations and (n+1) unknowns |     |     |     |     |     |     |     |     |     | P P   | n b n b |     |
Text format by
Increase / decrease list level
Place cursor in text
| and use these 2 buttons (tab Start - |     |    |     |     |     |     |     |     |     | = b |     |     |     |
| ------------------------------------ | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|                                      |     | 0   |     |     |     |     |     |     |     | 0   |     |     |     |
group Paragraph)
|                 |     | (   | ) (   | ) (   | )     |     |       |     |     |     |     |     |     |
| --------------- | --- | --- | ----- | ----- | ----- | --- | ----- | --- | --- | --- | --- | --- | --- |
|                 |     | − a |  + a |  − a |      |     |       |     |     | = b |     |     |     |
|                 |     |     | 0     | 1     | 2     |     |       |     |     | 1   |     |     |     |
|                 |     |     | (     | ) (   | ) (   | )   |       |     |     |     |     |     |     |
|                 |     |     | − a   |  + a |  − a |    |       |     |     | = b |     |     |     |
|                 |     |     |       | 1     | 2     | 3   |       |     |     | 2   |     |     |     |
| 1 = Normal text |     |     |       | (     | ) (   | )   | (     | )   |     |     |     |     |     |
|                 |     |     |       | − a   |  + a |    | − a  |     |     | = b |     |     |     |
2 = Paragraph text
|     |     |     |     |     | 2   | 3   |     | 4   |     | 3   |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
3 = • text
| 4 =    • text |     |     |     |     | (   | )   | (   | ) (   | )   |     |     |     |     |
| ------------- | --- | --- | --- | --- | --- | --- | --- | ----- | --- | --- | --- | --- | --- |
|               |     |     |     |     | − a |    | + a |  − a |    | = b |     |     |     |
5 =       • text
|     |     |     |     |     |     | n − 1 |     | n   | n + 1 | n     |     |     |     |
| --- | --- | --- | --- | --- | --- | ----- | --- | --- | ----- | ----- | --- | --- | --- |
|     |     |     |     |     |     |       |     |     |      | = b   |     |     |     |
|     |     |     |     |     |     |       |     |     | n + 1 | n + 1 |     |     |     |
• Solve by forward elimination and backward substitution
(Tri-diagonal matrix algorithm)
25 Introduction to CFD (4RC30)

Solution of discretized equations
• 2D: apply TDMA line by line horizontally
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
Known boundary values
Temporarily ‘known’
1 = Normal text
values
2 = Paragraph text
3 = • text
4 = • text
5 = • text Points to calculate
y
x
26 Introduction to CFD (4RC30)

Solution of discretized equations
• 2D: apply TDMA line by line vertically
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
Known boundary values
Temporarily ‘known’
1 = Normal text
values
2 = Paragraph text
3 = • text
4 = • text
5 = • text Points to calculate
y
x
27 Introduction to CFD (4RC30)

Flow between two parallel plates
• Analytical solution:
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
28 Introduction to CFD (4RC30)
u (
u
y

)
=
3
2

1 −
 2
h
y 
2 
y
h
x
u = 1 m/s


Flow between two parallel plates
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
29 Introduction to CFD (4RC30)

Flow between two parallel plates
Text format by
Increase / decrease list level
|     | 1.6 |     | 6.E-03 |     |     |
| --- | --- | --- | ------ | --- | --- |
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
)
|     | 1.2 |     | 4.E-03 | s   |     |
| --- | --- | --- | ------ | --- | --- |
/ m
u num.
|     | )   |     |     | (   |     |
| --- | --- | --- | --- | --- | --- |
|     | s   |     |     |   e |     |
/
|     | m 0.8 |     | 2.E-03 | c   | u theor. |
| --- | ----- | --- | ------ | --- | -------- |
n
(
|                    |     |     |     | e   |       |
| ------------------ | --- | --- | --- | --- | ----- |
| 1 = Normal text    | u   |     |     |     |       |
|                    |     |     |     | r   | diff. |
| 2 = Paragraph text |     |     |     | e   |       |
f
| 3 = • text | 0.4 |     | 0.E+00 | f   |     |
| ---------- | --- | --- | ------ | --- | --- |
i d
4 =    • text
5 =       • text
|     | 0.0       |         | -2.E-03 |     |     |
| --- | --------- | ------- | ------- | --- | --- |
|     | -1.0 -0.5 | 0.0 0.5 | 1.0     |     |     |
2y/H
30 Introduction to CFD (4RC30)

Flow between plates with baffles
Text format by
Increase / decrease list level
T = 373 K
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph)
T = 273 K
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text u = 0.1 m/s
5 = • text 
y
x
T = 373 K
31 Introduction to CFD (4RC30)

Flow between plates with baffles
The governing equations are:
Text format by
Increase / decrease list level
Place cursor in text
|     |     |    | p   |     |     |
| --- | --- | --- | --- | --- | --- |
and use these 2 buttons (tab Start -
|     | d i v (  | u u ) = − | + d i v | (  g r a d u | ) + S |
| --- | --------- | --------- | ------- | ------------- | ----- |
group Paragraph)
M x
|     |           |           |  x     |                 |     |
| --- | --------- | --------- | ------- | --------------- | --- |
|     |           |          | p       |                 |     |
|     | d i v (  | v u ) = − | + d i v | (  g r a d v ) | + S |
|     |           |          | y       |                 | M y |
1 = Normal text
2 = Paragraph text
3 = • text
| 4 =    • text    |          |        | k      |     |     |
| ---------------- | -------- | ------ | ------ | --- | --- |
| 5 =       • text | div(Tu) | = div( | gradT) |     |     |
C
p
32 Introduction to CFD (4RC30)

Flow between plates with baffles
0.1
'output.dat'
Text format by
Increase / decrease list level
0.09
Place cursor in text
and use these 2 buttons (tab Start - 0.08
group Paragraph)
0.07
0.06
)
m
0.05
(
1 = Normal text y
2 = Paragraph text
0.04
3 = • text
4 = • text
5 = • text 0.03
0.02
0.01
0
0 0.05 0.1 0.15 0.2 0.25
x (m)
33 Introduction to CFD (4RC30)

Flow between plates with baffles
Temperature distribution with baffles
Text format by
Increase / decrease list level
Place cursor in text 'output.dat' u 1:2:9
and use these 2 buttons (tab Start -
370
group Paragraph)
360
350
340
380
330
370
360 320
350
340 310
1 = Normal text 330 300
2 = Paragraph text 320
310 290
3 = • text 300
280
4 = • text 290
5 = • text 280
270
0.12
0.1
0.08
0 0.06
0.05 y (m)
0.1 0.04
0.15 0.02
x (m) 0.2
0
0.25
34 Introduction to CFD (4RC30)

Flow between plates with baffles
Temperature distribution without baffles
Text format by
Increase / decrease list level
'output.dat' u 1:2:9
Place cursor in text
and use these 2 buttons (tab Start - 360
group Paragraph) 340
320
300
380
280
360
340
1 = Normal text 320
2 = Paragraph text
300
3 = • text
280
4 = • text
5 = • text 260
0.12
0.1
0.08
0 0.06
0.05 y (m)
0.1 0.04
0.15 0.02
x (m) 0.2
0
0.25
35 Introduction to CFD (4RC30)

Performance as heat exchanger
• With baffles ΔT = 42 K
Text format by
Increase / decrease list level
Place cursor in text
• Without baffles ΔT = 36 K
and use these 2 buttons (tab Start -
group Paragraph)
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
36 Introduction to CFD (4RC30)
3
3
3
3
3
2
2
9
7
5
3
1
9
7
0
0
0
0
0
0
0
0 .0 0 0 .0 2 0 .0 4 0 .0
y (m
6
)
0 .0 8 0 .1 0 0 .1 2
)K
( T
T
T
w
w
ith
ith o u t

Wrap up
• Source term linearization
Text format by
Increase / decrease list level
Place cursor in text
• Role of pressure
and use these 2 buttons (tab Start -
group Paragraph)
• Staggered grid
• SIMPLE algorithm
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text • TDMA solver
5 = • text
37 Introduction to CFD (4RC30)

Make groups
• 2 or 3 persons as a group for final assignment
Text format by
Increase / decrease list level
Place cursor in text
and use these 2 buttons (tab Start -
group Paragraph) • Make the group now and work together for tutorials
• Use “Partner wanted” post on Canvas
1 = Normal text
2 = Paragraph text
3 = • text
4 = • text
5 = • text
38 Introduction to CFD (4RC30)