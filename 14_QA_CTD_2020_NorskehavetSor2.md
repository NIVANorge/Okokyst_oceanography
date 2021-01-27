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
- See mail from Caroline Mengeot <caroline.mengeot@niva.no> tirsdag 28. januar 2020 10:33    
- Collectors / stations:  
    * OKOKYST_NH_Sor2_Aquakompetanse: VR52
    * OKOKYST_NH_Sor2_MagneAuren: VT42  
    * OKOKYST_NH_Sor2_SNO: VR31



## 1. Read files   

### New data (2020)  
- Read from excel files in folders under `K:/Avdeling/214-Oseanografi/DATABASER/OKOKYST_2017s`  
- 3 files in 3 separate folders in this case    


### Old data (2017-2019)    
Read from excel files in folders in each collectors' 'xlsbase'   
- Some trouble with excel file for VT42 2017 - the file is big (5 MB) but has only 1 line of data    



## 2. Data       

### Check sample dates   
- `dat_old`= 2017-2019   
- `dat` = last part of 2019 + 2020  

```
## -------------------------------------------------------------------------------------- 
## dat_old 
## -------------------------------------------------------------------------------------- 
## Number of dates:  98 
## First and last date:  2017-02-20 10:53:01 - 2019-11-26 12:14:10 
## Missing dates:  0 
## -------------------------------------------------------------------------------------- 
## dat: 
## -------------------------------------------------------------------------------------- 
## Number of dates:  38 
## First and last date:  2019-12-04 11:35:51 - 2020-12-01 10:31:21 
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
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2019-12-17 09:23:33 </td>
   <td style="text-align:right;"> 268 </td>
   <td style="text-align:right;"> 267 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-01-29 09:23:53 </td>
   <td style="text-align:right;"> 260 </td>
   <td style="text-align:right;"> 259 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-03-02 09:10:05 </td>
   <td style="text-align:right;"> 376 </td>
   <td style="text-align:right;"> 375 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-04-15 12:24:53 </td>
   <td style="text-align:right;"> 258 </td>
   <td style="text-align:right;"> 257 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-04-27 11:40:54 </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 264 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-05-19 11:50:57 </td>
   <td style="text-align:right;"> 271 </td>
   <td style="text-align:right;"> 270 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-06-17 11:49:17 </td>
   <td style="text-align:right;"> 258 </td>
   <td style="text-align:right;"> 257 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-07-14 10:22:06 </td>
   <td style="text-align:right;"> 276 </td>
   <td style="text-align:right;"> 275 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-08-27 11:13:19 </td>
   <td style="text-align:right;"> 248 </td>
   <td style="text-align:right;"> 247 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-09-24 17:30:14 </td>
   <td style="text-align:right;"> 273 </td>
   <td style="text-align:right;"> 272 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-10-20 13:40:01 </td>
   <td style="text-align:right;"> 237 </td>
   <td style="text-align:right;"> 236 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-10-30 09:57:02 </td>
   <td style="text-align:right;"> 270 </td>
   <td style="text-align:right;"> 269 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR31 </td>
   <td style="text-align:left;"> 2020-11-25 14:29:07 </td>
   <td style="text-align:right;"> 264 </td>
   <td style="text-align:right;"> 263 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2019-12-23 12:37:36 </td>
   <td style="text-align:right;"> 327 </td>
   <td style="text-align:right;"> 326 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-01-28 00:00:00 </td>
   <td style="text-align:right;"> 327 </td>
   <td style="text-align:right;"> 326 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-02-25 13:08:03 </td>
   <td style="text-align:right;"> 328 </td>
   <td style="text-align:right;"> 327 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-03-26 09:02:24 </td>
   <td style="text-align:right;"> 327 </td>
   <td style="text-align:right;"> 326 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-04-22 14:37:47 </td>
   <td style="text-align:right;"> 328 </td>
   <td style="text-align:right;"> 327 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-05-25 21:59:02 </td>
   <td style="text-align:right;"> 325 </td>
   <td style="text-align:right;"> 324 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-06-25 18:52:33 </td>
   <td style="text-align:right;"> 327 </td>
   <td style="text-align:right;"> 326 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-07-27 15:44:18 </td>
   <td style="text-align:right;"> 327 </td>
   <td style="text-align:right;"> 326 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-08-27 20:12:22 </td>
   <td style="text-align:right;"> 328 </td>
   <td style="text-align:right;"> 327 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-09-26 13:50:07 </td>
   <td style="text-align:right;"> 327 </td>
   <td style="text-align:right;"> 326 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-10-23 11:26:41 </td>
   <td style="text-align:right;"> 328 </td>
   <td style="text-align:right;"> 327 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VR52 </td>
   <td style="text-align:left;"> 2020-11-09 13:08:36 </td>
   <td style="text-align:right;"> 328 </td>
   <td style="text-align:right;"> 327 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2019-12-04 11:35:51 </td>
   <td style="text-align:right;"> 419 </td>
   <td style="text-align:right;"> 418 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-01-06 12:16:38 </td>
   <td style="text-align:right;"> 424 </td>
   <td style="text-align:right;"> 423 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-02-03 11:02:43 </td>
   <td style="text-align:right;"> 394 </td>
   <td style="text-align:right;"> 393 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-02-24 10:27:07 </td>
   <td style="text-align:right;"> 418 </td>
   <td style="text-align:right;"> 417 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-04-14 08:23:14 </td>
   <td style="text-align:right;"> 358 </td>
   <td style="text-align:right;"> 357 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-05-05 07:37:02 </td>
   <td style="text-align:right;"> 410 </td>
   <td style="text-align:right;"> 409 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-06-03 07:41:00 </td>
   <td style="text-align:right;"> 425 </td>
   <td style="text-align:right;"> 424 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-07-20 10:41:36 </td>
   <td style="text-align:right;"> 416 </td>
   <td style="text-align:right;"> 415 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-08-04 10:11:50 </td>
   <td style="text-align:right;"> 404 </td>
   <td style="text-align:right;"> 403 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-09-01 07:47:22 </td>
   <td style="text-align:right;"> 421 </td>
   <td style="text-align:right;"> 420 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-10-06 07:05:14 </td>
   <td style="text-align:right;"> 411 </td>
   <td style="text-align:right;"> 410 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-10-31 07:57:33 </td>
   <td style="text-align:right;"> 399 </td>
   <td style="text-align:right;"> 398 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> VT42 </td>
   <td style="text-align:left;"> 2020-12-01 10:31:21 </td>
   <td style="text-align:right;"> 422 </td>
   <td style="text-align:right;"> 421 </td>
  </tr>
</tbody>
</table>


## 3. Profiles of 2020 data  

### Salinity  
_NOTE: also see plots for top 20 m further down._  
   
- Gl_5: Profile looks strange at 20-30 m in April 2019 (and no pattern in temperature)  
   
- Very low salinity at 0-1 meter:     
    + Dec 2018 at Gl_3 and Gl_5: Dubious? no indication of top freshwater layer in temperature  
    + 4. April 2019 Gl_5: Dubious? no indication of top freshwater layer in temperature  
    + 21 June 2019 at Gl_6: Dubious? little indication of top freshwater layer in temperature  
    + July 2019 at Gl_2 and Gl_3: probably OK - temperature also indicates top freshwater layer  
    + 15 Aug 2019 at Gl_2 and Gl_4: Dubious? little indication of top freshwater layer in temperature  

![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-6-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-6-3.png)<!-- -->

### Salinity top 50 m 
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-7-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-7-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-7-3.png)<!-- -->


### Temperature    
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-8-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-8-3.png)<!-- -->

### Temperature top 50 m 
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-9-3.png)<!-- -->

### Oxygen volume      
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-10-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-10-3.png)<!-- -->

### Oxygen saturation        
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-11-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-11-3.png)<!-- -->




## 4. Times series (since 2017)  

### Combined data

```
## New names:
## * ...11 -> ...12
```

```
##       addNA(StationCode)
## Year   VR31 VR52 VT42 <NA>
##   2017   13   13    2    0
##   2018   13   12   12    0
##   2019   12   12   12    0
##   2020   12   11   12    0
```

### Station VR31 (SNO)      
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-13-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-13-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-13-3.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-13-4.png)<!-- -->


### Station VR52 (Aquakompetanse)      
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-14-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-14-3.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-14-4.png)<!-- -->

### Station VT42 (Magne Auren)      
![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-15-2.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-15-3.png)<!-- -->![](14_QA_CTD_2020_NorskehavetSor2_files/figure-html/unnamed-chunk-15-4.png)<!-- -->
  

