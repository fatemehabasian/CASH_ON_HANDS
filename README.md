
# Cash-on-Hand and Competing Models of Intertemporal Behavior: Replication Code

## Overview

This repository contains the replication code for the paper **"Cash-on-Hand and Competing Models of Intertemporal Behavior: New Evidence from the Labor Market"** by David Card, Raj Chetty, and Andrea Weber. The replication was conducted by **Fatemeh Abbasian-Abyaneh** on **April 24, 2024**.

### Paper Overview

The paper investigates how unemployed individuals make intertemporal choices—decisions involving trade-offs between costs and benefits at different times—using data from the Austrian labor market. It examines how access to liquidity (cash-on-hand) influences job search behavior and responses to unemployment insurance (UI) benefits.

#### Key Findings:
- **Impact of Cash-on-Hand**: Individuals with more cash-on-hand tend to remain unemployed longer, likely because they can afford to be more selective in their job search.
- **Severance Pay**: Eligibility for severance pay increases the duration of unemployment, especially for workers with shorter job tenures.
- **Extended UI Benefits**: Extended UI benefits lead to longer unemployment durations, though less significantly than cash-on-hand.
- **Job Tenure**: There is a non-linear relationship between job tenure and unemployment duration, with mid-tenure workers being most affected by liquidity.

### Replication Code Summary

The replication code in this repository reproduces the key figures and tables from the original paper using detailed datasets from Austrian labor market records.


#### Key Figures:
- **Figure 2a**: Fraction eligible for extended UI benefits by job tenure.
- **Figure 2b**: Eligibility for severance pay by past employment.
- **Figures 3 to 7**: Various analyses on unemployment durations, job search behavior, and more.

#### Key Tables:
- **Table 2**: Results of Cox proportional hazard models assessing the effects of severance pay and extended UI benefits on job search durations.

## Instructions

### Prerequisites
- Stata (version 14 or higher)

### Running the Code
1. **Set Working Directory**: Replace `"ENTER YOUR PATH OF CHOICE"` in the code with your working directory path.
2. **Load Datasets**: Ensure the `sample_75_02.dta` and `work_history.dta` datasets are in the working directory.
3. **Execute the Replication Code**: Run the `replication_code.do` file in Stata to generate the figures and tables.

### Outputs
- **Figures**: The code generates figures that are saved as PNG files in the working directory.
- **Tables**: The code outputs the results of the hazard models directly in Stata, with the ability to save them as desired.

## Notes

The replication code includes all necessary adjustments for potential seasonality and controls for observed characteristics to ensure robustness. The code is structured for easy replication and adaptation to similar datasets.

## Contact

For any issues or questions regarding this replication code, please contact Fatemeh Abbasian-Abyaneh at [your email].

## Acknowledgments

This project is a replication of the work by David Card, Raj Chetty, and Andrea Weber. All credit for the original analysis and findings belongs to them.

