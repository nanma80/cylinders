#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 40;
maxRecursion = 2;
opacity = 0.9;
r = 1;
hyperbolaParameter = 0.05;
randomView = False;
edgeOnly = False;

start = AbsoluteTime[];
Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];

viewPoint = {1, -1, 1}/Sqrt[3];
rotation = If[randomView, IdentityMatrix[3], RotationMatrix[{{0, 0, 1}, viewPoint}]];
lighting = {{"Point", White, viewPoint * 10}};

constraint[x_, y_, z_, direction_] := {x,y,z}.{x,y,z} - (1 + hyperbolaParameter) * ({x,y,z}.rotation.direction)^2/(direction.direction) - r^2;
insideConstraint[x_, y_, z_, vertices_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]] ] <= 0&, verticesIndices]];

outsideConstraint[x_, y_, z_, vertices_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]] ] >= 0&, verticesIndices]];


colors = Join[{Red, Blue, Green, Yellow, Magenta, Cyan, Brown, Orange, Pink, Purple}, RandomColor[100]];

(* shape = "Octahedron"; *)
(* shape = "Icosahedron"; *)
(* shape = "Cube"; *)
(* shape = "Dodecahedron"; *)
(* shape = "Cuboctahedron"; *)
shape = "Icosidodecahedron";

For[intersectionLevel = 2, intersectionLevel <= 2, intersectionLevel++,
    Print["intersectionLevel: " <> IntegerString[intersectionLevel] <> " shape: " <> shape];

    plotRangeMap = <|
        "Octahedron" -> 1,
        "Cube" -> 1.5 - intersectionLevel * 0.025,
        "Icosahedron" -> 2.2 - intersectionLevel * 0.1,
        "Dodecahedron" -> 3.2 - intersectionLevel * 0.2,
        "Cuboctahedron" -> 2.0 - intersectionLevel * 0.07,
        "Icosidodecahedron" -> 3.2 - intersectionLevel * 0.1
    |>;
    plotRange = plotRangeMap[shape] * If[intersectionLevel <= 2, 1.5, 1.3];
    (* for icosidodecahedron, level 2, 0.05, * 1.3 is a little too small. Should try 1.5 *)

    viewPointMap = <|
        "Octahedron" -> {5, -3, 1},
        "Cube" -> {4, -3, 2},
        "Icosahedron" -> {2, -3, 2}*3,
        "Dodecahedron" -> {2, -3, 2}*3,
        "Cuboctahedron" -> {5, -3, 1},
        "Icosidodecahedron" -> {2, -3, 2}*3
    |>;
    
    If[randomView, viewPoint = viewPointMap[shape]];

    vertices = PolyhedronData[shape, "VertexCoordinates"];
    vertices = Select[vertices, #.{0.1, 0.123, 0.23} >= 0 &];
    Print["Number of vertices to plot: " <> IntegerString[Length[vertices]]];

    indicesList = {};
    allIndices = Table[k, {k, 1, Length[vertices]}];
    For[i = 1, i <= Length[vertices], i++,
        otherIndices = Complement[allIndices, {i}];
        subsets = Subsets[otherIndices, {intersectionLevel - 1}];
        indices = Map[{{i}, #, Complement[otherIndices, #], colors[[i]]}&, subsets];
        indicesList = Join[indicesList, indices]
    ];

    (* indicesList = { indicesList[[1]], indicesList[[2]] }; *)

    Print["Segments to plot: " <> IntegerString[Length[indicesList]]];
    (* Print[indicesList]; *)

    plots = Map[
                ContourPlot3D[constraint[x, y, z, vertices[[ (#[[1]][[1]]) ]] ] == 0, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, BoundaryStyle -> Red, 
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint * 100,
                    Lighting -> lighting,
                    MeshFunctions -> {0 &}, 
                    MeshShading -> { If[edgeOnly, None, { Lighter[#[[4]]] , Opacity[opacity] }] },
                    RegionFunction -> Function[
                        {x, y, z},
                        insideConstraint[x, y, z, vertices, #[[2]] ] &&
                        outsideConstraint[x, y, z, vertices, #[[3]] ]
                    ]
                ]&,
            indicesList];


    Print["creating graph"];
    graph = Apply[Show, plots];
    Print["created graph"];

    outputFolder = "output/hyperboloids/";
    outputFileName = outputFolder <> shape <> If[edgeOnly, "_edge_only_", "_surface_"] <> If[exportToPov, "pov_", "native_"] <> If[randomView, "", "5fold_"] <> IntegerString[Round[hyperbolaParameter * 100]] <> "_" <> IntegerString[intersectionLevel] <>  "_" <> IntegerString[plotPoints] <> ".png";

    imageSize = {4, 3} * 240;
    cropCommand = "mogrify -crop " <> IntegerString[imageSize[[2]]] <> "x" <> IntegerString[imageSize[[2]]] <> "+" <> IntegerString[(imageSize[[1]]-imageSize[[2]])/2] <> "+0 " <> outputFileName;

    If[exportToPov,
        If[FileExistsQ[outputFileName], DeleteFile[outputFileName]];
        POVRayRender[graph, Method -> "Triangle", OutputPath -> outputFileName, ImageSize -> imageSize, RenderOptions -> "+A0.001 -J +UA"];
        Run[cropCommand];
        ,
        Export[outputFileName, graph];
    ];
    Print["Saved the image to " <> outputFileName];
];


end = AbsoluteTime[];
Print["Elapsed time in seconds"];
Print[end - start];
