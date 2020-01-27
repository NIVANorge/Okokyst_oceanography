---
title: "15_QA_CTD_NordsjoNord"
author: "DHJ"
date: "27 1 2020"
output: 
  html_document:
    keep_md: true
    toc: true
    toc_float: true
---


# QA for CTDs - ØKOKYST Nordsjøen NOrd 2019 report (January 2020)    
- Check Excel files from Anna Birgitta and Trond  
- Only CTDs
- See mail from Anna Birgitta Ledang <AnnaBirgitta.Ledang@niva.no> Sent: torsdag 23. januar 2020 14:59

   
**Veileder:**  
- `Documents\artikler\veiledere etc\02_2013_klassifiserings-veileder_.pdf`  

  

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
```


## 1. Folders and file information 


```r
### Path to mother folder (must end with a slash)
basefolder <- "Datasett/Nordsjø Nord/"


# Norskehavet Sør I
folder1 <- "Hardangerfjorden"
folder2 <- "MON"
folder3 <- "Sognefjorden"
```


### Check file names, sheet names and variable names   
Makes 'fileinfo' which contains all of this info (one line per file)  

```
## [1] "Hardangerfjorden" "MON"              "Sognefjorden"
```

```
##              Folder           File  Sheet
## 1  Hardangerfjorden  VT52_CTD.xlsx Rådata
## 2  Hardangerfjorden  VT53_CTD.xlsx Rådata
## 3  Hardangerfjorden  VT69_CTD.xlsx Rådata
## 4  Hardangerfjorden  VT70_CTD.xlsx Rådata
## 5  Hardangerfjorden  VT74_CTD.xlsx Rådata
## 6  Hardangerfjorden  VT75_CTD.xlsx Rådata
## 7               MON NORD1_CTD.xlsx Rådata
## 8               MON NORD2_CTD.xlsx Rådata
## 9               MON OFOT1_CTD.xlsx Rådata
## 10              MON OFOT2_CTD.xlsx Rådata
## 11              MON  OKS1_CTD.xlsx Rådata
## 12              MON  OKS2_CTD.xlsx Rådata
## 13              MON  SAG1_CTD.xlsx Rådata
## 14              MON  SAG2_CTD.xlsx Rådata
## 15              MON SJON1_CTD.xlsx Rådata
## 16              MON SJON2_CTD.xlsx Rådata
## 17              MON  TYS1_CTD.xlsx Rådata
## 18              MON  TYS2_CTD.xlsx Rådata
## 19     Sognefjorden  VT16_CTD.xlsx Rådata
## 20     Sognefjorden  VT79_CTD.xlsx Rådata
##                                                                                            Variables
## 1  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 2  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 3  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 4  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 5  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 6  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 7  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 8  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 9  ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 10 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 11 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 12 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 13 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 14 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 15 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 16 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 17 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 18 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 19 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
## 20 ProjectName,StationCode,Date,Depth1,Depth2,Saltholdighet,Temperatur,Oksygen,Oksygenmetning,Metode
```







### Delete som negative oxygen measurements    
After plotting below  


```r
# Check
# datalist[[7]] %>% filter(year(Date) == 2014 & month(Date) == 6) %>% View()

