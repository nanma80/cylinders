#!/usr/bin/env wolframscript

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

intersection = RegionIntersection[cylinders];


Print[Volume[intersection]//FullSimplify];
(* -8*(-2 + Sqrt[2]) *)

Print[SurfaceArea[intersection]];
(* 13.991191137296584 *)

volume = Volume[region];
Print[volume];
(* 16*(-1 + Sqrt[2]) *)
Print[volume//N];

Print[SurfaceArea[region]];
(* 19.39477160271971 *)
(* numerical areas may not be accurate at all *)