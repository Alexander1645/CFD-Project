**General goal: get familiar with the code: where does what?**

# Problem 4

As was discussed during the lectures the momentum balances are written in a general form:

![](data:image/x-wmf;base64...)![](data:image/x-wmf;base64...)

![](data:image/x-wmf;base64...)![](data:image/x-wmf;base64...)As indicated on page 23 of the book a part of the less important contributions of the stress term are ‘hidden’ in the source terms. The total source term is:

Note that λ is generally taken to be zero and that the pressure gradient is already included in the code. The code does *not* contain the ‘hidden’ stress term contributions yet. The assignment of today is to include these contributions in the sourceterms and to investigate their effect on the outcome of your results (evaluate the Strouhal number, St = *f D*/*u*). The case to be studied is the example of vortex shedding that was discussed in the lecture. Use the code *transient01.m*

Hint 1: make a **large** drawing of the grid and investigate on what positions u and v are evaluated.

Hint 2: discretise the stress contributions using ‘NSWE’ notation. It is common practice to use the variables at the old time level in the calculation of the ‘hidden’ stress term contributions. **Consult the teachers before you start with the actual implementation.**

Hint 3: write a procedure that computes the different velocity gradients and stores them in variables like dudx, dudy, dvdx, dvdy. Make sure to use proper indices (should it be dudxij or dudxIJ?).

![](data:image/png;base64...)![](data:image/png;base64...)

So only this term ( is added to the former equation.

![](data:image/png;base64...)![](data:image/png;base64...)![](data:image/png;base64...)![](data:image/png;base64...)

We know (continuity equation). So we have

![](data:image/png;base64...)![](data:image/png;base64...)![](data:image/png;base64...)![](data:image/png;base64...)![](data:image/png;base64...)

Similarly, we can do the same for the momentum equation in the y-direction. So these terms have not any effect on the result.

Velocity components are defined on interfaces. With central differentiation, we obtain the gradient of the velocities in the cell centers. So we should use dudxIJ.