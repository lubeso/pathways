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

# +
m = folium.Map(location = loc)

commute = folium.Choropleth(
    geo_data = geo_url,
    data     = ctracts,
    columns  = ['tract','travel_time'],
    key_on   = 'feature.properties.tract',
    fill_color = 'Oranges',
    fill_opacity = 0.8,
    line_color = '#000000',
    line_weight = 0.3,
    line_opacity = 0.6,
    legend_name = 'Average Commute (minutes)',
    highlight = True,
    name = 'Average commute',
    bins = [10,30,50,70,90,110,130]
).add_to(m)

folium.GeoJson(
    geo_url,
    name = 'Average Commute',
    style_function = lambda x : {'opacity' : 0.0, 'fillOpacity' : 0.0},
    tooltip = folium.GeoJsonTooltip(
        fields = ['name','travel_time','median_income','beeswarm'],
        aliases = ['Neighborhood:','Average Commute:','Median Income:',''],
        style = 'width: 300px; height: 350px;',
        localize = True,
    )
).add_to(commute)

folium.LayerControl().add_to(m)
# -

m

m.save('interact.html')
