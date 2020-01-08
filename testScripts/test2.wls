#!/usr/bin/env wolframscript

solution = Quiet@Solve[ {x ^ 2 + y ^ 2 == 1, x ^ 2 + z ^ 2 == 1}, {x, y, z}];
Print[solution];
graph = ParametricPlot3D[{x, y, z}/.solution, {x, -1, 1}];

exportToPov = True;
plotPoints = 20;

Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];

cylinders = {
    Cylinder[{{-1, 0, 0}, {1, 0, 0}}, 1],
    Cylinder[{{0, -1, 0}, {0, 1, 0}}, 1],
    Cylinder[{{0, 0, -1}, {0, 0, 1}}, 1]
    }

(* region12 = RegionIntersection[cylinders[[1]], cylinders[[2]]];
region23 = RegionIntersection[cylinders[[2]], cylinders[[3]]];
region13 = RegionIntersection[cylinders[[1]], cylinders[[3]]];
region = RegionUnion[region12, region23, region13];

graph = RegionPlot3D[region, PlotPoints -> plotPoints];
 *)
outputFolder = "output/";
outputFileName = outputFolder <> "seam.png";
imageSize = {600, 450};
    cropCommand = "mogrify -crop " <> IntegerString[imageSize[[2]]] <> "x" <> IntegerString[imageSize[[2]]] <> "+" <> IntegerString[(imageSize[[1]]-imageSize[[2]])/2] <> "+0 " <> outputFileName;

If[exportToPov,
    If[FileExistsQ[outputFileName], DeleteFile[outputFileName]];
    POVRayRender[graph, Method -> "Triangle", OutputPath -> outputFileName, ImageSize -> imageSize, RenderOptions -> "+A0.001 -J +UA"];
    Run[cropCommand];
    ,
    Export[outputFileName, graph];
];
Print["Saved the image to " <> outputFileName];



