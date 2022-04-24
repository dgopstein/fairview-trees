#!/bin/sh ruby

require 'csv'

image_size = [4000, 3000]

tree_locations = CSV.read("tree_locations.csv", headers: true, converters: :numeric)

trees = tree_locations.map(&:to_h).to_a

def pixels_to_feet(px)
  px / 11
end

def area(quad)
  a,b,c,d = quad

  px_area =
  (a['x']*b['y']-a['y']*b['x'] + b['x']*c['y']-b['y']*c['x'] +
   c['x']*d['y']-c['y']*d['x'] + c['x']*d['y']-c['y']*d['x']) / 2

  pixels_to_feet(px_area).abs
end

def dist(a, b)
  px_dist = Math.sqrt((b['x']-a['x'])**2 + (b['y']-a['y'])**2)

  pixels_to_feet(px_dist)
end

def perim(quad)
  a,b,c,d = quad
  dist(b, a) + dist(c, b) + dist(d, c) + dist(a, d)
end

# compare pixel coordinates to hand-measured benchmarks
t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17=trees

dist(t15, t3) # 94 ft
dist(t15, t7) # 95 ft
dist(t15, t10) # 88 ft
dist(t15, t9) # 33 ft?

house_points = [t15, t16, t17]

combos = trees.combination(4)
  .map{|q| {trees: q.map(&:first).map(&:last), perim: perim(q), area: area(q)} }; nil

good_combos = combos
     .filter{|combo| !(combo[:trees] & house_points.map{|t| t['name']}).empty?}
     .filter{|combo| combo[:perim] > 420 && combo[:perim] < 440}
     .sort_by{|combo| - combo[:area]}; good_combos.size

good_combos.last

puts; good_combos.take(50).map{|combo| puts combo}
