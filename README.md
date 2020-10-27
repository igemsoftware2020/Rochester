# Rochester
Our Rochester team has five modeling projects and two software projects for iGEM 2020.
To learn more about our project, see our wiki: https://2020.igem.org/Team:Rochester.

## Model
### Clinical Predictive Model
To improve endometriosis diagnostics, our team created a model to assess endometriosis risk from clinical variables by using machine learning on a dataset of 756 patients. The "Cleaning Predictive Model Data.R" script was used to transform the raw dataset into a form readable by the machine learning script "Endometriosis Predictive Model.R".

Our team developed lateral flow assays (LFA) to measure levels of endometriosis biomarkers in menstrual blood, thereby diagnosing endometriosis. The Sensitivity & Specificity, Antibody, and LFA Model were created in support of assay development.

### Sensitivity & Specificity
There are 12 biomarkers for endometriosis in peripheral blood and menstrual effluent reported in literature. Our modeling team used combined log odds ratios to find the best combination of three biomarkers that contribute the most to the diagnostic accuracy of our test panel.

### Antibody Modeling
An LFA requires two antibodies that can bind to the target biomarker simultaneously. We used Rosetta software to predict the epitopes of 14 candidate antibodies for four biomarkers, and identified antibody pairs to be used in our assay. The workflow is "relax.sh", "prepack.sh", "snugdock.sh".

### LFA Model
In designing our LFAs, we developed a model to find the optimal test line position and reagent concentrations, using the "Rochester_LFA_Model.m" script. We planned to parameter fit our experimental data to our model using the "Rochester_LFA_Model_DataFit.m" script.

### ERE Model
To develop endometriosis diagnostics, our team designed an estrogen sensing circuit. We created an ODE model of the circuit to find the optimal promoter strength and plasmid copy number for this circuit.

## Software
### Biomarker Database
To support future iGEM teams in the Diagnostics Track, we created a software collecting biomarkers that have been used in iGEM. Users can contribute to the database or search for potential biomarkers of the disease they want to study.

### Endometriosis Risk Calculator
We integrated our Clinical Predictive Model into a web UI where users can fill out an anonymous survey, and find out their risk of endometriosis from their answers.

## Hardware
### LFA imaging station Light
Code to for the LFA imaging station, controlling an LED using a potentiometer

### Centrifuge control
Code to control the centrifuge's speed using a keypad

