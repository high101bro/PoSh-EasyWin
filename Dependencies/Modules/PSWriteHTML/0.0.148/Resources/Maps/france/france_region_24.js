/*!
*
* Jquery Mapael - Dynamic maps jQuery plugin (based on raphael.js)
* Requires jQuery and Mapael
*
* Map of Centre for Mapael
* Equirectangular projection
* 
* @author CCM Benchmark Group
* @source http://fr.m.wikipedia.org/wiki/Fichier:France_location_map-Departements.svg
*/
(function (factory) {
    if (typeof exports === 'object') {
        // CommonJS
        module.exports = factory(require('jquery'), require('jquery-mapael'));
    } else if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['jquery', 'mapael'], factory);
    } else {
        // Browser globals
        factory(jQuery, jQuery.mapael);
    }
}(function ($, Mapael) {

    "use strict";

    $.extend(true, Mapael,
        {
            maps :  {
                france_region_24 : {
                    width : 140.46022,
                    height : 171.25021,
                    getCoords : function (lat, lon) {
                        var xfactor = 45.48385;
                        var xoffset = -1.9679;
                        var x = (lon * xfactor) + xoffset;
                        
                        var yfactor = -65.97284;
                        var yoffset = 3228.8694;
                        var y = (lat * yfactor) + yoffset;
                        return {x : x, y : y};
                    },
                    elems : {
                        "department-37" : "m 26.32,81.64 c -0.84,0.11 -0.47,1.14 -1.03,1.54 -0.49,0.61 -1.16,1.03 -1.95,0.94 -0.73,0.28 -1.16,1.18 -2.07,0.97 -0.78,0.12 -1.32,0.86 -2.19,0.71 -1.08,-0.1 -0.56,1.42 -1.46,1.55 -1.15,0.5 -1.59,-0.95 -2.39,-1.41 -0.58,0.14 -1.04,0.95 -1.12,1.45 0.83,0.58 1.52,1.61 1.58,2.58 -0.48,0.61 -1.22,1.02 -1.91,0.42 -0.98,-0.36 -1.46,-1.58 -2.63,-1.49 -0.84,0.07 -1.44,-0.46 -2.09,-0.89 -0.56,-0.34 -1.36,0.02 -1.1,0.76 0.12,0.69 0.06,1.42 -0.57,1.83 -0.39,0.67 -1.14,1.64 -0.66,2.41 0.32,0.32 1.1,0.31 0.82,0.96 -0.12,1.97 -2.06,3.42 -1.78,5.52 0.17,0.79 -0.18,1.47 -0.8,1.93 -0.35,0.52 0.2,1.28 0.63,1.52 -0.44,0.9 -1.77,1.38 -1.57,2.53 -0.28,0.83 -1.42,0.86 -1.59,1.8 -0.39,0.87 -1.3,1.58 -1.05,2.63 -0.79,1.23 -0.57,2.78 -0.76,4.16 -0.38,0.45 -0.96,1.17 -0.32,1.66 0.19,0.92 -0.86,2.02 0.09,2.81 0.5,0.04 0.61,0.47 0.63,0.92 -0.02,0.81 0.99,1.06 1.31,0.32 0.4,0.04 1.19,0.14 1.32,0.6 -0.27,0.86 0.83,1.2 1.37,0.68 0.37,-0.34 0.77,-0.45 0.84,0.18 0.3,0.63 0.66,1.39 -0.05,1.9 -0.47,0.31 -0.55,1.34 0.23,1.02 0.44,0.03 0.71,0.76 1.21,0.29 0.53,-0.55 1.37,-1.21 2.1,-0.65 0.09,0.45 -0.17,1.52 0.64,1.3 0.46,-0.17 1.15,-0.58 1.37,0.14 0.27,0.54 0.3,1.2 -0.11,1.64 -0.28,0.58 0.32,1.14 0.18,1.66 -0.7,0.61 0.02,1.44 -0.14,2.2 -0.13,0.77 0.32,2.22 1.33,1.88 0.74,-0.22 1.18,-1.34 2,-0.74 0.91,0.12 1.8,0.92 2.72,0.73 1.28,-1.37 3.3,-1.72 5.11,-1.53 0.69,-0.15 1.84,0.34 2.29,-0.36 0.16,-0.99 -1.5,-0.85 -1.29,-1.87 -0.03,-0.34 -0.62,-0.9 0.05,-0.91 0.68,0.02 1.64,-0.41 2.21,0.09 0.16,0.78 0.82,1.08 1.52,1.18 0.47,0.73 1.81,0.33 1.91,1.36 0.57,1.39 0.37,2.94 0.79,4.35 0.72,0.79 1.19,2.08 2.3,2.37 0.66,-0.13 0.05,0.95 0.77,0.88 0.33,-0.02 1.08,0.05 0.6,0.49 -0.28,0.75 0.96,0.74 0.83,1.5 0.13,0.88 0.24,1.79 0.82,2.46 0.16,0.88 1.05,1.5 1.75,1.97 0.95,0.14 2.1,-0.66 2.96,-0.02 0.31,0.38 0.73,1.47 1.31,0.8 0.53,-0.31 0.63,-1.17 1.19,-1.35 1,0.41 1.39,-0.08 0.74,-0.9 -0.15,-0.53 0.04,-1.21 -0.61,-1.49 -0.27,-0.63 0.94,-0.77 0.81,-1.47 -0.11,-0.86 0.63,-1.51 0.51,-2.36 0.33,-1.87 0.68,-3.75 0.87,-5.64 0.75,-0.38 1.45,-1.3 0.88,-2.14 -0.67,-0.85 0.43,-1.74 0.81,-2.44 0.32,-0.76 1.35,-1.17 2.15,-1.21 1,-0.03 1.98,-1.2 2.95,-0.65 0.55,0.72 1.53,0.74 2.17,1.32 0.81,0.1 1.34,-0.87 1.72,-1.46 0.24,-1.08 1.08,-1.98 1.95,-2.55 0.13,-0.49 -0.28,-1.51 0.45,-1.65 1.25,0.5 2.15,-1.06 1.74,-2.12 -0.52,-1.07 -0.67,-2.29 -1.46,-3.21 -1.1,-1.96 -1.95,-4.09 -3.66,-5.61 -0.48,-0.44 -0.4,-1.6 -1.33,-1.45 -0.56,0.88 -2.01,0.18 -2.53,1.18 -0.49,0.18 -1.05,-0.91 -1.64,-1.16 -0.42,-0.35 -1.14,-0.21 -1.19,-0.93 -0.13,-0.61 -0.71,-1.47 0.03,-1.92 0.52,-0.6 0.92,-1.58 0.17,-2.16 -0.2,-0.65 0.97,-0.98 0.49,-1.67 -0.28,-0.9 -1.09,-1.64 -1.39,-2.44 0.81,0.11 1.91,-0.31 1.82,-1.28 -0.19,-0.83 -1.04,-1.03 -1.75,-0.89 0.02,-1.36 -1.09,-2.47 -1.12,-3.84 -0.31,-0.32 -1.3,-0.65 -0.71,-1.24 0.19,-0.65 1.31,-0.98 1.07,-1.72 -1.09,-0.46 -1,-2.17 -2.04,-2.74 -0.88,-0.08 -0.63,1.23 -1.2,1.49 -0.79,-0.25 -0.91,-1.17 -0.72,-1.88 -0.23,-0.93 -1.41,-0.84 -2.17,-0.96 -0.99,-0.44 -1.66,0.71 -1.8,1.51 -0.48,0.16 -1.25,0.47 -1.67,0.17 -0.08,-0.56 -0.98,-0.94 -0.45,-1.52 0.75,-0.47 -0.4,-1.06 -0.35,-1.48 0.09,-0.76 0.88,-1.6 0.58,-2.35 -0.57,-0.11 -1.05,0.64 -1.68,0.29 -1.29,0 -2.44,-0.5 -3.65,-0.89 -0.56,-0.16 -1.07,0.33 -1.33,0.63 -0.84,-0.14 -1.49,-1.53 -2.27,-0.47 -0.28,0.32 -1.04,0.41 -0.8,-0.22 0.17,-0.41 -0.04,-0.94 -0.54,-0.89 z",
                        "department-28" : "m 64.97,0.15 c -1.16,-0.15 -1.07,1.39 -0.65,2.06 0.63,0.9 0.3,2.34 -0.87,2.57 -0.64,0.64 -1.86,0.16 -2.24,1.1 -0.57,0.74 -1.97,1.25 -1.53,2.45 0.36,0.66 1.18,2.09 -0.07,2.3 -0.75,0.32 -1.23,1.71 -2.21,1.06 -0.88,-0.71 -1.79,0.6 -2.65,0.25 -0,-0.74 -1.31,-0.7 -1.33,-0.02 -0.84,-0.1 -1.55,-0.96 -2.49,-0.63 -1.02,0.31 -1.07,-1.52 -2.08,-1.08 -0.37,0.55 0.06,1.38 -0.3,1.98 -0.19,1.04 -1.25,-0.03 -1.86,0.26 -0.37,0.37 -0.79,-0.59 -1.18,0.04 -0.45,0.34 -0.71,0.96 -0.79,1.43 -0.75,-0.29 -1.31,0.35 -2.06,0.18 -0.79,-0.2 -1.4,0.27 -1.91,0.79 -0.83,0.44 -1.97,0.47 -2.71,-0.12 -1.23,0.04 -0.64,1.9 -1.73,2.19 -0.72,0.13 -2.01,0.62 -1.65,1.57 0.41,0.52 0.31,1.26 0.62,1.8 -0.19,0.42 -0.69,1.28 0.12,1.36 1.03,-0.05 0.58,1.35 1.19,1.85 0.56,0.9 1.78,0.62 2.52,1.31 0.41,0.29 1.5,0.8 0.85,1.39 -0.19,0.88 1.22,0.86 1.66,1.37 0.03,0.67 -0.77,1.07 -0.73,1.68 0.41,0.51 0.18,1.37 -0.5,1.41 -0.38,0.87 0.55,1.84 1.29,2.22 0.79,0.18 -0.33,0.79 -0.51,1.14 -0.64,0.42 -0.17,1.28 -0.55,1.75 -0.85,0.55 -1.22,1.7 -2.22,2.02 -0.3,0.47 -0.66,0.84 -1.26,0.83 -0.88,0.53 -1.86,0.76 -2.87,0.69 -0.65,0.05 -1.06,0.49 -1.26,1.04 -0.26,0.48 -0.88,1.26 -0.44,1.75 0.54,0.1 1.24,0.45 1.46,0.9 -0.66,0.67 -0.76,1.77 -0.16,2.56 0.46,0.82 1.21,1.69 1.38,2.58 -0.47,0.36 -1.25,0.79 -1.27,1.38 0.81,0.81 1.7,1.68 2.93,1.63 0.92,0.27 2.22,0.82 2.32,1.88 -0.8,0.54 -2.12,-0.07 -2.77,0.7 0.12,0.48 -0.6,1.04 -0.15,1.39 0.97,-0.35 1.99,0.57 2.9,-0.11 0.57,-0.42 1.45,-0.58 1.54,0.3 0.76,0.12 1.13,-0.98 1.74,-1.31 0.62,-0.7 2.61,-1.15 2.71,0.15 -0.56,0.78 -1.83,0.87 -2.2,1.79 0.48,0.67 1.62,0.29 2.35,0.47 0.73,-0.15 1.03,0.7 1.75,0.47 0.45,-0.1 1.52,-0.32 1.1,0.53 -0.2,1.39 0.88,2.77 2.3,2.88 0.38,0.38 0.11,1.2 0.69,1.52 0.97,0.29 0.64,1.59 1.35,2.07 0.8,-0.02 1.83,-0.86 2.43,0.09 0.46,0.65 1.28,0.16 1.84,0.36 0.15,0.49 0.61,1 1.17,0.65 0.57,-0.18 1.24,-0.57 1.74,-0.08 0.79,0.02 0.58,-1.66 1.41,-1.36 0.54,0.86 2.29,0.27 1.94,-0.81 -0.07,-0.38 -0.38,-1.56 0.38,-1.35 1.17,0.27 1.9,1.59 3.08,1.68 0.69,-0.68 0.03,-1.86 0.2,-2.72 0.21,-0.52 1.01,-0.61 1.31,-1.12 0.77,0.03 1.79,1.14 2.38,0.22 0.56,-0.32 1.27,-0.63 1.18,-1.42 0.25,-0.62 1.19,-0.72 1.76,-0.85 0.19,0.5 0.82,0.67 1.02,0.08 0.32,-0.69 0.87,0.36 1.37,0.24 1.32,0.21 2.91,-0.05 3.91,-0.96 0.13,-0.61 0.99,0.09 1.39,-0.01 0.39,-0.1 0.73,-0.29 1.15,-0.18 0.5,-0.31 0.97,-0.72 1.41,-1.11 0.43,-0.62 0.36,-1.59 1.15,-1.9 0.33,-0.29 0.37,-0.84 -0.07,-0.98 -0.63,-0.73 0.38,-1.49 1.02,-1.7 0.47,-0.18 1.63,0.31 1.65,-0.45 -0.05,-0.46 -0.88,-0.78 -0.54,-1.24 0.39,0.08 1.04,-0.02 0.72,-0.56 -0.49,-0.94 -0.57,-2.2 -0.2,-3.15 0.53,-0.41 1.53,-1.4 0.85,-2.04 -0.4,-0.02 -0.49,-0.59 -0.87,-0.62 -0.39,-0.4 -0.53,-1.15 0.21,-1.24 0.65,-0.72 -0.32,-1.7 0.13,-2.52 0.36,-0.71 0.47,-1.58 -0.31,-1.98 0.07,-0.46 0.5,-1.26 -0.25,-1.4 -0.57,-0.13 -1.78,0.25 -1.57,-0.74 0.42,-0.62 0.81,-1.83 -0.05,-2.24 -0.69,0.03 -1.17,0.79 -1.94,0.57 -1.08,0 -1.89,-0.74 -2.39,-1.62 -0.46,-0.31 -1.26,0.18 -1.48,-0.54 -0.68,-1.48 -1.44,-3.2 -0.81,-4.84 -0.16,-0.65 -0.78,-1.12 -1.1,-1.7 -0.76,-0.38 -2.17,0.17 -2.48,-0.88 -0.16,-0.67 0.84,-1.31 0.41,-1.81 -0.6,0.07 -1.15,0.01 -1.63,-0.26 -0.59,0.25 -1.01,-0.29 -0.98,-0.83 -0.55,-0.41 -0.5,-1.54 -1.4,-1.48 -0.88,-0.32 -1.38,-1.33 -0.79,-2.14 0.01,-0.65 -1.83,-0.83 -0.92,-1.54 0.17,-1.09 1.44,-1.7 1.54,-2.79 -0.34,-0.69 -1.32,-0.68 -1.76,-1.15 0.02,-0.86 -0.52,-1.65 -0.2,-2.53 0.26,-0.58 0.37,-1.17 0.25,-1.81 0.44,-0.27 0.28,-0.9 -0.23,-0.89 0.28,-0.7 -0.24,-1.54 -1.02,-1.33 -0.76,-0.39 -0.08,-0.94 0.04,-1.45 -0.14,-0.67 -0.99,-1.1 -0.75,-1.86 -0.09,-0.69 -0.95,-0.41 -1.29,-0.59 C 66.53,0.07 65.8,0.06 64.97,0.15 z",
                        "department-45" : "m 98.31,39.76 c -0.62,0.3 -0.95,1.06 -1.13,1.64 -0.42,-0.01 -1.51,-0.01 -0.94,0.65 0.4,0.49 -0.67,0.45 -0.92,0.46 -0.38,-0.06 -1.06,0.14 -1.33,-0.13 -0.11,-0.77 -0.75,0.07 -1.09,0.21 -0.66,0.13 -1.37,0.14 -1.94,0.54 -0.7,0.35 -1.63,-0.11 -2.27,0.32 -0.25,0.67 -0.47,1.38 -1.1,1.81 -0.7,1.17 -0.02,2.61 0.19,3.8 -0.54,0.27 -0.67,0.87 -0.23,1.29 0.25,0.76 -0.98,0.37 -1.38,0.51 -0.66,0.04 -1.53,0.48 -1.58,1.14 0.54,0.28 0.83,0.79 0.41,1.3 -0.19,0.52 -0.88,0.55 -0.9,1.2 -0.04,0.86 -0.81,1.22 -1.32,1.77 -0.09,0.74 -1.07,-0.08 -1.35,0.49 -0.61,0.05 -1.66,-0.73 -1.84,0.26 -0.47,0.29 -1.16,0.32 -1.67,0.6 -1.06,0.23 -2.23,0.15 -3.18,-0.35 -0.42,0.11 -0.66,0.98 -1.13,0.36 -0.72,-0.55 -2.01,-0.02 -1.95,0.94 -0.1,0.61 -0.67,0.77 -1.15,0.91 -0.13,0.31 -0.36,1.02 -0.76,0.53 -0.49,-0.08 -1.32,-0.82 -1.65,-0.2 0.03,0.69 -1.26,-0.18 -1.23,0.64 0.06,0.85 -0.02,1.91 0.32,2.62 0.53,0.12 1.43,-0.67 1.76,-0.05 0.31,0.8 -0.58,1.19 -0.61,1.88 0.3,0.73 -0.98,0.39 -1.07,1.04 -0.4,0.82 0.55,1.19 1.14,1.44 1.12,0.59 1.41,1.87 1.57,3 -0.32,1.41 -2.18,1.9 -2.47,3.3 0.2,1.04 1.98,1.52 1.58,2.71 -0.4,0.4 -0.99,1.09 -0.29,1.54 0.82,0.38 1.41,1.76 2.44,1.47 0.49,-0.23 0.25,-1.53 0.98,-1.07 0.95,0.48 1.85,1.12 2.93,1.2 0.96,0.64 0.98,2.08 1.28,3.12 0.28,0.97 0.52,2.32 1.78,2.36 0.39,0.08 0.74,0.21 0.68,0.63 0.23,0.59 0.94,0.4 1.01,-0.15 0.52,-0.69 1.93,-0.53 1.72,-1.72 -0.12,-0.56 0.37,-1.43 0.97,-0.98 0.21,1.08 1.61,0.57 2.37,0.69 0.59,-0.04 1.34,0.03 1.3,0.75 0.74,0.65 2.04,0.17 2.65,-0.47 0.63,-0.71 1.76,0.02 2.58,-0.21 0.8,-0.38 1.77,-0.35 2.53,0.14 0.49,-0.01 0.93,-0.51 1.4,-0.04 0.89,0.75 1.95,-0.33 2.85,-0.09 -0.08,0.51 0.31,0.72 0.69,0.85 0.7,0.65 0.89,1.6 1.09,2.46 0.75,0.52 1.91,-0.79 2.45,0.21 0.82,0.9 2.21,0.95 2.84,2.04 0.98,0.64 1.87,-0.7 2.78,-0.87 0.61,-0.33 1.32,-0.4 1.58,0.39 0.57,0.76 1.23,1.52 2,2.03 1.16,-0.37 2.74,-0.69 3.57,0.46 0.67,0.23 1.34,0.54 1.65,1.24 0.29,0.48 0.04,1.22 0.75,1.43 0.61,0.3 1.38,0.66 1.28,1.47 0.06,1.3 1.7,1.03 2.49,0.62 0.98,-0.6 0.29,-2.05 0.7,-2.95 0.17,-0.6 0.63,0.37 0.91,0.41 0.74,0.23 1.52,0.5 1.92,1.27 0.23,0.74 1.11,1.14 1.7,0.54 0.58,-0.6 1.25,-1.09 2.09,-1.2 -0.04,-0.61 -1.7,-1.29 -0.88,-1.95 0.67,-0.15 1.37,-0.27 2.04,-0.49 0.56,-0.25 0.96,-0.92 1.65,-0.49 0.49,0.22 1.66,0.41 1.51,-0.47 -0.04,-0.72 -0.62,-1.13 -1.02,-1.57 -0.26,-0.88 -0.5,-1.9 -0.37,-2.8 0.81,-0.37 0.57,-1.45 -0.31,-1.44 -0.78,-0.52 -0.13,-1.71 -1.04,-2.12 -0.52,-0.39 -1.34,-0.74 -1.18,-1.52 -0.36,-0.49 -0.93,0.62 -1.26,-0.09 -0.52,-0.87 0.31,-1.8 0.13,-2.75 0.03,-0.88 1.52,-0.46 2.22,-0.69 0.83,-0.02 1.82,0.21 2.39,-0.51 0.86,-0.61 1.9,-0.88 2.91,-1.03 0.36,-0.46 0.24,-1.26 -0.15,-1.65 -0.11,-0.47 -0.41,-1.21 0.27,-1.34 0.86,-0.61 0.12,-1.79 -0.75,-1.85 -0.46,-0.05 -0.54,-0.41 -0.14,-0.62 0.39,-0.58 0.06,-1.35 0.42,-1.94 0.2,-0.61 1.24,-0.34 1.59,-0.92 0.42,-0.86 1.43,-1.22 1.98,-1.93 0.82,-0.28 0.91,-1.31 1.54,-1.8 0.05,-0.98 -0.15,-2.16 -0.89,-2.85 -0.27,-0.49 0.28,-0.63 0.44,-0.93 -0.31,-0.46 -1,-0.68 -1.12,-1.32 -0.47,-0.89 -2.05,-0.91 -1.92,-2.15 -0.1,-0.65 -0.46,-1.21 -0.61,-1.85 -0.19,-0.38 -1.02,-0.12 -0.74,-0.74 0.61,-0.73 -0.31,-1.57 -1.06,-1.39 -0.33,-0.68 -1.34,-0.38 -1.75,-1.02 -0.81,-0.78 -2.08,0 -3.07,0.03 -1.53,0.1 -2.46,2.25 -4.06,1.67 -0.46,-0.63 0.05,-1.43 0.12,-2.05 -0.63,-0.42 -1.69,-0.14 -2.22,0.35 -0.14,0.37 0.17,0.88 -0.42,0.97 -0.99,0.26 -1.53,1.42 -2.65,1.22 -0.54,-0.04 -1.05,0.64 -1.44,0.01 -0.47,-0.6 -1.22,-1.04 -1.97,-0.59 -0.7,0.25 -1.52,0.29 -2.06,-0.25 -0.85,-0.34 -1.7,0.17 -2.3,0.72 -1.01,0.04 -2.06,-0.22 -3.01,0.2 -0.66,0.05 -0.42,-0.7 0.02,-0.87 0.79,-0.34 0.72,-1.68 1.57,-1.82 0.47,0.46 1.36,0.11 1.05,-0.59 -0.42,-0.9 0.64,-1.7 0.26,-2.66 0.02,-0.46 -0.26,-0.86 -0.45,-1.16 -0.13,-0.66 -1.14,-0.19 -1.28,-0.92 -0.54,-0.97 -2.23,-0.07 -2.57,-1.3 -0.34,-1.07 0.17,-2.63 -0.9,-3.34 -0.8,0.15 -1.79,0.82 -2.48,0.01 -0.45,-0.32 -1.11,-1.52 -1.65,-0.75 -0.36,0.54 -0.61,1.59 -1.45,0.93 -0.7,-0.3 -1.04,0.81 -1.56,0.81 -0.05,-0.42 -0.07,-0.95 -0.38,-1.2 0.42,-0.92 -0.79,-0.85 -1.2,-1.35 -0.08,-0.06 -0.2,-0.09 -0.3,-0.07 z",
                        "department-41" : "m 44.14,53.49 c -1.43,0.14 -2.26,1.6 -3.36,2.2 -0.25,-0.38 -0.54,-1.18 -1.11,-0.7 -1.14,0.83 -2.78,-0.17 -3.93,0.59 -0.12,0.43 0.58,0.46 0.35,1 0.11,0.69 -0.45,1.1 -1.09,0.95 -1.17,-0.38 -1.18,0.64 -1.05,1.49 0.02,0.84 0.92,1.17 1.61,0.9 0.83,1.04 -0.37,2.32 -0.56,3.35 0.55,0.77 1.28,1.79 1.1,2.78 -0.62,0.31 -1.59,0.46 -1.57,1.39 -0.15,0.64 0.34,1.46 0.09,2 -0.67,-0.05 -0.85,-0.78 -1.24,-1.14 -0.7,0.1 -1.64,0.62 -1.24,1.47 0.03,0.89 0.21,1.79 0.65,2.55 0.04,0.57 -0.11,1.15 -0.77,1.13 -0.77,0.22 -0.51,1.19 -1.13,1.58 -0.46,0.54 -0.96,1.13 -1.61,1.32 -0.32,0.44 0.68,1.22 -0.1,1.39 -0.7,-0.1 -1.46,-0.11 -1.91,0.55 -0.5,0.45 -1.61,0.29 -1.57,1.2 -0.2,0.65 -0.72,1.05 -1.34,1.23 -0.46,0.57 0.2,1.29 0.39,1.85 0.79,0.27 1.06,-1.48 1.85,-1.04 0.43,0.26 0.61,0.75 0.48,1.21 0.55,0.38 0.91,-1 1.51,-0.41 0.63,0.52 1.35,1.04 1.96,0.2 0.91,-0.53 1.83,0.6 2.78,0.57 1.14,0.28 2.41,0.43 3.4,-0.31 0.49,-0.11 -0.02,0.83 -0.01,1.04 -0.18,0.86 -1.05,1.87 -0.08,2.51 0.24,0.37 0.08,0.73 -0.24,0.88 -0.07,0.89 1.24,1.78 1.85,0.94 0.14,-0.67 0.77,-1.13 1.16,-1.65 0.71,0.2 1.45,0.29 2.18,0.25 0.27,0.38 0.81,0.35 1.12,0.59 -0.1,0.76 -0.42,1.65 0.25,2.3 0.52,-0.35 0.63,-2.05 1.66,-1.42 0.69,0.76 1.03,1.95 1.99,2.39 0.15,1.02 -1.2,1.55 -1.26,2.45 0.54,0.57 1.15,1.13 1.15,1.96 0.39,0.85 0.52,2.17 1.5,2.51 0.65,0.08 0.89,0.88 1.27,1.29 -0.41,0.66 -1.02,1.14 -1.7,1.45 0.04,0.55 0.65,0.98 0.79,1.57 0.23,0.48 0.64,1.08 0.03,1.47 -1.11,0.8 1.18,1.47 -0.12,2.42 -0.62,0.82 -0.84,2.33 0.23,2.87 0.86,0.13 1.29,1 1.89,1.49 0.35,-0.44 0.75,-0.99 1.4,-0.68 0.79,0.12 1.42,-0.91 2.15,-0.21 0.71,0.31 0.28,1.33 0.99,1.71 1.45,0.8 1.8,2.63 2.63,3.95 0.26,1.22 1.6,0.49 2.36,0.21 1.65,-0.56 2.48,-2.58 4.36,-2.51 0.58,-0.1 1.13,0.03 1.6,0.27 0.55,-0.22 1.38,1.21 1.45,0.25 0.03,-0.58 -0.69,-1.7 0.27,-1.82 0.75,-0.37 1.71,0.06 2.4,-0.38 0.03,-0.47 0.31,-0.89 0.87,-0.8 0.68,0.08 1.66,-0.04 2.1,0.55 0.21,0.84 1.41,0.35 1.95,0.12 0.51,-0.12 0.99,-1.2 1.35,-0.27 0.85,0.81 1.54,2.39 2.89,2.35 0.87,-0.49 1.58,0.73 2.43,0.84 0.81,-0.13 1.32,1.11 2.13,0.57 0.66,-0.21 1.61,-1.24 0.98,-1.87 -0.43,-0.09 -1.03,-0.57 -0.49,-0.96 0.47,-0.31 1.09,-0.57 1.14,-1.21 0.37,-0.82 0.98,-1.43 1.75,-0.58 0.84,0.6 1.8,1.33 2.91,0.9 1.17,-0.46 2.31,-1.31 3.65,-1.01 0.47,0.24 1.16,0.52 1.35,-0.19 0.43,-0.48 1.18,-1.19 0.49,-1.81 -0.44,-0.6 -1.39,-1.11 -1.04,-1.98 0.03,-0.71 -0.4,-1.47 -1.07,-1.62 -0.16,-1.2 0.65,-2.28 0.83,-3.37 0.49,0.3 0.94,1.18 1.47,0.39 0.58,-0.44 1.16,-1.05 1.81,-1.32 0.41,0.66 0.56,2.01 1.66,1.68 1.03,-0.14 0.92,-1.63 0.83,-2.41 -0.52,-0.97 0.3,-2.38 -0.45,-3.26 -0.57,-0.25 -1.12,0.49 -1.61,0.4 0.08,-1.02 0.94,-2.09 0.23,-3.13 -0.18,-1.28 -1.73,-0.64 -2.63,-0.92 -0.55,0.02 -1.19,-0.32 -0.99,-0.97 0.19,-0.48 -0.58,-1.34 0.18,-1.49 0.97,-0.83 2.18,-1.22 3.39,-1.58 0.82,-0.28 2,-0.82 1.6,-1.9 -0.14,-0.68 -0.61,-1.52 -1.35,-1.57 0.03,-0.44 -0.18,-1.09 -0.74,-0.72 -0.93,0.33 -1.91,0.14 -2.8,-0.1 -0.44,0.13 -0.87,0.68 -1.26,0.1 -0.52,-0.46 -1.27,-0.49 -1.76,-0.04 -1.01,0.22 -2.51,-0.65 -3.08,0.57 -0.31,0.37 -0.9,0.04 -1.26,0.41 -0.66,0.26 -1.4,-0.08 -1.53,-0.8 -0.51,-0.49 -1.33,0.05 -1.96,-0.19 -0.57,-0.08 -1.45,0.03 -1.53,-0.71 -0.64,-0.38 -0.63,0.83 -0.65,1.19 0.2,1.14 -1.5,0.63 -1.87,1.56 -0.13,0.68 -0.85,0.63 -1.11,0.07 -0.14,-1.01 -1.73,-0.48 -1.97,-1.48 -0.11,-0.74 -0.77,-1.37 -0.71,-2.11 0.09,-0.76 -0.41,-1.44 -0.55,-2.15 -0.71,-0.83 -2.02,-0.37 -2.72,-1.24 -0.31,-0.4 -1.15,-0.68 -1.2,0.07 -0.21,0.79 -1.26,1.24 -1.93,1.32 0.02,-0.36 0.79,-0.58 0.32,-1.01 -0.6,-0.63 -1.31,-1.16 -1.97,-1.74 0.8,-0.54 1.29,-1.76 0.42,-2.48 -0.32,-0.4 -0.93,-0.67 -1.32,-0.88 0.14,-1.71 2.49,-2.29 2.63,-4 -0.42,-0.72 -0.19,-1.75 -1.04,-2.24 -0.49,-0.64 -1.99,-0.64 -1.75,-1.7 0.09,-0.69 1.09,-0.73 1.15,-1.45 0.44,-0.37 1.05,-1.42 0.29,-1.72 -1.24,0.29 -2.73,0.45 -3.63,-0.59 -0.47,-0.2 -1.14,-1.23 -1.63,-0.69 -0.4,0.78 0.48,2.24 -0.75,2.28 -0.55,0.33 -1.03,-0.03 -1.53,-0.22 -0.63,0.15 -0.45,1.45 -1.14,1.39 -0.82,-0.8 -1.8,0.34 -2.66,0.04 -0.19,-0.79 -1.02,-0.81 -1.68,-0.62 -0.63,-0.03 -0.76,-1.08 -1.52,-0.86 -0.57,-0.05 -1.39,0.88 -1.83,0.32 -0.07,-0.84 -0.27,-1.83 -1.13,-2.18 -0.5,-0.49 -0.29,-1.43 -1.16,-1.55 -0.81,-0.24 -1.54,-0.83 -1.54,-1.71 -0.58,-0.5 0.22,-2.01 -1,-1.54 -0.46,0.11 -0.99,0.21 -1.27,-0.26 -1.01,-0.45 -2.49,0.19 -3.26,-0.74 0.28,-1.07 1.9,-1.1 2.33,-2.04 -0.1,-0.36 -0.62,-0.53 -0.95,-0.51 z",
                        "department-36" : "m 70.62,110.2 c -0.72,0.12 0.12,1.45 -0.88,1.04 -0.76,0.1 -2.19,-0.34 -2.48,0.65 -0.03,0.6 0.44,1.31 0.2,1.84 -0.74,-0.15 -1.32,-0.9 -2.15,-0.98 -1.28,-0.5 -2.59,0.19 -3.4,1.17 -1.02,0.85 -2.2,1.58 -3.51,1.81 -0.41,0.59 0.63,1.09 0.66,1.7 0.45,1.19 1.29,2.94 0.09,3.96 -0.45,0.49 -1.68,-0.08 -1.58,0.87 0.13,0.61 -0.08,1.38 -0.8,1.39 -0.37,0.4 -0.67,0.91 -0.98,1.38 0.01,1.07 -1.06,1.92 -1.99,2.28 -0.47,-0.03 -0.69,-0.76 -1.24,-0.75 -0.69,-0.18 -1.13,-1.11 -1.96,-0.76 -0.98,0.28 -1.84,0.92 -2.87,0.93 -0.88,0.21 -1.04,1.25 -1.62,1.73 -0.66,0.43 -0.6,1.35 -0.17,1.91 0.22,0.76 -0.25,1.54 -0.97,1.79 -0.39,0.99 -0.12,2.18 -0.45,3.2 -0.42,1.35 -0.26,2.8 -0.81,4.1 -0.06,0.74 -0.37,1.42 -0.9,1.92 0.05,0.49 0.65,0.82 0.45,1.37 -0.04,0.49 0.69,1.14 0.28,1.54 -0.47,0.1 -1.23,-0.32 -1.38,0.34 -0.39,0.43 -0.97,1.32 -1.63,1.04 -0.33,-0.65 -0.85,-1.32 -1.68,-1.13 -0.52,-0.07 -1.82,0.12 -1.3,0.9 0.66,0.23 1.44,0.59 1.62,1.36 0.06,0.75 1.04,1.75 0.04,2.26 -0.45,0.72 0.09,1.65 -0.03,2.38 -0.72,0.64 -0.81,1.64 -0.32,2.46 0.14,0.7 0.75,1.05 1.33,1.29 0.13,1.01 1.31,1.23 2.14,1.39 0.35,0.47 0.97,0.28 1.42,0.33 0.48,0.5 0.26,1.37 0.73,1.83 1.26,0.38 2.83,-0.4 3.82,0.76 0.52,0.55 1.37,1.07 1.62,1.76 -0.76,0.52 -0.17,1.3 0.08,1.91 -0.84,0.43 -0.12,1.43 0.51,1.65 0.48,0.26 1.25,0.42 1.19,1.11 0.29,0.31 0.93,-0.58 1.12,-0.07 -0.29,0.73 -0.77,1.43 -0.8,2.21 -0.11,0.38 -0.94,0.88 -0.46,1.23 0.43,0.09 1.06,-0.94 1.33,-0.32 -0.19,0.78 0.79,1.61 1.37,0.85 0.78,-1.03 2.63,0.64 3.16,-0.78 0.06,-0.37 -0.03,-0.77 0.49,-0.81 0.61,-0.25 1.34,-0.6 1.75,0.14 0.92,0.86 1.78,1.85 2.49,2.86 0.93,0.03 0.91,-1.44 1.82,-1.6 0.65,-0.49 0.98,-1.29 1.72,-1.65 0.58,-0.47 0.76,-2.04 1.75,-1.61 0.71,0.34 0.65,1.21 0.72,1.85 0.65,-0.17 1.18,-0.89 1.92,-0.94 0.41,-0.29 1.01,-1.23 1.41,-0.45 -0.26,0.74 0.02,2.25 1.09,1.84 0.72,-0.45 0.99,-1.59 1.81,-1.85 0.61,0.5 0.89,1.71 1.8,1.71 1.26,-0.76 1.72,-2.42 1.28,-3.78 0.87,-0.51 2.26,-0.62 2.79,0.45 0.36,0.61 1.35,1.28 1.9,0.55 0.53,-0.01 1.17,0.16 1.55,-0.3 0.62,-0.29 1.36,-0.34 1.85,0.18 1.02,0.22 2.18,-0.72 3.06,0.15 1.4,0.69 3.16,0.49 4.4,1.51 0.67,0.09 0.95,-0.86 1.67,-0.69 0.51,0 1.55,-0.07 1.27,-0.84 -0.27,-0.64 -0.43,-1.58 0.4,-1.87 0.73,-0.4 2.12,-0.92 1.57,-2.01 -0.13,-0.65 -0.88,-0.96 -0.75,-1.67 -0.11,-0.97 -1.05,-1.78 -0.98,-2.73 0.92,-0.67 -0.18,-2.01 0.72,-2.73 0.51,-0.76 0.13,-1.71 0.39,-2.53 -0.37,-0.5 -1.11,-0.67 -1.5,-1.22 -0.3,-0.38 -1.13,-0.85 -0.51,-1.34 0.95,-0.67 -0.16,-1.4 -0.72,-1.86 -0.56,-0.42 -1.91,0.13 -1.73,-0.96 -0.13,-0.8 -1.71,-1.6 -0.55,-2.27 1.04,-0.09 2.13,-1.53 1.26,-2.43 -0.79,-0.94 -2.22,-1.61 -2.43,-2.9 0.55,-0.23 1.35,-0.16 1.62,-0.85 0.38,-0.58 -0.07,-1.55 0.84,-1.76 0.99,-0.43 2.24,-1.33 2.1,-2.54 -0.67,-0.52 -1.72,0.31 -2.35,-0.4 -0.78,-0.46 -1.77,-1.21 -1.27,-2.25 0.57,-0.44 0.92,-1.08 0.93,-1.83 0.13,-0.66 0.99,-1.41 0.2,-1.98 -0.84,-0.83 -1.8,-1.63 -2.85,-2.07 -0.47,-0.95 1.03,-1.65 0.85,-2.66 -0.08,-0.43 0.01,-1.75 -0.75,-1.4 -0.23,0.45 -1.18,0.94 -1.34,0.21 -0.07,-0.71 -0.38,-1.82 -1.34,-1.46 -1.04,0.04 -1.78,1.03 -2.74,1.17 -0.77,-0.29 -1.57,0.61 -2.3,-0.02 -0.99,-0.36 -1.77,-1.39 -2.92,-1 -0.46,-0.07 -0.99,-0.4 -1.18,-0.77 0.63,-0.79 1.4,-1.52 1.79,-2.43 0.33,-0.52 1.2,-0.53 1,-1.33 -0.08,-0.95 0.31,-2.22 -0.89,-2.57 -0.44,-0.35 -1,-0.58 -1.5,-0.27 -1.44,-0.31 -2.16,-1.8 -3.13,-2.74 -0.78,0.68 -2.15,1.29 -3.08,0.61 -0.11,-0.9 -1.4,-0.45 -2.01,-0.72 -0.08,-0.01 -0.15,-0.01 -0.23,0 z",
                        "department-18" : "m 101.75,86.94 c -1.92,0.11 -3.54,1.27 -5.37,1.69 -0.93,0.41 -2.09,1.18 -1.66,2.37 -0.17,1.33 1.48,0.72 2.29,0.94 1.18,-0.17 1.51,1.19 1.65,2.07 -0.01,0.57 -1,1.81 0.08,1.6 0.44,-0.12 1.76,-0.16 1.38,0.62 -0.42,1.62 0.58,3.54 -0.44,5.01 -0.55,0.42 -1.65,0.44 -1.74,-0.45 -0.14,-0.51 -0.61,-1.32 -1.12,-0.63 -0.62,0.31 -1.11,1.23 -1.81,1.24 -0.47,-0.51 -1,-0.01 -1.07,0.53 -0.22,0.6 -0.86,1.75 0.06,2.01 0.61,0.65 0.62,1.55 0.68,2.35 0.38,0.74 1.43,1.31 1.35,2.19 -0.66,0.46 -1.11,1.9 -2.14,1.23 -1.54,-0.67 -2.86,0.9 -4.31,1.06 -1.34,0.13 -2.23,-1.3 -3.5,-1.28 -0.69,0.37 -0.45,1.5 -1.31,1.74 -0.51,0.09 -0.91,0.78 -0.19,0.87 0.97,0.62 0.13,1.97 -0.7,2.26 -0.66,0.74 -1.07,-0.04 -1.61,-0.41 -0.76,-0.41 -0.84,0.78 -0.73,1.26 0.05,0.7 0.4,1.52 -0.51,1.62 -0.88,0.62 -1.25,1.72 -1.9,2.54 -0.33,0.89 0.98,0.88 1.52,0.89 1.18,0.21 2.15,1.53 3.4,1.08 1.2,0.09 2.13,-0.66 3.14,-1.15 0.51,-0.04 1.13,-0.24 1.59,-0.16 0.05,0.59 0.72,0.82 0.44,1.45 -0.02,0.69 0.9,0.48 1.09,0.03 0.41,-0.15 1.28,-0.35 1.02,0.44 0.08,0.78 0.27,1.71 -0.44,2.27 -0.34,0.39 -0.88,1.35 -0.01,1.37 1.04,0.74 2.32,1.48 2.86,2.68 0.02,0.88 -0.99,1.57 -0.72,2.51 -0.35,0.51 -1.18,0.99 -0.73,1.74 0.59,0.93 1.71,1.72 2.83,1.3 0.51,-0.19 1.07,0.22 0.75,0.75 -0.36,1.28 -1.55,1.87 -2.61,2.45 -0.28,0.49 0.05,1.16 -0.46,1.59 -0.32,0.65 -1.35,0.57 -1.55,1.11 0.7,0.88 1.64,1.49 2.41,2.25 0.47,0.53 0.74,1.28 0.1,1.81 -0.32,0.66 -1.01,0.86 -1.58,1.18 -0.39,0.88 1.24,1.21 0.97,2.19 0.4,0.57 1.4,0.03 1.78,0.75 0.25,0.51 1.45,0.58 0.91,1.29 -0.66,0.65 -0.71,1.33 0.16,1.85 0.35,0.59 1.47,0.5 1.52,1.27 -0.35,0.79 0.22,1.88 -0.3,2.55 -1.1,0.51 0.13,1.99 -0.76,2.7 -0.13,0.96 0.92,1.73 0.81,2.74 0.12,0.68 0.94,0.98 0.92,1.74 0.32,1.2 -1.06,1.66 -1.89,2.07 -0.87,0.83 0.03,2.76 1.31,2.26 0.6,-0.51 1.44,0.21 2.14,-0.05 0.57,-0.3 1.39,0.53 1.76,-0.1 0.26,-1.1 0.64,-2.38 1.37,-3.19 0.54,0.71 1.26,-0.06 0.93,-0.72 0.24,-1.02 1.23,-1.93 2.24,-2.18 0.93,0.07 1.81,-0.21 2.67,-0.47 0.91,0.57 1.72,-0.36 2.61,-0.44 0.4,0.25 0.85,0.74 1.27,0.2 0.52,-0.1 0.94,0.89 1.44,0.19 0.86,-0.66 2.2,-0.97 2.59,-2.06 -0.01,-0.84 0.02,-2.16 -0.97,-2.41 -0.17,-0.32 -0.52,-0.72 -0.66,-0.93 0.25,-0.37 0.79,-0.58 0.64,-1.12 0.39,-0.42 0.71,-1.53 -0.19,-1.5 -0.45,-0.01 -0.84,-0.53 -0.29,-0.77 0.51,-0.2 1.46,-1.04 1.8,-0.2 0.51,0.71 1,-0.58 0.46,-0.9 -0.34,-0.51 0.23,-1.19 0.79,-0.91 0.54,-0.11 0.86,-0.64 1.37,-0.81 0.36,-0.58 0.64,-1.24 1.33,-1.49 0.33,-0.42 0.14,-1.12 0.84,-1.25 0.9,-0.75 1.19,0.75 1.67,1.21 0.63,0.75 1.46,-0.1 1.94,-0.56 0.68,-0.3 1.87,0.41 2.2,-0.5 0.6,-0.61 1.21,-1.26 1.75,-1.91 0.64,-0.26 1.11,-0.78 1.48,-1.33 0.56,-0.59 1.63,0.19 1.96,-0.71 0.53,-0.37 1.36,0.17 1.98,0.07 0.52,-0.1 1.35,0.6 1.52,-0.24 0.42,-0.71 1.09,-1.37 0.96,-2.27 0.23,-0.6 0.71,-1.12 0.48,-1.83 -0.01,-1.02 -0.41,-1.97 -0.69,-2.91 0.13,-1.09 0.89,-1.96 1.11,-2.98 -0.1,-0.91 -0.86,-1.67 -0.46,-2.64 0.22,-1.12 0.68,-2.63 -0.49,-3.39 -0.64,-0.63 -1.98,-0.9 -1.45,-2.03 0.18,-1.39 0.45,-2.9 -0.24,-4.19 -0.04,-2.12 -1.21,-4.05 -1.76,-6.05 -0.17,-0.91 0.63,-2.17 -0.53,-2.62 -1.39,-0.85 -2.18,-2.44 -3.76,-2.99 -0.99,-0.66 -0.78,-2.2 -0.02,-2.97 0.81,-1.35 1.34,-2.85 1.77,-4.31 0.61,-1.16 -0.48,-2.37 -0.96,-3.39 -0.62,-0.75 -0.35,-2.18 -1.35,-2.57 -1.12,-0.04 -1.74,1.08 -2.66,1.46 -1.21,0.25 -1.23,-1.44 -2.2,-1.76 -0.46,-0.35 -1.11,-0.16 -1.45,-0.63 -0.75,0.18 -0.31,1.35 -0.37,1.92 0.1,0.96 -1.26,1.09 -1.94,1.26 -0.88,0.22 -1.44,-0.62 -1.45,-1.39 -0.18,-0.97 -1.62,-0.88 -1.87,-1.72 0.12,-1.04 -0.84,-1.86 -1.78,-2 -0.45,-0.6 -1.16,-0.99 -1.94,-0.77 -0.75,0.01 -1.66,0.8 -2.13,-0.13 -0.77,-0.64 -1.37,-1.48 -1.96,-2.24 -1.19,0.09 -2.12,1.19 -3.26,1.38 -0.79,-0.36 -1.28,-1.27 -2.2,-1.44 -0.68,-0.27 -1.13,-1.18 -1.9,-1.13 z"
                    }
                }
            }
        }
    );

    return Mapael;

}));