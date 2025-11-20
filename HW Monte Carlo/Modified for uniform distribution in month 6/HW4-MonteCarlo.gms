$ontext
CEE 6410 Fall 2020
Modification of HW #4 Reservoir Optimization Problem to Use Monte Carlo Methods

How do uncertain initial reservoir storage and inflows affect total net benefits?

Assume:
  - Initial storage varies uniformly between 0.5 and 10 units
  - Inflow in month 1 varies according to observations (Table 1)
  - Inflows in subsequent months exhibit lag-1 correlation (Table 2)
  - Instream flow at A must be at least 1 unit or 20% of largest simulated flow

Use 250 samples

Table 1. Flow likelihood in Month 1
Flow     Prob. (%)  Cum. (%)
1        0.1        0.1
3        0.3        0.4
5        0.4        0.8
8        0.2        1.0

Table 2. Transitional probabilities of flow from time t to time t+1
                   Flow in Time t+1
                   1        3           5         8
Flow    1        0.2        0.5        0.2        0.1
in      3        0.2        0.3        0.3        0.2
Time    5        0.1        0.4        0.4        0.1
 t      8        0.2        0.3        0.4        0.1

Show the probability distribution of total net benefits

THE ORIGINAL PROBLEM: A reservoir is designed to provide hydropower and water for irrigation.
The turbine has a capacity of 4 units of water per month,
water downstream must be at least on unit, irrigation will use all water
that is available from the turbine and spillover.
The reservoir must be kept at a capacity under 9 units and the end storage is
greater than or equal to 5 units.

PART I sets ups the original deterministic linear programming problem with the
       base case parameter values
PART II generates the Monte Carlo samples and solves the model 250 times for each set of
     sampled values

Programmed by David E. Rosenberg
October 26, 2015
Updated October 23, 2018
david.rosenberg@usu.edu
$offtext

*****************************************
** PART I. Original Deterministic Linear Programmign Problem
********************************

*1. Define the sets
SETS t month /m1*m6/
     l network locations
         /res "Reservoir", hyd "Hydropower", "irr" Irrigation", spi "Spill", AAA "At_A"/;

*2. Define th input data
PARAMETERS
   inflow(t) reservoir inflow (volume)
        /m1 2, m2 2, m3 3, m4 4, m5 3, m6 2/
   hb(t) hydropower benefits ($ per volume)
        /m1 1.6, m2 1.7, m3 1.8, m4 1.9, m5 2.0, m6 2.0/
   ib(t) Irrigation benefits ($ per volume)
        /m1 1.0, m2 1.2, m3 1.9, m4 2.0, m5 2.2, m6 2.2/
          ;

SCALARS
   MaxStor Maximum reservoir storage (volume) /9/
   InitStor Initital reservoir storage (volume) /5/
   FlowReq  Minimum required flow at A (volume) /1/
   TurbCap  Turbine capacity (volume) /4/;


*3. Define the decision variables
VARIABLES
   X(l,t)  Flow or storage in network at location l at time t (volume)
   TotalBen   Total benefits ($);

Positive Variables X;

*4. Define the equations
EQUATIONS
   WatBENEFIT Total water use benefits from allocation ($ ) and objective function
   ResBalance(t) Reservoir mass balance in time t (volume)
   ResCapacity(t) Upper limit on reservoir storage (volume)
   EndStorage Ending reservoir storage (volume)
   HydropowerCap(t) Hydropower capacity for each month (volume)
   RiverBalance(t)  Flow balance in river at irrigation diversion (volume)
   MinFlowA(t)      Minimum required flow at a (volume) ;

*Equations for LP formulation
WatBENEFIT..        TotalBen =E= SUM(t, hb(t)*X("hyd",t) + ib(t)*X("irr",t));
ResBalance(t)..     X("res",t) =E= inflow(t) - X("hyd",t) - X("spi",t) +
                               InitStor$(ord(t) eq 1) +
                               X("res",t-1)$(ord(t) gt 1);
ResCapacity(t) ..   X("res",t) =L= MaxStor;
EndStorage..        sum(t$(ord(t) eq card(t)),X("res",t)) =G= InitStor;
HydropowerCap(t)..  X("hyd",t) =L=  TurbCap;
RiverBalance(t)..   X("spi",t) + X("hyd",t) =E= X("irr",t) + X("AAA",t);
MinFlowA(t)..      X("AAA",t) =G= FlowReq;

*5. Define the models
*Linear Program for single maximize economic benefits objective
MODEL EconBen Single Objective LP Economic Benefits
         /WatBenefit,ResBalance,ResCapacity,EndStorage,HydropowerCap,RiverBalance,MinFlowA/;

*Check on prior single-objective deterministic linear programming formulation
SOLVE EconBen USING LP Maximizing TotalBen;

*****************************************
** PART II. Monte Carlo Simulation
********************************

* Define the uncertain parameters
Set fs Flow states /fs1*fs4/
    s  Monte carlo simultions /s1*s250/;

ALIAS (fs, fss);
ALIAS (fs, fsss);

PARAMETERS
*   Minimum and Maximum range for initial storage
    InitStorMin Minimum value of initial storage /0.5/
    InitStorMax Maximum value of initial storage /10/
*   Flow values and probabilities for inflow
    FlowVals(fs) Flow value of state fs in month 1
         /fs1  1, fs2   3, fs3 5, fs4  8/
    FlowProb(fs) Probability of flow state fs in month 1
         /fs1  0.1, fs2   0.3, fs3 0.4, fs4  0.2/
    FlowCumProb(fs) Cumulative probability of flow less than or equal to flow value fs in month 1
    CumFlowTranProb(fs,fss) Cumulative probability of moving from flow value fs in Time t to flow value fs2 in time t+1
    IBmin Minimum value for irrigation benefits in month 6 /1.7/
    IBmax Maximum value for irrigation benefits in month 6 /2.3/
