% This script is the Lateral Flow Assay (LFA) Model of Rochester iGEM team. This script finds the signal strength on our LFA for the design parameters specified under "Changing parameters".

[pa,lp,out] = loopRun;
save('LFA_Model');

function [pa,lp,out] = loopRun
%Parameters
pa.DA = 1e-4; % Analyte diffusivity (mm2/s)
pa.DP = 1e-6; % Detector diffusivity (mm2/s)
pa.ka = 7e-4; % A-P association constant (1/nMs)
pa.kd = 6e-5; % A-P dissociation constant (1/s)
pa.ka2 = 7e-4; % A-R association constant (1/nMs)
pa.kd2 = 6e-5; % A-R dissociation constant (1/s)
pa.wtest = 1; % Test line width (mm)

% Flow rate is defined with respect to L and T, U = 1/2*L^2/(T*x) is the
% flow rate along a test strip with manufacturer-specified flow rate T
% sec/L mm (in this example, 180 sec/40 mm).
pa.L = 40; % Test strip length (mm)
pa.T = 180; % Time to flow through test strip (s)
pa.vc = (1/2*(pa.L)^2/pa.T);

% Time and space grid.
pa.dx = 0.1; % Step size in x (mm), reducing dx gives better model
pa.dt = 1; % Step size in t (s), does not affect model
pa.tend = 600; % Simulation time (s)
pa.t = 0:pa.dt:pa.tend; % Time grid
pa.t = pa.t';

% Changing parameters.
lp.Ao = 1e-7; % Initial analyte concentration (nM)
lp.Po = 1:10; % Initial detector concentration (nM)
lp.Ro = 1:10; % Initial receptor concentration (nM)
lp.dtest = 20:10:70; % Test line location (mm)

for k = 1:length(lp.Ao)
    pa.Ao = lp.Ao(k); % Get Ao
    for m = 1:length(lp.Po)
        pa.Po = lp.Po(m); % Get Po
        for n = 1:length(lp.Ro)
            pa.Ro = lp.Po(n); % Get Ro
            for o = 1:length(lp.dtest)
                pa.dtest = lp.dtest(o); % Get dtest
                
% To save time, only run to 1 mm  after test line.
pa.xend = pa.dtest + pa.wtest +1; % Test strip length (mm)
pa.x = 0:pa.dx:pa.xend; % Space grid
pa.v = pa.vc./(pa.x); % Flow rate (m/s)
pa.x = pa.x';
pa.index = find(pa.x == pa.dtest); % Get dtest on pa.x
% Get field name
fn = ['Ao',num2str(k),'Po',num2str(m),'Ro',num2str(n),'dtest',num2str(o)];
                out.(fn) = mol4(pa);
            end
        end
    end
end

end

function c = mol4(pa)
nx = length(pa.x); % Points in space grid

% Initial-boundary values.
icA = zeros(nx,1); % A(x,t=0) = 0
icA(1) = pa.Ao; % A(x=0,t) = Ao
icP = zeros(nx,1); % P(x,t=0) = 0
icP(1) = pa.Po; % P(x=0,t) = Po
icPA = zeros(nx,1); % PA(x,t=0) = 0
icRA = zeros(nx,1); % RA(x,t=0) = 0
icRPA = zeros(nx,1); % RPA(x,t=0) = 0
ic = [icA; icP; icPA; icRA; icRPA];

% Solve ODEs.
[t,y] = ode15s(@(t,y) tdiff(t,y,pa),pa.t,ic);
c.x = pa.x;
% Time grid corresponds to volume sample (mm * cross-sectional area).
c.samp = sqrt(2*pa.vc.*t) - pa.dtest;
% Save y into species concentrations.
c.species.A = y(:,1:nx);
c.species.P = y(:,nx+1:2*nx);
c.species.PA = y(:,2*nx+1:3*nx);
c.species.RA = y(:,3*nx+1:4*nx);
c.species.RPA = y(:,4*nx+1:5*nx);
end

function dy = tdiff(t,y,pa)
% The number of points in the space grid is the number of ODEs we have to
% solve for each variable.
nx = length(pa.x);

% Define ranges for A, P, PA, RA, RPA in vector y.
yA = y(1:nx);
yP = y(nx+1:2*nx);
yPA = y(2*nx+1:3*nx);
yRA = y(3*nx+1:4*nx);
yRPA = y(4*nx+1:5*nx);
dyA = zeros(nx,1);
dyP = zeros(nx,1);
dyPA = zeros(nx,1);

% Reaction equations.
fPA = pa.ka*yA.*yP - pa.kd*yPA; % A + P <-> PA.
% R(t=0) = Ro for x=dtest->dtest+wtest, and 0 everywhere else.
Ro = zeros(nx,1);
i = find(pa.x == pa.dtest);
while pa.x(i) <= (pa.dtest+pa.wtest)
    Ro(i) = pa.Ro;
    i = i+1;
end
% R = Ro - RA - RPA.
fRA = pa.ka2*yA.*(Ro-yRA-yRPA) - pa.kd2*yRA; % A + R <-> RA.
fRPA1 = pa.ka*yRA.*yP - pa.kd*yRPA; % RA + P <-> RPA (1).
fRPA2 = pa.ka2*(Ro-yRA-yRPA).*yPA - pa.kd2*yRPA; % R + PA <-> RPA (2).

% The diffusive term (second order partial x) is discretized with central
% finite difference scheme. The convective term (first order partial x) is
% discretized with first order upwind scheme.
% Define dAdt.
aA = pa.DA/pa.dx^2;
b = (pa.v/pa.dx)';
dyA(2:nx-1) = aA*(yA(3:nx)+yA(1:nx-2)-2*yA(2:nx-1))... % Diffusive term
    -b(2:nx-1).*(yA(2:nx-1)-yA(1:nx-2))...             % Convective term
    -fPA(2:nx-1)-fRA(2:nx-1);                          % Rate of formation
dyA(nx) = aA*(yA(nx-1)-yA(nx))... % Diffusive term
    -b(nx).*(yA(nx)-yA(nx-1))...  % Convective term
    -fPA(nx)-fRA(nx);             % Rate of formation

% Define dPdt.
aP = pa.DP/pa.dx^2;
dyP(2:nx-1) = aP*(yP(3:nx)+yP(1:nx-2)-2*yP(2:nx-1))...
    -b(2:nx-1).*(yP(2:nx-1)-yP(1:nx-2))-fPA(2:nx-1)-fRPA1(2:nx-1);
dyP(nx) = aP*(yP(nx-1)-yP(nx))-b(nx).*(yP(nx)-yP(nx-1))-fPA(nx)-fRPA1(nx);

% Define dPAdt.
dyPA(2:nx-1) = aP*(yPA(3:nx)+yPA(1:nx-2)-2*yPA(2:nx-1))...
    -b(2:nx-1).*(yPA(2:nx-1)-yPA(1:nx-2))+fPA(2:nx-1)-fRPA2(2:nx-1);
dyPA(nx) = aP*(yPA(nx-1)-yPA(nx))-b(nx).*(yPA(nx)-yPA(nx-1))...
    +fPA(nx)-fRPA2(nx);

% Define dRAdt, dRPAdt. No diffusive and convective terms because these
% species are immobilized.
dyRA(1:nx,1) = fRA-fRPA1;
dyRPA(1:nx,1) = fRPA1+fRPA2;

% Concatenate dA, dP, dPA, dRA, dRPA into vector dy.
dy = [dyA; dyP; dyPA; dyRA; dyRPA];
end