function [img_2blue closed_holes]= diogo_2blue(unclust, blueholes, D, props);

N_obj = size(props.blue,1);
img_2blue = unclust;
closed_holes = [];
MJAs = [];

for j = 1 : N_obj

	MJA = props.blue(j,2); % major axis length
	miA = props.blue(j,3); % minor axis length
	ori2 = props.blue(j,5); % distance between closets and farthest point to palm
	check = 1;

	if MJA < 30, check = 0; end % too short
	if miA > (MJA/4), check = 0; end % to fat
	if MJA/ori2 < 0.7 || MJA/ori2 > 1.3, check = 0; end % wrong orientation

	if check
		MJAs = [MJAs; MJA j]; 
	end
end


lbl_holes = bwlabel(blueholes,8);
closed_holes = blueholes;
for k = 1 : size(MJAs,1)
	[lbl_current N] = bwlabel(blueholes,8);
	ori = props.blue(k,4);
	MJA = props.blue(k,2);
	hole = blueholes;
	hole(lbl_holes ~= k) = 0;
	closed_hole = imdilate(hole, strel('line', MJA, ori));
	temp_holes = blueholes + closed_hole;
	temp_holes(temp_holes==2)=1;
	[lbl_current N_temp] = bwlabel(temp_holes);
	if N_temp < N
		N = N_temp; 
		closed_holes = closed_holes + closed_hole;
		closed_holes(closed_holes==2)=1;
	end
	
	%img_2blue = imdilate(blueholes, strel('line', MJA, ori));
end
closed_holes = imclose(closed_holes, strel('disk',4));
if size(MJAs,1) > 0
	p = find(MJAs(:,1) == max(MJAs(:,1)),1,'first');
	p = MJAs(p,2); % number of object with biggest MJA
	ori = props.blue(p,4);
	MJA = props.blue(p,2);
	original_close = imclose(blueholes, strel('line', MJA, ori));
	closed_holes = closed_holes + original_close;
end
img_2blue = unclust - closed_holes;
