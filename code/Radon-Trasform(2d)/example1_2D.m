
iptsetpref('ImshowAxesVisible','on');
%% Creating image
I = zeros(100,100);
I(25:75, 25:75) = 1;
figure('name','Original Image: painting');
imshow(I);
axis tight,axis on;o1 = get(gca, 'Position');colorbar();set(gca, 'Position', o1);

%% Calculate the Radon transform
theta = 0:180;
[R,xp] = radon(I,theta);

%% Display the transform
figure
imshow(R,[],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
xlabel('\theta (degrees)')
ylabel('x''')
colormap(gca,hot), colorbar;
iptsetpref('ImshowAxesVisible','off');
%% GPU

iptsetpref('ImshowAxesVisible','on')
I = zeros(100,100);
I(25:75, 25:75) = 1;
theta = 0:180;
[R,xp] = radon(gpuArray(I),theta);
disp('Finding Radon using GPU... Done.');
figure
imshow(R,[],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
xlabel('\theta (degrees)');
ylabel('x''')
colormap(gca,hot), colorbar
iptsetpref('ImshowAxesVisible','off')

%% 

addpath(genpath('~/git/Cryp-EM/code/lib/astra/matlab'))