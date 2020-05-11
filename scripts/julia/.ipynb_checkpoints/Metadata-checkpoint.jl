# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.4.2
#   kernelspec:
#     display_name: Julia 1.4.0
#     language: julia
#     name: julia-1.4
# ---

using JSON, CSV, DataFrames; rd, wr = CSV.read, CSV.write
using GeoInterface, LibGEOS, GeoJSON
using DataStructures

tracts = rd("../../data/info/ctracts.csv") |> DataFrame;
minc   = rd("../../data/info/ctmean-income.csv") |> DataFrame;

# +
nj = OrderedDict(); nj["type"] = "FeatureCollection"; 
k = nrow(tracts); n = names(tracts)[1:end-1]
feats = []

for i ∈ 1:k
    feat = OrderedDict("properties" => OrderedDict(),
                "geometry" => OrderedDict(),
                "type" => "Feature")
    for name ∈ n
        feat["properties"][String(name)] = tracts[i,name]
    end
    
    feat["properties"]["beeswarm"] = 
    "<img src='../../figs/beeswarms/$(tracts[i,:tract]).svg' height = '300' width = '300'>"
    
    geom = LibGEOS._readgeom(tracts[i,:geometry])
    poly = LibGEOS.MultiPolygon(geom) |> GeoInterface.MultiPolygon
    feat["geometry"]["coordinates"] = poly.coordinates
    feat["geometry"]["type"] = "MultiPolygon"
    
    push!(feats, feat)
end

nj["features"] = feats;
# -

open("../../data/geo/ctracts.geojson", "w") do f
    write(f, JSON.json(nj))
end
