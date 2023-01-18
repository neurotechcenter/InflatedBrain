addpath('GIFTI');
addpath('InflatableRender');
addpath('distinguishable_colors');
addpath('FreesurferFunctions');

surface=gifti('TestData/L_Surface.surf.gii');
inflated_surface=gifti('TestData/L_InflatedSurface.surf.gii');
brainmat=load('TestData/ElectrodeLocations.mat');


%% only use points within 4mm  use sulc labels
allowed_dist=4;
figure('color','white');


ci=fast_read_curv('TestData/lh.sulc');

%plot the inflatable surface - allows to be modified like any other patch,
%with additional parameter for inflation
h=inflatablesurf(surface.faces,surface.vertices,inflated_surface.vertices,ci, ...
    'linestyle', 'none','FaceLighting','gouraud','BackFaceLighting','unlit','AmbientStrength',1);


colormap(flipud(gray(100)));
clim(max(abs(ci))*[-1 1]);
h.Inflation=0;
colorbar
hold on;

%% Add electrodes grouped by trajectory
cols=distinguishable_colors(numel(unique(brainmat.electrodeDefinition.DefinitionIdentifier)));
for traj=unique(brainmat.electrodeDefinition.DefinitionIdentifier)'
    elecs=brainmat.electrodeDefinition.Location(brainmat.electrodeDefinition.DefinitionIdentifier == traj,:);
    d=minDistance(elecs,surface.vertices);
    elIdx=1:size(elecs,1);
    elecs=elecs(d < allowed_dist,:);
    elIdx=elIdx(d < allowed_dist);
    hh=inflatablescatter3(h,elecs(:,1), ...
        elecs(:,2), ...
        elecs(:,3),300,'filled','MarkerFaceColor',cols(traj,:),'MarkerEdgeColor','k','LineWidth',3);

end

view([-90 0]);


%% add slider

slhan=uicontrol('style','slider','position',[100 0 400 40] ...
    ,'min',0,'max',1,'Value',h.Inflation,'Callback',@(x,y)set(h,'Inflation',x.Value));

