%% From antenna toolbox to Phased Array Analysis
% Dual polarization antenna
%
% * a PCB Antenna Design has been created from this shipping example : <https://www.mathworks.com/help/releases/R2025b/antenna/ug/model-and-analyze-dual-polarized-patchmicrostrip-antenna.html 
% https://www.mathworks.com/help/releases/R2025b/antenna/ug/model-and-analyze-dual-polarized-patchmicrostrip-antenna.html>
% * Please open PCB_AntennaDesign.mat in PCBAntennaDesigner for more details

clear;
% Load dual polarization antenna design
% - created using PCBAntennaDesigner App

load dualPolarizedAntennaDesign.mat;

c       = physconst('LightSpeed');
fc      = 2.4e9;
lambda  = freq2wavelen(fc,c);

% Array specifications
numRows = 8;
numCols = 8;
lattice = "rectangular";

% Adjust Meshing
meshconfig(dualPolarizedAntenna,'manual');

figure
mesh(dualPolarizedAntenna,"MaxEdgeLength",0.006, "MinEdgeLength",0.004, "GrowthRate",0.7)

az = -180:3:180;
el = -90:3:90;
%% Plot radiating diagram for a single element
% This step could take up to 2-3 minutes...please be patient
tic;
figure;
pattern(dualPolarizedAntenna,fc,az,el);
toc
%% Import radiating element in the array
AESA = phased.URA(...
    "Element",dualPolarizedAntenna,...
    "Size",[numRows, numCols],...
    "ElementSpacing",lambda/2, ...
    "Lattice",lattice,"ArrayNormal","z");

%%
tic;
figure;
pattern(AESA,fc,az,el,"ShowArray",true)
toc
%%
bw = beamwidth(AESA,fc);
%%
viewArray(AESA)
%%
dvty =  directivity(AESA,fc,[0;90])

%%
Optional
Could illustrate mag and phase patterns
pResp = phased.ArrayResponse("SensorArray",AESA,"EnablePolarization",false);

az = -180:1:180;
el = -90:1:90;

pat = zeros(181,361);

for m = 1:181
pat(m,:) = pResp(fc,[az;el(m)*ones(1,361)]);
end 

magPattern = mag2db(abs(pat))

figure
patternCustom(mag2db( abs(magPattern)'),el,az)
grid on

PhiPattern = angle(pat)