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
    fill_color = 'Purples',
    fill_opacity = 0.7,
    line_color = '#5b94eb',
    line_weight = 0.7,
    legend_name = 'Average Commute (minutes)',
    highlight = True,
    name = 'Average commute',
).add_to(m)

folium.GeoJson(
    geo_url,
    name = 'Average Commute',
    style_function = lambda x : {'opacity' : 0.0, 'fillOpacity' : 0.0},
    tooltip = folium.GeoJsonTooltip(
        fields = ['name','travel_time','public','beeswarm'],
        aliases = ['Neighborhood:','Average Commute:','Public school enrollment:',''],
        style = 'width: 300px; height: 350px;',
        localize = True,
    )
).add_to(commute)

folium.LayerControl().add_to(m)
# -

m