# June 2014: NORD1 (7) + NORD2 (8) + OFOT2 (10) + OKS2 (12) + SG2 (14)
for (i in c(7,8,10,12,14)){
  sel <- with(datalist[[i]], year(Date) == 2014 & month(Date) == 6 & !is.na(Oksygen) & Oksygen < 0)
  cat(sum(sel), "\n")
  datalist[[i]]$Oksygen[sel] <- NA
  datalist[[i]]$Oksygenmetning[sel] <- NA
}
```

```
## 85 
## 25 
## 31 
## 11 
## 18
```

```r
# June 2019: SJON2 (16, hele vannsøylen) + VT79 (20)
for (i in c(16,20)){
  sel <- with(datalist[[i]], year(Date) == 2019 & month(Date) == 6 & !is.na(Oksygen) & Oksygen < 0)
  cat(sum(sel), "\n")
  datalist[[i]]$Oksygen[sel] <- NA
  datalist[[i]]$Oksygenmetning[sel] <- NA
}
```

```
## 620 
## 41
```

```r
# April 2019 VT16 (19) og VT79 (20)
for (i in c(19,20)){
  sel <- with(datalist[[i]], year(Date) == 2019 & month(Date) == 4 & !is.na(Oksygen) & Oksygen < 0)
  cat(sum(sel), "\n")
  datalist[[i]]$Oksygen[sel] <- NA
  datalist[[i]]$Oksygenmetning[sel] <- NA
}
```

```
## 70 
## 52
```

```r
# Mai 2019 VT16 (19) og VT79 (20)
for (i in c(10)){
  sel <- with(datalist[[i]], year(Date) == 2019 & month(Date) == 5 & !is.na(Oksygen) & Oksygen < 0)
  cat(sum(sel), "\n")
  datalist[[i]]$Oksygen[sel] <- NA
  datalist[[i]]$Oksygenmetning[sel] <- NA
}
```

```
## 438
```

```r
# Feb 2017: OKS2 (12)
for (i in c(12)){
  sel <- with(datalist[[i]], !is.na(Oksygen) & Oksygen < 0)
  cat(sum(sel), "\n")
  datalist[[i]]$Oksygen[sel] <- NA
  datalist[[i]]$Oksygenmetning[sel] <- NA
}
```

```
## 0
```

## 2. Plot casts

Plot all casts  
- Also check max depth    
**Notes**  
- NB: Samme StationCode på mange av filene (eks. StationCode = 69165 for alle Hardangerfjordfilene VT52, VT53, etc.). Se over.     
- VT69 har stor variasjon i dybde: 12 meter i feb 2017, rundt 40-50 meter mars 2017 til okt. 2018, så 70-90 meter (opptil 95 meter) vinteren 2018-2019 før det går tilbake til ca 50 meter (obs: kun 32 meter i aug 2018): Hva har skjedd her?  
- 35-50 meter variasjon i maks.dybde for noen av de andre Hardangerfjordfilene, men det er vel greit siden disse er på stort dyp  
- MON/NORD1: lav maksdybde i mars 2013 (229 m) og juni 2014 (222 m), skal være 285-290 m  
- MON/NORD2: Ligger oftest på 225-230 m, men har ekstra stor maksdybde i mars 2013 (289 m), så denne må være et annet sted  
- MON/OFOT1: Typisk 230-240 meter, men store avvik begge veier: små dybder i sept 2013 (156 m), juli 2018 (75 m), okt 2018 (36 m), og veldig store dybder ( 433-436 meter) i feb 2014, april 2018 og jan 2019.   
- MON/OFOT2: Normalt 430-440 m. Lave dybder (<300 m) i des 2013, feb 2014, juni 2014 aug 2016, april 2018, jan 2019  
- MON/OKS1: Ganske stort avvik i des. 2013 (122 m istedet for normalt 150-190 m)   
- MON/OKS2: Ganske stort avvik i des. 2013 (135 m istedet for normalt 175-195 m)  
- MON/SAG1: Normalt rundt 600 m, store avvik i des 2013 (436 m) og mars 2018 (343 m)   
- MON/SAG2: Normalt rundt 340-350 m, store avvik i des 2015 (253 m)   
- Sognefjord/SJON1: OK   
- Sognefjord/SJON2: april 2017: 371 m mot normalt ca 620   
- Sognefjord/TYS1: nov-des 2013: <350 m mot normalt 720 m, også 571 m i sept 029
- Sognefjord/TYS2: normal dybde ca 600 m, lav (<450 m) nov-des 2013, høy (708 m) i apr 2013  
- Sognefjord/VT16: >1250 m normalt, store avvik i jan 2019 (893 m) og aug 2019 (496 m)   


```r
plot_cast_all()
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-2.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-3.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-4.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-5.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-6.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-7.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-8.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-9.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-10.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-11.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-12.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-13.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-14.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-15.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-16.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-17.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-18.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-19.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-6-20.png)<!-- -->

## 3. Plot parameters

### Plot salinity time series


```r
plot_timeseries_all("Saltholdighet")
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-1.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-2.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-3.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-4.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-5.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-6.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-7.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-8.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-9.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-10.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-11.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-12.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-13.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-14.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-15.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-16.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-17.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-18.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-19.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-7-20.png)<!-- -->

### Plot salinity profiles


```r
plot_ctdprofile_all("Saltholdighet")
```

```
## Warning: Removed 20 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-2.png)<!-- -->

```
## Warning: Removed 45 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-3.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-4.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-5.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-6.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-7.png)<!-- -->

```
## Warning: Removed 63 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-8.png)<!-- -->

```
## Warning: Removed 201 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-9.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-10.png)<!-- -->

```
## Warning: Removed 38 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-11.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-12.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-13.png)<!-- -->

```
## Warning: Removed 6 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-14.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-15.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-16.png)<!-- -->

```
## Warning: Removed 74 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-17.png)<!-- -->

```
## Warning: Removed 97 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-18.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-19.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-8-20.png)<!-- -->

### Plot temperature time series

```r
plot_timeseries_all("Temperatur")
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-2.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-3.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-4.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-5.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-6.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-7.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-8.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-9.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-10.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-11.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-12.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-13.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-14.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-15.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-16.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-17.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-18.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-19.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-9-20.png)<!-- -->

