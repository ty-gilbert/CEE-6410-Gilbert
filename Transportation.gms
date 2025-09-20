$ontext
CEE 6410 - Water Resources Systems Analysis
Example 2.1 from Bishop Et Al Text (https://digitalcommons.usu.edu/ecstatic_all/76/)
Modifies Example with labor constraints

Further modification for transportation example ( with metal, circuit boards, and labor constraints)

THE PROBLEM:

An irrigated farm can be planted in two crops:  eggplants and tomatoes.  Data are as fol-lows:

Seasonal Resource
Inputs or Profit        Crops        Resource
Availability
        Eggplant        Tomatoes
Water        1x103 gal/plant        2x103 gal/plant      4x106 gal/year
Land        4 ft2/plant        3 ft2/plant               1.2x104 ft2
Labor         5hr/plant        2.5/hr plant              17,500 hours
Profit/plant        $6        $7

                Determine the optimal planting for the two crops.

THE SOLUTION:
Uses General Algebraic Modeling System to Solve this Linear Program

Ty Gilbert
A02298741@usu.edu
September 18, 2025
$offtext

* 1. DEFINE the SETS
SETS cars cars produced /coups, minivans/
     res resources /Metal, cboards, Labor/;

* 2. DEFINE input data
PARAMETERS
   carprofit(cars) Objective function coefficients ($ per car)
         /coups 6000,
         minivans 7000/
   carconstraints(res) Righthand constraint values for car production (per resource)
          /Metal 4000000,
           cboards  12000,
           Labor  17500/;

TABLE Z(cars,res) Left hand side constraint coefficients
            Metal    cboards    Labor
 Coups      1000     4          5
 Minivans   2000     3          2.5;


* 3. DEFINE the variables
VARIABLES W(cars) cars produced (Number)
          CPROFIT  total profit from producing cars($);

* Non-negativity constraints
POSITIVE VARIABLES W;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT Total profit ($) and objective function value
   RES_CONSTRAIN(res) Resource Constraints;

PROFIT..                 CPROFIT =E= SUM(cars, carprofit(cars)*W(cars));
RES_CONSTRAIN(res) ..    SUM(cars, Z(cars,res)*W(cars)) =L= carconstraints(res);


* 5. DEFINE the MODEL from the EQUATIONS
MODEL CARPRODUCTION /PROFIT, RES_CONSTRAIN/;
*Altnerative way to write (include all previously defined equations)
*MODEL PLANTING /ALL/;


* 6. SOLVE the MODEL
* Solve the PLANTING model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize VPROFIT
SOLVE CARPRODUCTION USING LP MAXIMIZING CPROFIT;

* 6. CLick File menu => RUN (F9) or Solve icon and examine solution report in .LST file
