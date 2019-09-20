% Diogo Martins, 2011

function [img_out tips bots] = diogo_final(bw_fingers, D, props)

lbl_fingers = bwlabel(bw_fingers,4);
N_obj = max(max(lbl_fingers));
tips = []; bots = [];
img_out = 0;

for obj = 1 : N_obj

	if check_finger(props.fingers(obj,:), props.palm(:,1))
		finger = D; % template
		finger(lbl_fingers~=obj) = 0; % interest finger
		[j k] = find( finger == max(max(finger)), 1, 'first');
		finger = D;
		finger(lbl_fingers~=obj) = 9999;
		[l m] = find( finger == min(min(finger)), 1, 'first');
		tip_bot_dist = sqrt( (j-l)^2 + (m-k)^2 );
		if tip_bot_dist > 0.65 * props.fingers(obj,6) && tip_bot_dist < 1.35*props.fingers(obj,6)
			bots = [bots; l m];
			tips = [tips; j k];
		end
	end
end

if size(tips,2) > 0, img_out = print_tips(bw_fingers,tips,bots);
end 

function check = check_finger(fingerprops, hand_area)

	area = sqrt(fingerprops(1));
	peri = fingerprops(2);
	ecc = fingerprops(5);
	ap = area/peri;
	check = 1;
	rel_area = fingerprops(1) / hand_area;
	rel_axis = fingerprops(6) / fingerprops(7);
	if length(rel_area) > 1; rel_area = rel_area(1); end % this happened once :X
 
	% check values
%	if area < 42 || area > 105, check = 0; end
%	if peri < 200 || peri > 600, check = 0; end
	if ap < 0.17 || ap > 0.24, check = 0; end
	if ecc < 0.85, check = 0; end
	if rel_area < 0.07 || rel_area > 0.25, check = 0; end
%	if rel_axis < 2.3 || rel_axis > 5.285, check = 0; end

function img_out = print_tips(bw_fingers, tips, bots)

	img_out = zeros([size(bw_fingers) 3]);
        
	img_out(:,:,1) = bw_fingers; img_out(:,:,2) = bw_fingers; img_out(:,:,3) = bw_fingers;
	tips = [tips; bots];
        for i = 1 : size(tips,1)
		% check for indexing out of bounds
		if tips(i,1) < 5, tips(i,1) = 5; end 
		if tips(i,1) > (size(img_out,1)-4), tips(i,1) = size(img_out,1)-4; end
		if tips(i,2) < 5, tips(i,2) = 5; end
		if tips(i,2) > (size(img_out,2)-4), tips(i,2) = size(img_out,2)-4; end
                img_out(tips(i,1)-4 : tips(i,1)+4, tips(i,2) -4 : tips(i,2) + 4 ,1) = 1;
                img_out(tips(i,1)-4 : tips(i,1)+4, tips(i,2) -4 : tips(i,2) + 4, 2) = 0;
                img_out(tips(i,1)-4 : tips(i,1)+4, tips(i,2) -4 : tips(i,2) + 4, 3) = 0;
        end