### Plot temperature profiles   

```r
plot_ctdprofile_all("Temperatur")
```

```
## Warning: Removed 20 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-2.png)<!-- -->

```
## Warning: Removed 45 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-3.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-4.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-5.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-6.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-7.png)<!-- -->

```
## Warning: Removed 63 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-8.png)<!-- -->

```
## Warning: Removed 201 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-9.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-10.png)<!-- -->

```
## Warning: Removed 38 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-11.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-12.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-13.png)<!-- -->

```
## Warning: Removed 6 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-14.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-15.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-16.png)<!-- -->

```
## Warning: Removed 74 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-17.png)<!-- -->

```
## Warning: Removed 97 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-18.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-19.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-10-20.png)<!-- -->

### Plot oxygen conc time series    

Veilederen sier:   

> Oksygenmålingene og klassifisering er knyttet til maksimalt dyp,   
> men det anbefales at målingene foretas som vertikale profiler   
> for å avklare om større deler av vannsøylen har reduserte oksygenmengder.  
   
- VT52: Oksygenkonsentrasjon er ofte lavere rundt 100-200 m dyp enn ved bunnen (og lavere enn 4.5 i noen måneder)   
- VT52: Oksygenkonsentrasjon er ofte veldig nær grensa på 4.5 i en stor del av vannsøylen    
- OFOT1: Oksygenkonsentrasjon er ofte lavere rundt 100 m dyp enn ved bunnen
- "Hakkete" oksygenprofiler i des. 2018 (VT53, VT74) og mai 2019 (alle Sognefjordsdata). Ser tvilsomt ut, kan være feil på sensor.  
-  Vær oppmerksom på tidstrender i noen av datasettene og at bra tilstand i 2017-2018 kan "maskere" dårlig tilstand i de siste målingene (2019) og eldre målinger (2013-2014). Bør bemerkes.    


```r
plot_timeseries_all("Oksygen")
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-2.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-3.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-4.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-5.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-6.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-7.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-8.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-9.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-10.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-11.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-12.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-13.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-14.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-15.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-16.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-17.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-18.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-19.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-11-20.png)<!-- -->

### Plot oxygen conc. profiles     
"Hakkete" oksygenprofiler i des. 2018 (VT53, VT74) og mai 2019 (alle Sognefjordsdata)

```r
plot_ctdprofile_all("Oksygen", limits = 4.5)
```

```
## Warning: Removed 20 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-2.png)<!-- -->

```
## Warning: Removed 45 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-3.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-4.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-5.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-6.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-7.png)<!-- -->

```
## Warning: Removed 63 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-8.png)<!-- -->

```
## Warning: Removed 201 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-9.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-10.png)<!-- -->

```
## Warning: Removed 38 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-11.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-12.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-13.png)<!-- -->

```
## Warning: Removed 6 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-14.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-15.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-16.png)<!-- -->

```
## Warning: Removed 74 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-17.png)<!-- -->

```
## Warning: Removed 97 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-18.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-19.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-12-20.png)<!-- -->



### Plot oxygen saturation time series


```r
plot_timeseries_all("Oksygenmetning")
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-1.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-2.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-3.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-4.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-5.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-6.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-7.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-8.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-9.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-10.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-11.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-12.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-13.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-14.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-15.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-16.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-17.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-18.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-19.png)<!-- -->![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-13-20.png)<!-- -->

### Plot oxygen saturation profiles


```r
plot_ctdprofile_all("Oksygenmetning", limits = c(50,65))
```

```
## Warning: Removed 20 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-2.png)<!-- -->

```
## Warning: Removed 45 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-3.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-4.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-5.png)<!-- -->

```
## Warning: Removed 2 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-6.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-7.png)<!-- -->

```
## Warning: Removed 63 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-8.png)<!-- -->

```
## Warning: Removed 201 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-9.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-10.png)<!-- -->

```
## Warning: Removed 38 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-11.png)<!-- -->

```
## Warning: Removed 3 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-12.png)<!-- -->

```
## Warning: Removed 4 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-13.png)<!-- -->

```
## Warning: Removed 6 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-14.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-15.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-16.png)<!-- -->

```
## Warning: Removed 74 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-17.png)<!-- -->

```
## Warning: Removed 97 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-18.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-19.png)<!-- -->

```
## Warning: Removed 5 rows containing missing values (geom_path).
```

![](15_QA_CTD_NordsjoNord_files/figure-html/unnamed-chunk-14-20.png)<!-- -->
