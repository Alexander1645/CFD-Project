**General goal: get familiar with the code: where does what?**

# Problem 3: two-dimensional steady convection-diffusion of a compressible flow

Consider the flow of air in a heat exchanger:

v∞ = 0.02 m/s

T∞ = 273 K

T = 373 K

T = 373 K

![](data:image/x-wmf;base64...)![](data:image/x-wmf;base64...)![](data:image/x-wmf;base64...)The steady flow in the heat exchanger can be described by the following equations:

The viscosity, *μ*, the thermal conductivity, *k* and the density, *ρ* are dependent upon the temperature. The temperature dependencies are already programmed in the computer code. The density is calculated through the ideal gas law:

![](data:image/x-wmf;base64...)

You can place baffles in the heat exchanger through source terms in the routine ‘ucoeff’. See page 267 of the book (*page 193 in the first edition*) for a full explanation.

**Assignment:**

Investigate the influence of number, size and position of baffles on the performance of the heat exchanger. Note: the performance involves both the temperature increase of the fluid and the pressure drop over the heat exchanger.

**Example 1: default baffle size position**

Source term in ucoeff.m

if (i == ceil((NPI+1)/5) && J < ceil((NPJ+1)/3))

SP(i,J) = -LARGE;

end

if (i == ceil(2\*(NPI+1)/5) && J > ceil(2\*(NPJ+1)/3))

SP(i,J) = -LARGE;

end

The source term in vcoeff.m and Tcoeff.m should be changed accordingly. They are not shown here.

* 1. Velocity profile

![](data:image/png;base64...)

The flow streamline profile is shown in the figure.

* 1. Temperature

![](data:image/png;base64...)

Calculate the performance of heat exchange by estimating the average temperature difference at two ends:

diffT = mean(T(end,:))-mean(T(1,:)) = 56.33 K

* 1. Pressure

![](data:image/png;base64...)

Calculate the pressure drop by the pressure difference at two ends:

diffP = mean(p(2,:))-mean(p(end-1,:)) = 1.1 mPa

**Example 2: no baffles**

* 1. Velocity profile

![](data:image/png;base64...)

Temperature increase: diffT = 54.80 K

![](data:image/png;base64...)

* 1. Pressure drop: diffP = 0.63 mPa

![](data:image/png;base64...)

**Example 3: distanced baffle position**

Source term in ucoeff.m

if (i == ceil((NPI+1)/5) && J < ceil((NPJ+1)/3))

SP(i,J) = -LARGE;

end

if (i == ceil(4\*(NPI+1)/5) && J > ceil(2\*(NPJ+1)/3))

SP(i,J) = -LARGE;

end

The source term in vcoeff.m and Tcoeff.m should be changed accordingly. They are not shown here.

* 1. Velocity profile

![](data:image/png;base64...)

* 1. Temperature

![](data:image/png;base64...)

diffT = mean(T(end,:))-mean(T(1,:)) = 58.72 K

* 1. Pressure

![](data:image/png;base64...)

diffP = mean(p(2,:))-mean(p(end-1,:)) = 1.32 mPa

**Example 4: 4 baffles**

Source term in ucoeff.m

if (i == ceil((NPI+1)/5) && J < ceil((NPJ+1)/3))

SP(i,J) = -LARGE;

elseif (i == ceil(3\*(NPI+1)/5) && J < ceil((NPJ+1)/3))

SP(i,J) = -LARGE;

elseif (i == ceil(2\*(NPI+1)/5) && J > ceil(2\*(NPJ+1)/3))

SP(i,J) = -LARGE;

elseif (i == ceil(4\*(NPI+1)/5) && J > ceil(2\*(NPJ+1)/3))

SP(i,J) = -LARGE;

end

* 1. Velocity profile

![](data:image/png;base64...)

* 1. Temperature

![](data:image/png;base64...)

diffT = mean(T(end,:))-mean(T(1,:)) = 61.43 K

* 1. Pressure

![](data:image/png;base64...)

diffP = mean(p(2,:))-mean(p(end-1,:)) = 1.93 mPa