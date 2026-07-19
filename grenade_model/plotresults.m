function [] = plotresults(time,xKN)
% Purpose: contour plots of the main fields, in the style of
% ProjectInfo/contourfplots.m.

% variables
global x y u v T mfu mox mk2 sf rho

clf

subplot(2,3,1)
contourf(x,y,T','EdgeColor','none');
colormap(jet); colorbar
title(sprintf('T [K]   (t = %.3f s, x_{KN} = %.2f)',time,xKN));
xlabel('x [m]'); ylabel('y [m]');

subplot(2,3,2)
contourf(x,y,sf','EdgeColor','none');
colorbar; caxis([0 1]);
title('unburnt solid fraction m_{fu}+m_{ox} [-]');
xlabel('x [m]'); ylabel('y [m]');

subplot(2,3,3)
contourf(x,y,mk2','EdgeColor','none');
colorbar
title('K_2CO_3 smoke fraction m_{k2} [-]');
xlabel('x [m]'); ylabel('y [m]');

subplot(2,3,4)
quiver(x,y,u',v',2);
axis([0 max(x) 0 max(y)]);
title('velocity vectors');
xlabel('x [m]'); ylabel('y [m]');

subplot(2,3,5)
contourf(x,y,mfu','EdgeColor','none');
colorbar
title('fuel (sucrose) m_{fu} [-]');
xlabel('x [m]'); ylabel('y [m]');

subplot(2,3,6)
contourf(x,y,log10(rho'),'EdgeColor','none');
colorbar
title('log_{10} \rho [kg/m^3]');
xlabel('x [m]'); ylabel('y [m]');
end
