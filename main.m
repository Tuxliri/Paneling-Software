clc; clear all; close all;
geometry = stlread('culone_stl.stl');
trimesh(geometry)
axis equal

% Flight parameters
Mach = 5;  
z = 10e3;   

% Get atmospheric properties at height 10km (US Standard Atmosphere)

T = -49.90 + 273.15;    % Temperature [K]
rho_inf = 0.4135;       % Density @10km[kg/m^3]
gamma = 1.4;
R = 8.31432e3/29;

c = sqrt(gamma*R*T);
% Angles of attack definition

AoA1 = 10;   % First angle of attack [deg]
AoA2 = 10;  % Second angle of attack [deg]

% Normals and areas vector generation
F = faceNormal(geometry);
area = ones(size(geometry.ConnectivityList,1),1); %initialize the area
for i = 1:size(geometry.ConnectivityList,1)   %the number of rows gives the number of triangles produced
    a =  geometry.Points(geometry.ConnectivityList(i,:),:); %this gives the 3 vertices of the ith triangle
    
    %extract the three vertices
    p1 = a(1,:);  
    p2 = a(2,:);
    p3 = a(3,:);
    
    %calculate the area of the triangle
    area(i) = 0.5 * norm(cross(p2-p1,p3-p1));  
end

% Define velocity direction and magnitude
Vinf_dir = [0,-cos(AoA1),sin(AoA1)];
v_inf = c*Mach;

% Dynamic pressure
q = 0.5*rho_inf*v_inf^2;

dF = ones(length(area),3);
theta = ones(length(area),1);
for i = 1:length(area)
    theta(i) = pi/2 - acos(dot(-Vinf_dir,F(i,:)));
    if dot(-Vinf_dir,F(i,:))<=0
        Cp=0;
    else
        Cp = 2*(sin(theta(i)));
    end
    
    dF(i,:) = -Cp*q*area(i)*F(i,:);     % Not sure about the (-) sign
end

F = sum(dF);