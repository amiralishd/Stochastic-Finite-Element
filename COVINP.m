function [COV_Inp] = COVINP (Par,Mat,El,Nd)

corrL = Par(4);
COV_Inp = zeros(length(El(:,1)),length(El(:,1)));
for i = 1:length(El(:,1))
    for j = i:length(El(:,1))
% x and y coordinates of the start and end node of element i
    xi = Nd(El(i,2),2); xii = Nd(El(i,3),2);
    yi = Nd(El(i,2),3); yii = Nd(El(i,3),3);
% x and y coordinates of the start and end node of element j
    xj = Nd(El(j,2),2); xjj = Nd(El(j,3),2);
    yj = Nd(El(j,2),3); yjj = Nd(El(j,3),3);
% distance of the midpoints of the two elements
   dist = sqrt(((xi+xii)/2-(xj+xjj)/2)^2+((yi+yii)/2-(yj+yjj)/2)^2);
% Covariance matrix
   COV_Inp(i,j) = Mat(El(i,4),4)*Mat(El(j,4),4)*exp(-dist/corrL);
   COV_Inp(j,i) = COV_Inp(i,j);
    end
end
end