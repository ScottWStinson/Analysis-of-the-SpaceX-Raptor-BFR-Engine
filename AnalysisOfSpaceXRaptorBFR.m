%Analysis of the SpaceX Raptor BFR Engine
clc,clear,close all;
warnStruct = warning('off');

tic
%given data
mfr=549; % mass flow rate kg/s
throatDia=0.2216; % diameter of throat m
exitDia=1.3; % diameter of exit section m
%Liquid CH4 temp
CH4rTemp=-112.46+273.15; %kelvin
%Liquid Oxygen Temp
O2rTemp=-155+273.15; % kelvin

%Balanced stoich equation, phi=1
%Reactants
nCH4r=0.9;
nO2r=1.8;
nCO2r=0.1;
nH2Or=0.2;
InitialO2=2.0;

%Products
nH2Op=2;
nCO2p=1.0;
nO2p=0;
nCH4p=0;

fprintf('The balanced stoichiometric equation is:\n %0.1f CH4 + %0.1f O2 + %0.1f CO2 + %0.1f H2O => %0.1f H2O + %0.1f CO2 \n',nCH4r,nO2r,nCO2r,nH2Or,nH2Op,nCO2p);
%Initialize phi, the equivalence ratio

phi=-1;
while phi <= 0 || phi >= 9
    phi = input('Enter an equivalence ratio value: ');
    if phi < 1 && phi > 0
        fprintf('\nA value less than 1 means that the mixture has extra oxidizer.\n\n');
        
        %Use phi to find additional O2 in equation:
        n1O2r = (1/phi).*InitialO2-0.2;
        n1O2p = n1O2r - nO2r;
        
        %reactant side
        lhC = nCH4r+nCO2r;
        lhH = (nCH4r*4)+(nH2Or*2);
        lhO = (n1O2r*2)+(nCO2r*2)+nH2Or;
        
        %product side
        rhC = nCO2p;
        rhH = nH2Op*2;
        rhO = (nH2Op)+(nCO2p*2)+(n1O2p*2);
        
        %Renaming variables for enthalpy
        n1CH4r = nCH4r;
        n1CO2r = nCO2r;
        n1H2Or = nH2Or;
        n1CO2p = nCO2p;
        n1H2Op = nH2Op;
        n1CH4p = 0;
            
    elseif phi > 1 && phi < 9
        fprintf('\nA value greater than 1 means that the mixture has extra unburnt fuel.\n\n');
        
        %Use phi to find additional CH4 in equation:
        n1O2r = (1/phi).*InitialO2-0.2;
        n1CH4p = nCH4r-(n1O2r/2);
        
        %reactant side
        lhC = nCH4r + nCO2r;
        lhH = (nCH4r*4)+(nH2Or*2);
        lhO = (n1O2r*2)+(nCO2r*2)+nH2Or;
        
        %Use leftover CH4 to find new products
        n1CO2p = lhC - n1CH4p;
        n1H2Op = (lhH-(n1CH4p*4))/2;
        
        %product balancing:
        rhC = n1CO2p+n1CH4p;
        rhH = (n1H2Op*2)+(n1CH4p*4);
        rhO = n1H2Op+(n1CO2p*2);
        
        n1CH4r = nCH4r;
        n1CO2r = nCO2r;
        n1H2Or = nH2Or;
        n1O2p = 0;
    
    elseif phi == 1
        fprintf('\nA value of 1 means that the mixture is stoichiometric.\n\n');
        
        %reactant side balancing:
        lhC = nCH4r+nCO2r;
        lhH = (nCH4r*4)+(nH2Or*2);
        lhO = (nO2r*2)+(nCO2r*2)+nH2Or;
        
        %product side balancing:
        rhC = nCO2p;
        rhH = nH2Op*2;
        rhO = (nH2Op)+(nCO2p*2);
        
        n1CH4r = nCH4r;
        n1O2r = nO2r;
        n1CO2r = nCO2r;
        n1H2Or = nH2Or;
        
        n1CO2p = nCO2p;
        n1H2Op = nH2Op;
        n1O2p = 0;
        n1CH4p = 0;
    else
        
        %Equivalence Ratio cannot be less than 0 or greater than 9:
        fprintf('\nPlease enter a value greater than 0 and less than 9.\n\n');
    end
    
end

