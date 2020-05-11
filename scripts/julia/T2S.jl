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

using CSV, DataFrames; rd, wr = CSV.read, CSV.write
using JSON, GeoJSON, GeoInterface, LibGEOS
using StatsBase, DataStructures

ctracts = rd("../../data/info/ctracts.csv") |> DataFrame; tracts = ctracts[:,:tract]
schools = rd("../../data/school/hs-directory.csv") |> DataFrame; codes = schools[:,:dbn]
achieve = rd("../../data/school/2019-student-achievement.csv") |> DataFrame; names(achieve)

A = Set(achieve[:,:DBN]); C = Set(codes); AnC = A ∩ C;
ainds = findall(c -> !(c in AnC), achieve[:,:DBN])
sinds = findall(c -> !(c in AnC), codes)
deleterows!(achieve,ainds); deleterows!(schools,sinds)
@assert nrow(achieve) == nrow(schools)

sort!(achieve, [:DBN]); sort!(schools, [:dbn])

ptr = [LibGEOS.Point(schools[i,:Longitude],schools[i,:Latitude]) for i in 1:nrow(schools)]
pts = LibGEOS.writegeom.(ptr)
ratings = DataFrame(:dbn => schools[:,:dbn],
                    :score => achieve[:,Symbol("Student Achievement - Section Score")],
                    :geometry => pts); first(ratings,6)

dbns = ratings[:,:dbn]; scores = ratings[:,:score]; geoms = ratings[:,:geometry]
for tract in tracts
    S = OrderedDict([(dbn => NaN) for dbn in dbns]...)
    try
        J = JSON.Parser.parsefile("../python/jsons/$tract.json")
        R = J["results"][1]; L = R["locations"]
        for l ∈ L
            dbn = l["id"]
            if dbn ∈ dbns
                S[dbn] = l["properties"][1]["travel_time"] / 60
            end
        end
    catch
        @warn "$tract not found...."
    end
    D = DataFrame(:dbn => dbns, :score => scores, 
                    :travel_time => collect(values(S)), :geom => geoms)
    D |> wr("csvs/$tract.csv")
end
