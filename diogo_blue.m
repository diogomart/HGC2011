function unclust = diogo_blue(red_fing, blue, props, img_id)

lbl_fingers = bwlabel(red_fing,4);
N_obj = max(max(lbl_fingers));
tips = []; bots = [];
img_out = 0;
unclust = red_fing;

for obj = 1 : N_obj

        check = check_finger(props.fingers(obj,:), props.palm(:,1));
	if check(3) == 2
		clust = blue;
		lbl = bwlabel(red_fing,4);
		clust(lbl ~= obj) = 0;
		for i = 0 :7 
			f = 1 + 0.1*i;
			k = im2bw(clust, f*graythresh(clust));
			k = imopen(k, strel('disk', 14));
			if max(max(bwlabel(k,4))) > 1 % detachment happened :D
				unclust(lbl==obj)=0;
				unclust = unclust + k;
				break 
			end
		end
	%else
		
        end
end


function check = check_finger(fingerprops, hand_area)

        area = sqrt(fingerprops(1));
        peri = fingerprops(2);
        ecc = fingerprops(5);
        ap = area/peri;
        rel_area = fingerprops(1) / hand_area;
        check = [-1 -1 -1]'; % [ ap, ecc, rel_area ] %

%	check values
%       if area < 42 || area > 105, check = 0; end
%       if peri < 200 || peri > 600, check = 0; end
        if ap < 0.17, check(1) = 0; 
	elseif  ap > 0.24, check(1) = 2; 
	else check(1) = 1; end

        if ecc < 0.85, check(2) = 0; else check(2) = 1;end

        if rel_area < 0.07, check(3) = 0;
	elseif rel_area > 0.25, check(3) = 2;
	else check(3) = 0; end

function props = bw2props(bw)

lbl = bwlabel(bw,4);
n = max(max(lbl)); % number of objects
s = regionprops(lbl, 'Area', 'Perimeter', 'ConvexArea', 'EulerNumber', 'Eccentricity');
for i = 1 : n
        props(i, :) = [s(i).Area, s(i).Perimeter, s(i).ConvexArea, s(i).EulerNumber, s(i).Eccentricity];
end

