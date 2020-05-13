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

from geopy.geocoders import ArcGIS; ag = ArcGIS()
import pandas as pd; import json
import folium; import branca

# +
r = ag.geocode('New York, NY, US'); loc = [r.latitude, r.longitude]
geo_url = '../../data/geo/ctracts-minus-staten.geojson'
csv_url = '../../data/info/ctracts.csv'

ctracts = pd.read_csv(csv_url)
# -

cmp = branca.colormap.LinearColormap(
    colors = [
        (0.102,0.588,0.255,1.0),
        (0.651,0.851,0.416,1.0),
        (0.992,0.682,0.380,1.0),
        (0.843,0.098,0.110,1.0)
    ],
    index = [10,50,90,130],
    vmin = 10, vmax = 130    
)
cmp.caption = 'Average Commute (minutes)'

# +
m = folium.Map(location = loc,
               zoom_start = 11)

cmp.add_to(m)

def style(feature):
    ttime = feature['properties']['travel_time']
    return {
        'weight' : 0.3,
        'color' : 'white',
        'opacity' : 0.6,
        'fillOpacity': 0.8,
        'fillColor' : '#ffffff00' if ttime is None else cmp(ttime)
    }

folium.GeoJson(
    geo_url,
    name = 'Average Commute',
    style_function = style,
    tooltip = folium.GeoJsonTooltip(
        fields = ['name','travel_time','median_income','beeswarm'],
        aliases = ['Neighborhood:','Average Commute:','Median Income:',''],
        style = 'width: 300px; height: 350px;',
        localize = True,
    )
).add_to(m)

folium.LayerControl().add_to(m)
# -

m

m.save('../html/src/traveltime.html')
