# -*- coding: utf-8 -*-
# load necessary packages
using CSV, DataFrames; rd, wr = CSV.read, CSV.write
using JSON, GeoJSON, DataStructures
using StatsBase

ctrax = rd("data/geo/ct2010.csv"); tag = :BoroCT2010
fails = rd("scripts/python/failed.csv"); fs = fails[:,:failed]

T = ctrax[:,tag]; n = length(T)
# avgs = OrderedDict([t => 0.0 for t in T]...)
avgs = OrderedDict()

path = "scripts/python/jsons/"; Fs = Int[]
for i ∈ 1:n
	t = T[i];
	try
		f = JSON.Parser.parsefile("$path$t.json")
		pull = f["results"][1]; locs = pull["locations"]
		time = [loc["properties"][1]["travel_time"] for loc in locs]
		if "unreachable" in keys(pull)
			push!(time,[9000 for i ∈ length(pull["unreachable"])]...)
		end
		avgs[t] = mean(time./60)
	catch
		@warn "$t not found..."
        avgs[t] = NaN
		push!(Fs,t)
	end
end
insertcols!(ctrax,ncol(ctrax)+1,:travel_time => [v for v in values(avgs)])

jtrax = JSON.Parser.parsefile("data/geo/ct2010.geojson")

FT = jtrax["features"]; k = length(FT)
for i ∈ 1:k
	code = FT[i]["properties"]["boro_ct2010"]; code = Base.parse(Int,code)
	!(code in Fs) ? ttime = avgs[code] : ttime = NaN
    jtrax["features"][i]["properties"]["travel_time"] = ttime
end

ctrax |> wr("data/info/cttimes.csv")
open("data/geo/cttimes.geojson", "w") do f
	write(f, JSON.json(jtrax))
end
