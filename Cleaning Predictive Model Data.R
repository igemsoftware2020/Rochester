
library(tidyverse)
library(tidyr)
library(ggplot2)
library(randomForest)
library(hablar)

#Summary of Endo Clinical Data
summary(Endo_Registry_062520_iGem)

#Removing outliers

#Change 97s & 98s to NA so they don't appear as outlier
Endo_Registry_062520_iGem_version_1_xlsb[Endo_Registry_062520_iGem_version_1_xlsb == 98] <- NA
Endo_Registry_062520_iGem_version_1_xlsb[Endo_Registry_062520_iGem_version_1_xlsb == 97] <- NA

#Turn columns with numeric values into numerics
Endo_Outlier <- Endo_Registry_062520_iGem_version_1_xlsb %>% 
convert(num(age, Civil_Status, Education, cycle_regularity, age_menarche, Menstrual_Cycle_length, Period_length, Incapacitating_pain, Dysmenorrhea, Dyspareunia, children_n, Miscarriages_Y_N, miscarriages_n, OCP_before, OCP_current, IUD, Depo_provera, birth_control_other,  age_1st_child, years_smoking,Age_symptoms, Smoking, cigarets_day_n, years_smoking:AUB, Migraines:Hysterectomy, Health_Insurance:Age_symptoms, Endometriosis_delay, Family_Hx, Endo_treatment_Y_N, treatment_infertility_Y_N:bmi, exercise_week))

#check for outliers
source("http://goo.gl/UUyEzD") #source code
outlierKD(Endo_Outlier, Period_length)
#Outliers are in Age_symptoms, period length, menstrual cycle length, BMI

#Remove Patients without value for Endo diagnosis
Endo_Drop_NA <- Endo_Outlier %>% drop_na(Endometriosis_DX)
#Convert numeric to character
Endo_Clean_NumFix <- Endo_Drop_NA %>% mutate_if(is.numeric, as.character)
#convert logic to character
Endo_Clean_LogFix <- Endo_Clean_NumFix %>% mutate_if(is.logical, as.character)

#replace NA with 98
Endo_Clean_LogFix[is.na(Endo_Clean_LogFix)] <- "98"

