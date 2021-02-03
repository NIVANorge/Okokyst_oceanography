---
title: "QC Norskehavet Sør 2, nutrients + Chl"
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

  






## 1. Read Norskehavet Nord I nutrients     

### Get data  

```
## 5796 rows of data downloaded 
## Stations: VR52, VT42, VR31 
## Parameters: NO3+NO2-N, NH4-N, TOTP, PO4-P, SiO2, KlfA, TSM, TOTN (old EF), TOTN, TOTN (est.)
```


### Measurements by parameter, site and year    

```
## , , STATION_CODE = VR31
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   64    65        65    65   65   55            10   65  60
##   2018   60    55        55    55   50   25            30   55  54
##   2019   60    60        60    60   60    5            60   60  55
##   2020   58    58        58    58   58   10            48   58  57
## 
## , , STATION_CODE = VR52
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   65    65        65    65   65   45            20   65  65
##   2018   59    59        60    60   60   20            40   60  60
##   2019   60    60        60    60   60    5            60   59  60
##   2020   60    57        57    57   57   10            47   57  57
## 
## , , STATION_CODE = VT42
## 
##       PARAM_NAME
## Year   KlfA NH4-N NO3+NO2-N PO4-P SiO2 TOTN TOTN (old EF) TOTP TSM
##   2017   60    65        65    65   65   50            15   65  65
##   2018   60    60        60    60   60   25            35   60  60
##   2019   60    60        60    60   60    0            60   60  59
##   2020   60    60        60    60   60    6            59   60  60
```
### Measurements by depth, site and year    

```
## , , STATION_CODE = VR31
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   12   12   12
##     5    13   12   12   12
##     10   13   12   12   12
##     20   13   12   12   11
##     30   13   12   12   11
## 
## , , STATION_CODE = VR52
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   12   12   12
##     5    13   12   12   12
##     10   13   12   12   12
##     20   13   12   12   12
##     30   13   12   12   12
## 
## , , STATION_CODE = VT42
## 
##       Year
## DEPTH1 2017 2018 2019 2020
##     0    13   14   13   13
##     5    13   14   13   13
##     10   13   14   13   14
##     20   14   14   13   14
##     30   13   13   13   14
```
### Parameters  

```
## # A tibble: 10 x 3
##    PARAM_NAME    NAME                 n
##    <chr>         <chr>            <int>
##  1 KlfA          Klorofyll A        726
##  2 NH4-N         Ammonium           724
##  3 NO3+NO2-N     Nitritt + nitrat   725
##  4 PO4-P         Fosfat             725
##  5 SiO2          Silikat            720
##  6 TOTN          Total nitrogen     256
##  7 TOTN (old EF) Total nitrogen     484
##  8 TOTP          Total fosfor       724
##  9 TSM           TSM                673
## 10 TSM           TSM-F               39
```

### Reformat data    
Formatting the data in 'wide' format (one column per paremeter) as shown below  

```
## # A tibble: 4 x 15
##   StationCode Date                Depth1 `NH4-N`   TSM  SiO2 `NO3+NO2-N`  TOTP
##   <chr>       <dttm>               <dbl>   <dbl> <dbl> <dbl>       <dbl> <dbl>
## 1 VR31        2017-02-23 13:00:00      0       5    NA   240          98    21
## 2 VR31        2017-02-23 13:00:00      5       5    NA   240         101    22
## 3 VR31        2017-02-23 13:00:00     10       5    NA   230          99    22
## 4 VR31        2017-02-23 13:00:00     20       5    NA   240         102    23
## # ... with 7 more variables: TOTN <dbl>, `PO4-P` <dbl>, KlfA <dbl>, `TOTN (old
## #   EF)` <dbl>, Year <dbl>, Month <dbl>, `Nitrate + ammonium` <dbl>
```
  
## Chl a   
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-8-3.png)<!-- -->

## Nutrients  {.tabset}

### NH4-N
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-9-3.png)<!-- -->


### NO3+NO2-N
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-10-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-10-3.png)<!-- -->


### TOTN
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-11-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-11-3.png)<!-- -->


### TOTN (old EF) 
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-12-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-12-3.png)<!-- -->


### PO4-P
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-13-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-13-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-13-3.png)<!-- -->

### TOTP
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-14-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-14-3.png)<!-- -->

### SiO2
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-15-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-15-3.png)<!-- -->

### TSM
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-16-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-16-3.png)<!-- -->

## TotN versus the sum of nitrate + ammonium    
![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-17-1.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-17-2.png)<!-- -->![](17_QC_Nutrients_2020_Norskehavet_Sor2_files/figure-html/unnamed-chunk-17-3.png)<!-- -->




