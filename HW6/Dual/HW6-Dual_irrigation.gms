$ontext
CEE 6410 - Water Resources Systems Analysis
Example 2.1 from Bishop Et Al Text (https://digitalcommons.usu.edu/ecstatic_all/76/)
Modifies Example to fit problem 2.3

Further modification for irrigation problem ( with June, July, Aug, and total acre constraints)

THE PROBLEM:

An irrigated farm can be planted in two crops:  hay and grain.
Each month has a water requirement for each crop and an available amount of water in acft.
Additionaly the total acres must not exceed 10,
Data are as fol-lows:


Inputs or Profit        Crops        Months
Availability
                Hay             Grain
June            2 acft/acre     1 acft/acre     14,000 acft
July            1 acft/acre     2 acft/acre     18,000 acft
Aug             1 acft/acre     0 acft/acre      6,000 acft
Total acres     1 acft/acre     1 acft/acre     10,000 acre
Profit/acre     $100/acre       $120/acre

                Determine the optimal planting for the two crops.

THE SOLUTION:
Uses General Algebraic Modeling System to Solve this Linear Program

Ty Gilbert
A02298741@usu.edu
September 24, 2025
$offtext

* 1. DEFINE the SETS
SETS crops crops produced /hay, grain/
     month months and other acreage constraint /June, July, Aug, tot/;

* 2. DEFINE input data
PARAMETERS
   c(crops) Objective function coefficients ($ per acre of crop)
         /hay 100,
         grain 120/
   b(month) Righthand constraint values for crop production (per month)
          /June 14000,
           July 18000,
           Aug  6000
           tot  10000/;

TABLE A(crops, month) Left hand side constraint coefficients
            June    July    Aug     Tot
 Hay        2       1       1       1
 Grain      1       2       0       1;


* 3. DEFINE the variables
VARIABLES X(crops) crops produced (acres)
          VPROFIT  total profit from producing crops($)
          Y(month) value of ac-ft or acres depending on variable
          VREDCOST total reduced cost ($);

* Non-negativity constraints
POSITIVE VARIABLES X,Y;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT_PRIMAL Total profit ($) and objective function value
   MONTH_CONS_PRIMAL(month) Monthly Constraints
   REDCOST_DUAL Reduced Cost ($) associated with ???
   MONTH_CONS_DUAL(crops) Profit levels;

*primal equations
PROFIT_PRIMAL..                 VPROFIT =E= SUM(crops, c(crops)*X(crops));
MONTH_CONS_PRIMAL(month) ..    SUM(crops, A(crops, month)*X(crops)) =L= b(month);

*dual equations
REDCOST_DUAL..                  VREDCOST =E= SUM(month,b(month)*Y(month));
MONTH_CONS_DUAL(crops)..        sum(month,A(crops,month)*Y(month)) =G= c(crops);

* 5. DEFINE the MODEL from the EQUATIONS
*PRIMAL model
MODEL CROPS_PRIMAL /PROFIT_PRIMAL, MONTH_CONS_PRIMAL/;
*Set the options file to print out range of basis information
CROPS_PRIMAL.optfile = 1;

*DUAL model
MODEL CROPS_DUAL /REDCOST_DUAL, MONTH_CONS_DUAL/;

* 6. SOLVE the MODEL
* Solve the CROPS_PRIMAL model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize VPROFIT
SOLVE CROPS_PRIMAL USING LP MAXIMIZING VPROFIT;

* Solve the CROPS_DUAL model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to minimize VREDCOST
SOLVE CROPS_DUAL USING LP MINIMIZING VREDCOST;


* 6. CLick File menu => RUN (F9) or Solve icon and examine solution report in .LST file

* 7 . Dump all data and results to GAMS proprietary file storage .gdx and to Excel
Execute_Unload "HW6-Dual.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls HW6-Dual.gdx"
* To open the GDX file in the GAMS IDE, select File => Open.
* In the Open window, set Filetype to .gdx and select the file.