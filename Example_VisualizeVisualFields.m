%% Add paths and load example data

addpath('GIFTI');
addpath('InflatableRender');
addpath('distinguishable_colors');
addpath('FreesurferFunctions');

surface=gifti('TestData/L_Surface.surf.gii');
inflated_surface=gifti('TestData/L_InflatedSurface.surf.gii');
brainmat=load('TestData/ElectrodeLocations.mat');

%% plot continous colormap
figure('color','white');

ci_sulc=fast_read_curv('TestData/lh.sulc');
ci_sulc(ci_sulc < 0.7) =0;
ci_sulc(ci_sulc >= 0.7)=1;

[ci,fnum]=fast_read_curv('TestData/lh.benson14_varea'); % load sulcus information - this information is generated from the freesurfer segmentation
ci=ci+1;
ci(ci == 1)=ci_sulc(ci == 1); % lets add sulcus information for non-visual areas
% ROI names in order of ID (first ID is 2):
%"V1v" "V1d" "V2v" "V2d" "V3v" "V3d" "hV4" "VO1" "VO2" "PHC1" "PHC2" 
%    "TO2" "TO1" "LO2" "LO1" "V3B" "V3A" "IPS0" "IPS1" "IPS2" "IPS3" "IPS4" 
%    "IPS5" "SPL1" "FEF"

h_surf=inflatablesurf(surface.faces, ...
    surface.vertices, ... %uninflated vertices
    inflated_surface.vertices, ... %inflated vertices
    ci, ... %colormap value associated to each vertex
    'linestyle', 'none','FaceColor', 'interp');



%change material and light conditions
material([.3 .9 .2 50 1]);
lighting gouraud
l1 = light;
set(l1,'Position',[-1 0 1]);


cmap=distinguishable_colors(numel(unique(ci)));
cmap(1,:)=[0.7 0.7 0.7];
cmap(2,:)=[0.5 0.5 0.5];
colormap( cmap);

axis equal

view([-90 0]);
h_surf.Inflation=1;


%% Add electrodes grouped by trajectory
brainmat=load('TestData/ElectrodeLocations.mat');
allowed_dist=4;
cols=distinguishable_colors(numel(unique(brainmat.electrodeDefinition.DefinitionIdentifier)));
hold on;
for traj=unique(brainmat.electrodeDefinition.DefinitionIdentifier)'
    elecs=brainmat.electrodeDefinition.Location(brainmat.electrodeDefinition.DefinitionIdentifier == traj,:);
    d=minDistance(elecs,surface.vertices);
    elIdx=1:size(elecs,1);
    elecs=elecs(d < allowed_dist,:);
    elIdx=elIdx(d < allowed_dist);
    hh=inflatablescatter3(h_surf,elecs(:,1), ...
        elecs(:,2), ...
        elecs(:,3),200,'filled','MarkerFaceColor',cols(traj,:),'MarkerEdgeColor','k','LineWidth',3);

end


