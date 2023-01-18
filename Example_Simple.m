%% Add paths and load example data

addpath('GIFTI');
addpath('InflatableRender');
addpath('distinguishable_colors');
addpath('FreesurferFunctions');

surface=gifti('TestData/L_Surface.surf.gii');
inflated_surface=gifti('TestData/L_InflatedSurface.surf.gii');
brainmat=load('TestData/ElectrodeLocations.mat');
%% Create a morphable surface 
figure;
h_surf=inflatablesurf(surface.faces, ... 
    surface.vertices, ... %uninflated vertices
    inflated_surface.vertices, ... %inflated vertices
    surface.cdata, ... %colormap value associated to each vertex
    'linestyle', 'none','FaceLighting','gouraud','BackFaceLighting','unlit','AmbientStrength',1); % see patch for all options
colormap prism; %set colors for colormap

h_surf.Inflation=0.5; %set inflation

%% Determine Electrode locations within 4mm of surface
eLocs=brainmat.electrodeDefinition.Location;
d=minDistance(eLocs,surface.vertices);

%remove electrode locations outside of 4mm
eLocs(d > 4,:)=[];
%% Add linked electrode locations
hold on;


h_scatter=inflatablescatter3(h_surf,eLocs(:,1), ... %x coordinates
    eLocs(:,2), ... % y coordinates
    eLocs(:,3), ...% z coordinates
    100,'filled','MarkerFaceColor','r','MarkerEdgeColor','k','LineWidth',3); %see scatter3 for all options

h_scatter.Inflation=0; % changing inflation on inflatablescatter3 will also morph the surface

disp(h_scatter.inflated_xyz); %access the electrode coordinates for the current inflation value

%% Add linked text for each electrode

for iel=1:size(eLocs,1)
    inflatabletext(h_scatter, ... % new objects can be linked to any other linked object 
        eLocs(iel,1),eLocs(iel,2),eLocs(iel,3), ...
        num2str(iel), ... 
        'FontSize',14,'Color','k','Interpreter','none'); % for additional settings see text
end

%% Change Surface Transparency 
set(h_surf,'FaceAlpha',0.3);
% or
h_surf.FaceAlpha=0.15;

