#!/bin/sh ruby

require 'csv'
require 'geometry'

#image_size = [4000, 3000]

tree_locations = CSV.read("tree_locations.csv", headers: true, converters: :numeric)

trees = tree_locations.map(&:to_h).to_a

def pixels_to_feet(px)
  px / 11.0
end

trees.each{|t| t.merge!({'x' => pixels_to_feet(t['px']), 'y' => pixels_to_feet(t['py'])})}
  .each{|t| t.merge!({'pt' => Geometry::Point[t['x'], t['y']]})}

#def area(trees)
#  (trees.each_cons(2).map{|a,b| a['x']*b['y']-a['y']*b['x']}.sum/2).abs
#end

def area(polygon)
  (polygon.edges.map{|e| a = e.first; b = e.last; a.x*b.y-a.y*b.x}.sum/2).abs
end
area([t1, t2, t3])
area([t1, t2, t3])

def convex?(poly)
  poly.convex.vertices.size == poly.vertices.size
end

#def dist(a, b)
#  Math.sqrt((b['x']-a['x'])**2 + (b['y']-a['y'])**2)
#end

#def perim(trees)
#  trees.each_cons(2).map{|a, b| dist(b, a)}.sum
#end

def perim(polygon)
  polygon.edges.map(&:length).sum
end

# compare pixel coordinates to hand-measured benchmarks
t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17=trees

#dist(t15, t3) # 94 ft
#dist(t15, t7) # 95 ft
#dist(t15, t10) # 88 ft
#dist(t15, t9) # 33 ft?

house_points = [t15, t16, t17]

combos = (trees.combination(3) + trees.combination(4) + trees.combination(5)); combos.size

polygons = combos.map{|c| {trees: c.map(&:first).map(&:last), polygon: Geometry::Polygon.new(*c.map{|t| t['pt']})}}
                     .map{|c| c.merge({perim: perim(c[:polygon]).to_i, area: area(c[:polygon]).to_i}) }; nil

antenna_length = 288
ideal_perim = antenna_length + 80

good_combos = polygons
    .filter{|poly| convex?(poly[:polygon])}
    .filter{|combo| !(combo[:trees] & house_points.map{|t| t['name']}).empty?}
    .filter{|combo| (combo[:perim] - ideal_perim).abs < 30}
    .sort_by{|combo| - combo[:area]}; good_combos.size

good_combos.last

puts; good_combos.take(50).map{|combo| puts combo.slice(:area, :perim, :trees)}
