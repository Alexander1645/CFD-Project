function make_figures(rundir, varargin)
% MAKE_FIGURES — report figures for an Option B run.              NEW FILE [B3]
% Pure post-processing: reads grenade_history.txt (time traces) and
% snapshots.mat (full fields every SNAP_DT s, written by grenade06.m).
% Writes PNGs into <rundir>/figs/.
%
% Usage:
%   make_figures                          % everything, all snapshots
%   make_figures('.', 'plots', {'p','quiver'})        % only these types
%   make_figures('.', 'times', [2.5 10 35])           % only these snapshots
%   make_figures('.', 'plots', {'hist'})              % only the time traces
%
% Plot types ('plots' option, cell array of any of):
%   'hist'   uvent_vs_t.png + K2_vs_t.png (time traces; ignores 'times')
%   'p'      p_t####s.png      pressure contour, T-figure style
%   'vel'    vel_t####s.png    velocity-magnitude contour
%   'quiver' vec_t####s.png    velocity vector (arrow) plot
%   'T'      T_t####s.png      temperature contour
%   'yk2'    yk2_t####s.png    smoke species (K2CO3 loading) contour
%
% 'times' option: vector of snapshot times [s] to plot (nearest snapshot is
% used, warning if >0.1 s away). Default: all snapshots in the file.
%
% The unburnt solid region is plotted as-is: its stored values are the pinned
% constants (p = 0 gauge, u = v = 0), so it renders as a uniform dark block —
% same convention as the T contour in grenade06.m.

if nargin < 1 || isempty(rundir), rundir = '.'; end
opt = struct('plots', {{'hist','p','vel','quiver','T','yk2'}}, 'times', []);
for k = 1:2:numel(varargin), opt.(lower(varargin{k})) = varargin{k+1}; end
want = @(s) any(strcmpi(s, opt.plots));

figdir = fullfile(rundir,'figs');
if ~exist(figdir,'dir'), mkdir(figdir); end
nfig = 0;

%% ---- time traces from grenade_history.txt --------------------------------
if want('hist')
    H = readmatrix(fullfile(rundir,'grenade_history.txt'), ...
                   'FileType','text','NumHeaderLines',1);
    t      = H(:,1);   uvent = H(:,4);
    K2prod = H(:,9);   mdotK2 = H(:,11);   MK2v = H(:,12);

    f = figure('Visible','off');
    plot(t, uvent, 'LineWidth', 1.0); grid on;
    xlabel('t [s]'); ylabel('mean vent velocity [m/s]');
    title('Outlet (vent) velocity');
    exportgraphics(f, fullfile(figdir,'uvent_vs_t.png'), 'Resolution', 200);
    close(f);  nfig = nfig + 1;

    f = figure('Visible','off');
    yyaxis left
    plot(t, K2prod, '-', t, MK2v, '--', 'LineWidth', 1.2); grid on;
    ylabel('cumulative K_2CO_3 [kg per m depth]');
    yyaxis right
    plot(t, mdotK2, ':', 'LineWidth', 1.0);
    ylabel('venting rate [kg/s per m depth]');
    xlabel('t [s]');
    legend('produced (from burned charge)','vented (left the chamber)', ...
           'venting rate','Location','northwest');
    title('Potassium carbonate production and release');
    exportgraphics(f, fullfile(figdir,'K2_vs_t.png'), 'Resolution', 200);
    close(f);  nfig = nfig + 1;
end

