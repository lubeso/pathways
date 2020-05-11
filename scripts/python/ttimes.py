# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.4.2
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

# +
# import necessary libraries
import os; import dotenv; 
import requests; import json
import pandas as pd
import numpy as np

# load .env file
dotenv.load_dotenv()
# -

# load authentication credentials
KEY = os.getenv('TTKEY')
ID  = os.getenv('TTAPP')

# load datasets
ct = pd.read_csv('../../data/geo/ct2010-centroids.csv'); T = ct.shape[0]
sc = pd.read_csv('../../data/school/hs-directory.csv'); S = sc.shape[0]

# POST request header
H = {'Host' : 'api.traveltimeapp.com',
     'Content-Type' : 'application/json',
     'Accept' : 'application/json',
     'X-Application-Id' : ID,
     'X-Api-Key' : KEY}

# Morning departure time, maximum travel time of 2.5 hours
dtime = '2020-04-23T08:00:00-05'; ttime = 9000

# JSON skeleton
param = {
         'locations' : [
            {'id' : str(ct.loc[0,'BoroCT2010']),
             'coords' : {
                 'lat' : ct.loc[0,'centroid_lat'],
                 'lng' : ct.loc[0,'centroid_lon']
             }}
        ],
        'departure_searches' : [
            {'id' : 'forward search',
             'departure_location_id' : str(ct.loc[0,'BoroCT2010']),
             'arrival_location_ids' : [],
             'transportation' : {
                 'type' : 'public_transport'
             },
             'departure_time' : dtime,
             'travel_time' : ttime,
             'properties' : ['travel_time']
            }
        ]}

# Add school locations
for i in range(S):
    aid = sc.loc[i,'dbn']
    lat = sc.loc[i,'Latitude']; lng = sc.loc[i,'Longitude']
    d = {'id' : aid, 'coords' : {'lat' : lat, 'lng' : lng}}
    param['locations'].append(d)
    param['departure_searches'][0]['arrival_location_ids'].append(aid)

# send request
url = 'http://api.traveltimeapp.com/v4/time-filter'
r = requests.post(url,headers=H,json=param)

# save response
j = r.json()
with open(str(ct.loc[0,'BoroCT2010'])+'.json', 'w', encoding='utf-8') as f:
    json.dump(j, f, ensure_ascii=False, indent=4, sort_keys=True)


def skeleton(ct,i):
    params = {
         'locations' : [
            {'id' : str(ct.loc[i,'BoroCT2010']),
             'coords' : {
                 'lat' : ct.loc[i,'centroid_lon'],
                 'lng' : ct.loc[i,'centroid_lat']
             }}
        ],
        'departure_searches' : [
            {'id' : 'forward search',
             'departure_location_id' : str(ct.loc[i,'BoroCT2010']),
             'arrival_location_ids' : [],
             'transportation' : {
                 'type' : 'public_transport'
             },
             'departure_time' : dtime,
             'travel_time' : ttime,
             'properties' : ['travel_time']
            }
        ]}
    return params


def fill(params):
    for j in range(S):
        aid = sc.loc[j,'dbn']
        lat = sc.loc[j,'Latitude']; lng = sc.loc[j,'Longitude']
        d = {'id' : aid, 'coords' : {'lat' : lat, 'lng' : lng}}
        params['locations'].append(d)
        params['departure_searches'][0]['arrival_location_ids'].append(aid)
    return params


def saveJSON(i,r):
    j = r.json()
    with open('jsons/'+str(ct.loc[i,'BoroCT2010'])+'.json', 'w', encoding='utf-8') as f:
        json.dump(j, f, ensure_ascii=False, indent=4, sort_keys=True)


from time import sleep; last = 1

for i in range(1533,T):
    last = i
    print(f'{i}...\n')
    params = skeleton(ct,i)
    params = fill(params)
    r = requests.post(url, headers=H, json=params)
    if r.status_code == 200:
        saveJSON(i,r); sleep(10)
    else:
        failed.append(i)
