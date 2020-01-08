#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 50;
intersectionLevel = 2;
(* shape = "Octahedron"; *)
shape = "Icosahedron";
(* shape = "Cube"; *)

r = 1;
len = 10;
implicitRegion = False;

cylinder[direction_] :=
If[implicitRegion,
    ImplicitRegion[Norm[{x,y,z}]^2 - ({x, y, z}.direction)^2/Norm[direction]^2 <= r^2 && ({x, y, z}.direction)^2/Norm[direction]^2 <= len^2, {x, y, z}],
    Cylinder[{-direction/Norm[direction] * len, direction/Norm[direction] * len}, r]
];

Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];

(* cylinders = {
    cylinder[{1, 0, 0}],
    cylinder[{0, 1, 0}],
    cylinder[{0, 0, 1}]
};
 *)

vertices = PolyhedronData[shape, "VertexCoordinates"];
vertices = Select[vertices, #.{0.1, 0.123, 0.23} > 0 &];
cylinders = Map[cylinder[#]&, vertices];
Print["Total number of cylinders: " <> IntegerString[Length[cylinders]] 
    <> ". Number of cylinders to intersect: " <> IntegerString[intersectionLevel]];
(* cylinders = {cylinders[[1]], cylinders[[2]], cylinders[[3]]}; *)
(* cylinders = {cylinders[[1]], cylinders[[2]]}; *)

regions = Subsets[cylinders, {intersectionLevel}];

Print["Computing intersections: " <> IntegerString[Length[regions]]];

regionIntersections = Map[Apply[RegionIntersection, #]&, regions ];
Print["Computing union"];
regionUnion = Apply[RegionUnion, regionIntersections];


Print["creating graph"];
graph = RegionPlot3D[regionUnion, PlotPoints -> plotPoints(* , MaxRecursion -> 5 *)];
Print["created graph"];

outputFolder = "output/";
outputFileName = outputFolder <> shape <> If[implicitRegion, "_implicit", "_native"] <> "_" <> IntegerString[Length[cylinders]] <> "_" <> IntegerString[intersectionLevel] <>  "_" <> IntegerString[plotPoints] <> ".png";
imageSize = {600, 450};
    cropCommand = "mogrify -crop " <> IntegerString[imageSize[[2]]] <> "x" <> IntegerString[imageSize[[2]]] <> "+" <> IntegerString[(imageSize[[1]]-imageSize[[2]])/2] <> "+0 " <> outputFileName;

If[exportToPov,
    If[FileExistsQ[outputFileName], DeleteFile[outputFileName]];
    POVRayRender[graph, Method -> "Triangle", OutputPath -> outputFileName, ImageSize -> imageSize, RenderOptions -> "+A0.001 -J +UA"];
    (* Run[cropCommand]; *)
    ,
    Export[outputFileName, graph];
];
Print["Saved the image to " <> outputFileName];



