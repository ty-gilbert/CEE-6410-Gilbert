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
   cropprofit(crops) Objective function coefficients ($ per acre of crop)
         /hay 100,
         grain 120/
   cropconstraints(month) Righthand constraint values for crop production (per month)
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
          CPROFIT  total profit from producing crops($);

* Non-negativity constraints
POSITIVE VARIABLES X;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT Total profit ($) and objective function value
   MONTH_CONSTRAIN(month) Monthly Constraints;

PROFIT..                 CPROFIT =E= SUM(crops, cropprofit(crops)*X(crops));
MONTH_CONSTRAIN(month) ..    SUM(crops, A(crops, month)*X(crops)) =L= cropconstraints(month);


* 5. DEFINE the MODEL from the EQUATIONS
MODEL CROPPRODUCTION /PROFIT, MONTH_CONSTRAIN/;


* 6. SOLVE the MODEL
* Solve the CROPPRODUCTION model using a Linear Programming Solver (see File=>Options=>Solvers)
*     to maximize CPROFIT
SOLVE CROPPRODUCTION USING LP MAXIMIZING CPROFIT;

* 6. CLick File menu => RUN (F9) or Solve icon and examine solution report in .LST file
