#!/usr/bin/env wolframscript

exportToPov = True;
plotPoints = 40;
maxRecursion = 5;
lighting = {{"Point", White, {10, -10, 10}}};
opacity = 0.9;
r = 1;

start = AbsoluteTime[];
Needs["POVRayRender`"];
ConfigurePOVRayRender["POVRayPath" -> "C:\\Program Files\\POV-Ray\\v3.7\\bin\\pvengine64.exe"];

getOrthDirections[direction_] := Orthogonalize[{direction, {2, -1.4, 0.3}, {0, 1, 2.3}}];
constraint[x_, y_, z_, direction_] := {x,y,z}.{x,y,z} - ({x,y,z}.direction)^2/(direction.direction) - r^2;
insideConstraint[x_, y_, z_, vertices_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]] ] <= 0&, verticesIndices]];

outsideConstraint[x_, y_, z_, vertices_, verticesIndices_] := 
    Apply[And, Map[constraint[x, y, z, vertices[[ # ]] ] >= 0&, verticesIndices]];


colors = Join[{Red, Blue, Green, Yellow, Magenta, Cyan, Brown, Orange, Pink, Purple}, RandomColor[100]];

(* shape = "Octahedron"; *)
shape = "Icosahedron";
(* shape = "Cube"; *)
(* shape = "Dodecahedron"; *)
(* shape = "Cuboctahedron"; *)
(* shape = "Icosidodecahedron"; *)

For[intersectionLevel = 3, intersectionLevel <= 3, intersectionLevel++,
    Print["intersectionLevel: " <> IntegerString[intersectionLevel] <> " shape: " <> shape];

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

    allDirections = Map[getOrthDirections, vertices];

    plots = Map[
                ParametricPlot3D[
                    (allDirections[[#[[1]][[1]]]][[2]] Cos[phi] r +
                    allDirections[[#[[1]][[1]]]][[3]] Sin[phi] r +
                    allDirections[[#[[1]][[1]]]][[1]] * l),
                    {phi, 0, 2 Pi}, {l, -5, 5},
                    Axes -> None, 
                    BoundaryStyle -> Directive[Red, Thick], 
                    Mesh -> None,
                    PlotPoints -> plotPoints, 
                    MaxRecursion -> maxRecursion,
                    ViewPoint -> viewPoint,
                    Lighting -> lighting,
                    PlotStyle -> { Lighter[#[[4]]] , Opacity[opacity] },
                    PlotRange -> All,
                    RegionFunction -> Function[
                        {x, y, z, phi, l},
                        insideConstraint[x, y, z, vertices, #[[2]] ] &&
                        outsideConstraint[x, y, z, vertices, #[[3]] ]
                    ]
                ]&,
            indicesList];

    Print["creating graph"];
    graph = Apply[Show, plots];
    (* graph = plots[[1]]; *)
    Print["created graph"];

    outputFolder = "output/";
    outputFileName = outputFolder <> shape <> "_param_" <> If[exportToPov, "pov_", "native_"] <> IntegerString[Length[cylinders]] <> "_" <> IntegerString[intersectionLevel] <>  "_" <> IntegerString[plotPoints] <> ".png";

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
