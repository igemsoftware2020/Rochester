% This script tests the parameter fitting algorithm for incorporating experimental data into Lateral Flow Assay model.

% Constant parameters
pa.DA = 1e-4; % Analyte diffusivity (mm2/s)
pa.DP = 1e-6; % Detector diffusivity (mm2/s)
pa.wtest = 1; % Test line width (mm)
pa.vc = 5.069; % Flow rate constant (mm2/s)
pa.Ao = 1e-7; % Initial analyte concentration (nM)
pa.Po = 6e0; % Initial detector concentration (nM)
pa.Ro = 10; % Initial receptor concentration (nM)
pa.dtest = 20; % Test line location (mm)

% Time and space grid.
pa.dx = 0.1; % Step size in x (mm), reducing dx gives better model
pa.dt = 5; % Step size in t (s), does not affect model
pa.tend = 1200; % Simulation time (s)
pa.t = 0:pa.dt:pa.tend; % Time grid
pa.t = pa.t';

% To save time, only run to 5 mm  after test line.
pa.xend = pa.dtest + 5; % Test strip length (mm)
pa.x = 0:pa.dx:pa.xend; % Space grid
pa.v = pa.vc./(pa.x); % Flow rate (mm/s)
pa.x = pa.x';
pa.index = find(pa.x == pa.dtest); % Get dtest on pa.x

% Starting values for kinetic constants
k0 = [7e-4, 6e-5, 7e-4, 6e-5]; 
% Simulated kinetic constants
rng('shuffle');
fakek = k0 + k0.*(rand(size(k0))-1/2);
% Experimental data collection time 1-15 min
tmeas = (1:15).*60;
pa.tind = ismember(pa.t,tmeas);
% Get model predictions
experi = mol4(pa,fakek);

% Call error function
fun = @(k) finderr(experi,k,pa);
% Parameter fit by minimizing experiment-model error
kc = zeros(6,4);
kc(1,:) = fminsearch(fun,k0);
for i = 1:5
    per = ['Error ' num2str(i*20) '%'];
    disp(per)
    e = experi.*(i*20/100); % Percent error
    noise = rand(size(experi))-1/2;
    experinoise = experi + e.*noise;
    funnoise = @(k) finderr(experinoise,k,pa);
    kc(i+1,:) = fminsearch(funnoise,k0);
end
save('kin.mat','kc','fakek');

function err = finderr(experi,k,pa)
% This error function finds the error between experimental data and model
% predictions.
% Get signal
signal = mol4(pa,k);
% Find error at each signal
singleErr = abs(signal - experi)./signal;
% Sum of error
err = sum(singleErr);
end

function c = mol4(pa,k)
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
[t,y] = ode15s(@(t,y) tdiff(t,y,pa,k),pa.t,ic);
% Save [RPA] at beginning of test line.
RPA = y(:,4*nx+1:5*nx);
sig = RPA(:,pa.index);
c = sig(pa.tind);
end

function dy = tdiff(t,y,pa,k)
% The number of points in the space grid is the number of ODEs we have to
% solve for each variable.
nx = length(pa.x);

% Fitting parameters
pa.ka = k(1); % A-P association constant (1/nMs)
pa.kd = k(2); % A-P dissociation constant (1/s)
pa.ka2 = k(3); % A-R association constant (1/nMs)
pa.kd2 = k(4); % A-R dissociation constant (1/s)

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
