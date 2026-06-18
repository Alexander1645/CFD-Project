ANIN_C04.qxd  29/12/2006  09:57 AM  Page 121
| 4.3 | WORKED EXAMPLES |     |     |     |     |     |     | 121 |
| --- | --------------- | --- | --- | --- | --- | --- | --- | --- |
Table 4.1
| Node |     | a   | a   | S    |     | S    | a =a +a | −S  |
| ---- | --- | --- | --- | ---- | --- | ---- | ------- | --- |
|      |     | W   | E   | u    |     | P    | P W     | E P |
| 1    |     | 0   | 100 | 200T |     | −200 | 300     |     |
A
| 2   |     | 100 | 100 |      | 0   | 0    | 200 |     |
| --- | --- | --- | --- | ---- | --- | ---- | --- | --- |
| 3   |     | 100 | 100 |      | 0   | 0    | 200 |     |
| 4   |     | 100 | 100 |      | 0   | 0    | 200 |     |
| 5   |     | 100 | 0   | 200T |     | −200 | 300 |     |
B
This set of equations can be rearranged as
|     | G     | −100 |      |     |     | 0JGT J | G200T J |     |
| --- | ----- | ---- | ---- | --- | --- | ------ | ------- | --- |
|     |       | 300  |      | 0   | 0   |        |         |     |
|     | H−100 |      | −100 |     |     | 1      | A       |     |
|     |       |      | 200  |     | 0   | 0KHT K | H 0 K   |     |
2
|     | H   | 0 −100 | 200 | −100 |     | 0KHT K | = H 0 K | (4.23) |
| --- | --- | ------ | --- | ---- | --- | ------ | ------- | ------ |
3
|     | H   | 0   | 0 −100 | 200 | −100KHT | K   | H 0 K |     |
| --- | --- | --- | ------ | --- | ------- | --- | ----- | --- |
4
|     | I   | 0   | 0   | 0 −100 | 300LIT | L   | I200T L |     |
| --- | --- | --- | --- | ------ | ------ | --- | ------- | --- |
|     |     |     |     |        |        | 5   | B       |     |
The above set of equations yields the steady state temperature distribution
of the given situation. For simple problems involving a small number of
nodes the resulting matrix equation can easily be solved with a software
| package such as MATLAB (1992). For T |     |     |     |     | =100 and T |     | =500 the solution |     |
| ------------------------------------ | --- | --- | --- | --- | ---------- | --- | ----------------- | --- |
|                                      |     |     |     |     | A          |     | B                 |     |
of (4.23) can obtained by using, for example, Gaussian elimination:
|     | GT  | J G140J |     |     |     |     |     |     |
| --- | --- | ------- | --- | --- | --- | --- | --- | --- |
1
|     | HT  | K H220K |     |     |     |     |     |     |
| --- | --- | ------- | --- | --- | --- | --- | --- | --- |
2
|     | HT  | K = H300K |     |     |     |     |     | (4.24) |
| --- | --- | --------- | --- | --- | --- | --- | --- | ------ |
3
|     | HT  | K H380K |     |     |     |     |     |     |
| --- | --- | ------- | --- | --- | --- | --- | --- | --- |
4
|     | IT  | L I460L |     |     |     |     |     |     |
| --- | --- | ------- | --- | --- | --- | --- | --- | --- |
5
The exact solution is a linear distribution between the specified boundary
temperatures: T=800x+100. Figure 4.5 shows that the exact solution and
the numerical results coincide.
Figure 4.5 Comparison of the
numerical result with the
analytical solution
Example 4.2
Now we discuss a problem that includes sources other than those arising
from boundary conditions. Figure 4.6 shows a large plate of thickness
L=2 cm with constant thermal conductivity k=0.5 W/m.Kand uniform
|     |     | =   | 1000 kW/m3. The faces A and B are at temperatures  |     |     |     |     |     |
| --- | --- | --- | -------------------------------------------------- | --- | --- | --- | --- | --- |
heat generation q
of 100°C and 200°C respectively. Assuming that the dimensions in the y- and

