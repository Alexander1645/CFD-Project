% SWEEP_FIGURE — headline result figure (UPDATE_2 item 4).      NEW FILE [B2-8]
% Four panels vs xKN: yK2 (chemistry), quasi-steady Tvent_fw, dilution D and
% formation concentration C_form; A_screen table printed + saved. Reads the
% three finished sweep runs through postproc_smoke() so the numbers are the
% same as each run's postproc_summary.txt. Figure generation only — no solver
% interaction.

xKNs = [0.55 0.65 0.70 0.75 0.80];
n = numel(xKNs);
dirs = cell(1,n);
for k = 1:n
    dirs{k} = fullfile('results', sprintf('xKN%03d', round(100*xKNs(k))));
end

Tfw = zeros(1,n); D = zeros(1,n); Cf = zeros(1,n); As = zeros(1,n);
Tfl = zeros(1,n); yK = zeros(1,n); Creq = 0;
for k = 1:n
    o = postproc_smoke(dirs{k});
    Tfw(k) = o.Tfw_qs;  D(k) = o.D_qs;  Cf(k) = o.Cform_qs;  As(k) = o.A_screen;
    Creq = o.Creq;
    [yK(k), dT] = chemistry(xKNs(k));  Tfl(k) = 298 + dT;
end

% smooth chemistry curves for context
xs = 0.50:0.01:0.80;  yKs = zeros(size(xs));  Tfls = zeros(size(xs));
for k = 1:numel(xs)
    [yKs(k), dT] = chemistry(xs(k));  Tfls(k) = 298 + dT;
end

T_c = 1164.;
fig = figure('Position',[80 80 900 640]);
tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

nexttile; plot(xs,yKs,'-','LineWidth',1.2); hold on;
plot(xKNs,yK,'o','MarkerFaceColor','auto'); grid on;
xlabel('x_{KN} [-]'); ylabel('y_{K2CO3} [kg/kg]');
title('(a) K_2CO_3 yield (chemistry)');

nexttile; plot(xs,Tfls,'--','LineWidth',1.0); hold on;
plot(xKNs,Tfw,'o-','LineWidth',1.4);
yline(T_c,':','T_c = 1164 K'); grid on;
xlabel('x_{KN} [-]'); ylabel('T [K]');
legend('T_{flame} (chemistry)','T_{vent,fw} (CFD, quasi-steady)','Location','south');
title('(b) vent temperature vs flame temperature');

nexttile; plot(xKNs,D,'s-','LineWidth',1.4); grid on;
xlabel('x_{KN} [-]'); ylabel('D [kg air / kg gas]');
title('(c) dilution to reach T_c');

nexttile; plot(xKNs,1000*Cf,'d-','LineWidth',1.4); hold on;
yline(1000*Creq,'--',sprintf('C_{req} = %.2f g/m^3',1000*Creq)); grid on;
xlabel('x_{KN} [-]'); ylabel('C [g/m^3]');
title('(d) smoke concentration at the T_c point');

sgtitle('KNSu smoke grenade: composition sweep (h_{wall} = 10 W/m^2K)');
saveas(fig, fullfile('results','sweep_summary.png'));

fid = fopen(fullfile('results','sweep_summary.txt'),'w');
fprintf(fid,'xKN    yK2     Tvent_fw[K]  D[kg/kg]  C_form[g/m3]  A_screen[m2/m]\n');
for k = 1:n
    fprintf(fid,'%.2f  %.3f  %10.1f  %8.3f  %11.2f  %13.1f\n', ...
        xKNs(k), yK(k), Tfw(k), D(k), 1000*Cf(k), As(k));
end
fprintf(fid,'C_req = %.3f g/m3 (alpha=3 m2/g, T=2%%, L=5 m)\n', 1000*Creq);
fclose(fid);
fprintf('sweep figure + table written to results/\n');
