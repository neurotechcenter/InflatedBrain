%% Add paths and load example data

addpath('GIFTI');
addpath('InflatableRender');
addpath('distinguishable_colors');
addpath('FreesurferFunctions');

surface = gifti('TestData/L_Surface.surf.gii');
inflated_surface = gifti('TestData/L_InflatedSurface.surf.gii');
brainmat = load('TestData/ElectrodeLocations.mat');

if ~exist('VeraOutput','dir')
    mkdir VeraOutput
end

%% plot continous colormap
fh = figure('Position',[0 0 600 335],'color','white');

% load sulcus information - this information is generated from the freesurfer segmentation
ci_sulc = fast_read_curv('TestData/lh.sulc');
ci_sulc(ci_sulc < 0.7) = 0;
ci_sulc(ci_sulc >= 0.7) = 1;

% load segmentation from NeuroPythy: https://github.com/noahbenson/neuropythy
[ci,fnum] = fast_read_curv('TestData/lh.benson14_varea'); 
ci = ci+1;
ci(ci == 1) = ci_sulc(ci == 1); % lets add sulcus information for non-visual areas
% ROI names in order of ID (first ID is 2):
%"V1v" "V1d" "V2v" "V2d" "V3v" "V3d" "hV4" "VO1" "VO2" "PHC1" "PHC2" 
%    "TO2" "TO1" "LO2" "LO1" "V3B" "V3A" "IPS0" "IPS1" "IPS2" "IPS3" "IPS4" 
%    "IPS5" "SPL1" "FEF"

% render surface
h_surf = inflatablesurf(surface.faces, ...
    surface.vertices, ... %uninflated vertices
    inflated_surface.vertices, ... %inflated vertices
    ci, ... %colormap value associated to each vertex
    'linestyle', 'none','FaceColor', 'interp');

%change material and light conditions
material([.3 .9 .2 50 1]);
lighting gouraud
l1 = light;
set(l1,'Position',[-1 0 1]);

% set colormap
cmap = distinguishable_colors(numel(unique(ci)));
cmap(1,:) = [0.7 0.7 0.7];
cmap(2,:) = [0.5 0.5 0.5];
colormap( cmap);
axis equal

% set view
view([-90 0]);

% set level of inflation
h_surf.Inflation = 0;

% zoom
zoom(2);

% little bit transparent
h_surf.FaceAlpha = .90;

%% Add electrodes grouped by trajectory
allowed_dist = 4; % distance from pial in mm
cols = distinguishable_colors(numel(unique(brainmat.electrodeDefinition.DefinitionIdentifier)));
hold on;
for traj = unique(brainmat.electrodeDefinition.DefinitionIdentifier)'
    elecs = brainmat.electrodeDefinition.Location(brainmat.electrodeDefinition.DefinitionIdentifier == traj,:);
    d = minDistance(elecs,surface.vertices);
    elIdx = 1:size(elecs,1);
    elecs = elecs(d < allowed_dist,:);
    elIdx = elIdx(d < allowed_dist);
    hh = inflatablescatter3(h_surf,elecs(:,1), ...
        elecs(:,2), ...
        elecs(:,3), ...
        70,'filled','MarkerFaceColor','k','MarkerEdgeColor','w','LineWidth',1);
%         70,'filled','MarkerFaceColor',cols(traj,:),'MarkerEdgeColor','w','LineWidth',1);
end

%% get frames for gif

h_surf.Inflation = 1;

inflation_steps = [[0:.02:1],[1:-0.02:0]];

% get frames to plot
for kk = 1:length(inflation_steps)% write X frames: decides speed
    h_surf.Inflation = inflation_steps(kk);
    % Draw a frame on the figure.
    frames(kk) = getframe(fh);
end

close all


%% now plot and save gif

fh = figure('Position',[0 0 600 335],'color','white');

% Write each step to the file
for kk = 1:length(inflation_steps)% write X frames: decides speed
    image(frames(kk).cdata)
    axis image
    set(gca,'XTick',[],'YTick',[])
    exportgraphics(fh,'./VeraOutput/inflated_Adameketal_lateral2022.gif','Append',true);
    cla
end
