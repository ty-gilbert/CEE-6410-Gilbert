$ontext
CEE 6410 - Water Resources Systems Analysis
Example 2.1 from Bishop Et Al Text (https://digitalcommons.usu.edu/ecstatic_all/76/)
Modifies Example to fit problem 2.3

Further modification for Vehicle Production problem ( with tanks, rows of seats,
four-wheel drive systems, and total vehicle constraints)

THE PROBLEM:

A motor vehicle company can produce two types of vehicles: Trucks and Sedans.
There are a total of 14000 tanks, 18000 rows of seats, and 6000 four-wheel drive systems.
Additionaly the total vehicles produced must not exceed 10000,
Data are as fol-lows:


Inputs or Profit        Vehicles        Resources
Availability
                Trucks              Sedans              Available
Tanks           2 per vehicle       1 per vehicle       14,000 tanks
Rows of Seats   1 rows/vehicle      2 per vehicle       18,000 rows
4WD Systems     1 per vehicle       0 per vehicle       6,000 4WD
Total vehicles     1 per vehicle       1 per vehicle       10,000 vehicles
Profit/Vehicle  $100 per vehicle    $120 per vehicle   

    Determine the optimal production for the two vehicles.

THE SOLUTION:
Uses General Algebraic Modeling System to Solve this Linear Program

Ty Gilbert
A02298741@usu.edu
September 24, 2025
$offtext

* 1. DEFINE the SETS
SETS vehicles vehicles produced /truck, sedan/
     res resources /tanks, rows, four_wd, total_vehicle/;

* 2. DEFINE input data
PARAMETERS
   vehicleprofit(vehicles) Objective function coefficients ($ profit per vehicle)
         /truck 100,
         sedan 110/
   vehicleconstraints(res) Righthand constraint values for vehicle production (per resource)
          /tanks 14000,
           rows 18000,
           four_wd  6000
           total_vehicle  10000/;

TABLE A(vehicles, res) Left hand side constraint coefficients
            tanks   rows    four_wd     total_vehicle
 Truck      2       1       1           1
 Sedan      1       2       0           1;


* 3. DEFINE the variables
VARIABLES X(vehicles) vehicles produced (#)
          CPROFIT  total profit from producing vehicles($);

* Non-negativity constraints
POSITIVE VARIABLES X;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT Total profit ($) and objective function value
   RES_CONSTRAIN(res) resly Constraints;

PROFIT..                 CPROFIT =E= SUM(vehicles, vehicleprofit(vehicles)*X(vehicles));
RES_CONSTRAIN(res) ..    SUM(vehicles, A(vehicles, res)*X(vehicles)) =L= vehicleconstraints(res);


* 5. DEFINE the MODEL from the EQUATIONS
MODEL VEHICLEPRODUCTION /PROFIT, RES_CONSTRAIN/;


* 6. SOLVE the MODEL
* Solve the VEHICLEPRODUCTION model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize CPROFIT
SOLVE VEHICLEPRODUCTION USING LP MAXIMIZING CPROFIT;

* 6. CLick File menu => RUN (F9) or Solve icon and examine solution report in .LST file
