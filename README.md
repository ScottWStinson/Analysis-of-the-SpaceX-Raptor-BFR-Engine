# Analysis-of-the-SpaceX-Raptor-BFR-Engine
The SpaceX Raptor BFR is a full-flow, staged-combustion, methane-fueled rocket engine. 
The propellant used in this engine is cryogenic liquid oxygen and liquid methane. 
SpaceX is using this engine for the development of Starship, which is a fully reusable system designed to transport 
crew and cargo to Earth orbit, the Moon, or potentially Mars. Orbital flight has not been implemented yet but is targeted to happen in 2020.

In this analysis of the SpaceX Raptor BFR, we made some simplifying assumptions such that, combustion reaction specimens (except for liquid methane 
an liquid oxygen) are ideal gases, and the nozzle flow is isentropic. I used the ‘Fundamentals of Thermodynamics’, 8th edition textbook by Borgnakke 
and Sonntag as well as the NIST WebBook for data on the properties for the products and reactants in the combustion reaction. We specified that the 
reaction Pressure was 25 MPa, even though the enthalpy of a liquid is somewhat independent of the pressure. This pressure is later calculated in the 
Analysis.

To run this code, run the "AnalysisOfSpaceXBFR.m" file after having all files added to your directory then choose an equivalence ratio
for combustion, real world ratios around usually around 1.1-1.2. you will then get an output with a balanced chemical reaction equation and
the adiabatic flame temperature. You will also get an output of different enthalpy's that are spelled out.

Additional output is mass flow rate of oxidizer and fuel, chamber pressure (denoted as PO), Mach number, exit velocity of gas from the nozzle,
pressure of gas exiting the nozzle, and thrust produced at sea level.

The last output is the multiple types of graphs use in the analysis below to help identify trends.

ANALYSIS:
Looking at the graphs of adiabatic flame temperature, chamber pressure, exit velocity, and thrust vs equivalence ratio, we can see they all have the same general shape, where the lowest point is at 𝜙 = 0.6, rising until the maximum at 𝜙 = 1.0, then decreasing as
𝜙 approaches 1.2. The Mach number decreases as the equivalence ratio increases. According to SpaceX, this engine runs with an equivalence ratio of 1.1. At 𝜙 = 1.1, the adiabatic flame temperature is 4394.9 K, the exit velocity is 3018.3 m/s, the chamber pressure is 25.037 Mpa, the Mach number is 4.8032, and the thrust is 1579 kN. The published data of the thrust and chamber pressure is around 172 mT or 1686.74 kN and 257 bar or 25.7 Mpa respectively. These published values appear to be closer to my calculated values at 𝜙 = 1.0, where the thrust is 1614.6 kN and the chamber pressure is 25.563 Mpa.
