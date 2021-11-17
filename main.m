clc; clear all; close all;
geometry = stlread('culone_stl.stl');
trimesh(geometry)
axis equal
% Flight parameters
Mach = 5;  v_inf = Mach*333; % Mach number [-]
z = 10e3;   rho_inf = 0.4135;% Density @10km[kg/m^3]
AoA1 = 10;   % First angle of attack [deg]
AoA2 = 10;  % Second angle of attack [deg]
% Normals generation
F = faceNormal(geometry);
area = ones(size(geometry.ConnectivityList,1),1); %initialize the area
for i = 1:size(geometry.ConnectivityList,1)   %the number of rows gives the number of triangles produced
    a =  geometry.Points(geometry.ConnectivityList(i,:),:); %this gives the 3 vertices of the ith triangle
    %extract the three vertices
    p1 = a(1,:);  
    p2 = a(2,:);
    p3 = a(3,:);
    area(i) = 0.5 * norm(cross(p2-p1,p3-p1));  %calculate the area of the small triangle and add with previous result
end

% Define the flow magnitude and direction
q = 0.5*rho_inf*v_inf^2;
Vinf_dir = [0,-cos(AoA1),sin(AoA1)];
dF = ones(length(area),3);
for i = 1:length(area)
    theta = pi/2 - acos(dot(-Vinf_dir,F(i,:)));
    Cp = 2*(sin(theta));
    dF(i,:) = -Cp*q*area(i)*F(i,:);     % Not sure about the (-) sign
end
F = sum(dF);