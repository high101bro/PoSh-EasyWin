/*!
*
* Jquery Mapael - Dynamic maps jQuery plugin (based on raphael.js)
* Requires jQuery and Mapael
*
* Map of Paris by district (with Bois de Boulogne and Bois de Vincennes)

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
            maps :{
                paris_districts : {
                    width : 867.55469,
                    height : 465.94473,
                    getCoords : function (lat, lon) {
                        // TODO
                        return {x : lat, y : lon};
                    },
                    elems : {
                        "district-75101" : "m 387.31065,229.36801 11.13736,4.76664 6.81561,5.00795 8.46022,10.02602 3.30159,3.39843 9.17115,4.60997 6.68777,-12.93169 13.99444,-38.40607 -47.32341,-17.0907 -13.99442,-3.64856 -14.3628,-4.41671 -3.49861,-2.68842 -2.57793,-2.88046 -4.41924,-4.60872 -15.83585,4.41668 -13.18122,31.0192 6.4606,2.07437 20.13297,11.32476 29.03177,10.02731 z",
                        "district-75102" : "m 446.58174,205.96922 13.54134,-35.71171 -55.0767,-12.89967 -44.39994,13.03544 6.64046,7.19667 4.16654,3.39463 11.97885,3.39465 8.46335,2.44417 6.64042,1.49364 48.04568,17.65218 z",
                        "district-75103" : "m 496.05972,180.03408 12.62982,28.65083 4.03629,41.55053 -9.37472,-2.85151 -7.35675,-2.86738 -5.5335,-2.15674 -9.11437,-5.83878 -8.33318,-8.6903 -9.37467,-6.92506 -16.14541,-5.56723 -3.64582,-1.22208 16.27567,-43.99465 32.29081,8.28294 z",
                        "district-75105" : "m 489.56799,341.2573 -38.82234,18.68629 -53.39986,-15.36241 28.81241,-87.30815 9.74654,4.88038 10.41942,5.555 5.73376,2.62523 7.5725,3.2266 6.26589,2.65684 6.7874,3.47302 7.28109,4.63522 3.18907,4.08698 8.8386,9.98557 7.84634,8.52512 -10.27082,34.33431 z",
                        "district-75107" : "m 324.5806,204.60623 7.38094,1.32652 6.21409,2.27525 20.01243,11.17063 18.68069,6.55508 8.69509,3.06037 -20.44221,45.88007 -7.27342,2.78446 -17.67722,13.82618 -11.41659,7.10512 -6.9972,6.14496 -8.93066,4.6087 -7.91794,-6.24096 -4.69546,-4.32069 -4.87965,1.63229 -5.33997,2.97644 -2.02555,0 -12.88963,-12.77001 -49.93184,-43.73362 3.00236,-5.00163 18.76171,-24.17562 14.41373,-7.83787 28.27191,-5.31633 z",
                        "district-75108" : "M 260.43936,209.8719 248.47049,168.29733 237.0539,147.65408 249.94352,120.86583 356.283,88.316696 l 0.46041,3.55255 -1.28902,5.56889 -1.02548,44.350194 1.82856,5.86574 -0.092,2.61009 -1.6445,1.73712 -9.51852,23.10289 -13.29141,31.06608 -7.19673,-1.5098 -34.49862,-0.10488 -29.57629,5.31633 z",
                        "district-75109" : "m 435.9225,164.50473 -30.88907,-7.20113 -58.92404,17.42674 -0.64443,-0.48007 -0.13817,-0.19204 9.299,-22.46754 1.74935,-1.44021 0.13804,-2.4964 -2.07155,-5.71291 1.01275,-44.695064 1.38101,-5.56888 -0.64443,-3.26452 5.06379,-1.68025 3.08426,-3.74459 1.97955,0 34.06545,13.53812 2.34777,0 30.01442,-9.02541 8.24018,-0.5761 0.18418,22.755624 -4.23527,22.32349 -0.87464,12.09793 -0.13816,20.40321 z",
                        "district-75110" : "m 440.71019,86.876456 20.89959,-2.6884 16.38826,-1.44023 3.77481,-0.76812 29.36989,0.48008 9.02285,12.38595 1.01268,24.291834 0.36833,2.01632 23.10927,32.06906 -6.35276,2.78445 -18.13752,11.04172 -5.70832,3.84066 -18.50582,9.12143 -3.86686,-1.72831 -32.22415,-8.16128 -23.93794,-5.66492 0.18416,-21.41134 0.82863,-11.90589 4.23528,-21.41139 -0.46037,-22.851624 z",
                        "district-75111" : "m 544.36576,153.14847 5.20814,7.06088 34.8949,42.63677 8.72374,29.05821 7.81233,3.39461 9.50495,7.06087 15.75475,31.09499 1.56243,12.35653 1.1719,4.61674 -47.52483,-8.55451 -13.80164,-0.81473 -19.92147,-5.15986 -5.98938,-1.0863 -17.44746,-8.6903 -10.80701,-7.19667 -4.68741,-50.10498 -12.62985,-28.78664 17.96826,-9.23345 8.59356,-5.56718 14.84336,-8.96193 6.77073,-3.12305 z",
                        "district-75112" : "m 676.86371,295.93344 -33.28182,-3.33281 -14.71313,-2.03681 -47.78523,-8.96187 -13.93201,-0.67891 -18.48905,-4.75253 -6.90088,-1.22205 -18.09853,-9.23344 -9.37469,-6.24614 -0.84379,0.0428 0.73648,6.04895 -1.74423,5.03828 -9.95625,28.61504 -2.53693,7.50813 21.26532,25.92914 17.51099,21.09681 15.42665,21.42906 20.8997,26.81607 10.1474,8.71519 13.00251,-10.90536 15.51912,-2.93603 12.79281,-7.54986 7.1304,0.20971 5.03326,4.40407 8.17899,11.7442 7.34014,5.24296 10.48587,2.72632 16.56771,0.20972 9.01792,5.03323 31.03825,-1.04858 20.97178,20.55236 -0.62915,3.14576 1.25832,1.67775 6.29153,-1.0486 3.14579,2.51663 -0.62917,4.61382 10.06644,-0.83891 7.75959,3.98466 28.73135,-1.25831 11.95399,5.45265 19.50367,-1.468 12.16369,-9.85676 13.00254,-45.71852 -2.72635,-0.41943 -3.77486,1.67774 0.83875,-16.98713 3.35558,-7.9693 6.92061,-7.1304 5.45276,-2.09719 2.09716,-16.14829 -7.1304,-13.42193 -10.69571,-14.05112 -7.1304,-4.61378 -21.60084,-5.87213 -34.39381,-6.72589 -2.09718,-5.0183 -19.02291,-0.87923 -1.73918,8.84853 -8.80815,-0.62916 -1.13547,15.92363 -17.0275,2.63947 -17.72426,-5.18151 -13.41143,-0.29661 -6.09235,-11.81615 -2.75178,-0.71601 -5.61148,5.31926 -0.62916,11.11505 4.19435,9.43731 3.98466,20.55236 -18.87462,10.48591 -7.96929,2.09718 -7.96927,-0.20973 -3.56524,-2.5166 5.87212,-5.87209 8.17899,-40.05614 2.93607,-16.98717 0.0232,-6.14101 z",
                        "district-75113" : "m 419.074,462.46003 2.30176,-7.7495 -5.34001,-15.65047 -1.74933,-13.44209 2.02546,-6.04898 -1.84131,-28.22847 -0.36834,-8.73735 2.94634,-32.45313 33.5129,9.69753 39.00652,-18.59916 10.37566,-34.44795 18.57479,22.37404 12.51636,14.87228 9.38843,12.0347 8.53932,12.00065 8.16093,10.80805 18.04055,22.71013 9.62357,8.96853 -12.5964,6.43108 -16.77744,9.85674 -10.48589,8.38871 -50.1226,24.11756 -8.59846,3.35549 -11.95391,-0.20973 -13.42197,-2.09716 -7.54984,-11.95395 -2.51661,0 -7.34013,6.29157 -9.64702,6.29154 -9.64704,-0.20975 0.20971,4.61381 -1.67773,-0.20972 -3.58828,-2.775 z",
                        "district-75114" : "m 284.16759,417.18377 2.60351,-10.48081 11.69268,-16.41859 5.98454,-7.39318 22.83305,-33.02921 15.65164,-19.87513 1.83025,1.44022 7.6305,-10.27361 44.76784,23.3317 20.07098,5.66488 -3.22239,32.35709 2.20961,37.15789 -1.93339,5.85694 1.84137,14.01821 5.24797,15.26639 -2.41945,7.67109 -5.3119,-2.48555 -32.71602,-0.41944 -0.62912,-9.43731 z",
                        "district-75115" : "m 136.27945,365.95718 36.99623,-57.46506 9.88224,-14.51853 14.92056,-14.16229 24.52588,-26.40159 1.5908,-4.92961 1.72885,-1.35178 46.02394,40.61187 16.11204,15.74645 1.84137,0 5.15597,-2.97642 5.06378,-1.7283 5.43202,4.80075 6.99721,5.47288 9.20685,-4.32068 30.751,16.03453 -7.82583,10.46564 -1.74935,-1.24819 -16.11203,20.73927 -22.28062,32.2611 -6.99723,8.2573 -10.77203,15.07437 -2.27621,11.3197 -14.08786,-5.04278 -29.15079,-10.27618 -13.21226,-6.29154 -15.93856,-12.79277 -21.18149,-11.5345 -3.14578,8.59842 -17.82601,17.82603 -18.03576,0.41944 -0.2097,-22.43983 8.80812,-6.71093 -8.38871,-6.71101 -15.84665,3.27424 z",
                        "district-75116" : "m 136.43034,365.64261 21.89657,-33.76694 24.9819,-38.00691 15.44484,-14.89631 24.00163,-25.77244 1.59075,-5.03448 3.72122,-6.48987 18.97733,-23.80029 8.44047,-5.03231 5.03381,-3.00396 -12.10914,-41.48259 -11.45801,-20.77526 -42.98203,-19.23786 -6.61099,1.5526 -66.48058,-13.42196 -11.95393,35.23265 -31.667404,-13.63169 -2.726328,-0.20974 -15.099705,24.32732 -26.214746,11.32477 -1.887462,-2.93606 -14.260821,19.71351 -7.549843,17.6163 L 0.5,239.15906 l 1.88746,10.06646 -1.048589,12.79282 52.010049,17.19687 9.227599,13.21222 25.585596,10.06646 10.69561,0.20971 0.41942,4.8235 -5.03322,9.64704 1.67777,4.4041 0.2097,19.29404 10.066475,12.16363 3.35547,9.01789 22.85927,3.98464 4.01773,-0.39583 z",
                        "district-75117" : "m 363.08078,5.968541 -1.73397,9.088581 -10.03546,53.672484 4.69547,17.66679 0,2.01631 -31.76368,9.69756 -17.21695,5.280814 -33.32886,10.17761 -23.75382,7.39318 -12.88962,26.69221 -41.48718,-18.96805 3.53619,-21.43958 2.72632,-6.92069 9.85679,-12.163664 26.63415,-20.34263 10.90535,-0.83886 44.25047,-34.81319 40.05618,-18.664901 10.48587,-6.710975 19.06274,-0.822999 z",
                        "district-75118" : "m 513.00815,1.105904 6.61851,16.120832 -0.13014,2.98731 -13.67148,53.09229 -6.38004,9.09765 -17.70797,-0.54312 -3.12488,0.95049 -17.83812,1.35786 -20.05151,2.98731 -7.94253,0.27158 -29.55656,9.09763 -2.99464,0 -33.9835,-13.4428 -1.82286,-0.1358 -2.86451,3.53044 -5.98948,2.17256 0.5208,-1.90101 -4.81758,-18.19529 10.15601,-53.907022 1.59131,-8.331257 31.75081,-0.992041 36.28121,-0.629153 18.66488,-1.677751 49.49344,-1.468026 13.79883,-0.442682 z",
                        "district-75119" : "m 654.64925,121.91773 -10.54658,5.43142 -11.06738,3.9378 -30.20754,2.30835 -17.0569,4.48092 -22.52546,8.41876 -18.61935,6.92506 -22.78584,-31.9097 -0.65096,-2.98729 -0.91151,-23.490974 -9.11437,-12.35653 -11.06739,-0.27156 -0.2604,-0.67892 5.72897,-8.01137 14.19238,-54.72174 -0.26041,-1.76522 L 512.92867,1.093858 566.94824,0.5 l 15.09968,5.24295 4.61381,0.419436 5.24296,2.306894 10.27618,10.066466 10.48589,22.64955 1.88748,14.05108 1.25827,13.42197 1.04862,5.6624 0.2097,16.5677 9.85676,15.938564 11.53447,5.03325 13.8414,4.82352 2.34579,5.23395 z",
                        "district-75120" : "m 676.00295,295.72369 -28.77538,-2.71571 -18.0984,-2.30835 -0.91151,-3.93778 -1.82285,-13.17126 -16.14539,-31.23078 -9.11437,-6.92506 -7.68213,-3.53042 -8.59353,-27.293 -0.52083,-1.76521 -17.18705,-21.31837 -18.09851,-21.45418 -4.42697,-6.65353 31.24918,-11.67758 10.67686,-3.93781 16.40582,-4.34514 30.20753,-2.17256 11.32791,-4.0736 9.97507,-5.2338 9.57926,17.77321 3.35547,13.2122 2.09719,68.99723 3.35548,16.77743 0.20974,14.0511 5.24295,29.15083 -2.30555,13.78214 z",
                        "district-75104" : "m 426.29692,256.983 6.95864,-13.75639 10.63729,-29.19277 19.43689,6.76531 9.94175,7.30081 7.65326,7.98124 9.53375,6.27709 12.22592,4.76579 10.01824,2.87286 0.74632,9.55098 0.71724,5.89095 -8.65484,25.06433 -3.06352,8.8076 -2.66877,8.03598 -20.10624,-23.20731 -14.45727,-8.21103 -12.10952,-5.14819 -7.15696,-3.2718 z",
                        "district-75106" : "m 385.36011,228.92237 13.36451,5.41552 6.79698,5.11043 11.38451,12.9959 9.18772,5.02391 -28.81041,87.05141 -44.77522,-23.75014 -30.94211,-15.94484 7.18831,-6.23465 11.05367,-6.87926 18.57483,-14.25673 6.29888,-2.41138 z"
                    }
                }
            }
        }
    );

    return Mapael;

}));