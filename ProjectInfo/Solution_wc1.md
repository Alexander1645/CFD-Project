**Introduction to Computational Fluid Dynamics**

**Tutorial 1 Solution**

**Problem 1a: one-dimensional steady heat-transfer in an insulated rod**

An insulated rod (1.0 m) is kept at constant temperatures of 300 K on the left end and 500 K on the right end. The thermal conductivity of the rod is 1000 W/m/K.

1. Make a sketch of the rod and the important parameters.

$$k=1000\frac{W}{mK}$$

$$A\_{rod}\in R$$

$$T\_{a}=300K$$

$$T\_{b}=500K$$

$$L=1.0 m$$

*A W P E B*

Control volume boundaries/Cell faces

Control volume/Grid cell/Mesh cell, …

$$T\_{a}=300K$$

$$T\_{b}=500K$$

1. Derive the differential equation for one-dimensional steady heat transfer in the rod.

Energy conserves at a steady state.

In – Out = 0

Considering only heat conduction:

![](data:image/x-wmf;base64...)

1. Implement the problem in the program *conduction01.m*. Use the following parameters:
   number of grid cells, NPI = 20
   number of iterations for the solver, OUTER\_ITER = 100
   Hint: change the procedures *init*, *bound* and *T-equation*.

![](data:image/x-emf;base64...)

1. Vary the number of grid cells. What effect does the number of grid cells have on the convergence speed? Compare the numerical results with the analytical solution.

Analytical solution:

![](data:image/x-wmf;base64...)

Increase the number of grid cells requires more number of OUTER\_ITER to achieve convergence, see the following two graphs. For NPI = 50, OUTER\_ITER = 100 is not enough for an accurate result. Increase the outer iteration number to 1000, the result converges to the analytical solution. In the case of NPI = 100, it requires even more OUTER\_ITER until convergence.

![](data:image/png;base64...)![](data:image/png;base64...)

**Problem 1b: one-dimensional steady heat-transfer in a plate**

Consider Example 4.2 in the book of Versteeg and Malalasekera.

1. Implement the problem as suggested by the book in the program *conduction01.m* and calculate the temperature profile in the plate.

NPI = 5; % number of grid cells in x-direction [-]

XMAX = 0.02; % width of the domain [m]

OUTER\_ITER = 100; % number of outer iterations

% Specify boundary conditions for a calculation

T(Istart-1) = 373.15;

T(Iend+1) = 473.15;

AREAw = 1;

AREAe = 1;

Su(i) = 1000000.\*(AREAw+AREAe)/2\*Dx; % 1000000 is the source term

![](data:image/png;base64...)

boundary node 5

boundary node 1

nodal point 4

nodal point 3

nodal point 2

1. Use the suggested coefficients of the internal nodes. However apply these coeffients also for the boundary nodes. Does this change the results of your simulation? Explain why.

It does not change. The expressions are the same.

Considering the plate is discretized into 5 internal nodes. Applying the discretization coefficients on the boundary node 1, Eq. (4.30):

![](data:image/x-wmf;base64...)

Note that the distance between node 1 and the boundary is only **half** of the internal distance, so that

![](data:image/x-wmf;base64...)

![](data:image/x-wmf;base64...)

Now apply the discretization coefficients on the boundary node 1 using Eq. (4.33)

![](data:image/x-wmf;base64...)

The expression is exactly the same as that derived from Eq. (4.30). As long as the spatial discretization is treated properly, the solutions will be identical. Perform the same analysis on boundary node 5 should yield the same conclusion.

1. Analyse the differences between the predicted and theoretical temperatures. Try to explain the differences? Hint: verify the discretisation for the boundary nodes.

![](data:image/png;base64...)

As can be seen from the figure, the numerical solution slightly overpredicts the temperature.

**Problem 1c: one-dimensional steady heat-transfer**

If you have any time left, you can formulate and implement a one-dimensional steady heat-transfer problem yourself.