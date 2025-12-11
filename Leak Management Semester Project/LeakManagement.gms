$Title Optimizing Leak Management Strategies for Logan Water Networks
$Ontext
Project: Optimizing Leak Management Strategies for Water Networks
Author: Ty Gilbert
Course: CEE 6410
Date: December 11, 2025
Location: Logan, Utah (Dewitt Springs Subsystem)

Description:
This MILP model minimizes the total cost of inspection, repair, and water loss
for the high-elevation subsystem.

Updates based on 2025/2016 Data Sources:
1. Water Price ($0.82/m3) derived from "Research on Water Price and Quantity" 
   (suggested basic price ~5.78 Yuan).
2. Repair Costs ($10k avg) and Break Rates derived from USU Water Main Break Study.
   - Cast Iron break rate: ~28.6/100mi/yr (High Risk)
   - PVC break rate: ~2.9/100mi/yr (Low Risk)
3. Logan System Data derived from 2016 Master Plan (Table 3-3, Table 7-2).
   - Dewitt Springs Capacity: 10,000 gpm
   - Zone Demands converted from gpm to m3/quarter.
$Offtext

* -----------------------------------------------------------------------------
* 1. SETS AND DEFINITIONS
* -----------------------------------------------------------------------------

Sets
    i   Pipe segments / 
        Trans_Dewitt_01   "Aging Cast Iron Transmission Main (High Break Rate)"
        Trans_Dewitt_02   "Aging Cast Iron Transmission Main"
        Dist_CastleH_01   "Residential PVC (Low Break Rate)"
        Dist_CastleH_02   "Residential PVC"
        Dist_CastleH_03   "Residential PVC"
        Dist_Upper_01     "Residential Mixed (Medium Break Rate)"
        Dist_Upper_02     "Residential Mixed"
    /
    
    t   Time periods (Quarters) / Q1*Q4 /
    
    z   Pressure Zones / CastleHills, Upper, USU /;

Alias(t, tt);

* -----------------------------------------------------------------------------
* 2. PARAMETERS (DATA INPUT)
* -----------------------------------------------------------------------------

Scalars
* Source: Research on Water Price and Quantity (2024), Table 6.
* Converted 5.78 Yuan/m3 to approx $0.82/m3.
    C_water      Value of treated water lost ($ per m3)         / 0.82 /

* Source: Logan Master Plan 2016, Table 3-1.
* Dewitt Springs Capacity = 10,000 gpm.
* ADDED: Crockett Well (5,500 gpm) and 7th North Well (4,000 gpm) to meet summer peaks.
* Total Capacity ~ 19,500 gpm
* 19,500 gpm * 1440 min/day * 90 days * 0.003785 m3/gal = ~9,500,000 m3/qtr
* Previous value (4.9M) was insufficient for Q2/Q3 demand of 5.35M.
    Total_Supply Available water supply per quarter (m3)        / 9500000 /;

Parameters
    L_rate(i)    Baseline leak volume per quarter if pipe i fails (m3)
    C_inspect(i) Cost to inspect pipe segment ($)
    C_repair(i)  Cost to repair pipe segment ($);

* -----------------------------------------------------------------------------
* DATA CALIBRATION
* Source: Water Main Break Rates in the USA and Canada (2023)
* - Repair Cost Avg: ~$10,000
* - Cast Iron Break Rate: 28.6 (High frequency -> modeled as likely large leak)
* - PVC Break Rate: 2.9 (Low frequency)
* -----------------------------------------------------------------------------

* -- Transmission Mains (Aging Cast Iron) --
* Modeled as high consequence (large volume loss) and high repair cost.
* Leak Volume: Assume 100 gpm leak = ~49,000 m3/quarter
L_rate('Trans_Dewitt_01') = 49000;
L_rate('Trans_Dewitt_02') = 49000;
* Inspection cost (Acoustic methods for large diameter)
C_inspect('Trans_Dewitt_01') = 1500;
C_inspect('Trans_Dewitt_02') = 1500;
* Repair Cost (Large diameter, deep bury)
C_repair('Trans_Dewitt_01')  = 25000;
C_repair('Trans_Dewitt_02')  = 25000;

* -- Distribution Lines (Residential PVC/Mixed) --
* Modeled as lower consequence (smaller volume) and lower repair cost.
* Leak Volume: Assume 10 gpm leak = ~4,900 m3/quarter
L_rate('Dist_CastleH_01') = 4900;
L_rate('Dist_CastleH_02') = 4900;
L_rate('Dist_CastleH_03') = 4900;
L_rate('Dist_Upper_01')   = 4900;
L_rate('Dist_Upper_02')   = 4900;

C_inspect('Dist_CastleH_01') = 300;
C_inspect('Dist_CastleH_02') = 300;
C_inspect('Dist_CastleH_03') = 300;
C_inspect('Dist_Upper_01')   = 300;
C_inspect('Dist_Upper_02')   = 300;