%% ---- field snapshots ------------------------------------------------------
if want('p') || want('vel') || want('quiver') || want('T') || want('yk2')
    S = load(fullfile(rundir,'snapshots.mat'));   % SNAP, x, y
    x = S.x;  y = S.y;
    NPI = numel(x)-2;  NPJ = numel(y)-2;

    % select snapshots: all, or nearest to each requested time
    if isempty(opt.times)
        sel = 1:numel(S.SNAP);
    else
        tsnap = [S.SNAP.t];
        sel = zeros(1,numel(opt.times));
        for k = 1:numel(opt.times)
            [derr, sel(k)] = min(abs(tsnap - opt.times(k)));
            if derr > 0.1
                warning('no snapshot near t=%.2f s; using nearest (t=%.2f s)', ...
                        opt.times(k), tsnap(sel(k)));
            end
        end
        sel = unique(sel);
    end

    for n = sel
        sn = S.SNAP(n);

        % velocity averaged from staggered faces to cell centres
        uc = zeros(NPI+2, NPJ+2);  vc = zeros(NPI+2, NPJ+2);
        uc(1:NPI+1,:) = 0.5*(sn.u(1:NPI+1,:) + sn.u(2:NPI+2,:));
        vc(:,1:NPJ+1) = 0.5*(sn.v(:,1:NPJ+1) + sn.v(:,2:NPJ+2));

        if want('p')
            f = figure('Visible','off');
            contourf(x, y, sn.p', 20, 'LineColor','none');
            colorbar; axis equal tight;
            title(sprintf('p_{gauge} [Pa], t=%.1f s (front at x=%.0f mm)', ...
                          sn.t, sn.xf*1000));
            exportgraphics(f, fullfile(figdir, sprintf('p_t%05.1fs.png',sn.t)), ...
                           'Resolution',200);
            close(f);  nfig = nfig + 1;
        end

        if want('vel')
            f = figure('Visible','off');
            contourf(x, y, sqrt(uc.^2 + vc.^2)', 20, 'LineColor','none');
            colorbar; axis equal tight;
            title(sprintf('|V| [m/s], t=%.1f s (front at x=%.0f mm)', ...
                          sn.t, sn.xf*1000));
            exportgraphics(f, fullfile(figdir, sprintf('vel_t%05.1fs.png',sn.t)), ...
                           'Resolution',200);
            close(f);  nfig = nfig + 1;
        end

        if want('T')
            f = figure('Visible','off');
            contourf(x, y, sn.T', 20, 'LineColor','none');
            colorbar; axis equal tight;
            title(sprintf('T [K], t=%.1f s (front at x=%.0f mm)', ...
                          sn.t, sn.xf*1000));
            exportgraphics(f, fullfile(figdir, sprintf('T_t%05.1fs.png',sn.t)), ...
                           'Resolution',200);
            close(f);  nfig = nfig + 1;
        end

        if want('yk2')
            f = figure('Visible','off');
            contourf(x, y, sn.YK2', 20, 'LineColor','none');
            colorbar; axis equal tight;
            title(sprintf('Y_{K_2CO_3} [kg/kg], t=%.1f s (front at x=%.0f mm)', ...
                          sn.t, sn.xf*1000));
            exportgraphics(f, fullfile(figdir, sprintf('yk2_t%05.1fs.png',sn.t)), ...
                           'Resolution',200);
            close(f);  nfig = nfig + 1;
        end

        if want('quiver')
            f = figure('Visible','off');
            [X,Y] = ndgrid(x, y);
            quiver(X(2:NPI+1,2:NPJ+1), Y(2:NPI+1,2:NPJ+1), ...
                   uc(2:NPI+1,2:NPJ+1), vc(2:NPI+1,2:NPJ+1), 2, 'k');
            hold on; xline(sn.xf, 'r--', 'front');        % burning surface
            axis equal tight; xlim([x(1) x(end)]); ylim([y(1) y(end)]);
            xlabel('x [m]'); ylabel('y [m]');
            title(sprintf('velocity vectors, t=%.1f s (front at x=%.0f mm)', ...
                          sn.t, sn.xf*1000));
            exportgraphics(f, fullfile(figdir, sprintf('vec_t%05.1fs.png',sn.t)), ...
                           'Resolution',200);
            close(f);  nfig = nfig + 1;
        end
    end
end

fprintf('make_figures: wrote %d figure(s) to %s\n', nfig, figdir);
end
