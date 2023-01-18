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
s1=subplot(1,2,1);

ci=fast_read_curv('TestData/lh.sulc'); % load sulcus information - this information is generated from the freesurfer segmentation

h=inflatablesurf(surface.faces, ...
    surface.vertices, ... %uninflated vertices
    inflated_surface.vertices, ... %inflated vertices
    ci, ... %colormap value associated to each vertex
    'linestyle', 'none','FaceColor', 'interp');

%change material and light conditions
material([.3 .9 .2 50 1]);
lighting gouraud
l1 = light;
set(l1,'Position',[-1 0 1]);


colormap(s1,flipud(gray(100))); % use a grey colormap
clim(max(abs(ci))*[-1 1]);
axis equal
h.Inflation=0;
view([-90 0]);

title('Continous Colormap');

%% plot binarized colormap to highlight sulci 

s2=subplot(1,2,2);


ci=fast_read_curv('TestData/lh.sulc'); % load sulcus information - this information is generated from the freesurfer segmentation
% create binary colormap
ci(ci < 0.7) =0;
ci(ci >= 0.7)=1;

h=inflatablesurf(surface.faces, ...
    surface.vertices, ... %uninflated vertices
    inflated_surface.vertices, ... %inflated vertices
    ci, ... %colormap value associated to each vertex
    'linestyle', 'none','FaceColor', 'interp');

%change material and light conditions
material([.3 .9 .2 50 1]);
lighting gouraud
l1 = light;
set(l1,'Position',[-1 0 1]);


colormap(s2,[0.7 0.7 0.7;0.5 0.5 0.5]); % use two shades of gray to plot binary map

axis equal
h.Inflation=0;
view([-90 0]);
title('Binary Colormap');