* Avg Repair cost from Break Rate Study is ~$10k. 
* Distribution repairs are cheaper than Transmission.
C_repair('Dist_CastleH_01') = 8000;
C_repair('Dist_CastleH_02') = 8000;
C_repair('Dist_CastleH_03') = 8000;
C_repair('Dist_Upper_01')   = 8000;
C_repair('Dist_Upper_02')   = 8000;

Parameter Budget(t) Maintenance budget available in period t ($);
* Source: Logan Master Plan Table 7-2 suggests ~$900k annual replacement budget.
* Since this model focuses on the Dewitt Springs/High Elevation subsystem only,
* we assume this subsystem receives ~13-15% of the total city budget.
* Total Annual Allocation: ~$120,000
* Quarterly breakdown reflects seasonal constraints (winter vs summer work).
Budget('Q1') = 15000;
Budget('Q2') = 45000;
Budget('Q3') = 45000;
Budget('Q4') = 15000;

* Source: Logan Master Plan Table 3-3 (Existing Source Requirements)
* Castle Hills Demand: 918 gpm  -> ~450,000 m3/qtr
* Upper Demand: 5,091 gpm       -> ~2,500,000 m3/qtr
* USU Demand: 3,019 gpm         -> ~1,500,000 m3/qtr
* Note: Q2/Q3 are higher due to irrigation (Summer).
Table ZoneDemand(z,t) Mandatory water demand for zone z in period t (m3)
                 Q1        Q2        Q3        Q4
    CastleHills  300000    550000    550000    300000
    Upper        1800000   3000000   3000000   1800000
    USU          1000000   1800000   1800000   1000000;

Parameter TotalDemand(t);
TotalDemand(t) = sum(z, ZoneDemand(z,t));

* -----------------------------------------------------------------------------
* 3. VARIABLES
* -----------------------------------------------------------------------------

Variables
    Z_obj        Total Cost (Objective Function Value)
    W_lost(i,t)  Volume of water lost from pipe i in time t (m3);

Binary Variables
    X(i,t)       1 if pipe i is inspected in time t
    Y(i,t)       1 if pipe i is repaired in time t;

positive variable W_lost;

* -----------------------------------------------------------------------------
* 4. EQUATIONS (CONSTRAINTS)
* -----------------------------------------------------------------------------

Equations
    ObjFunction          Minimize total cost
    BudgetConst(t)       Total spending cannot exceed quarterly budget
    InspectReq(i,t)      Cannot repair unless inspected
    DeliveryConst(t)     Ensure supply meets demand after losses
    LeakContinuity(i,t)  Calculate water loss based on repair history
    SingleRepair(i)      Logical constraint: a pipe is repaired max once per year;

* -- 1. Objective Function --
* Min Z = Inspection Cost + Repair Cost + Water Loss Cost
ObjFunction.. 
    Z_obj =e= sum((t,i), 
                (C_inspect(i) * X(i,t)) + 
                (C_repair(i)  * Y(i,t)) + 
                (C_water      * W_lost(i,t))
              );

* -- 2. Budget Constraint --
BudgetConst(t)..
    sum(i, C_inspect(i)*X(i,t) + C_repair(i)*Y(i,t)) =l= Budget(t);

* -- 3. Inspection Pre-requisite --
* Y cannot be 1 unless X is 1
InspectReq(i,t)..
    Y(i,t) =l= X(i,t);

* -- 4. Volumetric Delivery --
* Supply minus total leakage must be greater than or equal to Demand
DeliveryConst(t)..
    Total_Supply - sum(i, W_lost(i,t)) =g= TotalDemand(t);

* -- 5. Leak State Continuity (Memory) --
* Water loss happens if no repair has occurred up to (and including) time t.
* The term "1 - sum(...)" becomes 0 once a repair happens, stopping the leak.
LeakContinuity(i,t)..
    W_lost(i,t) =e= L_rate(i) * (1 - sum(tt$(ord(tt) <= ord(t)), Y(i,tt)));

* -- 6. Logical Constraint --
* Assume for this horizon that a pipe only needs to be fixed once.
SingleRepair(i)..
    sum(t, Y(i,t)) =l= 1;

* -----------------------------------------------------------------------------
* 5. MODEL AND SOLVE
* -----------------------------------------------------------------------------

Model LoganLeakModel /all/;

* Use MIP (Mixed Integer Programming) because of Binary Variables X and Y
Solve LoganLeakModel using mip minimizing Z_obj;

* -----------------------------------------------------------------------------
* 6. OUTPUT AND ANALYSIS
* -----------------------------------------------------------------------------

Display Z_obj.l;
Display X.l, Y.l;
Display W_lost.l;

* Calculate portion of cost due to Water Loss vs Maintenance
Parameter CostBreakdown(*);
CostBreakdown('Inspection') = sum((t,i), C_inspect(i) * X.l(i,t));
CostBreakdown('Repair')     = sum((t,i), C_repair(i)  * Y.l(i,t));
CostBreakdown('WaterLoss')  = sum((t,i), C_water      * W_lost.l(i,t));

Display CostBreakdown;