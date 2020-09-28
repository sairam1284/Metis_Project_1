# Project One: Metropolitan Transportation Authority

In this project we explore public data provided by the New York City Metropolitan Transportation Authority (MTA). Our goal is to consult WomenTechWomenYes (WTWY) on their street canvassing strategy targeting subway stations in NYC. Their street teams will work to build awareness and reach by gathering signatures and commitments to attend their gala aimed at increasing the participation of women in technology. We will quantify optimal locations based on:

1. Station traffic
2. Time series patterns
3. Demographic data provided by the United States Census. 

We will consider MTA turnstile data from August 3rd, 2019 to October 3rd, 2019 as the appropriate window before their Fall 2020 gala. This data is filtered to remove errors and inconsistencies in the reporting process. Included in this depository are behind the scenes data cleaning and filtering methods used in our analysis. During our designated time frame, we analyze the busiest stations, weekday vs. weekend traffic, and daily time trends.   

In our final reccomendations, we suggest stations based on pure traffic to increase awareness and also stations based on appropriate demographics to target the most likely commitments. To this extent, we have created a scoring model with adjustable weights to quantify optimimal cavassing locations.   

Note that the file 'Final_Project_Markdown.ipynb' contains the final code for much of the project.

The 'MTA_Data_Cleaning.ipynb' and 'Daily_Trends_Dataframe.ipynb' provide code for building the necessary datasets for the analysis.

The 'formulas.py' contains several functions used in the notebooks.



















