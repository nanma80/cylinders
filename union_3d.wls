#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 40;
maxRecursion = 1;
lighting = {{"Point", White, {10, -10, 10}}};
opacity = 0.9;
r = 1;

start = AbsoluteTime[];
Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];


constraint[x_, y_, z_, direction_] := {x,y,z}.{x,y,z} - ({x,y,z}.direction)^2/(direction.direction) - r^2;
insideConstraint[x_, y_, z_, vertices_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]] ] <= 0&, verticesIndices]];

outsideConstraint[x_, y_, z_, vertices_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]] ] >= 0&, verticesIndices]];


colors = Join[{Red, Blue, Green, Yellow, Magenta, Cyan, Brown, Orange, Pink, Purple}, RandomColor[100]];

shape = "Octahedron";
(* shape = "Icosahedron"; *)
(* shape = "Cube"; *)
(* shape = "Dodecahedron"; *)
(* shape = "Cuboctahedron"; *)
(* shape = "Icosidodecahedron"; *)

For[intersectionLevel = 1, intersectionLevel <= 1, intersectionLevel++,
    Print["intersectionLevel: " <> IntegerString[intersectionLevel] <> " shape: " <> shape];

    plotRangeMap = <|
        "Octahedron" -> 1,
        "Cube" -> 1.5 - intersectionLevel * 0.025,
        "Icosahedron" -> 2.2 - intersectionLevel * 0.1,
        "Dodecahedron" -> 3.2 - intersectionLevel * 0.2,
        "Cuboctahedron" -> 2.0 - intersectionLevel * 0.07,
        "Icosidodecahedron" -> 3.2 - intersectionLevel * 0.1
    |>;
    plotRange = plotRangeMap[shape];
    plotRange = 3;

    viewPointMap = <|
        "Octahedron" -> {5, -3, 1},
        "Cube" -> {4, -3, 2},
        "Icosahedron" -> {2, -3, 2}*3,
        "Dodecahedron" -> {2, -3, 2}*3,
        "Cuboctahedron" -> {5, -3, 1},
        "Icosidodecahedron" -> {2, -3, 2}*3
    |>;

    viewPoint = viewPointMap[shape];

    vertices = PolyhedronData[shape, "VertexCoordinates"];
    vertices = Select[vertices, #.{0.1, 0.123, 0.23} >= 0 &];
    Print["Number of vertices to plot: " <> IntegerString[Length[vertices]]];

    cylinders = Map[Cylinder[{-#, #}*5, 1] &, vertices];

    plots = Map[
            ContourPlot3D[constraint[x, y, z, vertices[[ (#[[1]][[1]]) ]] ] == 0, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[#]]] , Opacity[opacity] } }
                ]&,

        Table[k, {k, 1, Length[cylinders]}]
    ];

    ends = {
        ContourPlot3D[y == -3, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    RegionFunction -> Function[
                        {x, y, z},
                        x^2 + z^2 <= 1
                    ],
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[1]]] , Opacity[opacity] } }
                ],

        ContourPlot3D[y == 3, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    RegionFunction -> Function[
                        {x, y, z},
                        x^2 + z^2 <= 1
                    ],
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[1]]] , Opacity[opacity] } }
                ],

        ContourPlot3D[x == 3, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    RegionFunction -> Function[
                        {x, y, z},
                        y^2 + z^2 <= 1
                    ],
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[3]]] , Opacity[opacity] } }
                ],

        ContourPlot3D[x == -3, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    RegionFunction -> Function[
                        {x, y, z},
                        y^2 + z^2 <= 1
                    ],
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[3]]] , Opacity[opacity] } }
                ],

        ContourPlot3D[z == 3, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    RegionFunction -> Function[
                        {x, y, z},
                        y^2 + x^2 <= 1
                    ],
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[2]]] , Opacity[opacity] } }
                ],

        ContourPlot3D[z == -3, 
                    {x, -plotRange, plotRange}, {y, -plotRange, plotRange}, {z, -plotRange, plotRange},
                    Axes -> None, 
                    (* BoundaryStyle -> Red, *)
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    RegionFunction -> Function[
                        {x, y, z},
                        y^2 + x^2 <= 1
                    ],
                    MeshFunctions -> {0 &}, MeshShading -> { { Lighter[colors[[2]]] , Opacity[opacity] } }
                ]

    };
    plots = Union[plots, ends];
    graph = Apply[Show, plots];

    outputFolder = "output/cylinders/";
    outputFileName = outputFolder <> shape <> "_union_" <> If[exportToPov, "pov_", "native_"] <> IntegerString[Length[cylinders]] <> "_" <> IntegerString[intersectionLevel] <>  "_" <> IntegerString[plotPoints] <> ".png";

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
];


end = AbsoluteTime[];
Print["Elapsed time in seconds"];
Print[end - start];
