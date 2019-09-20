function correct_order = diogo_spin(bots)

N = size(bots,1);

bot_dist = zeros(N,N); xd = zeros(N,N); yd = zeros(N,N);

x = bots(:,1); y = bots(:,2);
for i = 1 : N
	for j = 1 : N
		xd(i,j) = abs(x(i)-x(j));
		yd(i,j) = abs(y(i)-y(j));
	end
end

xd = xd.^2; yd = yd.^2;

bot_dist = sqrt(xd+yd);

bot_sum = sum(bot_dist);

[bot_ord ord] = sort(bot_sum,'ascend');

thum = bot_dist(ord(5),:);

if N==6, thum(ord(6)) = -1; end % arm is -1 now...

[thum_ord correct_order] = sort(thum,'descend'); % arm is the last one.



