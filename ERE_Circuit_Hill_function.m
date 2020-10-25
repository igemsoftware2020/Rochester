function hill_function
% Parameters
k1 = 20.1; %the transcriptional rate in proteins/min
rt = 5; %run time of the experiment, in hours 
cn = 100; %copy number of the plasmid used
kd1 = 0.9; %kd of ER-ERE binding in nM
kd2 = 0.5; %kd of ER-E2 binding in nM
ER = 0.5; %ER concentration in nM
n = 1; %hill coefficient
e2r = 5; %max range for E2 concentration in nM

function gfp = hill(E2)
amax = (k1 * cn * rt * 60);
%calculation for the amax based on conditions
kdt7 = (kd1 * kd2) / ER^n;
gfp = amax * ( E2^n / (kdt7 + E2^n));
gfp = gfp/3;

end

fplot(@hill, [0,e2r])
grid on
title('Reporter Production as a function of E2 Concentration (efficiency=0.33,cn=100)')
xlabel('E2 Concentration in nm');
ylabel('Number of GFP Molecules per cell (10^4)');
end

