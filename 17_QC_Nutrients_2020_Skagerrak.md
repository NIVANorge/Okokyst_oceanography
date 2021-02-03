---
title: "QC Skagerrak, nutrients + Chl"
author: "DHJ"
date: "28.02.2021"
output: 
  html_document:
    toc: true
    toc_float: true
    keep_md: true
---

**QC of Norskehavet Sør I (Caroline + Lars)**      
- Stations:  
    + VR52: OKOKYST_NH_Sor2_Aquakompetanse  
    + VT42: OKOKYST_NH_Sor2_MagneAuren   
    + VR31: OKOKYST_NH_Sor2_SNO:   
    
- **Note: Here we download data from Aquamonitor insted of reading excel files (as last year)**  

**Veileder:**  
- `Documents\artikler\veiledere etc\02_2013_klassifiserings-veileder_.pdf`  
- Chlorophyll: page 91.   
"I SørNorge (til Stadt) anbefales det at innsamlingen starter i februar og avsluttes ved utgangen av oktober."   
"Nord for Stadt anbefales det at innsamlingsperioden strekker seg fra mars til og med september."   
90% percentiles should be used   
  
- Also see calculation example on on page 187-189, and the comment on page 189:  
"Det gjøres oppmerksom på at dataprogrammene som beregner 90-persentil, gjerne benytter ulike metoder". We use the Excel method PERCENTILE.EXC, corresponding to type 6 quantiles in R  
  
- Nutrients: page 102 in veileder  
Vinter er november til og med februar   
Sommer er juni til og med august  

  






## 1. Read nutrients     

### Get data  

```
## Stations: 
##  VT16 VT52 VT53 VT69 VT70 VT74 VT75 VT79 
## 
## 12637 rows of data downloaded 
## Stations: VT16, VT52, VT53, VT69, VT70, VT74, VT75, VT79 
## Parameters: NO3+NO2-N, NH4-N, TOTP, PO4-P, SiO2, KlfA, TSM, TOTN (old EF), TOTN, TOTN (est.)
```


### Measurements by parameter, site and year    

```
## , , STATION_CODE = VT16
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   65    60        60    60   55   55             5   60  65
##   2018   60    60        51    60   60   25            35   60  60
##   2019   60    60        60    60   60    0            60   60  60
##   2020   55    55        55    55   55    0            55   55  55
## 
## , , STATION_CODE = VT52
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   60    60        60    60   60   45            15   60  60
##   2018   60    54        55    54   55   20            35   55  59
##   2019   60    60        60    60   60    0            60   60  60
##   2020    0     0         0     0    0    0             0    0   0
## 
## , , STATION_CODE = VT53
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   65    65        65    65   65   50            15   65  65
##   2018   60    55        55    55   55   20            35   55  60
##   2019   60    60        60    60   60    0            60   60  60
##   2020   55    54        55    55   55    4            51   55  55
## 
## , , STATION_CODE = VT69
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   13    13        13    13   13   10             3   13  13
##   2018   12    11        11    11   11    4             7   11  12
##   2019   12    12        12    12   12    0            12   12  12
##   2020   11    12        12    12   12    0            12   12  12
## 
## , , STATION_CODE = VT70
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   65    65        65    65   65   50            15   65  64
##   2018   60    55        55    55   55   21            34   55  60
##   2019   60    60        60    60   60    0            60   60  60
##   2020   55    54        55    55   55    4            51   55  55
## 
## , , STATION_CODE = VT74
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   65    65        65    65   65   50            15   65  65
##   2018   60    55        55    55   55   20            35   55  59
##   2019   60    60        60    60   60    0            60   60  60
##   2020   55    58        58    58   58    3            55   58  58
## 
## , , STATION_CODE = VT75
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   60    60        60    60   60   45            15   60  60
##   2018   60    55        55    55   55   21            34   55  60
##   2019   60    60        60    60   60    0            60   60  60
##   2020    0     0         0     0    0    0             0    0   0
## 
## , , STATION_CODE = VT79
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   65    60        60    60   55   55             5   60  65
##   2018   60    60        49    60   60   25            35   60  60
##   2019   60    60        60    60   60    0            60   60  58
##   2020   55    55        55    55   55    0            55   55  55
```
### Measurements by depth, site and year    

