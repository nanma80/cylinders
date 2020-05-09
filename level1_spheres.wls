#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 40;
maxRecursion = 2;
lighting = {{"Point", White, {10, -10, 10}}};
opacity = 1;
r = 1;
plotRangeFactor = 1.1;
intersectionLevel = 1;

shape = "Tetrahedron";
(* shape = "Octahedron"; *)
(* shape = "Icosahedron"; *)
(* shape = "Cube"; *)
(* shape = "Dodecahedron"; *)

Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];


colors = Join[{Red, Blue, Green, Yellow, Magenta, Cyan, Brown, Orange, Pink, Purple}, RandomColor[100]];

vertices = PolyhedronData[shape, "VertexCoordinates"];
Print["Number of vertices to plot: " <> IntegerString[Length[vertices]]];

Print["intersectionLevel: " <> IntegerString[intersectionLevel] <> " shape: " <> shape];

viewPointMap = <|
    "Tetrahedron" -> {5, -3, 3},
    "Octahedron" -> {5, -3, 1},
    "Cube" -> {4, -3, 2},
    "Icosahedron" -> {2, -3, 2}*3,
    "Dodecahedron" -> {2, -3, 2}*3,
    "Cuboctahedron" -> {5, -3, 1},
    "Icosidodecahedron" -> {2, -3, 2}*3
|>;

viewPoint = viewPointMap[shape];

plotRange = Norm[vertices[[1]]] + r;
Print["plotRange: " <> ToString[N[plotRange]]];
plotRange = plotRange * plotRangeFactor;

plots = Table[Graphics3D[{Lighter[colors[[k]]], Opacity[opacity], Sphere[vertices[[k]], r]}], {k, 1, Length[vertices]}];

Print["creating graph"];
graph = Apply[Show, plots];
Print["created graph"];

outputFolder = "output/spheres/";
outputFileName = outputFolder <> shape <> "_1_" <> IntegerString[plotPoints] <> ".png";

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

