---
title: "QA for CTDs in Sørfjorden - ØKOKYST 2019 report"
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
    * Lind1   
    * S16    
    * S22    
    * SOE10    
    * SOE72  
    
    


## 1. Read files   

### New data (2020)  
- Read from excel files in folders under `K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017s`  
- 3 files in 3 separate folders in this case    


## 2. Data       

### Check sample dates   
- `dat` = 2018, 2019, 2020  

```
## -------------------------------------------------------------------------------------- 
## dat: 
## -------------------------------------------------------------------------------------- 
## Number of dates:  17 
## First and last date:  2018-03-14 - 2020-11-06 
## Missing dates:  0
```


### Dates + min and max depth of new data    
<table class="table table-striped" style="width: auto !important; ">
 <thead>
  <tr>
   <th style="text-align:left;"> StationCode </th>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> Min_depth </th>
   <th style="text-align:right;"> Max_depth </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2019-12-09 </td>
   <td style="text-align:right;"> 35 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 35 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 37 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 37 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-04-06 </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 40 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-05-15 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-06-11 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-07-10 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 44 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-08-10 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 43 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-09-07 </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-10-07 </td>
   <td style="text-align:right;"> 31 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 35 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lind1 </td>
   <td style="text-align:left;"> 2020-11-06 </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 33 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S16 </td>
   <td style="text-align:left;"> 2018-03-14 </td>
   <td style="text-align:right;"> 843 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 844 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S16 </td>
   <td style="text-align:left;"> 2018-05-13 </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S16 </td>
   <td style="text-align:left;"> 2018-06-18 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S16 </td>
   <td style="text-align:left;"> 2018-08-13 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S16 </td>
   <td style="text-align:left;"> 2018-09-08 </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 30 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S22 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 25 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S22 </td>
   <td style="text-align:left;"> 2020-05-15 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 20 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S22 </td>
   <td style="text-align:left;"> 2020-07-10 </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S22 </td>
   <td style="text-align:left;"> 2020-09-07 </td>
   <td style="text-align:right;"> 37 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> S22 </td>
   <td style="text-align:left;"> 2020-11-06 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE10 </td>
   <td style="text-align:left;"> 2018-05-12 </td>
   <td style="text-align:right;"> 35 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 37 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE10 </td>
   <td style="text-align:left;"> 2018-09-07 </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 36 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2019-12-09 </td>
   <td style="text-align:right;"> 31 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 34 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-03-25 </td>
   <td style="text-align:right;"> 31 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-04-06 </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 41 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-05-15 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-06-11 </td>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-07-10 </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 40 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-09-07 </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 35 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-10-07 </td>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SOE72 </td>
   <td style="text-align:left;"> 2020-11-06 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 43 </td>
  </tr>
</tbody>
</table>


## 3. Profiles of 2020 data  

### Salinity  
_NOTE: also see plots for top 20 m further down._  
   
- Lind1:  
    - Max. depth varies from 23 to 44 m, particularly small in June + Sept 2020  
    - Lacking top 7 m in Oct 2020  (see table above)
- S22:  
    - Max. depth varies a bit (shallow in May + Nov 2020)     
    - Lacking top 4 in May 2020  
- S16:  
    - Only one CTD to the bottom (844 m, so I assume this is by design)   
- Soe10:  
    - Top 7 m lacking in Sept 2018  
- Soe72:  
    - Top 5 m lacking in Oct 2018  
    - Max. depth varies a bit   
    
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-5-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-5-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-5-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-5-4.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-5-5.png)<!-- -->

### Salinity top 50 m 
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-6-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-6-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-6-4.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-6-5.png)<!-- -->


### Temperature    
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-7-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-7-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-7-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-7-4.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-7-5.png)<!-- -->

### Temperature top 50 m 
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-8-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-8-4.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-8-5.png)<!-- -->

### Oxygen volume      
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-9-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-9-4.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-9-5.png)<!-- -->

### Oxygen saturation        
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-10-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-10-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-10-4.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-10-5.png)<!-- -->




## 4. Times series (since 2018)  



### Station Lind1       
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-12-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-12-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-12-4.png)<!-- -->
### Station S16  
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-13-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-13-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-13-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-13-4.png)<!-- -->



### Station S22  
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-14-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-14-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-14-4.png)<!-- -->


### Station SOE10  
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-15-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-15-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-15-4.png)<!-- -->


### Station SOE72  
![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-16-2.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-16-3.png)<!-- -->![](14_QA_CTD_2020_Soerfjorden_files/figure-html/unnamed-chunk-16-4.png)<!-- -->