```
## , , STATION_CODE = VT16
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   12   12   11
##     5    13   12   12   11
##     10   13   12   12   11
##     20   13   12   12   11
##     30   13   12   12   11
## 
## , , STATION_CODE = VT52
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    12   12   12    0
##     5    12   12   12    0
##     10   12   12   12    0
##     20   12   12   12    0
##     30   12   12   12    0
## 
## , , STATION_CODE = VT53
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   13   12   11
##     5    13   13   12   11
##     10   13   13   12   11
##     20   13   13   12   11
##     30   13   13   12   11
## 
## , , STATION_CODE = VT69
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0     0    0    0    0
##     5    13   12   12   12
##     10    0    0    0    0
##     20    0    0    0    0
##     30    0    0    0    0
## 
## , , STATION_CODE = VT70
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   12   12   11
##     5    13   12   12   11
##     10   13   12   12   11
##     20   13   12   12   11
##     30   13   12   12   11
## 
## , , STATION_CODE = VT74
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   12   12   11
##     5    13   12   12   11
##     10   13   12   12   12
##     20   13   12   12   12
##     30   13   12   12   12
## 
## , , STATION_CODE = VT75
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    12   12   12    0
##     5    12   12   12    0
##     10   12   12   12    0
##     20   12   12   12    0
##     30   12   12   12    0
## 
## , , STATION_CODE = VT79
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   12   12   11
##     5    13   12   12   11
##     10   13   12   12   11
##     20   13   12   12   11
##     30   13   12   12   11
```
### Parameters  

```
## # A tibble: 10 x 3
##    PARAM_NAME    NAME                 n
##    <chr>         <chr>            <int>
##  1 KlfA          Klorofyll A       1608
##  2 NH4-N         Ammonium          1573
##  3 NO3+NO2-N     Nitritt + nitrat  1556
##  4 PO4-P         Fosfat            1575
##  5 SiO2          Silikat           1566
##  6 TOTN          Total nitrogen     527
##  7 TOTN (old EF) Total nitrogen    1049
##  8 TOTP          Total fosfor      1576
##  9 TSM           TSM               1417
## 10 TSM           TSM-F              190
```

### Reformat data    
Formatting the data in 'wide' format (one column per paremeter) as shown below  

```
## # A tibble: 4 x 15
##   StationCode Date                Depth1 `NH4-N`   TSM  SiO2 `NO3+NO2-N`  TOTP
##   <chr>       <dttm>               <dbl>   <dbl> <dbl> <dbl>       <dbl> <dbl>
## 1 VT16        2017-02-21 16:30:00      0       5  0.22   200          77    18
## 2 VT16        2017-02-21 16:30:00      5       5  0.18   200          76    17
## 3 VT16        2017-02-21 16:30:00     10       5  0.15   200          78    17
## 4 VT16        2017-02-21 16:30:00     20       5  0.14   210          62    20
## # ... with 7 more variables: TOTN <dbl>, `PO4-P` <dbl>, KlfA <dbl>, `TOTN (old
## #   EF)` <dbl>, Year <dbl>, Month <dbl>, `Nitrate + ammonium` <dbl>
```
  
## Chl a   
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-8-7.png)<!-- -->

## Nutrients  {.tabset}

### NH4-N
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-9-7.png)<!-- -->


### NO3+NO2-N
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-10-7.png)<!-- -->


### TOTN
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-11-7.png)<!-- -->


### TOTN (old EF) 
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-12-7.png)<!-- -->


### PO4-P
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-13-7.png)<!-- -->

### TOTP
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-14-7.png)<!-- -->

### SiO2
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-15-7.png)<!-- -->

### TSM
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-3.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-16-7.png)<!-- -->

## TotN versus the sum of nitrate + ammonium    
![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-1.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-2.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-3.png)<!-- -->

```
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
## geom_path: Each group consists of only one observation. Do you need to adjust
## the group aesthetic?
```

![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-4.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-5.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-6.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-7.png)<!-- -->![](17_QC_Nutrients_2020_Skagerrak_files/figure-html/unnamed-chunk-17-8.png)<!-- -->




