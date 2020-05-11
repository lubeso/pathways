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

import requests; get = requests.get
import pandas as pd
import json


# +
def colnames(cols,d):
    for i in range(len(cols)):
        if cols[i] in d:
            cols[i] = d[cols[i]]
    return cols

def borocode(rows,c):
    for i in range(len(rows)):
        rows[i][-1] = c + rows[i][-1]
    return rows


# +
url = 'https://api.census.gov/data/2016/acs/acs5?get='
qry = 'NAME,'
crd = '&key=42c4af5849c25e45cab5add011a9e440505d4148'

# grade
codes = ['B14001_007E','B14002_017E','B14002_018E','B14002_041E','B14002_042E']; ncode = len(codes)
types = ['Total', 'Male (Public)','Male (Private)','Female (Public)','Female (Private)']
dtype = {codes[i] : types[i] for i in range(ncode)}
for i in range(ncode):
    qry += codes[i]
    if i != (ncode - 1):
        qry += ','

# +
url = 'https://api.census.gov/data/2016/acs/acs5?get='
qry = 'NAME,'
crd = '&key=42c4af5849c25e45cab5add011a9e440505d4148'

# race
codes = [f'B02001_00{i}E' for i in range(1,9)]; ncode = len(codes)
types = ['Total', 'White', 'Black', 'Indigenous', 'Asian', 'Pacific Islander', 'Other', 'Multiracial']
dtype = {codes[i] : types[i] for i in range(ncode)}
for i in range(ncode):
    qry += codes[i]
    if i != (ncode - 1):
        qry += ','

# +
url = 'https://api.census.gov/data/2016/acs/acs5?get='
qry = 'NAME,'
crd = '&key=42c4af5849c25e45cab5add011a9e440505d4148'

# income
codes = [f'B19001_00{i}E' for i in range(1,10)]
codes.extend([f'B19001_0{i}E' for i in range(10,18)])
ncode = len(codes)
types = ['Total',"<$10,000","$10,000-$14,999","$15,000-$19,999","$20,000-$24,999",
         "$25,000-$29,999","$30,000-$34,999","$35,000-$39,999","$40,000-$44,999",
         "$45,000-$49,999","$50,000-$59,999","$60,000-$74,999","$75,000-$99,999",
         "$100,000-$124,999","$125,000-$149,999","$150,000-$199,999","$200,000+"]
dtype = {codes[i] : types[i] for i in range(ncode)}
for i in range(ncode):
    qry += codes[i]
    if i != (ncode - 1):
        qry += ','

# +
# Manhattan (New York County)
# borough code: 1
loc = '&for=tract:*&in=state:36&in=county:061'
full = url + qry + loc + crd; r = get(full); rj = r.json()

# decode column names
cols = rj[0]; cols = colnames(cols,dtype)

# append borough code
manhattan = rj[1:]; manhattan = borocode(manhattan, '1')

# +
# The Bronx (Bronx County)
# borough code: 2
loc = '&for=tract:*&in=state:36&in=county:005'
full = url + qry + loc + crd; r = get(full); rj = r.json()

# decode column names
cols = rj[0]; colnames(cols,dtype)

# append borough code
bronx = rj[1:]; bronx = borocode(bronx, '2')

# +
# Brooklyn (Kings County)
# borough code: 3
loc = '&for=tract:*&in=state:36&in=county:047'
full = url + qry + loc + crd; r = get(full); rj = r.json()

# decode column names
cols = rj[0]; cols = colnames(cols,dtype)

# append borough code
brooklyn = rj[1:]; brooklyn = borocode(brooklyn, '3')

# +
# Queens (Queens County)
# borough code: 4
loc = '&for=tract:*&in=state:36&in=county:081'
full = url + qry + loc + crd; r = get(full); rj = r.json()

# decode column names
cols = rj[0]; cols = colnames(cols,dtype)

# append borough code
queens = rj[1:]; queens = borocode(queens, '4')

# +
# Staten Island (Richmond County)
# borough code: 5
loc = '&for=tract:*&in=state:36&in=county:085'
full = url + qry + loc + crd; r = get(full); rj = r.json()

# decode column names
cols = colnames(rj[0],dtype)

# append borough code
staten = rj[1:]; staten = borocode(staten, '5')
# -

rows = manhattan[:]
rows.extend(bronx)
rows.extend(brooklyn)
rows.extend(queens)
rows.extend(staten)

ct = pd.DataFrame(rows, columns = cols); ct.head()

ct.to_csv('../../data/info/ctincome.csv', index = False)