#Recoding to make yes = 1 and no = 0
Endo_Clean_Recode <- Endo_Clean_LogFix %>%
  mutate(cycle_regularity=recode(cycle_regularity, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Dysmenorrhea=recode(Dysmenorrhea, "6" = "98", "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Incapacitating_pain=recode(Incapacitating_pain, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Dyspareunia =recode(Dyspareunia,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Tried_get_pregnant=recode(Tried_get_pregnant, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(problems_getting_pregnant=recode(problems_getting_pregnant, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Miscarriages_Y_N=recode(Miscarriages_Y_N,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Hysterectomy=recode(Hysterectomy,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(OCP_before=recode(OCP_before,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(OCP_current=recode(OCP_current, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Smoking=recode(Smoking, "5" = "98", "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Endometriosis_DX=recode(Endometriosis_DX, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Endo_Surgical_Dx=recode(Endo_Surgical_Dx, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Family_Hx=recode(Family_Hx, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Endo_treatment_Y_N =recode(Endo_treatment_Y_N,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(treatment_infertility_Y_N=recode(treatment_infertility_Y_N, "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(Cause_infertility_Y_N=recode(Cause_infertility_Y_N,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) %>%
  mutate(exercise=recode(exercise, "1" = "no", "2" = "yes", "No" = "no", "Yes"="yes")) %>%
  mutate(treatments_Hormonal_non_Hormonal=recode(treatments_Hormonal_non_Hormonal,  "1" = "0", "2" = "1", "no" = "0", "No" = "0", "yes" = "1", "Yes" = "1")) 

#recoding inconsistencies in categories
Endo_Clean_Recode_2 <- Endo_Clean_Recode %>%
  mutate(Endo_severity=recode(Endo_severity, "2ne" = "98")) %>%
  mutate(Endo_severity=recode(Endo_severity, "Mod-Sev" = "Moderate (III)")) %>%
  mutate(Cancer=recode(Cancer, "endometrio" = "98")) %>%
  mutate(Cancer=recode(Cancer, "Lymphoma hodkins" = "Lymphoma")) %>%
  mutate(Cancer=recode(Cancer, "parothid" = "98")) %>%
  mutate(Cancer=recode(Cancer, "Breast (treated)" = "breast")) %>%
  mutate(Tx_1=recode(Tx_1,"Laparoscopy" = "laparoscopy", "Nordet" = "OCP", "Lupron-Depot" = "lupron", "Lupron x 3 months" = "lupron", "Hysterectomy" = "hysterectomy","Laser ablation" = "Laser", "OCP's" = "OCP", "Danocrine," = "Danazol", "Surgery (total)" = "surgery", "Lupron 3.75" = "lupron","Lupron x 3 months " = "lupron",  "Lupron" = "lupron", "don't remember" = "98", "OCPs (Triphasil-28)" = "OCP","OCP's   Ortonovum" = "OCP", "Depo Provera" = "depo-provera", "Depo-Provera" = "depo-provera","Depo-provera," = "depo-provera", "Depo-provera" = "depo-provera", "Depro-povera" = "depo-provera", "Depo-Provera" = "depo-provera", "lupron (6 months)" = "lupron", "Lupron" = "lupron", "'Lupron Depot" = "lupron","Lupron Depot 3.75mgs." = "lupron","Lupron 3.75mgs." = "lupron", "Lupron  x 1 year" = "lupron", "Naprozen" = "NSAID", "Lepot-Depot" = "lupron", "'Lupron" = "lupron", "Lupron ," = "lupron", "Lupron depot 3.75" = "lupron", "Lupron 3.75mg" = "lupron", "Lupron depot" = "lupron", "Lupron Depot" = "lupron", "Lupron Depot 3.75" = "lupron", "Lupron dupot 3.75" = "lupron", "Lupron 3.75 mg" = "lupron", "Lupron 3.75 mg" = "lupron", "lupron (6 months)" = "lupron", "Lupron 11.25mgs" = "lupron", "Lurpon depot 3.75" = "lupron", "Lupron-2001" = "lupron", "Lupron x 1 year" = "lupron", "'Lupron ," = "lupron", "Lupron," = "lupron", "Lupron Deport 3.75mgs" = "lupron", "lupron," = "lupron", "Motrin" = "NSAID", "NSAID's" = "NSAID", "don't remember" = "98", "Danazol/Danocrine" = "Danazol", "Danocrine/ Danazol" = "Danazol", "Danazol 600mgs" = "Danazol", "Danocrin" = "Danazol", "Danazol x 3 months" = "Danazol", "Danocrine/Danazol" = "Danazol", "danazol &" = "Danazol", "danazol" = "Danazol", "DANAZOL" = "Danazol", "danazol 500" = "Danazol", "Danocrine" = "Danazol", "TAH + BSO" = "TAH and BSO", "TAH-BSO" = "TAH and BSO", "TAH / BSO" = "TAH and BSO", "Hysterectomy total" = "hysterectomy", "Lupron  x 1 year" = "lupron", "lapaorscopy" = "laparoscopy", ",  Syderal" = "Synarel" )) %>%
  mutate(Tx_2=recode(Tx_2, "Synarel," = "Synarel", "Danazol ," = "Danazol", "Depo provera" = "depo-provera", "Laparascopy x 4" = "laparoscopy", "Triphasil-28" = "OCP", "Triphasil 28" = "OCP", "Deprovera" = "depo-provera", "1996" = "98", "percocet" = "Pain Killer", "Progesterona" = "OCP", "pain meds" = "Pain Killer", "Pain Killers" = "Pain Killer", "lupron x 6 months" = "lupron", "Narcotics" = "Pain Killer", "Provera" = "depo-provera", ",  Danazol" = "Danazol", "anti-inflammatory drugs" = "NSAID", "relafen" = "NSAID", "OCP (OCP's)" = "OCP",  "Synarell" = "Synarel","OCP (OCP )" = "OCP",  "Laparoscopy" = "laparoscopy", "Nordet" = "OCP", "Lupron-Depot" = "lupron", "Relafen 700 mg" = "NSAID", "Lupron x 3 months" = "lupron", "Hysterectomy" = "hysterectomy","Laser ablation" = "Laser", "OCP's" = "OCP", "Danocrine," = "Danazol", "Surgery (total)" = "surgery", "Lupron 3.75" = "lupron","Lupron x 3 months " = "lupron",  "Lupron" = "lupron", "don't remember" = "98", "OCPs (Triphasil-28)" = "OCP","OCP's   Ortonovum" = "OCP", "Depo Provera" = "depo-provera", "Depo-Provera" = "depo-provera","Depo-provera," = "depo-provera", "Depo-provera" = "depo-provera", "Depro-povera" = "depo-provera", "Depo-Provera" = "depo-provera", "lupron (6 months)" = "lupron", "Lupron" = "lupron", "'Lupron Depot" = "lupron","Lupron Depot 3.75mgs." = "lupron","Lupron 3.75mgs." = "lupron", "Lupron  x 1 year" = "lupron", "Naprozen" = "NSAID", "Lepot-Depot" = "lupron", "'Lupron" = "lupron", "Lupron ," = "lupron", "Lupron depot 3.75" = "lupron", "Lupron 3.75mg" = "lupron", "Lupron depot" = "lupron", "Lupron Depot" = "lupron", "Lupron Depot 3.75" = "lupron", "Lupron dupot 3.75" = "lupron", "Lupron 3.75 mg" = "lupron", "Lupron 3.75 mg" = "lupron", "lupron (6 months)" = "lupron", "Lupron 11.25mgs" = "lupron", "Lurpon depot 3.75" = "lupron", "Lupron-2001" = "lupron", "Lupron x 1 year" = "lupron", "'Lupron ," = "lupron", "Lupron," = "lupron", "Lupron Deport 3.75mgs" = "lupron", "lupron," = "lupron", "Motrin" = "NSAID", "NSAID's" = "NSAID", "don't remember" = "98", "Danazol/Danocrine" = "Danazol", "Danocrine/ Danazol" = "Danazol", "Danazol 600mgs" = "Danazol", "Danocrin" = "Danazol", "Danazol x 3 months" = "Danazol", "Danocrine/Danazol" = "Danazol", "danazol &" = "Danazol", "danazol" = "Danazol", "DANAZOL" = "Danazol", "danazol 500" = "Danazol", "Danocrine" = "Danazol", "TAH + BSO" = "TAH and BSO", "TAH-BSO" = "TAH and BSO", "TAH / BSO" = "TAH and BSO", "Hysterectomy total" = "hysterectomy", "Lupron  x 1 year" = "lupron", "lapaorscopy" = "laparoscopy", ",  Syderal" = "Synarel" )) %>%
  mutate(Tx_3=recode(Tx_3, "depropovera" = "depo-provera", "Histeroscopía" = "hysterectomy", "Triphasil" = "OCP", "depoprovera" = "depo-provera", "Depo-provera." = "depo-provera", "'motrin & tylenol" = "NSAID", "Premarin, provera" = "depo-provera", "Synarel," = "Synarel", "Danazol ," = "Danazol", "Depo provera" = "depo-provera", "Laparascopy x 4" = "laparoscopy", "Triphasil-28" = "OCP", "Triphasil 28" = "OCP", "Deprovera" = "depo-provera", "1996" = "98", "percocet" = "Pain Killer", "Progesterona" = "OCP", "pain meds" = "Pain Killer", "Pain Killers" = "Pain Killer", "lupron x 6 months" = "lupron", "Narcotics" = "Pain Killer", "Provera" = "depo-provera", ",  Danazol" = "Danazol", "anti-inflammatory drugs" = "NSAID", "relafen" = "NSAID", "OCP (OCP's)" = "OCP",  "Synarell" = "Synarel","OCP (OCP )" = "OCP",  "Laparoscopy" = "laparoscopy", "Nordet" = "OCP", "Lupron-Depot" = "lupron", "Relafen 700 mg" = "NSAID", "Lupron x 3 months" = "lupron", "Hysterectomy" = "hysterectomy","Laser ablation" = "Laser", "OCP's" = "OCP", "Danocrine," = "Danazol", "Surgery (total)" = "surgery", "Lupron 3.75" = "lupron","Lupron x 3 months " = "lupron",  "Lupron" = "lupron", "don't remember" = "98", "OCPs (Triphasil-28)" = "OCP","OCP's   Ortonovum" = "OCP", "Depo Provera" = "depo-provera", "Depo-Provera" = "depo-provera","Depo-provera," = "depo-provera", "Depo-provera" = "depo-provera", "Depro-povera" = "depo-provera", "Depo-Provera" = "depo-provera", "lupron (6 months)" = "lupron", "Lupron" = "lupron", "'Lupron Depot" = "lupron","Lupron Depot 3.75mgs." = "lupron","Lupron 3.75mgs." = "lupron", "Lupron  x 1 year" = "lupron", "Naprozen" = "NSAID", "Lepot-Depot" = "lupron", "'Lupron" = "lupron", "Lupron ," = "lupron", "Lupron depot 3.75" = "lupron", "Lupron 3.75mg" = "lupron", "Lupron depot" = "lupron", "Lupron Depot" = "lupron", "Lupron Depot 3.75" = "lupron", "Lupron dupot 3.75" = "lupron", "Lupron 3.75 mg" = "lupron", "Lupron 3.75 mg" = "lupron", "lupron (6 months)" = "lupron", "Lupron 11.25mgs" = "lupron", "Lurpon depot 3.75" = "lupron", "Lupron-2001" = "lupron", "Lupron x 1 year" = "lupron", "'Lupron ," = "lupron", "Lupron," = "lupron", "Lupron Deport 3.75mgs" = "lupron", "lupron," = "lupron", "Motrin" = "NSAID", "NSAID's" = "NSAID", "don't remember" = "98", "Danazol/Danocrine" = "Danazol", "Danocrine/ Danazol" = "Danazol", "Danazol 600mgs" = "Danazol", "Danocrin" = "Danazol", "Danazol x 3 months" = "Danazol", "Danocrine/Danazol" = "Danazol", "danazol &" = "Danazol", "danazol" = "Danazol", "DANAZOL" = "Danazol", "danazol 500" = "Danazol", "Danocrine" = "Danazol", "TAH + BSO" = "TAH and BSO", "TAH-BSO" = "TAH and BSO", "TAH / BSO" = "TAH and BSO", "Hysterectomy total" = "hysterectomy", "Lupron  x 1 year" = "lupron", "lapaorscopy" = "laparoscopy", ",  Syderal" = "Synarel" )) %>%
  mutate(Tx_4=recode(Tx_4, "toradol" = "NSAID", "Provera" = "Depo-provera")) %>%
  mutate(Fam_HX_relation=recode(Fam_HX_relation, "grandmother" = "grandma", "hemana" = "sister")) %>%
  mutate(other_birth_control_1=recode(other_birth_control_1, "Rythm,  Comdoms" = "condoms, rythm", "Comdoms,  Rythm" = "condoms, rythm", "Comdoms & Rythm" = "condoms, rythm", "Comdoms" = "condoms", "Comdoms/Rythm" = "condoms, rythm", "Comdoms, Rythm" = "condoms, rythm", "Rythm" = "rythm", "Rythm, Comdoms" = "condoms, rythm", "99" = "98", "Comdoms (masculinos)" = "condoms", "Comdoms-Rythm" = "condoms, rythm", "Oc's" = "OCP", "Rythm, Comdoms" = "condoms, rythm", "pastilas" = "98", "ortho tricylenlo" = "OCP", "alis" = "98", "Comdoms,  Rythm, osc" = "condoms, rythm" ))
Endo_Clean_Recode_2

#Making new columns for health conditions
Endo_Clean_Recode_2$asthma <- 0
Endo_Clean_Recode_2$joint <- 0
Endo_Clean_Recode_2$IBS <- 0
Endo_Clean_Recode_2$allerg <- 0
Endo_Clean_Recode_2$constipation <- 0
Endo_Clean_Recode_2$arthritis <- 0
Endo_Clean_Recode_2$depression <- 0
Endo_Clean_Recode_2$fatigue <- 0
Endo_Clean_Recode_2$hyperglycemia <- 0
Endo_Clean_Recode_2$hypoglycemia <- 0
Endo_Clean_Recode_2$diabetes <- 0
Endo_Clean_Recode_2$hyperthyroid <- 0
Endo_Clean_Recode_2$hypothyroid <- 0
Endo_Clean_Recode_2$fibromyalgia <- 0
Endo_Clean_Recode_2$PMS <- 0
Endo_Clean_Recode_2$candidiasis <- 0
Endo_Clean_Recode_2$herpes <- 0
Endo_Clean_Recode_2$kidney <- 0 #kidney disease and kidney stones
Endo_Clean_Recode_2$sinusitis <- 0
Endo_Clean_Recode_2$MS <- 0
Endo_Clean_Recode_2$palpitations <- 0
Endo_Clean_Recode_2$MVP <- 0
Endo_Clean_Recode_2$infections <- 0
Endo_Clean_Recode_2$gastritis <- 0
Endo_Clean_Recode_2$lupus <- 0
Endo_Clean_Recode_2$PIV <- 0 #might be PID??
Endo_Clean_Recode_2$PMS <- 0
Endo_Clean_Recode_2$hyperprolactinemia <- 0
Endo_Clean_Recode_2$appendicitis <- 0
Endo_Clean_Recode_2$fatty <- 0 #fatty liver
Endo_Clean_Recode_2$arrythmias <- 0
Endo_Clean_Recode_2$thyroid <- 0 #includes thyroid disease, hyperthyroidism, hypothyroidism
Endo_Clean_Recode_2$carcinoma <- 0
Endo_Clean_Recode_2$herniated <- 0
Endo_Clean_Recode_2$retroverted <- 0 #retroverted uterus
Endo_Clean_Recode_2$pressure <- 0 #blood pressure
Endo_Clean_Recode_2$cholesterol <- 0 
Endo_Clean_Recode_2$HBP <- 0
Endo_Clean_Recode_2$acne <- 0
Endo_Clean_Recode_2$hirsutism <- 0
Endo_Clean_Recode_2$UTI <- 0
Endo_Clean_Recode_2$chron <- 0 #chron's disease
Endo_Clean_Recode_2$OA <- 0 #unsure what this is
Endo_Clean_Recode_2$CBD <- 0
Endo_Clean_Recode_2$colitis <- 0
Endo_Clean_Recode_2$murmur <- 0
Endo_Clean_Recode_2$aches <- 0 #muscle aches
Endo_Clean_Recode_2$tricupsid <- 0 #tricupsid valve regurgitation
Endo_Clean_Recode_2$PID <- 0 
Endo_Clean_Recode_2$osteoporosis <- 0
Endo_Clean_Recode_2$divertic <- 0 #diverticulitis
Endo_Clean_Recode_2$factor <- 0 #factor VII
Endo_Clean_Recode_2$hemorrhoids <- 0 
Endo_Clean_Recode_2$endometrioma <- 0 
Endo_Clean_Recode_2$PCOS <- 0 
Endo_Clean_Recode_2$reflux <- 0 #acid reflux
Endo_Clean_Recode_2$scoliosis <- 0
Endo_Clean_Recode_2$hyperplasia <- 0
Endo_Clean_Recode_2$lymphocytosis <- 0
Endo_Clean_Recode_2$nephritis <- 0
Endo_Clean_Recode_2$hyperlipidemia <- 0 
Endo_Clean_Recode_2$hydrosalpinx <- 0
Endo_Clean_Recode_2$CFS <- 0 #unsure what this is
Endo_Clean_Recode_2$anemia <- 0
Endo_Clean_Recode_2$psoriasis <- 0
Endo_Clean_Recode_2$hypertension <- 0
Endo_Clean_Recode_2$chest <- 0 #chest pain
Endo_Clean_Recode_2$rheumatic <- 0 #rheumatic fever
Endo_Clean_Recode_2$fibrilation <- 0
Endo_Clean_Recode_2$duodenitis <- 0 
Endo_Clean_Recode_2$inflammation <- 0 #pelvic inflammation search in excel
Endo_Clean_Recode_2$ulcers <- 0
Endo_Clean_Recode_2$hypertension <- 0
Endo_Clean_Recode_2$HTN <- 0 

#Create new columns for each endometriosis symptom
Endo_Clean_Recode_2$CPP <- 0
Endo_Clean_Recode_2$leg <- 0 #leg pain
Endo_Clean_Recode_2$infertility <- 0
Endo_Clean_Recode_2$irregular <- 0 #irregular bleeding
Endo_Clean_Recode_2$bloating <- 0
Endo_Clean_Recode_2$dysmenorr <- 0
Endo_Clean_Recode_2$dyspareun <- 0
Endo_Clean_Recode_2$diarrhea <- 0
Endo_Clean_Recode_2$vomiting <- 0
Endo_Clean_Recode_2$back <- 0 #back pain
Endo_Clean_Recode_2$asymptomatic <- 0
Endo_Clean_Recode_2$urina <- 0 #pain during urination
Endo_Clean_Recode_2$sickness <- 0
Endo_Clean_Recode_2$evacuating <- 0 #pain when evacuating
Endo_Clean_Recode_2$pelvic <- 0 #pelvic pain
Endo_Clean_Recode_2$profuse <- 0 #profuse bleeding
Endo_Clean_Recode_2$musc <- 0 #muscle pain
Endo_Clean_Recode_2$PID <- 0
Endo_Clean_Recode_2$headaches <- 0
Endo_Clean_Recode_2$dizziness <- 0
Endo_Clean_Recode_2$insomnia <- 0
Endo_Clean_Recode_2$dyschezia <- 0
Endo_Clean_Recode_2$vaginal <- 0 #vaginal pain
Endo_Clean_Recode_2$abdominal <- 0 #abdominal pain
Endo_Clean_Recode_2$sensitivity <- 0 #unsure what this means?
Endo_Clean_Recode_2$fatigue <- 0 #pelvic pain
Endo_Clean_Recode_2$resistance <- 0 #low resistance to infections
Endo_Clean_Recode_2$energy <- 0 #low energy
Endo_Clean_Recode_2$intestinal <- 0 #intestinal discomfort
Endo_Clean_Recode_2$depression <- 0
Endo_Clean_Recode_2$bowel <- 0 #pain with bowel
Endo_Clean_Recode_2$resentful <- 0 #resentful stomach
Endo_Clean_Recode_2$abortion <- 0 #abortions (why is this a symptom? might mean miscarriages)
Endo_Clean_Recode_2$sensibility <- 0 #unsure what this means
Endo_Clean_Recode_2$nausea <- 0
Endo_Clean_Recode_2$skeletal <- 0 #skeletal pain

#create new column for family HX relationship
Endo_Clean_Recode_2$mother <- 0 
Endo_Clean_Recode_2$sister <- 0
Endo_Clean_Recode_2$cousin <- 0
Endo_Clean_Recode_2$niece <- 0
Endo_Clean_Recode_2$daughter <- 0
Endo_Clean_Recode_2$grandma <- 0
Endo_Clean_Recode_2$aunt <- 0

#For loop to assign "1" to people with the conditions specified in columns 82-153
for (column in colnames(Endo_Clean_Recode_2)[82:153]) {
  Endo_Clean_Recode_2[grep(column, Endo_Clean_Recode_2$Other_Conditions_Table, ignore.case = FALSE), column] <- 1
}

#For loop to assign "1" to people with the symptoms specified in columns 157-186
for (column in colnames(Endo_Clean_Recode_2)[154:186]) {
  Endo_Clean_Recode_2[grep(column, Endo_Clean_Recode_2$Other_symptoms, ignore.case = FALSE), column] <- 1
}

#For loop to assign "1" to people with the family history specified in columns 187-193
for (column in colnames(Endo_Clean_Recode_2)[187:193]) {
  Endo_Clean_Recode_2[grep(column, Endo_Clean_Recode_2$Fam_HX_relation, ignore.case = FALSE), column] <- 1
}


categories <- unique(Endo_Clean_Recode_2$other_birth_control_1)
categories


#export summary of data into cvs
write.csv(Endo_Clean_Recode_2, "Endo Cleaned ES.csv") 


