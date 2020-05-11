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
minc   = rd("../../data/info/ctmedian-income.csv") |> DataFrame;

S = findall(n -> string(n)[1] == '5', tracts[:,:tract]); deleterows!(tracts, S);

# +
nj = OrderedDict(); nj["type"] = "FeatureCollection"; 
k = findall(n -> !occursin("park-cemetery-etc",n) && !occursin("Airport",n),tracts[:,:name])
n = names(tracts)
feats = []; url = "https://lubeso.github.io/pathways/figs"

for i ∈ k
    feat = OrderedDict("properties" => OrderedDict(),
                "geometry" => OrderedDict(),
                "type" => "Feature")
    for name ∈ n
        feat["properties"][String(name)] = tracts[i,name]
    end
    
    feat["properties"]["beeswarm"] = 
    "<img src='$url/$(tracts[i,:tract]).svg' height = '300' width = '300'>"
    
    geom = LibGEOS._readgeom(tracts[i,:geometry])
    poly = LibGEOS.MultiPolygon(geom) |> GeoInterface.MultiPolygon
    feat["geometry"]["coordinates"] = poly.coordinates
    feat["geometry"]["type"] = "MultiPolygon"
    
    push!(feats, feat)
end

nj["features"] = feats;
# -

open("../../data/geo/ctracts-minus-staten.geojson", "w") do f
    write(f, JSON.json(nj))
end
