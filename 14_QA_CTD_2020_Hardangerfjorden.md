---
title: "QA for CTDs in Norskehavet Sør I - ØKOKYST 2019 report"
author: "DHJ"
date: "13 1 2020"
output:
  html_document:
    keep_md: true
    toc: true
    toc_float: true

---

## QC done January 2021    
- CTDs with salinity + temp + oxygen      
- Excel files from Trond Kristansen's dropbox (29.01.2021)
- Stations:    
    * VT53 - Hardangerfjorden (this script)  
    * VT69 - Hardangerfjorden (this script)   
    * VT70 - Hardangerfjorden (this script)  
    * VT74 - Hardangerfjorden (this script)  
    * VT16 - Sognefjorden (see separate script)   
    * VT79 - Sognefjorden (see separate script)    
    
    


## 1. Read files   

### New data (2020)  
- Read from excel files in folders under `K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017s`  
- 3 files in 3 separate folders in this case    


#### Compare with old versions





### Older data (2017-2019)  


```
## -------------------------------------------------------------------------------------- 
## dat_old: 
## -------------------------------------------------------------------------------------- 
##             StationCode
## addNA(Date)  VT52 VT53 VT69 VT70 VT74 VT75
##   2017-02-20    0  856   96  594  231    0
##   2017-03-20  395  856   96  594  231  182
##   2017-04-04  395  856   96  594  231  182
##   2017-04-18  395  856   96  594  231  182
##   2017-05-22  395  856   96  594  231  182
##   2017-06-19  395  856   96  594  231  182
##   2017-07-17  395  856   96  594  231  182
##   2017-08-22  395  856   96  594  231  182
##   2017-09-18  395  856   96  594  231  182
##   2017-10-09  395  856   96  594  231  182
##   2017-10-24  395  856   96  594  231  182
##   2017-11-06  395  856   96  594  231  182
##   2017-12-18  395  856   96  594  231  182
##   2018-01-23  395  856   96  594  231  182
##   2018-02-26  395  856   96  594  231  182
##   2018-03-12  395  856   96  594  231  182
##   2018-04-16  395  856   96  594  231  182
##   2018-05-22  395  856   96  594  231  182
##   2018-06-18  395  856   96  594  231  182
##   2018-07-25  395  856   96  594  231  182
##   2018-08-20  395  856   96  594  231  182
##   2018-09-26  395  856   96  594  231  182
##   2018-10-17  395  856   96  594  231  182
##   2018-11-22  395  856   96  594  231  182
##   2018-12-17  395  856   96  594  231  182
##   2019-01-24  395  856   96  594  231  182
##   2019-02-26  395  856   96  594  231  182
##   2019-03-19  395  856   96  594  231  182
##   2019-04-25  395  856   96  594  231  182
##   2019-05-20    0    0   96    0    0    0
##   2019-05-21  395  856    0  594  231  182
##   2019-06-25    0  856   96  594  231    0
##   2019-07-16    0    0   96  594    0  182
##   2019-08-19  395  856   96  594  231  182
##   2019-09-24  395  856   96  594  231  182
##   2019-10-21  395  856   96  594  231  182
##   2019-11-11  395  856   96  594  231  182
##   <NA>          0    0    0    0    0    0
## -------------------------------------------------------------------------------------- 
## dat: 
## -------------------------------------------------------------------------------------- 
##             StationCode
## addNA(Date)  VT53 VT69 VT70 VT74
##   2019-12-16  856  125  595  231
##   2020-01-20  856  125  595  231
##   2020-02-19  856  125  595  231
##   2020-03-25  856  125  595  231
##   2020-04-20  856  125  595  231
##   2020-05-20  856  125  595  231
##   2020-06-22  856  125  595  231
##   2020-07-23  856  125  595  231
##   2020-08-24  856  125  595  231
##   2020-09-21  856  125  595  231
##   2020-10-22  856  125  595  231
##   2020-11-09  856  125  595  231
##   2020-12-16  856  125  595  231
##   <NA>          0    0    0    0
## StationCode2
## VT52_69165 VT53_69165 VT69_69165 VT70_69165 VT74_69165 VT75_69165 
##      13035      29960       3456      21384       8085       6188 
## StationCode2
## VT53_68911 VT69_68908 VT70_68910 VT74_68913 
##      11128       1625       7735       3003
```