ANIN_C04.qxd  29/12/2006  09:57 AM  Page 122
122 CHAPTER 4 FINITE VOLUME METHOD FOR DIFFUSION PROBLEMS
z-directions are so large that temperature gradients are significant in the x-
direction only, calculate the steady state temperature distribution. Compare
the numerical result with the analytical solution. The governing equation is
A dTD
d
| Bk  | E +q=0 |     |     |     | (4.25) |
| --- | ------ | --- | --- | --- | ------ |
dxC dxF
Figure 4.6
As before, the method of solution is demonstrated using a simple grid.
Solution
The domain is divided into five control volumes (see Figure 4.7), giving
δx=0.004 m; a unit area is considered in the y–zplane.
Figure 4.7 The grid used
Formal integration of the governing equation over a control volume gives
| (cid:1) |     | (cid:1) |     |     |     |
| ------- | --- | ------- | --- | --- | --- |
d A dTD
| Bk  | EdV+ | qdV=0 |     |     |     |
| --- | ---- | ----- | --- | --- | --- |
(4.26)
dxC dxF
| ∆V  |     | ∆V  |     |     |     |
| --- | --- | --- | --- | --- | --- |
We treat the first term of the above equation as in the previous example. The
second integral, the source term of the equation, is evaluated by calculating
| the average generation (i.e. D∆V |     |     | = q∆V) within each control volume. |     |     |
| -------------------------------- | --- | --- | ---------------------------------- | --- | --- |
Equation (4.26) can be written as
| GA dTD | A     | dTD | J      |     |        |
| ------ | ----- | --- | ------ | --- | ------ |
|        | −     |     | +q∆V=0 |     |        |
| HBkA   | E BkA | E   | K      |     | (4.27) |
| IC dxF | C     | dxF |        |     |        |
L
|       | e    |     | w     |         |        |
| ----- | ---- | --- | ----- | ------- | ------ |
| G AT  | −T   | D   | AT −T | DJ      |        |
|       | E PE | −k  | P WEK | +qAδx=0 |        |
| Hk AB |      | AB  |       |         | (4.28) |
| e     | δx   | w   | δx    |         |        |
| I C   |      | F   | C     | FL      |        |
The above equation can be rearranged as
| Ak  | AD  | Ak AD | Ak  | AD  |     |
| --- | --- | ----- | --- | --- | --- |
A k
| B e + | w ET | = B w | ET + B | e ET +qAδx | (4.29) |
| ----- | ---- | ----- | ------ | ---------- | ------ |
| δx    | δx   | P δx  | W      | δx E       |        |
| C     | F    | C     | F C    | F          |        |

ANIN_C04.qxd  29/12/2006  09:57 AM  Page 123
| 4.3 WORKED EXAMPLES |     |     |     |     |     | 123 |
| ------------------- | --- | --- | --- | --- | --- | --- |
This equation is written in the general form of (4.11):
| a T =a | T   | +a T +S |     |     |     | (4.30) |
| ------ | --- | ------- | --- | --- | --- | ------ |
| P P    | W W | E E     | u   |     |     |        |
Since k =k =kwe have the following coefficients:
e w
| a   | a   | a    |     | S S    |     |     |
| --- | --- | ---- | --- | ------ | --- | --- |
| W   | E   | P    |     | P u    |     |     |
| kA  | kA  |      |     |        |     |     |
|     |     | a +a | −S  | 0 qAδx |     |     |
| δx  | δx  | W    | E P |        |     |     |
Equation (4.30) is valid for control volumes at nodalpoints2,3and4.
To incorporate the boundary conditions at nodes 1 and 5 we apply the
linear approximation for temperatures between a boundary point and the
adjacent nodal point. At node 1 the temperature at the west boundary is
known. Integration of equation (4.25) at the control volume surrounding
node 1 gives
| GA dTD |     | A dTD | J         |     |     |        |
| ------ | --- | ----- | --------- | --- | --- | ------ |
| HBkA   | E − | BkA E | K +q∆V=0  |     |     | (4.31) |
| IC dxF |     | C dxF | L         |     |     |        |
|        | e   | w     |           |     |     |        |
Introduction of the linear approximation for temperatures between A and P
yields
| G AT  | −T   | D   | AT −T | DJ                          |     |        |
| ----- | ---- | --- | ----- | --------------------------- | --- | ------ |
|       | E PE | −k  | P     | AEK +qAδx=0                 |     |        |
| Hk AB |      | AB  |       |                             |     | (4.32) |
| e     | δx   | A   | δx/2  |                             |     |        |
| I C   |      | F   | C     | FL                          |     |        |
|       |      |     |       | =k =k, to yield the discre- |     |        |
The above equation can be rearranged, using k
|     |     |     |     | e A |     |     |
| --- | --- | --- | --- | --- | --- | --- |
tised equation for boundarynode1:
| a T =a | T   | +a T +S |     |     |     | (4.33) |
| ------ | --- | ------- | --- | --- | --- | ------ |
| P P    | W W | E E     | u   |     |     |        |
where
| a   | a   | a    |     | S S     |     |     |
| --- | --- | ---- | --- | ------- | --- | --- |
| W   | E   | P    |     | P u     |     |     |
|     | kA  |      |     | 2kA     | 2kA |     |
| 0   |     | a +a | −S  | − qAδx+ |     | T   |
|     |     | W    | E P |         |     | A   |
|     | δx  |      |     | δx      | δx  |     |
At nodal point 5, the temperature on the east face of the control volume is
known. The node is treated in a similar way to boundary node 1. At bound-
ary point 5 we have
| GA dTD |      | A dTD | J        |         |     |        |
| ------ | ---- | ----- | -------- | ------- | --- | ------ |
| HBkA   | E −  | BkA E | K +q∆V=0 |         |     | (4.34) |
| IC dxF |      | C dxF | L        |         |     |        |
|        | e    | w     |          |         |     |        |
| G AT   | −T   | D     | AT −T    | DJ      |     |        |
|        | B    | PE    | P        | WEK     |     |        |
| Hk AB  |      | −k AB |          | +qAδx=0 |     | (4.35) |
| B      | δx/2 | w     | δx       |         |     |        |
| I C    |      | F     | C        | FL      |     |        |

