function rgbcode = colors(colorinput)
%Get select decimal RGB triplets from color names as surveyed by Randall Munroe
%Color list can obviously be expanded as desired (from rgb.txt file)

colorlist={'warm purple';'sea green';'dark green blue';'teal';'dark red';'pale blue';...
    'neon green';'rose';'light pink';'indigo';'lime';'olive green';'peach';'light brown';...
    'hot pink';'black';'lilac';'navy blue';'beige';'salmon';'maroon';'bright green';...
    'forest green';'aqua';'cyan';'tan';'dark blue';'lavender';'turquoise';'violet';...
    'light purple';'lime green';'gray';'grey';'sky blue';'yellow';'magenta';'light green';...
    'orange';'light blue';'red';'brown';'pink';'blue';'green';'purple';'dark orange';
    'gold';'mint';'light orange';'dark brown';'light red';'crimson';'fuchsia';'dark magenta';
    'bright red';'dark turquoise';'chocolate';'orange red';'emerald';'jade';'auburn';'ruby';
    'dark green';'white';'light grey';'light gray';'ochre';'dark yellow';'sand';'khaki';'burgundy';
    'light pink';'very light gray';'ghost white'};
rgblist={'952e8f';'53fca1';'1f6357';'029386';'840000';'d0fefe';
    '0cff0c';'cf6275';'ffd1df';'380282';'aaff32';'677a04';'ffb07c';'ad8150';
    'ff028d';'000000';'cea2fd';'001146';'e6daa6';'ff796c';'650021';'01ff07';
    '06470c';'13eac9';'00ffff';'d1b26f';'00035b';'c79fef';'06c2ac';'9a0eea';
    'bf77f6';'89fe05';'929591';'929591';'75bbfd';'ffff14';'c20078';'96f97b';
    'f97306';'95d0fc';'e50000';'653700';'ff81c0';'0343df';'15b01a';'7e1e9c';'c65102';
    'dbb40c';'9ffeb0';'fdaa48';'341c02';'ff474c';'8c000f';'ed0dd9';'960056';
    'ff000d';'045c5a';'3d1c02';'fd411e';'01a049';'1fa774';'9a3001';'ca0147';
    '033500';'ffffff';'d8dcd6';'d8dcd6';'bf9005';'d5b60a';'e2ca76';'aaa662';'610023';
    'ffd1df';'faebd7';'f8f8ff'};



matchfound=0;
%disp(colorinput);
for rr=1:length(colorlist)
    if strcmp(colorinput,colorlist(rr))
        %disp('Match found');
        matchfound=1;
        rgbcode=rgblist(rr);
    end
end
if matchfound==0
    disp('Sorry, no matches');
end
rgbcode=hex2rgb(rgbcode)/255; %on a 0-to-1 scale as required by Matlab
    

end

