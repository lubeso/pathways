## Objective
# In this script, we'll be computing census tract centroids,
# and adding them to our `ct2010.csv` to compute travel times.
# To begin, we'll import the necessary packages:

using JSON, GeoJSON, GeoInterface
using CSV, DataFrames; rd, wr = CSV.read, CSV.write

# We then read in our census tracts files. Both the CSV and GeoJSON
# files contain geometry information, but we'll use the GeoJSON's
# for convenience.

geo = JSON.Parser.parsefile("data/geo/ct2010.geojson")
df  = rd("data/geo/ct2010.csv")

n = length(geo["features"]); @assert n == nrow(df)
clat = zeros(n); clon = zeros(n)

for i ∈ 1:n
	tract = geo["features"][i]
	geom = tract["geometry"]
	poly = MultiPolygon(geom["coordinates"])
	X = poly.coordinates[1][1]; k = length(X)
	C = [0.0,0.0]
	for x ∈ X
		C .+= reverse(x)
	end
	C ./= k
	clat[i] = C[1]; clon[i] = C[2]
end

insertcols!(df, ncol(df), (:centroid_lat => clat))
insertcols!(df, ncol(df), (:centroid_lon => clon))

df |> wr("ct2010-centroids.csv")