ANIN_C04.qxd 29/12/2006 09:57 AM Page 124
124 CHAPTER 4 FINITE VOLUME METHOD FOR DIFFUSION PROBLEMS
The above equation can be rearranged, noting that k = k = k, to give the
B w
discretised equation for boundarynode5:
a T =a T +a T +S (4.36)
P P W W E E u
where
a a a S S
W E P P u
kA 2kA 2kA
0 a +a −S − qAδx+ T
δx W E P δx δx B
Substitution of numerical values for A=1, k =0.5 W/m.K, q=1000 kW/m3
and δx=0.004 m everywhere gives the coefficients of the discretised equa-
tions summarised in Table 4.2.
Table 4.2
Node a a S S a =a +a −S
W E u P P W E P
1 0 125 4000 + 250T −250 375
A
2 125 125 4000 0 250
3 125 125 4000 0 250
4 125 125 4000 0 250
5 125 0 4000 + 250T −250 375
B
Given directly in matrix form the equations are
G 375 −125 0 0 0JGT J G29000J
1
H−125 250 −125 0 0KHT K H 4000K
2
H 0 −125 250 −125 0KHT K = H 4000K (4.37)
3
H 0 0 −125 250 −125KHT K H 4000K
4
I 0 0 0 −125 375LIT L I54000L
5
The solution to the above set of equations is
GT J G150J
1
HT K H218K
2
HT K = H254K (4.38)
3
HT K H258K
4
IT L I230L
5
Comparison with the analytical solution
The analytical solution to this problem may be obtained by integrating equa-
tion (4.25) twice with respect to x and by subsequent application of the
boundary conditions. This gives
GT −T q J
T= H B A + (L−x)Kx+T (4.39)
I L 2k L A
The comparison between the finite volume solution and the exact solution is
shown in Table 4.3 and Figure 4.8 and it can be seen that, even with a coarse
grid of five nodes, the agreement is very good.

ANIN_C04.qxd  29/12/2006  09:57 AM  Page 125
| 4.3 WORKED EXAMPLES |     |     | 125 |
| ------------------- | --- | --- | --- |
Table 4.3
| Nodenumber             | 1 2         | 3 4        | 5     |
| ---------------------- | ----------- | ---------- | ----- |
| x(m)                   | 0.002 0.006 | 0.01 0.014 | 0.018 |
| Finite volume solution | 150 218     | 254 258    | 230   |
| Exact solution         | 146 214     | 250 254    | 226   |
| Percentage error       | 2.73 1.86   | 1.60 1.57  | 1.76  |
Figure 4.8 Comparison of the
numerical result with the
analytical solution
Example 4.3
In the final worked example of this chapter we discuss the cooling of a
circular fin by means of convective heat transfer along its length. Convection
gives rise to a temperature-dependent heat loss or sink term in the govern-
ing equation. Shown in Figure 4.9 is a cylindrical fin with uniform cross-
| sectional area A. The base is at a temperature of 100°C (T |     | ) and the end is |     |
| ---------------------------------------------------------- | --- | ---------------- | --- |
B
insulated. The fin is exposed to an ambient temperature of 20°C. One-
dimensional heat transfer in this situation is governed by
A dTD
d
| BkA E −hP(T −T | ) =0 |     | (4.40) |
| -------------- | ---- | --- | ------ |
∞
dxC dxF
| where h is the convective heat transfer coefficient, P |     | the perimeter, k           | the |
| ------------------------------------------------------ | --- | -------------------------- | --- |
| thermal conductivity of the material and T             |     | ∞ the ambient temperature. |     |
Calculate the temperature distribution along the fin and compare the results
with the analytical solution given by
| T−T cosh[n(L−x)] |     |     |     |
| ---------------- | --- | --- | --- |
∞ =
(4.41)
| T −T | cosh(nL) |     |     |
| ---- | -------- | --- | --- |
B ∞
Figure 4.9 The geometry for
Example 4.3