function [] = mixprops(alpharho)
% Purpose: mixture properties for the one-phase solid/gas treatment.
% alpharho: under-relaxation factor for the density update (1 = none).
% Density feeds back on the pressure correction and the hole outflow, so
% inside the outer iteration loop it is updated with alpharho < 1.
% Replaces viscosity.m of the base code (laminar flow: no turbulent
% viscosity). The unburnt composition (mass fraction sf = mfu + mox) is
% given a very large viscosity so that it behaves as a solid; the K2CO3
% smoke is a dense particulate transported with the gas; the product gas
% is an ideal gas at atmospheric pressure (low-Mach assumption).

% constants
global P_ATM RUNIV MGAS RHOS RHOP CPMIX KSOL KGAS0 MUGAS0 MUSOLID SMALL
% variables
global T mfu mox mk2 rho mu Gamma GammaY sf

% clamp temperature and mass fractions to physical ranges
T   = min(max(T,250.),3500.);
mfu = min(max(mfu,0.),1.);
mox = min(max(mox,0.),1.);
mk2 = min(max(mk2,0.),1.);
scale = max(mfu + mox + mk2, 1.);   % renormalise numerical overshoots
mfu = mfu./scale;
mox = mox./scale;
mk2 = mk2./scale;
mpr = max(1 - mfu - mox - mk2, 0.); % product gas closes the mass balance

sf = mfu + mox;                     % unburnt solid mass fraction [-]

% mixture density.
% The gas/aerosol share mixes harmonically (volume-weighted), which is
% exact for a dilute particulate suspension. The solid share is blended
% LINEARLY in sf: a strict volume-weighted mix would let the density of
% a burning cell collapse as soon as a tiny gas mass fraction appears
% (gas specific volume is ~200x that of the solid), releasing the whole
% expansion at the start of the burn and destabilising the pressure
% correction. The linear blend releases the same total expansion evenly
% over the burn of the cell (physically: the gas stays compact in the
% pores of the char matrix until the matrix is consumed).
rhog   = P_ATM*MGAS./(RUNIV*T);                      % ideal product gas
gassh  = max(mk2 + mpr, SMALL);                      % gas + aerosol share
rho_ga = gassh./( mk2/RHOP + mpr./rhog + SMALL );    % density of that share
rhonew = sf*RHOS + (1 - sf).*rho_ga;
rho    = alpharho*rhonew + (1 - alpharho)*rho;

% viscosity: laminar gas value, blended to a huge value in the solid
mug = MUGAS0*(T/300.).^0.7;
mu  = mug + MUSOLID*sf.^2;

% conduction coefficient Gamma = k/cp for the T equation
kg    = KGAS0*(T/300.).^0.75;
kcond = KSOL*sf + kg.*(1 - sf);
Gamma = kcond/CPMIX;

% species diffusion coefficient GammaY = rho*D ~ mu_gas/Sc (Sc = 0.7);
% no species diffusion inside the solid
GammaY = (mug/0.7).*(1 - sf) + 1e-12;
end

