clc; clear all; close all;
geometry = stlread('culone_stl.stl');
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

angleOfAttack = 2;

switch angleOfAttack
    case 1
        AoA = deg2rad(2);   % First angle of attack [deg]
    case 2
        AoA = deg2rad(10);  % Second angle of attack [deg]
end

% Geometry plotting

P = incenter(geometry);
n = -faceNormal(geometry);  % The command generates inward normals, ...
                            % with the minus in front they become outward!
trisurf(geometry,'FaceColor', 'cyan', 'faceAlpha', 0.8);
axis equal;
hold on;
quiver3(P(:,1),P(:,2),P(:,3),n(:,1),n(:,2),n(:,3),0.5, 'color','r');
hold off;

% Normals and areas vector generation

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
Vinf_dir = [0,-cos(AoA),sin(AoA)];
v_inf = c*Mach;

% Dynamic pressure
q = 0.5*rho_inf*v_inf^2;

dF = ones(length(area),3);
theta = ones(length(area),1);

% Doubts: geometrical vectors
for i = 1:length(area)
    theta(i) = pi/2 - acos(dot(-Vinf_dir,n(i,:)));
    if dot(-Vinf_dir,n(i,:))<=0
        Cp=0;
    else
        Cp = 2*(sin(theta(i)))^2;
    end
    
    dF(i,:) = -Cp*q*area(i)*n(i,:);
end

F = sum(dF);
D = dot(F,Vinf_dir)*Vinf_dir;
L = F - D;

Lplot = L/norm(F);
Dplot = D/norm(F);

F=F/norm(F);
trisurf(geometry);
hold on
plotL = quiver3(0,0,0,Lplot(1),Lplot(2),Lplot(3),5,'LineWidth',2);
plotD = quiver3(0,0,0,Dplot(1),Dplot(2),Dplot(3),5,'LineWidth',2);
plotVinf = quiver3(0,0,0,Vinf_dir(1),Vinf_dir(2),Vinf_dir(3),5,'k');
legend([plotL plotD plotVinf],{'Lift','Drag','$v_{\infty}$'},'Interpreter','latex')
axis equal