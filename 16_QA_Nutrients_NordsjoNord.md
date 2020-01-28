---
title: "12_QA_2019_from_excel"
author: "DHJ"
date: "13 1 2020"
output: 
  html_document:
    keep_md: true
    toc: true
    toc_float: true
---

# QA for Nordsjøen Nord, nutrients, ØKOKYST 2019 report (January 2020)    


  
## 1. Libraries



## 2. Read file    

```
## Warning: NAs introduced by coercion

## Warning: NAs introduced by coercion
```

### Tables of stations    

```
## # A tibble: 8 x 2
##   StationCode     n
##   <chr>       <int>
## 1 VT16          188
## 2 VT52          178
## 3 VT53          191
## 4 VT69           60
## 5 VT70          184
## 6 VT74          184
## 7 VT75          178
## 8 VT79          184
```





## 3. KlfA
![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-1.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-2.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-3.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-4.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-5.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-6.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-4-7.png)<!-- -->


## 4. SiO2  
- Some really high values (ca 3 or more) in   
    + VT52 (Jan 2018 and Aug 2018)  
    + VT53 (Jan 2018)  
![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-1.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-2.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-3.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-4.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-5.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-6.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-5-7.png)<!-- -->


## 5. Nitrogen    
  
### Nitrite + nitrate, ammonium, Tot-N  
- TOTN is too low (>20%, see next section) in  
    + VT52, July 2018, 20 m  
    + VT74, Aug 2018, 30 m  
    + VT75, Dec 2017, 10 m  
- TOTN seems too low (deviates from pattern in inorganic components) in   
    + VT52, Aug 2018, 0, 5 and 10 m
    + VT53, Jan 2018, 5 m
    + VT53, July 2018, 5 + 10 m
    + VT70, July 2018?
    + VT70, Dec 2018, 5 m
    + VT74, May 2018, 0 m
    + VT75, Dec 2017, 10 m
- TOTN seems too high in   
    + VT75, Oct 2018, 10 m
![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-2.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-3.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-4.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-5.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-6.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-6-7.png)<!-- -->


### Inorg. N as fraction of TOTN  

```
## # A tibble: 9 x 5
## # Groups:   StationCode [5]
##   StationCode Date                    N Inorg_N_fraction_max Inorg_N_fraction_m~
##   <chr>       <dttm>              <int>                <dbl>               <dbl>
## 1 VT52        2018-01-23 00:00:00     1                 1.14                1.14
## 2 VT52        2018-07-25 00:00:00     2                 1.36                1.21
## 3 VT52        2018-08-20 00:00:00     1                 1.15                1.15
## 4 VT53        2018-07-25 00:00:00     1                 1.05                1.05
## 5 VT69        2017-12-18 00:00:00     1                 1.18                1.18
## 6 VT74        2018-08-20 00:00:00     1                 1.42                1.42
## 7 VT75        2017-05-22 00:00:00     1                 1.18                1.18
## 8 VT75        2017-12-18 00:00:00     1                 1.24                1.24
## 9 VT75        2018-10-17 00:00:00     2                 1.18                1.12
```

![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-1.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-2.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-3.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-4.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-5.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-6.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-7-7.png)<!-- -->

## 6. Phosphorus

### PO4-P and TOTP   
- TOTP is suspiciously high:  
    + VT70, Sept 2017, 20 m
    + VT70, Aug 2019, 5 m
- TOTP is a little too low (5-13%, see next section):
    + VT16, March and May 2017  
- PO4 is suspiciously low:  
    + VT74, April 2017, 30 m  
    
![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-3.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-4.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-5.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-6.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-8-7.png)<!-- -->




### Inorg. P as fraction of TOTP

```
## # A tibble: 2 x 5
## # Groups:   StationCode [1]
##   StationCode Date                    N Inorg_P_fraction_max Inorg_P_fraction_m~
##   <chr>       <dttm>              <int>                <dbl>               <dbl>
## 1 VT16        2017-03-18 00:00:00     2                 1.05                1.03
## 2 VT16        2017-05-01 00:00:00     2                 1.13                1.08
```

![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-3.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-4.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-5.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-6.png)<!-- -->![](16_QA_Nutrients_NordsjoNord_files/figure-html/unnamed-chunk-9-7.png)<!-- -->