%Output of the chemical reaction:
fprintf('The balanced chemical reaction in the main combustor is:\n');
if phi<1
fprintf('%0.2f CH4 + %0.2f O2 + %0.2f CO2 + %0.2f H2O -> %0.2f CO2 + %0.2f H2O + %0.2f O2\n\n',n1CH4r,n1O2r,n1CO2r,n1H2Or,n1CO2p,n1H2Op, n1O2p);
end
if phi > 1
fprintf('%0.2f CH4 + %0.2f O2 + %0.2f CO2 + %0.2f H2O -> %0.2f CO2 + %0.2f H2O + %0.2f CH4\n\n',n1CH4r,n1O2r,n1CO2r,n1H2Or,n1CO2p,n1H2Op, n1CH4p);
end
if phi==1
    fprintf('%0.1f CH4 + %0.1f O2 + %0.1f CO2 + %0.1f H2O => %0.1f H2O + %0.1f CO2 \n',n1CH4r,n1O2r,n1CO2r,n1H2Or,n1H2Op,n1CO2p);
end
%Checking for error:
error = (lhH-rhH)+(lhC-rhC)+(lhO-rhO);
%Products of Auxilary Combustion Unit are the reactants for the main
%combustor
% Data is taken from 'Fundamentals of Thermodynamics' by Borgnakke and
% Sonntag
% and from nist web books
% CO2 & H2O are ideal gases, use Table A.9 for delta-h-bar and Table A.10
% for enthalpy of formation

% enthalpy of formation: table A.10
%For reactants at 811K
hf0H2Or=-241826; %KJ/kmol
hf0CO2r=-393522; %KJ/kmol
%For reactants at lower temps
hf0O2r=0; %KJ/kmol at -155 C
hf0CH4r=-74873; %KJ/kmol at -112.46 C
%delta h
delhbCO2r=(811-800)*(28030-22806)/(900-800)+22806; %Table A.9 liner interpolation
delhbH2Or=(811-800)*(21937-18002)/(900-800)+18002; %Table A.9 liner interpolation
%h(T,P)
delhtpCH4r=3249.6; %KJ/kmol nist webbook
delhtpO2r=-2374.1; %KJ/kmol nist web book
%hstp
delhstpO2r=8667.7; %KJ/kmol nist webbook
delhstpCH4r=14593; %KJ/kmol nist webbook
% h(T,P)-h(stp)
delhbO2r=delhtpO2r-delhstpO2r;
delhbCH4r=delhtpCH4r-delhstpCH4r;

% hf+dh
hfdhCO2r=hf0CO2r+delhbCO2r;
hfdhH2Or=hf0H2Or+delhbH2Or;
hfdhCH4r=hf0CH4r+delhbCH4r;
hfdhO2r=hf0O2r+delhbO2r;
% solving for enthalpy of reactants
HR=(n1CH4r*hfdhCH4r)+(n1O2r*hfdhO2r)+(n1H2Or*hfdhH2Or)+(n1CO2r*hfdhCO2r);

%Products
hf0H2Op=hf0H2Or;
hf0O2p=hf0O2r;
hf0CO2p=hf0CO2r;
hf0CH4p=hf0CH4r;

%trendlines from table A.9 data
%H2O data
xh2o=xlsread('productData.xlsx',1,'A2:A17');
yh2o=xlsread('productData.xlsx',1,'B2:B17');
[ah2o,funh2o] = trendline(xh2o',yh2o');
title('Trendline for H2O')
xlabel('Temperature (Kelvin)')
ylabel('Enthalpy KJ/kmol')
%CO2 data
xco2=xlsread('productData.xlsx',1,'D2:D17');
yco2=xlsread('productData.xlsx',1,'E2:E17');
[aco2,funco2] = trendline(xco2',yco2');
title('Trendline for CO2')
xlabel('Temperature (Kelvin)')
ylabel('Enthalpy KJ/kmol')
%O2 data
xo2=xlsread('productData.xlsx',1,'G2:G17');
yo2=xlsread('productData.xlsx',1,'H2:H17');
[ao2,funo2] = trendline(xo2',yo2');
title('Trendline for O2')
xlabel('Temperature (Kelvin)')
ylabel('Enthalpy KJ/kmol')
%Using nist webbook data for liquid methane
%CH4 data
xch4=xlsread('productData.xlsx',1,'J2:J17');
ych4=xlsread('productData.xlsx',1,'K2:K17');
[ach4,funch4] = trendline(xch4',ych4');
title('Trendline for CH4')
xlabel('Temperature (Kelvin)')
ylabel('Enthalpy KJ/kmol')