* Hydro Benefits distribution
    HBmin Minimum value for hydropower benefits in month 6 /1.7/
    HBmax Maximum value for hydropower benefits in month 6 /2.3/;

TABLE FlowTransitionProb(fs,fss) Probability of moving from flow value fs in Time t to flow value fs2 in Time t+1
       fs1        fs2        fs3        fs4
fs1    0.2        0.5        0.2        0.1
fs2    0.2        0.3        0.3        0.2
fs3    0.1        0.4        0.4        0.1
fs4    0.2        0.3        0.4        0.1;

*Calculate the cumulative probability of flow in month 1 form the probability. Sum up
* all the probabilities from fs1, fs2, ... to fss
FlowCumProb(fs) = sum(fss$(ord(fss) le ord(fs)),FlowProb(fss));
*Calculate the cumulative probability of flow transitions from time t to t+1.
*Sum rows from column fss1, fss2, to fsss
*Same as FlowCumProb but for the matrix.
CumFlowTranProb(fs,fss) = sum(fsss$(ord(fsss) le ord(fss)), FlowTransitionProb(fs,fsss));

Display FlowCumProb, CumFlowTranProb;

*Parameters to store Monte Carlo sampled values
PARAMETERS
   InitStorS(s) Sampled initial reservoir storage
   CDFSampleS(s,t) Sampled cumulative distribution value for calculating inflow in time t
   FlowStateS(s,t) Sampled flow state in time t (integer corresponding to element in fs)
   InflowS(s,t) Sampled reservoir inflows
   InflowOrig(t) Original inflows
   FlowAtAS(s)  Calculated flow requirement at A
   IBbenS(s) sampled irrigation benefits in month 6
   HBbenS(s) sampled hdyropower benefits in month 6;

*Sample initial storage values in scenario s according to a uniform distribution
*between the minimum and maximum initial storage values (all values in range
*equally likely)
InitStorS(s) = uniform(InitStorMin, InitStorMax);
*Sample irrigation benefits in month 6
*IBbenS(s) = uniform(IBmin,IBmax);
IBbenS(s) = 2.2;
*Sample hydropower benefits in month 6
HBbenS(s) = uniform(HBmin, HBmax);

*Sample flow in each Time according to the emperical distribution. Use the inverse
* sampling method. First sample a cumulative distribution value between 0 and 1.
* Then map that CDF value to the flow state
* Sample the cdf value
CDFSampleS(s,t) = uniform(0,1);
* For the first timestep, search over the other flow states and find the state where the sampled cdf value actually
* falls in
FlowStateS(s,t)$(ord(t) eq 1) = max(1,
       sum(fs$((ord(fs) gt 1) and (CDFSampleS(s,t) gt FlowCumProb(fs-1)) and
               (CDFSampleS(s,t) le FlowCumProb(fs))),ord(fs)));

*Sample flows in Times 2 and up according to the transition probabilities. Again map back into
* a flow state
LOOP(t,
  FlowStateS(s,t)$(ord(t) gt 1) = max(1,
       sum(fss$((ord(fss) gt 1) and (CDFSampleS(s,t) gt sum(fs$(ord(fs) eq FlowStateS(s,t-1)),CumFlowTranProb(fs,fss-1))) and
              (CDFSampleS(s,t) le sum(fs$(ord(fs) eq FlowStateS(s,t-1)),CumFlowTranProb(fs,fss)))),ord(fss)));
  );

*Convert from flow states into flows
InflowS(s,t) = sum(fs$(ord(fs) eq FlowStateS(s,t)),FlowVals(fs));

*Calculate Flow at A as the maximum of 1 or 20% of the maximum generated inflow
FlowAtAS(s) = max(1,0.2*smax(t,InflowS(s,t)));

*These are all our Monte Carlo sampled values for each scenario
Display InitStorS, CDFSampleS,FlowStateS,InflowS, FlowAtAS;

* Parameters to record Monte-Carlo Optimized results
PARAMETERS
  NetBenS(s) Net benefits ($)
  ModStat(s) Model status
  SolStat(s) Solve status;

*Store the original inflows;
InflowOrig(t) = inflow(t);

*Surpress solution printing of model results because
*we will have a large number of models
EconBen.solprint = 2;

* Run the Monte-Carlo Simulations
Loop(s,
*   Read in the sampled parameter values
    InitStor = InitStorS(s);
    Inflow(t) = InflowS(s,t);
    FlowReq = FlowAtAS(s);
    IB("m6") = IBbenS(s);
    HB("m6")  = HBbenS(s);

*   Set the decision variable values to zero as initial solution
*   Not necessary for an LP, but would need for NLPs
    X.L(l,t) = 0;

*  Solve the model
   SOLVE EconBen USING LP Maximizing TotalBen;

*  Store results from current run
   NetBenS(s) = TotalBen.L;
   ModStat(s) = EconBen.ModelStat;
   SolStat(s) = EconBen.SolveStat;
   );

PARAMETERS
    AvgIB Average sampled irrigation benefits
    AvgNB Average net benefits;

AvgIB = sum(s, IBbenS(s))/card(s);
AvgNB = sum(s,NetBenS(s))/card(s);

Display NetBenS,ModStat,SolStat;
Display AvgIB, AvgNB;

Execute_Unload "HW4_mc.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls HW4_mc.gdx"


