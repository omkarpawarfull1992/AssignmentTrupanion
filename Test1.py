# Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import datetime as dt

#Import Data
df=pd.read_csv('Data.csv')
df['Prev1Claim'].fillna(0,inplace=True)
df['Prev2Claim'].fillna(0,inplace=True)

df['PreClaimMonthDiff'].fillna(-1,inplace=True)
df['PrePreClaimMonthDiff'].fillna(-2,inplace=True)

df['EnrollDate'] = pd.to_datetime(df['EnrollDate'])
df['EnrollDate']=df['EnrollDate'].map(dt.datetime.toordinal)

df['ClaimDate'] = pd.to_datetime(df['ClaimDate'])
df['ClaimDate']=df['ClaimDate'].map(dt.datetime.toordinal)

#Plotting Graph
import matplotlib.pyplot as plt
%matplotlib qt
plt.plot(df['ClaimDate'],df['ClaimPerMonth'])
plt.ylabel('some numbers')
plt.show()

#DEfining indipendent and dependent variables
X = df[['EnrollDate', 'Species', 'Breed', 'AgeAtEnroll', 'Prev1Claim',
       'Prev2Claim', 'ClaimRSum', 'MonthAfterEnroll',
       'ClaimDate', 'PreClaimMonthDiff', 'PrePreClaimMonthDiff']].values
y = df[['ClaimPerMonth']].values

# Encoding categorical data
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
labelencoderS = LabelEncoder()
X[:,1] = labelencoderS.fit_transform(X[:,1])
labelencoderB = LabelEncoder()
X[:,2] = labelencoderB.fit_transform(X[:,2])
labelencoderA = LabelEncoder()
X[:,3] = labelencoderA.fit_transform(X[:,3])

# Splitting the dataset into the Training set and Test set
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

# Fitting Random Forest Regression to the dataset
from sklearn.ensemble import RandomForestRegressor
regressor = RandomForestRegressor(n_estimators = 1000,n_jobs=-1, random_state = 0)
regressor.fit(X_train, y_train)

# Predicting a new result
y_pred = regressor.predict(X_test)