delh2op=@(temp) ah2o(1)+ah2o(2)*temp+ah2o(3)*temp^2;
delo2p=@(temp)  ao2(1)+ao2(2)*temp+ao2(3)*temp^2;
delco2p=@(temp) aco2(1)+aco2(2)*temp+aco2(3)*temp^2;
delch4p=@(temp) ach4(1)+ach4(2)*temp+ach4(3)*temp^2;
HPminusHR=@(temp) n1H2Op*(hf0H2Op+delh2op(temp))+n1O2p*(hf0O2p+delo2p(temp))+n1CO2p*(hf0CO2p+delco2p(temp))+n1CH4p*(hf0CH4p+delch4p(temp))-HR;
%Using fzero instead of the iterative method
AFT=fzero(HPminusHR,0);

deltaH2O=delh2op(AFT);
deltaO2=delo2p(AFT);
deltaCO2=delco2p(AFT);
deltaCH4=delch4p(AFT);
%Output of Adiabatic Flame Temp
fprintf('\nThe Adiabatic Flame Temperature is: %0.3f K\n\n',AFT)
%Output of enthalpy of formations
fprintf('hf for H2O in the reactants is : %0.2f KJ/kmol \n',hf0H2Or)
fprintf('hf for O2 in the reactants is : %0.2f KJ/kmol \n',hf0O2r)
fprintf('hf for CO2 in the reactants is : %0.2f KJ/kmol \n',hf0CO2r)
fprintf('hf for CH4 in the reactants is : %0.2f KJ/kmol \n',hf0CH4r)
%Output of delta h's
fprintf('Delta h for H2O in the reactants is: %0.2f KJ/kmol \n',delhbH2Or)
fprintf('Delta h for CO2 in the reactants is: %0.2f KJ/kmol \n',delhbCO2r)
fprintf('Delta h for CH4 in the reactants is: %0.2f KJ/kmol \n',delhbCH4r)
fprintf('Delta h for O2 in the reactants is: %0.2f KJ/kmol \n\n',delhbO2r)
%Product Outputs
fprintf('\nhf for H2O in the products is : %0.2f KJ/kmol \n',hf0H2Op)
fprintf('hf for O2 in the products is : %0.2f KJ/kmol \n',hf0O2p)
fprintf('hf for CO2 in the products is : %0.2f KJ/kmol \n',hf0CO2p)
fprintf('hf for CH4 in the products is : %0.2f KJ/kmol \n',hf0CH4p)
%Output of delta h's
fprintf('Delta h for H2O in the products is: %0.2f KJ/kmol \n',deltaH2O)
fprintf('Delta h for CO2 in the products is: %0.2f KJ/kmol \n',deltaCO2)
fprintf('Delta h for CH4 in the products is: %0.2f KJ/kmol \n',deltaCH4)
fprintf('Delta h for O2 in the products is: %0.2f KJ/kmol \n',deltaO2)

%Part 2

%Find M-mix, R-mix, and k-mix of products entering the nozzle
%M-mix = sum(yi*Mi)
%yi=ni/ntotal
ntotp=(n1CH4p+n1CO2p+n1O2p+n1H2Op);
ntotr=(n1CH4r+n1CO2r+n1O2r+n1H2Or);

yO2=n1O2p/ntotp;
yCO2=n1CO2p/ntotp;
yCH4=n1CH4p/ntotp;
yH2O=n1H2Op/ntotp;
% Molecular mass from table A.2 in Textbook
MO2=31.999;
MH2O=18.015;
MCH4=16.043;
MCO2=44.01;

Mmix=(yO2*MO2)+(yCO2*MCO2)+(yCH4*MCH4)+(yH2O*MH2O);
fprintf('\nMmix of the products going into the nozzle is: %0.4f kg/kmol\n',Mmix);

%R-mix = sum(CiRi) or Rbar/Mmix where Rbar is the universal gas constant.
Rbar=8.314; % KJ/kmol*K
Rmix=Rbar/Mmix;
fprintf('\nRmix of the products going into the nozzle is: %0.4f KJ/kmol*K\n',Rmix);

%Find k-mix
%k-mix= Cp/Cv, where Cp and Cv are specific heats

