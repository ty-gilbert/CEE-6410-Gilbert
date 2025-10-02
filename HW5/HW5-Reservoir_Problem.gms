$ontext
CEE 6410 - Water Resources Systems Analysis
Homework 5: Reservoir Operation Problem

THE PROBLEM:
A reservoir is designed to provide hydropower and water for irrigation.
- Hydropower turbines have a capacity of 4 units of water per month.
- At least one unit of water must be kept in the river each month at point A.
- The reservoir has a capacity of 9 units.
- Initial storage is 5 units.
- Ending storage must be equal to or greater than the beginning storage.

THE SOLUTION:
This GAMS model uses Linear Programming to determine the monthly reservoir
releases that maximize the total economic benefits from hydropower and irrigation
over a 6-month period.

Ty Gilbert
A02298741@usu.edu
October 01, 2025
$offtext

* 1. DEFINE the SETS
SETS
    spatial Locations and flow types /storage, turbine, spill, irrigation, flow_at_A/
    month   Time periods             /month1*month6/;

* 2. DEFINE input data
SCALARS
    TurbineCapacity     Max release through turbines      / 4 /
    MinFlowAtA          Minimum in-stream flow at point A / 1 /
    ReservoirCapacity   Max storage volume in reservoir   / 9 /
    InitialStorage      Storage at the beginning of month1/ 5 /;

PARAMETERS
    HB(month) Hydro Benefits per month /
        month1 1.6,
        month2 1.7,
        month3 1.8,
        month4 1.9,
        month5 2.0,
        month6 2.0 /

    IB(month) Irrigation benefits per month /
        month1 1.0,
        month2 1.2,
        month3 1.9,
        month4 2.0,
        month5 2.2,
        month6 2.2 /

    ResInflow(month) Reservoir inflow into system per month /
        month1 2,
        month2 2,
        month3 3,
        month4 4,
        month5 3,
        month6 2 /;

* 3. DEFINE the variables
VARIABLES
    X(spatial, month) Decision variables for flows and storage
    VPROFIT           Objective Function value ($);

* Non-negativity constraints
POSITIVE VARIABLE X;

* 4. COMBINE variables and data in equations
EQUATIONS
    PROFIT              Total profit and objective function
    TURBINECAP          Upper limit on turbine releases
    STORAGECAP          Upper limit on reservoir storage
    FLOWATADEF          Definition of flow at point A
    MIN_A_FLOW          Minimum flow constraint at point A
    IRRIGSOURCE         Irrigation water is a subset of total release
    RESMASSBAL          Reservoir Mass Balance in each month
    FINALSTORAGECON     Constraint on final storage level;

PROFIT..
    VPROFIT =E= SUM(month, HB(month)*X("turbine", month) + IB(month)*X("irrigation", month));

TURBINECAP(month)..
    X("turbine", month) =L= TurbineCapacity;

STORAGECAP(month)..
    X("storage", month) =L= ReservoirCapacity;
    
FLOWATADEF(month)..
    X("flow_at_A", month) =E= X("turbine", month) + X("spill", month) - X("irrigation", month);

MIN_A_FLOW(month)..
    X("flow_at_A", month) =G= MinFlowAtA;

IRRIGSOURCE(month)..
    X("irrigation", month) =L= X("turbine", month) + X("spill", month);

RESMASSBAL(month)..
    X("storage", month) =E= (X("storage", month-1)$(ord(month)>1) + InitialStorage$(ord(month)=1))
                           + ResInflow(month) - X("turbine", month) - X("spill", month);

FINALSTORAGECON..
    X("storage", "month6") =G= InitialStorage;

* 5. DEFINE the MODEL from the EQUATIONS
MODEL ReservoirModel Model for Reservoir Operation /ALL/;

* 6. SOLVE the MODEL
SOLVE ReservoirModel USING LP MAXIMIZING VPROFIT;

* 7. DISPLAY the results
DISPLAY X.L, VPROFIT.L;

