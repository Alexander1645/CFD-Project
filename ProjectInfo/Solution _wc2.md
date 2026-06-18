**General goal: get familiar with the code: where does what?**

# Problem 2: two-dimensional steady convection-diffusion

Consider a steady two-dimensional heat balance with a heat source. The temperature *T* is governed by:

![](data:image/x-wmf;base64...)

Where:

*ρ* = 1 kg/m3

*k* = 1 W /(K m) (note that *k* is named “Gamma” in the code)

*Cp* = 1 J/(K kg)

*a* = 10 W/m3

*b* = 2 W/(K m3)

The flow field is such that *u* = 1 m/s and *v* = 4 m/s everywhere. A domain of 1 x 1 m2 is divided into a uniform grid. The temperatures at the four boundaries are indicated in the figure below. Calculate the values of *Ta*, *Tb*, *Tc* and *Td*. The coordinates of these points are:

*Ta* = (0.25, 0.25) (theoretical value: *T* = 91.650)

*Tb* = (0.75, 0.25) (theoretical value: *T* = 65.200)

*Tc* = (0.25, 0.75) (theoretical value: *T* = 66.860)

*Td* = (0.75, 0.75) (theoretical value: *T* = 28.901)

Compare the following discretization schemes:

* The central difference scheme (currently implemented)
* The upwind scheme
* The hybrid scheme
* Optional: the power law scheme (see book)

Vary the number of grid points and note down the final values of the four temperatures. Make a plot of the values depending on the discretization scheme and the number of grid cells. Use the following grids: 2×2, 14×14, 34×34 and 66×66 numerical grid cells.

*T* = 100 K

*y*

*x*

*T* = 100 K

*T* = 0 K

*T* = 0 K

*φc* *φd*

*φa φb*

|  |  |  |
| --- | --- | --- |
| CDS | aW | Dw + Fw /2 |
| aE | De – Fe /2 |
| aN | Ds + Fs /2 |
| aS | Dn – Fn /2 |
| UDS | aW | Dw + max ( Fw ,0 ) |
| aE | De + max ( -Fe ,0 ) |
| aN | Ds + max ( Fs ,0 ) |
| aS | Dn + max ( -Fn ,0 ) |
| Hybrid | aW | Max ( Fw, Dw+Fw/2, 0 ) |
| aE | Max ( -Fe, De-Fe/2, 0 ) |
| aN | Max ( Fs, Ds+Fs/2, 0 ) |
| aS | Max ( -Fn, Dn-Fn/2, 0 ) |

**2×2**

CDS:

Ta = 88.487 k, Tb= 63.555 k, Tc= 65.992 k, Td=32.631 k

![](data:image/x-emf;base64...)

UDS:

Ta = 86.142 k, Tb= 62.542 k, Tc= 60.232 k, Td=31.164 k

![](data:image/x-emf;base64...)

Hybrid:

Ta = 88.487 k, Tb= 63.555 k, Tc= 65.992 k, Td=32.631 k

![](data:image/x-emf;base64...)

**14×14**

CDS:

Ta = 91.549 k, Tb= 65.106 k, Tc= 66.909 k, Td=29.034 k

![](data:image/x-emf;base64...)

UDS:

Ta = 91.386 k, Tb= 65.182 k, Tc= 65.001 k, Td=28.092 k

![](data:image/x-emf;base64...)

Hybrid:

Ta = 91.549 k, Tb= 65.106 k, Tc= 66.909 k, Td=29.034 k

![](data:image/x-emf;base64...)

**34×34**

CDS:

Ta = 91.633 k, Tb= 65.183 k, Tc= 66.869 k, Td=28.924k

![](data:image/x-emf;base64...)

UDS:

Ta = 91.583 k, Tb= 65.254 k, Tc= 66.016 k, Td=28.491 k

![](data:image/x-emf;base64...)

Hybrid:

Ta = 91.633 k, Tb= 65.183 k, Tc= 66.869 k, Td=28.924 k

![](data:image/x-emf;base64...)

**66×66**

CDS:

Ta = 91.646 k, Tb= 65.196 k, Tc= 66.862 k, Td=28.907 k

![](data:image/x-emf;base64...)

UDS:

Ta = 91.623 k, Tb= 65.241 k, Tc= 66.410 k, Td=28.675 k

![](data:image/x-emf;base64...)

Hybrid:

Ta = 91.646 k, Tb= 65.196 k, Tc= 66.862 k, Td=28.907 k

![](data:image/x-emf;base64...)

Now we pick up the value of one point and plot it as a function of grid number (NPI or NPJ) for different schemes. As you can see from the plot below, 1) for all the schemes, the results get better when refining the grid (increasing the number of grid points), eventually converge to the theoretical value. 2) CDS converges faster than UDS, because it is 2nd order accuracy and UDS is 1st accuracy. In this particular problem, Pe is always smaller than 2, so the hybrid scheme is just equivalent to CDS.

![](data:image/x-emf;base64...)