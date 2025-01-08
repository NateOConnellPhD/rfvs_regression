
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rfvs-regression

**Note**: The following work titled *A Comparison of Random Forest
Variable Selection Methods for Regression Modeling of Continuous
Outcomes* by O’Connell, N.S., Jaeger, B.C., Bullock, G.S., and Speiser,
J.L. is currently submitted for peer review publication.

<!-- badges: start -->
<!-- badges: end -->

The goal of rfvs-regression is to compare random forest variable
selection techniques for continuous outcomes. We compare several methods
available through various R packages and user defined functions from
published paper appendices. The code for implementing each RF variable
selection approach tested can be found in the function “rfvs()” and each
of the methods assessed and compared are given in the following table:

<br/>

<table class="table" style="color: black; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
Abbreviation in Paper
</th>
<th style="text-align:left;">
Publication
</th>
<th style="text-align:left;">
R package
</th>
<th style="text-align:left;">
Approach
</th>
<th style="text-align:left;">
Type of forest method
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
None
</td>
<td style="text-align:left;">
Breiman 2001
</td>
<td style="text-align:left;">
ranger
</td>
<td style="text-align:left;">
N/A
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
Svetnik
</td>
<td style="text-align:left;">
Svetnik 2004
</td>
<td style="text-align:left;">
Uses party, code from Hapfelmeier
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Conditional Inference
</td>
</tr>
<tr>
<td style="text-align:left;">
Jiang
</td>
<td style="text-align:left;">
Jiang 2004
</td>
<td style="text-align:left;">
Uses party, code from Hapfelmeier
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Conditional Inference
</td>
</tr>
<tr>
<td style="text-align:left;">
Caret
</td>
<td style="text-align:left;">
Kuhn 2008
</td>
<td style="text-align:left;">
caret
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
Altmann
</td>
<td style="text-align:left;">
Altmann 2010
</td>
<td style="text-align:left;">
vita
</td>
<td style="text-align:left;">
Test Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
Boruta
</td>
<td style="text-align:left;">
Kursa 2010
</td>
<td style="text-align:left;">
Boruta
</td>
<td style="text-align:left;">
Test Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
aorsf - Menze
</td>
<td style="text-align:left;">
Menze 2011
</td>
<td style="text-align:left;">
aorsf
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Oblique
</td>
</tr>
<tr>
<td style="text-align:left;">
RRF
</td>
<td style="text-align:left;">
Deng 2013
</td>
<td style="text-align:left;">
RRF
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
SRC
</td>
<td style="text-align:left;">
Ishwaran 2014
</td>
<td style="text-align:left;">
randomForestSRC
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
VSURF
</td>
<td style="text-align:left;">
Genuer 2015
</td>
<td style="text-align:left;">
VSURF
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
aorsf-Negation
</td>
<td style="text-align:left;">
Jaeger 2023
</td>
<td style="text-align:left;">
aorsf
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Oblique
</td>
</tr>
<tr>
<td style="text-align:left;">
aorsf- Permutation
</td>
<td style="text-align:left;">
Jaeger 2023
</td>
<td style="text-align:left;">
aorsf
</td>
<td style="text-align:left;">
Performance Based
</td>
<td style="text-align:left;">
Oblique
</td>
</tr>
<tr>
<td style="text-align:left;">
Axis - SFE
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
ranger
</td>
<td style="text-align:left;">
Test Based
</td>
<td style="text-align:left;">
Axis
</td>
</tr>
<tr>
<td style="text-align:left;">
rfvimptest
</td>
<td style="text-align:left;">
Hapfelmeier 2023
</td>
<td style="text-align:left;">
rfvimptest
</td>
<td style="text-align:left;">
Test Based
</td>
<td style="text-align:left;">
Conditional Inference
</td>
</tr>
</tbody>
</table>

<br/>

In this benchmarking study, we pulled datasets from *OpenML* and
*modeldata* following the criteria and steps outlined below:

# Datasets included

<img src="README_files/figure-gfm/unnamed-chunk-3-1.png" width="900" />

A total of 59 datasets met criteria and were used in this benchmarking
study. Summary characteristics of these datasets are given in the figure
below

<center>

<img src="README_files/figure-gfm/unnamed-chunk-4-1.png" width="1231" />

# Benchmarking Study

We used five replications of split sample validation (i.e., Monte-Carlo
cross validation) for each dataset to evaluate RF variable selection
methods.

<<<<<<< HEAD
1.  First, a dataset was split into training (75%) and testing (25%)
    sets.
=======
<img src="README_files/figure-gfm/unnamed-chunk-3-1.png" width="1564" />
>>>>>>> main

2.  Second, each variable selection method was applied to the training
    data, and the variables selected by each method were saved.

