# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: -all
#     formats: jl:light,ipynb
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

# load necessary packages
using CSV, DataFrames; rd, wr = CSV.read, CSV.write
using JSON, GeoJSON, DataStructures
using StatsBase, NaNMath; nm = NaNMath

ctrax = rd("../../data/geo/ct2010.csv") |> DataFrame; tag = :BoroCT2010
fails = rd("../python/failed.csv") |> DataFrame; fs = fails[:,:failed]
T = ctrax[:,tag]; n = length(T); avgs = OrderedDict()
;

DIR = "../python/jsons/"; Fs = Int[]
for i ∈ 1:n
    t = T[i];
    try
        f = JSON.Parser.parsefile("$DIR$t.json")
        pull = f["results"][1]; locs = pull["locations"]
        time = [loc["properties"][1]["travel_time"] for loc in locs]
        time = convert(Array{Float64,1},time)
        if "unreachable" in keys(pull)
            push!(time,[NaN for i ∈ length(pull["unreachable"])]...)
        end
        avgs[t] = nm.mean(time./60)
    catch
        @warn "$t not found..."
        avgs[t] = NaN
        push!(Fs,t)
    end
end
insertcols!(ctrax,ncol(ctrax)+1,:travel_time => [v for v in values(avgs)])

ctrax |> wr("../../data/info/cttimes.csv")

jtrax = JSON.Parser.parsefile("data/geo/ct2010.geojson")

FT = jtrax["features"]; k = length(FT)
for i ∈ 1:k
	code = FT[i]["properties"]["boro_ct2010"]; code = Base.parse(Int,code)
	!(code in Fs) ? ttime = avgs[code] : ttime = NaN
    jtrax["features"][i]["properties"]["travel_time"] = ttime
end

open("data/geo/cttimes.geojson", "w") do f
	write(f, JSON.json(jtrax))
end