massO2=n1O2p*MO2;
massCO2=n1CO2p*MCO2;
massH2O=n1H2Op*MH2O;
massCH4=n1CH4p*MCH4;
mtot=ntotp*Mmix;

cO2=massO2/mtot;
cCO2=massCO2/mtot;
cH2O=massH2O/mtot;
cCH4=massCH4/mtot;

CpO2=0.922;
CpCO2=0.842;
CpH2O=1.872;
CpCH4=2.254;

CvO2=0.662;
CvCO2=0.653;
CvH2O=1.410;
CvCH4=1.736;

Cvmix=(cO2*CvO2)+(cCO2*CvCO2)+(cH2O*CvH2O)+(cCH4*CvCH4);
Cpmix=(cO2*CpO2)+(cCO2*CpCO2)+(cH2O*CpH2O)+(cCH4*CpCH4);

Kmix=Cpmix/Cvmix;
fprintf('Kmix of the products going into the nozzle is: %0.4f KJ/kmol*K\n',Kmix);

mDotFuel=mfr/((n1O2r*MO2)/(n1CH4r*MCH4)+1);
mDotOxi=mfr-mDotFuel;

fprintf('\nThe mass flow rate of the fuel is: %0.3f kg/s \n',mDotFuel);
fprintf('The mass flow rate of the oxidizer is: %0.3f kg/s \n',mDotOxi);

T0=AFT;
Astar=pi*throatDia^2/4;
A=pi*exitDia^2/4;
AoverAstar=A/Astar;

P0=(mfr/Astar)*sqrt(T0)*sqrt(Rmix*1000/Kmix)*(((Kmix+1)/2)^((Kmix+1)/(2*(Kmix-1))))/1000;
fprintf('\nP0 is %0.3f Mpa\n',P0/1000)

Mach=@(M) (1/M)*((2/(Kmix+1))*(1+((Kmix-1)/2)*M^2))^((Kmix+1)/(2*(Kmix-1)))-AoverAstar;

Me=fzero(Mach,[0.5 100]);
fprintf('\nThe Mach number at the nozzle exit is: %0.3f \n',Me);

Te=T0/(1+(Kmix-1)/2*Me^2);
ce=sqrt(Kmix*Rmix*1000*Te);
fprintf('\nThe speed of sound ideal gas Ce: %0.3f m/s\n',ce);
Ve=Me*ce;
fprintf('\nThe velocity of the gas exiting the nozzle is: %0.3f m/s\n',Ve);

Pe=P0/((1+(Kmix-1)/2*Me^2)^(Kmix/(Kmix-1)));
fprintf('\nThe Pressure of the gas exiting the nozzle is: %0.3f Kpa\n',Pe);

Thrust=(mfr*(Ve)+(Pe-100)*1000*A)/1000;
fprintf('\nThe Thrust produced at sea level is %0.3f KN\n\n',Thrust)

equi=[0.6 0.8 1 1.1 1.2];

y=1;
while y<=5
[AFT1,P01,Ve1,Me1,Thrust1] = phiparameters(equi(y));
AFT2(y)=AFT1;
P02(y)=P01;
Ve2(y)=Ve1;
Me2(y)=Me1;
Thrust2(y)=Thrust1;
y=y+1;
end

figure(5)
plot(equi,AFT2,'r-.o');grid on
xlabel('Equivalence Ratio (phi)');
ylabel('Adiabatic Flame Temperature (Kelvin)');
title('Adiabatic Flame Temperature vs Equivalence Ratio');
figure(6)
plot(equi,P02,'k+:');grid on
xlabel('Equivalence Ratio (phi)');
ylabel('Chamber Pressure (Kpa)');
title('Chamber Pressure vs Equivalence Ratio');
figure(7)
plot(equi,Ve2,'o--'); grid on
xlabel('Equivalence Ratio (phi)');
ylabel('Exit Velocity (m/s)');
title('Exit Velocity vs Equivalence Ratio');
figure(8)
plot(equi,Me2,'mx--'); grid on
xlabel('Equivalence Ratio (phi)');
ylabel('Mach Number');
title('Exit Mach Number vs Equivalence Ratio');
figure(9)
plot(equi,Thrust2,'b*-.'); grid on
xlabel('Equivalence Ratio (phi)');
ylabel('Thrust (kN)');
title('Thrust vs Equivalence Ratio');
toc