## 2. Data       

### Check sample dates   
- `dat_old`= 2017-2019   
- `dat` = last part of 2019 + 2020  

```
## -------------------------------------------------------------------------------------- 
## dat_old: 
## -------------------------------------------------------------------------------------- 
## Number of dates:  37 
## First and last date:  2017-02-20 - 2019-11-11 
## Missing dates:  0 
## -------------------------------------------------------------------------------------- 
## dat: 
## -------------------------------------------------------------------------------------- 
## Number of dates:  13 
## First and last date:  2019-12-16 - 2020-12-16 
## Missing dates:  0
```


### Dates and max depth of new data    
<table class="table table-striped" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> StationCode </th>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> Max_depth </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2019-12-16 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-01-20 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-02-19 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-04-20 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-05-20 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-06-22 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-07-23 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-08-24 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-09-21 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-10-22 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-11-09 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT53 </td>
   <td style="text-align:left;"> 2020-12-16 </td>
   <td style="text-align:right;"> 856 </td>
   <td style="text-align:right;"> 855 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2019-12-16 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-01-20 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-02-19 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-04-20 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-05-20 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-06-22 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-07-23 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-08-24 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-09-21 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-10-22 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-11-09 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT69 </td>
   <td style="text-align:left;"> 2020-12-16 </td>
   <td style="text-align:right;"> 125 </td>
   <td style="text-align:right;"> 124 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2019-12-16 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-01-20 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-02-19 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-04-20 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-05-20 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-06-22 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-07-23 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-08-24 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-09-21 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-10-22 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-11-09 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT70 </td>
   <td style="text-align:left;"> 2020-12-16 </td>
   <td style="text-align:right;"> 595 </td>
   <td style="text-align:right;"> 594 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2019-12-16 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-01-20 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-02-19 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-04-20 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-05-20 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-06-22 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-07-23 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-08-24 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-09-21 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-10-22 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-11-09 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT74 </td>
   <td style="text-align:left;"> 2020-12-16 </td>
   <td style="text-align:right;"> 231 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
</tbody>
</table>


## 3. Profiles of 2020 data  

### Salinity  
_NOTE: also see plots for top 20 m further down._  
   
- VT69:  
    - Large variation in max. depth  
- VT70:  
    - Dec. 2020: salinity a bit rugged around 180-200 m   

![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-7-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-7-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-7-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-7-4.png)<!-- -->

### Salinity top 50 m 
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-8-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-8-4.png)<!-- -->


### Temperature    
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-9-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-9-4.png)<!-- -->

### Temperature top 50 m 
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-10-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-10-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-10-4.png)<!-- -->

### Oxygen volume      

Somewhat noisy, e.g. April in VT70

![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-11-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-11-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-11-4.png)<!-- -->

### Oxygen saturation        
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-12-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-12-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-12-4.png)<!-- -->




## 4. Times series (since 2017)  

### Combined data

```
##       addNA(StationCode)
## Year   VT52 VT53 VT69 VT70 VT74 VT75 <NA>
##   2017   12   13   13   13   13   12    0
##   2018   12   12   12   12   12   12    0
##   2019    9   11   12   12   11   10    0
##   2020    0   12   12   12   12    0    0
```

### All stations  


### Station VT53       
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-15-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-15-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-15-4.png)<!-- -->


### Station VT69       
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-16-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-16-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-16-4.png)<!-- -->

### Station VT70       
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-17-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-17-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-17-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-17-4.png)<!-- -->

### Station VT74       
![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-18-1.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-18-2.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-18-3.png)<!-- -->![](14_QA_CTD_2020_Hardangerfjorden_files/figure-html/unnamed-chunk-18-4.png)<!-- -->



