#!/usr/bin/env wolframscript

(* intersectionLevel = 4; *)
(* shape = "Octahedron"; *)
shape = "Icosahedron";
(* shape = "Cube"; *)

r = 1;
len = 100;
implicitRegion = False;

cylinder[direction_] :=
If[implicitRegion,
    ImplicitRegion[Norm[{x,y,z}]^2 - ({x, y, z}.direction)^2/Norm[direction]^2 <= r^2 && ({x, y, z}.direction)^2/Norm[direction]^2 <= len^2, {x, y, z}],
    Cylinder[{-direction/Norm[direction] * len, direction/Norm[direction] * len}, r]
];

For[intersectionLevel = 2, intersectionLevel <= 6, intersectionLevel++,

    start = AbsoluteTime[];

    vertices = PolyhedronData[shape, "VertexCoordinates"];
    vertices = Select[vertices, #.{0.1, 0.123, 0.23} > 0 &];
    cylinders = Map[cylinder[#]&, vertices];
    Print["Total number of cylinders: " <> IntegerString[Length[cylinders]] 
        <> ". Number of cylinders to intersect: " <> IntegerString[intersectionLevel]];

    regions = Subsets[cylinders, {intersectionLevel}];

    Print["Computing intersections: " <> IntegerString[Length[regions]]];

    regionIntersections = Map[Apply[RegionIntersection, #]&, regions ];
    Print["Computing union"];
    regionUnion = Apply[RegionUnion, regionIntersections];

    Print["Computing volume"];
    volume = Volume[regionUnion];
    Print[volume];
    Print[N[volume]];

    Print["Computing surface area"];
    surfaceArea = SurfaceArea[regionUnion];
    Print[surfaceArea];
    Print[N[surfaceArea]];

    end = AbsoluteTime[];
    Print["Elapsed time in seconds: " <> ToString[end - start]];
];