3.  Third, a standard axis-based RF model using the R package *ranger*
    and an oblique RF using the package *aorsf* were fit on the training
    data set using variables selected from each method, and R^2 was
    recorded based on the test data for each replication, method, and
    dataset.

4.  Fourth, methods of variable selection were compared based on
    computation time, accuracy measured by R^2, and percent variable
    reduction

*note*: If any missing values were present in the training or testing
data, they were imputed prior to running variable selection methods
using the mean and mode for continuous and categorical predictors,
respectively, computed in the training data.

## Primary Results Table

We provide the results in the table below for R^2 for downstream models
fitted in Axis and Oblique RFs, variable percent reduction (higher %
reduction implies more variables eliminated on average), and computation
time (in seconds).

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:center;">
</th>
<th style="text-align:center;">
R-Squared (Axis)
</th>
<th style="text-align:center;">
R-Squared (Oblique)
</th>
<th style="text-align:center;">
Variable Percent Reduced
</th>
<th style="text-align:center;">
Time (seconds)
</th>
</tr>
</thead>
<tbody>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>Altman</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.41 ( 0.009 )<br> 0.4 \[ 0.216 , 0.637 \]
</td>
<td style="text-align:center;">
0.43 (0.009)<br>0.43 \[0.231, 0.654\]
</td>
<td style="text-align:center;">
0.74 ( 0.006 )<br> 0.81 \[ 0.667 , 0.9 \]
</td>
<td style="text-align:center;">
310.78 ( 17.446 )<br> 48.59 \[ 17.551 , 308.984 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>aorsf -<br>Menze</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.42 ( 0.009 )<br> 0.4 \[ 0.225 , 0.69 \]
</td>
<td style="text-align:center;">
0.45 (0.009)<br>0.48 \[0.23, 0.724\]
</td>
<td style="text-align:center;">
0.61 ( 0.008 )<br> 0.67 \[ 0.428 , 0.816 \]
</td>
<td style="text-align:center;">
11.7 ( 0.908 )<br> 1.92 \[ 0.552 , 7.46 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>aorsf -<br>Permutation</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.42 ( 0.009 )<br> 0.42 \[ 0.224 , 0.693 \]
</td>
<td style="text-align:center;">
0.45 (0.009)<br>0.48 \[0.236, 0.724\]
</td>
<td style="text-align:center;">
0.55 ( 0.008 )<br> 0.59 \[ 0.325 , 0.786 \]
</td>
<td style="text-align:center;">
29.65 ( 2.566 )<br> 3.54 \[ 0.721 , 11.824 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>Boruta</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.42 ( 0.009 )<br> 0.42 \[ 0.223 , 0.67 \]
</td>
<td style="text-align:center;">
0.43 (0.009)<br>0.45 \[0.238, 0.672\]
</td>
<td style="text-align:center;">
0.46 ( 0.009 )<br> 0.44 \[ 0.133 , 0.781 \]
</td>
<td style="text-align:center;">
29.53 ( 2.018 )<br> 3.65 \[ 1.586 , 17.349 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>CARET</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.43 ( 0.009 )<br> 0.42 \[ 0.238 , 0.695 \]
</td>
<td style="text-align:center;">
0.44 (0.009)<br>0.44 \[0.23, 0.692\]
</td>
<td style="text-align:center;">
0.47 ( 0.01 )<br> 0.48 \[ 0.111 , 0.834 \]
</td>
<td style="text-align:center;">
3150.54 ( 251.018 )<br> 171.32 \[ 51.698 , 1178.646 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>rfvimptest</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.16 ( 0.008 )<br> 0.07 \[ -0.007 , 0.282 \]
</td>
<td style="text-align:center;">
0.2 (0.008)<br>0.09 \[-0.001, 0.343\]
</td>
<td style="text-align:center;">
0.92 ( 0.001 )<br> 0.93 \[ 0.9 , 0.952 \]
</td>
<td style="text-align:center;">
1266.94 ( 98.942 )<br> 77.48 \[ 17.061 , 542.933 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>Jiang</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.43 ( 0.009 )<br> 0.42 \[ 0.233 , 0.693 \]
</td>
<td style="text-align:center;">
0.45 (0.009)<br>0.44 \[0.235, 0.719\]
</td>
<td style="text-align:center;">
0.64 ( 0.008 )<br> 0.69 \[ 0.444 , 0.872 \]
</td>
<td style="text-align:center;">
403.82 ( 28.423 )<br> 35.16 \[ 9.501 , 202.174 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>SRC</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.41 ( 0.009 )<br> 0.39 \[ 0.203 , 0.657 \]
</td>
<td style="text-align:center;">
0.41 (0.009)<br>0.42 \[0.171, 0.632\]
</td>
<td style="text-align:center;">
0.36 ( 0.009 )<br> 0.28 \[ 0 , 0.667 \]
</td>
<td style="text-align:center;">
27.99 ( 0.591 )<br> 19.92 \[ 12.613 , 41.722 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>aorsf -<br>Negation</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.42 ( 0.01 )<br> 0.41 \[ 0.214 , 0.671 \]
</td>
<td style="text-align:center;">
0.44 (0.009)<br>0.42 \[0.198, 0.725\]
</td>
<td style="text-align:center;">
0.54 ( 0.008 )<br> 0.58 \[ 0.333 , 0.778 \]
</td>
<td style="text-align:center;">
38.17 ( 3.54 )<br> 2.01 \[ 0.623 , 11.479 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>None</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.4 ( 0.009 )<br> 0.39 \[ 0.203 , 0.617 \]
</td>
<td style="text-align:center;">
0.4 (0.009)<br>0.39 \[0.142, 0.632\]
</td>
<td style="text-align:center;">
0 ( 0 )<br> 0 \[ 0 , 0 \]
</td>
<td style="text-align:center;">
0 ( 0 )<br> 0 \[ 0 , 0 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>Axis -<br>SFE</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.4 ( 0.009 )<br> 0.4 \[ 0.219 , 0.619 \]
</td>
<td style="text-align:center;">
0.41 (0.009)<br>0.4 \[0.174, 0.635\]
</td>
<td style="text-align:center;">
0.13 ( 0.005 )<br> 0.05 \[ 0 , 0.222 \]
</td>
<td style="text-align:center;">
0.32 ( 0.021 )<br> 0.05 \[ 0.027 , 0.234 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>RRF</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.4 ( 0.009 )<br> 0.4 \[ 0.204 , 0.619 \]
</td>
<td style="text-align:center;">
0.4 (0.009)<br>0.39 \[0.146, 0.632\]
</td>
<td style="text-align:center;">
0.01 ( 0.002 )<br> 0 \[ 0 , 0 \]
</td>
<td style="text-align:center;">
1.91 ( 0.105 )<br> 0.33 \[ 0.118 , 1.726 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>Svetnik</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.41 ( 0.009 )<br> 0.37 \[ 0.204 , 0.647 \]
</td>
<td style="text-align:center;">
0.44 (0.009)<br>0.4 \[0.221, 0.685\]
</td>
<td style="text-align:center;">
0.69 ( 0.008 )<br> 0.78 \[ 0.579 , 0.902 \]
</td>
<td style="text-align:center;">
1132.1 ( 65.615 )<br> 178.94 \[ 57.772 , 1142.9 \]
</td>
</tr>
<tr grouplength="1">
<td colspan="5" style="border-bottom: 0px solid;">
<strong>VSURF</strong>
</td>
</tr>
<tr>
<td style="text-align:center;padding-left: 2em;" indentlevel="1">
Mean (SD)<br>Median \[IQR\]
</td>
<td style="text-align:center;">
0.42 ( 0.01 )<br> 0.41 \[ 0.218 , 0.689 \]
</td>
<td style="text-align:center;">
0.43 (0.01)<br>0.41 \[0.224, 0.715\]
</td>
<td style="text-align:center;">
0.76 ( 0.007 )<br> 0.84 \[ 0.7 , 0.923 \]
</td>
<td style="text-align:center;">
244.92 ( 20.163 )<br> 20.02 \[ 8.875 , 106.442 \]
</td>
</tr>
</tbody>
</table>

## Primary Results Figure

We present the results of accuracy, by time, and percent reduction in
the figure below. K-Means clustering was used to find the cluster of
methods that perform best optimally in terms of computation time and
accuracy (in the bottom right corner of the figure), with size and color
denoting percent reduction.

<img src="README_files/figure-gfm/unnamed-chunk-6-1.png" width="1038" />

We observe that for downstream Axis forests fitted in *ranger*, the
methods of Boruta (r package: *boruta*) and aorsf-Menze (r package:
*aorsf*) perform optimmaly in terms of fast computation time and
high-accuracy while preserving good parsimony (good variable percent
reduction).

For downstream oblique forests fitted in *aorsf*, the methods
aorsf-Menze and aorsf-Permutation (both found within the *aorsf* R
package) perform best in terms of computation time and accuracy.

## Sensitivity to incomplete replication

We note that in several dataset replications, at least one method failed
to select a single variable in variable selection. We performed a
sensitivity analysis by assessing results only in replications where all
methods selected at least one variable (2,464 out of 4,260)

<img src="README_files/figure-gfm/unnamed-chunk-7-1.png" width="1038" />

## Comparison of Axis vs Oblique fitted downstream RFs

Last but not least, we compare downstream fitted Axis RFs to Oblique
RFs.

<img src="README_files/figure-gfm/unnamed-chunk-8-1.png" width="773" />

We find that in terms of median accuracy, downstream oblique fitted
forests generally perform slightly better than downstream Axis forests,
particularly among the top performing methods of variable selection.
