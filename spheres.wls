#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 40;
maxRecursion = 2;
lighting = {{"Point", White, {10, -10, 10}}};
opacity = 1;
r = 1;
plotRangeFactor = 1.1;

(* shape = "Tetrahedron"; *)
(* shape = "Octahedron"; *)
shape = "Icosahedron";
(* shape = "Cube"; *)
(* shape = "Dodecahedron"; *)


start = AbsoluteTime[];
Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];


(* constraint[x_, y_, z_, direction_] := {x,y,z}.{x,y,z} - ({x,y,z}.direction)^2/(direction.direction) - r^2; *)
constraint[x_, y_, z_, center_, radius_] := ({x,y,z} - center).({x,y,z} - center) - radius^2;

insideConstraint[x_, y_, z_, vertices_, radius_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]], radius ] <= 0&, verticesIndices]];

outsideConstraint[x_, y_, z_, vertices_, radius_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]], radius ] >= 0&, verticesIndices]];


colors = Join[{Red, Blue, Green, Yellow, Magenta, Cyan, Brown, Orange, Pink, Purple}, RandomColor[100]];

vertices = PolyhedronData[shape, "VertexCoordinates"];
Print["Number of vertices to plot: " <> IntegerString[Length[vertices]]];

For[intersectionLevel = 5, intersectionLevel <= Length[vertices], intersectionLevel++,
    startIteration = AbsoluteTime[];

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

    indicesList = {};
    allIndices = Table[k, {k, 1, Length[vertices]}];
    For[i = 1, i <= Length[vertices], i++,
        otherIndices = Complement[allIndices, {i}];
        subsets = Subsets[otherIndices, {intersectionLevel - 1}];
        indices = Map[{{i}, #, Complement[otherIndices, #], colors[[i]]}&, subsets];
        indicesList = Join[indicesList, indices]
    ];

    Print["Segments to plot: " <> IntegerString[Length[indicesList]]];

    rsquares = Map[
        NMaximize[{x^2+y^2+z^2, insideConstraint[x, y, z, vertices, r, #[[2]] ] &&
                            (* outsideConstraint[x, y, z, vertices, r, #[[3]] ] && *)
                            constraint[x, y, z, vertices[[ (#[[1]][[1]]) ]], r ] == 0
                            },
                            {x, y, z}
        ][[1]]&, indicesList];
    plotRange = N[Sqrt[Max[rsquares]]];
    Print["plotRange: " <> ToString[plotRange]];
    plotRange = plotRange * plotRangeFactor;

    plots = Map[
                ContourPlot3D[constraint[x, y, z, vertices[[ (#[[1]][[1]]) ]], r ] == 0, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, BoundaryStyle -> Red, 
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[#[[4]]] , Opacity[opacity] } },
                    RegionFunction -> Function[
                        {x, y, z},
                        insideConstraint[x, y, z, vertices, r, #[[2]] ] &&
                        outsideConstraint[x, y, z, vertices, r, #[[3]] ]
                    ]
                ]&,
            indicesList];


    Print["creating graph"];
    graph = Apply[Show, plots];
    Print["created graph"];

    outputFolder = "output/spheres/";
    outputFileName = outputFolder <> shape <> 
        "_surface_" <> If[exportToPov, "pov_", "native_"] 
        <> IntegerString[Length[cylinders]] <> "_" 
        <> IntegerString[intersectionLevel] <>  "_" 
        <> IntegerString[plotPoints] <> ".png";

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
    
    endIteration = AbsoluteTime[];
    Print["Elapsed time in seconds, in this iteration"];
    Print[endIteration - startIteration];
];


end = AbsoluteTime[];
Print["Elapsed time in seconds in total"];
Print[end - start];
