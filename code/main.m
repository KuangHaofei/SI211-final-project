clear;clc;close all;
%% Image Reading
img = imread('lena.png');

gray_img = rgb2gray(img);

img_ref = imref2d(size(gray_img));

% Display the orignal images
figure(1);
subplot(1,2,1)
imshow(gray_img, img_ref);
title("Input image.", 'FontSize', 25);

%% Image Transformation
theta = 30;
x = 50;
y = 50;
ground_truth = [theta; x; y];
T = [cosd(theta) sind(theta) 0; -sind(theta) cosd(theta) 0; x y 1];

tform = affine2d(T);

[t_img, img_translated_ref] = imwarp(gray_img, tform, 'OutputView', img_ref);
figure(1);
subplot(1,2,2)
imshow(t_img, img_translated_ref);
title("Template image.", 'FontSize', 25);

%% Image Matching
% feature detection
points1 = detectFASTFeatures(gray_img);
points2 = detectFASTFeatures(t_img);

[f1,vpts1] = extractFeatures(gray_img,points1);
[f2,vpts2] = extractFeatures(t_img,points2);

figure(2);
subplot(1,2,1);
title("The features of Input Image.", 'FontSize', 25)
imshow(gray_img);
hold on
plot(vpts1);

figure(2);
subplot(1,2,2);
title("The features of Transformation Image.", 'FontSize', 25)
imshow(t_img);
hold on
plot(vpts2);


% feature mathcing
indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

figure(3); 
showMatchedFeatures(gray_img, t_img, matchedPoints1, matchedPoints2);
legend({'matched points 1','matched points 2'}, 'FontSize',15);

% matched points process
location1 = matchedPoints1.Location;
location2 = matchedPoints2.Location;
[m, n] = size(location1);

I = ones(m, 1);
l1 = [location1 I];
l2 = [location2 I];

%% Gaussian Newton (Only estimate T)
% Tk = eye(3,3);
% 
% itr = 10;
% i = 1;
% while i <= itr
%     Tk = Tk - (l1' * l1) \ l1' * (l1 * Tk - l2);
%     i = i + 1;
% end
% 
% Tk;

%% Newton (estimate [theta, tx, ty])
syms s_theta tx ty
T = [cosd(s_theta) sind(s_theta) 0; -sind(s_theta) cosd(s_theta) 0; tx ty 1];

% paramter [theta tx ty]
pk_n = [0; 0; 0];
param = [s_theta; tx; ty];

itr = 10;
e = -3;
cr_n_temp = norm(pk_n - ground_truth);
i = 1;
j = 1;
a = 1;

loss_n = [];
cr_n = cr_n_temp;
while i <= itr %cr_n_temp > e    
    f = l1 * T - l2;
    F = 0.5 * sum(f(:).^2);
    
    % store optimazation loss and convergence rate
    loss = double(subs(F, param, pk_n));
    loss_n = [loss_n loss];

    % copmute gradient and hessian of F
    dT = jacobian(F);
    hT = hessian(F);
    
    dT = double(subs(dT, param, pk_n));
    hT = double(subs(hT, param, pk_n));
    
    % line search
%     a = 1;
%     c = 0.001;
%     for j=1:10
%         pk_n_temp = pk_n - a * hT \ dT';
%         
%         loss_temp = double(subs(F, param, pk_n_temp));
%         
%         if loss_temp < loss %- c * a * dT * (hT \ dT')
%             pk_n = pk_n_temp;
%         else
%             a = a/2;
%         end
%     end
    
    pk_n = pk_n - hT \ dT';
    
    cr_n_temp = norm(pk_n - ground_truth);
    cr_n = [cr_n cr_n_temp];
    
    if i > itr
        break;
    end
    
    i = i + 1;
end
pk_n;

%% Gaussian Newton (estimate [theta, tx, ty])
syms s_theta tx ty % x y
T = [cosd(s_theta) sind(s_theta) 0; -sind(s_theta) cosd(s_theta) 0; tx ty 1];

% paramter [theta tx ty]
pk_gn = [0; 0; 0];
param = [s_theta; tx; ty];

itr = 10;
e = -3;
cr_gn_temp = norm(pk_gn - ground_truth);
i = 1;

loss_gn = [];
cr_gn = cr_gn_temp;
while i <= itr %cr_gn_temp > e
    f = l1 * T - l2;
 
    % store optimazation loss
    F = 0.5 * sum(f(:).^2);
    loss = double(subs(F, param, pk_gn));
    loss_gn = [loss_gn loss];
    
    % compute gradient of f
    dT = jacobian(f(:));
    dT = double(subs(dT, param, pk_gn));
    
    f = double(subs(f, param, pk_gn));
    
    pk_gn = pk_gn - (dT' * dT) \ dT' * f(:);
    
    cr_gn_temp = norm(pk_gn - ground_truth);
    cr_gn = [cr_gn cr_gn_temp];
    
    if i > itr
        break;
    end
    
    i = i + 1;
end
pk_gn;

%% Plot loss curve
figure(4);
semilogy(loss_n, 'LineWidth', 2);
hold on
semilogy(loss_gn, 'LineWidth', 2);
legend({'Newton','Gaussian Newton'}, 'FontSize',15);
title('Loss Curve', 'FontSize', 25);

%% convergence rate
figure(5);
% semilogy(cr_n, 'LineWidth', 2);
% hold on
semilogy(cr_gn, 'LineWidth', 2);
% legend({'Newton','Gaussian Newton'}, 'FontSize',15);
xlabel('Number of iterations', 'FontSize',15);
ylabel('Convergence Rate (log)', 'FontSize',15);
title('Convergence Rate Curve', 'FontSize', 25);

%% Compare with Original Image
T_n = [cosd(pk_n(1)) sind(pk_n(1)) 0; -sind(pk_n(1)) cosd(pk_n(1)) 0; pk_n(2) pk_n(3) 1];

tform_n = affine2d(T_n);

[t_img_n, img_translated_ref_n] = imwarp(gray_img, tform_n, 'OutputView', img_ref);

figure(6);
subplot(2,3,1)
imshow(t_img, img_translated_ref);
title("Template image.", 'FontSize', 20)

subplot(2,3,2)
imshow(t_img_n, img_translated_ref_n);
title("Newton Method.", 'FontSize', 20);

subplot(2,3,3)
imshow(abs(t_img_n - t_img), img_translated_ref_n);
title("The error between estimation and template.", 'FontSize', 20);

T_gn = [cosd(pk_gn(1)) sind(pk_gn(1)) 0; -sind(pk_gn(1)) cosd(pk_gn(1)) 0; pk_gn(2) pk_gn(3) 1];

tform_gn = affine2d(T_gn);

[t_img_gn, img_translated_ref_gn] = imwarp(gray_img, tform_gn, 'OutputView', img_ref);

figure(6);
subplot(2,3,4)
imshow(t_img, img_translated_ref);
title("Template image.", 'FontSize', 20)

subplot(2,3,5)
imshow(t_img_gn, img_translated_ref_gn);
title("Gaussian Newton Method.", 'FontSize', 20);

subplot(2,3,6)
imshow(abs(t_img_gn - t_img), img_translated_ref_gn);
title("The error between estimation and template.", 'FontSize', 20);