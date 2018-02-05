%% .map file reader

file='~/git/Cryp-EM/DB/EM/EMD-1003/map/emd_1003.map';
[map,s,mi,ma,av]=ReadMRC(file);
imshow3D(map);

%%