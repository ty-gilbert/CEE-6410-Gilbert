$ontext
CEE 6410 HW6 Integer Problem (Problem 7.4.1)

Maximize profit for an irrigation project by selecting
an optimal reservoir size (low or high dam) and or a river pump.
This is a Mixed Integer Program (MIP).


Ty Gilbert
A02298741@usu.edu
10/20/2025
$offtext

* 1. DEFINE the SETS
SETS
   t       seasons of the year /1, 2/
   res_opt reservoir options /high, low/;

* 2. DEFINE input data
PARAMETERS
   ResCap(res_opt)     Reservoir capacity (ac-ft)
                       /high 700,
                        low  300/
   ResCost(res_opt)    Reservoir capital cost ($ per year)
                       /high 10000,
                        low  6000/
   Q(t)                River inflow to reservoir (ac-ft per season)
                       /1 600,
                        2 200/
   IrrDemand(t)        Irrigation demand (ac-ft per acre)
                       /1 1.0,
                        2 3.0/
   PumpCapCost         Pump capital cost ($ per year) /8000/
   PumpOpCost          Pump operating cost ($ per ac-ft) /20/
   RevenuePerAcre      Revenue ($ per acre) /300/
   DaysPerSeason       Days per 6-month season /182.5/
   PumpDailyCap        Pump daily capacity (ac-ft per day) /2.2/
   GWInflowDaily       Groundwater inflow (ac-ft per day) /2.0/;

* Calculated Parameters
SCALAR
   PumpSeasonCap     Pump seasonal capacity (ac-ft)
   GWInflowSeason    Seasonal groundwater inflow (ac-ft);

PumpSeasonCap = PumpDailyCap * DaysPerSeason;
GWInflowSeason = GWInflowDaily * DaysPerSeason;

* 3. DEFINE the variables
VARIABLES
   I_res(res_opt)   Binary decision to build reservoir (1=yes 0=no)
   I_pump           Binary decision to build pump (1=yes 0=no)
   
   X_res(t)         Water diverted from reservoir (ac-ft per season)
   X_pump(t)        Water pumped from river (ac-ft per season)
   S(t)             Storage at end of season t (ac-ft)
   Release(t)       Release from reservoir in season t (ac-ft)
   Area             Area irrigated (acres)
   
   TPROFIT          Total annual profit ($);

BINARY VARIABLES I_res, I_pump;
POSITIVE VARIABLES X_res, X_pump, S, Release, Area;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT           Total Profit ($) and objective function
   MaxOneRes        Can build at most one reservoir (high or low)
   StorageBal(t)    Reservoir storage balance (continuity)
   MaxStorage(t)    Storage cannot exceed built capacity
   ResDiversion(t)  Reservoir diversion limited by available water
   MaxPump(t)       Pumping limited by pump capacity (if built)
   PumpSource(t)    Pumping limited by available river flow
   MeetDemand(t)    Supplied water must meet irrigation demand;

* Objective Function: Maximize (Revenue) - (Reservoir Cost) - (Pump Cost)
PROFIT..            TPROFIT =E= RevenuePerAcre*Area
                            - SUM(res_opt, ResCost(res_opt)*I_res(res_opt))
                            - PumpCapCost*I_pump
                            - PumpOpCost*SUM(t, X_pump(t));

* Constraint: Can only build one reservoir (or none)
MaxOneRes..         SUM(res_opt, I_res(res_opt)) =L= 1;

* Constraint: Storage balance. S(t-1) uses t.lag(1) for circular seasons
StorageBal(t)..     S(t) =E= S(t-1)$(ord(t) > 1) + Q(t) - X_res(t) - Release(t);

* Constraint: Storage is limited by the capacity of the *built* reservoir
* If no reservoir is built, SUM(res_opt,...) = 0, so S(t) =L= 0.
MaxStorage(t)..     S(t) =L= SUM(res_opt, ResCap(res_opt)*I_res(res_opt));

* Constraint: Cannot divert more water from reservoir than is available
ResDiversion(t)..   X_res(t) =L= S(t-1)$(ord(t) > 1) + Q(t);

* Constraint: Pumped volume is zero if pump isn't built (I_pump=0)
* and limited by seasonal capacity if it is built (I_pump=1)
MaxPump(t)..        X_pump(t) =L= PumpSeasonCap * I_pump;

* Constraint: Water available to pump = Release from reservoir + Groundwater
PumpSource(t)..     X_pump(t) =L= Release(t) + GWInflowSeason;

* Constraint: Total water supplied must meet the demand of the irrigated area
MeetDemand(t)..     X_res(t) + X_pump(t) =G= IrrDemand(t) * Area;


* 5. DEFINE the MODEL from the EQUATIONS
MODEL IrrigationMIP /ALL/;

* 6. Solve the Model as an MIP
SOLVE IrrigationMIP USING MIP MAXIMIZING TPROFIT;

* 7. Display the results
DISPLAY I_res.L, I_pump.L, Area.L, X_res.L, X_pump.L, S.L, Release.L, TPROFIT.L;

* Dump all input data and results to a GAMS gdx file
Execute_Unload "HW6-MIP.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls HW6-MIP.gdx"