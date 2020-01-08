#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 80;

Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];

cylinders = {
    Cylinder[{{-1, 0, 0}, {1, 0, 0}}, 1],
    Cylinder[{{0, -1, 0}, {0, 1, 0}}, 1],
    Cylinder[{{0, 0, -1}, {0, 0, 1}}, 1]
    }

region12 = RegionIntersection[cylinders[[1]], cylinders[[2]]];
region23 = RegionIntersection[cylinders[[2]], cylinders[[3]]];
region13 = RegionIntersection[cylinders[[1]], cylinders[[3]]];
region = RegionUnion[region12, region23, region13];

constraint1 = (x ^ 2 + y ^ 2 == 1);
constraint2 = (x ^ 2 + z ^ 2 == 1);
constraint3 = (y ^ 2 + z ^ 2 == 1);

seam12 = Quiet@Solve[ {constraint1, constraint2}, {x, y, z}];
seam13 = Quiet@Solve[ {constraint1, constraint3}, {x, y, z}];
seam23 = Quiet@Solve[ {constraint2, constraint3}, {x, y, z}];
seam12Graph = ParametricPlot3D[{x, y, z}/.seam12, {x, -1, 1}, PlotStyle -> Blue];
seam13Graph = ParametricPlot3D[{x, y, z}/.seam13, {y, -1, 1}, PlotStyle -> Blue];
seam23Graph = ParametricPlot3D[{x, y, z}/.seam23, {z, -1, 1}, PlotStyle -> Blue];

graph = Show[ RegionPlot3D[region, PlotPoints -> plotPoints], seam12Graph, seam13Graph, seam23Graph ];

outputFolder = "output/";
outputFileName = outputFolder <> "cylinders_3_2.png";
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



