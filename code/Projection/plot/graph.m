%% Test Accuracy plot
clear all;
nosielevel=[0,2,10,20,100,200,500];
%% dt
%% EM-5693
em5693_teststage3= [99.8,99.3,98.96,98.84,96.4,96.4,96.84];
em5693_teststage2= [99.8,98.0,98.7,99.64,99.8,97.05,95.05];
em5693_teststage1= [99.9,99.4,99.7,99.76,99.3,97.84,96.84];

%%dt
%% EM-2211

em2211_teststage3= [99.96,99.8,98.2,97.8,93.48,89.76,83.57];
em2211_teststage2= [99.96,95.3, 94.2,90.08,85.1,84.53,79.13];
em2211_teststage1= [99.72,95.7,96.64,96.2,95.56,93.8,85.09];


%%dt
%% EM-5689
dt_em5689_teststage3=[99.42,98.32,97.95,97.46,95.58,95.62,95.05]
dt_em5689_teststage2=[99.5,97.75,98.52,98.48,96.73,96.68,92.43]
dt_em5689_teststage1=[99.01,97.95,98.36,96.68,93.37,85.65,82.46]



%% rf
%% EM-2211
em2211_teststage3= [100,100,99.9,100,97.24,90.52,83.53];
em2211_teststage2= [100,100.0,98.28,94.0,80.21,80.09,79.93];
em2211_teststage1= [100,98.08, 97.44,96.3,83.01,80.57,80.33];

%% rf
%% EM-5693
em2211_teststage3=[100,100,99.96,99.92,99.96,99.84,99.88]
em2211_teststage2= [100,99.84,99.6,99.8,97.28,92.16,83.65]
em2211_teststage1= [99.96,96.7,79.9,79.93,79.93,79.9,79.93]

%%rf
%% EM-5689
rf_em5689_teststage3=[ 99.9,99.83,98.81,97.46,98.20,97.54,92.31]
rf_em5689_teststage2=[99.91,97.42,96.03,84.83,81.61,79.85,79.48]
rf_em5689_teststage1=[99.9,79.48,79.48,79.48,79.48,79.48,79.48]

%%svm
%% EM-5693
em5693_valstage3= [100,100,100,100,100,100,100];
em5693_valstage2= [99.7,100,100,100,95.1,77.2,62.42];
em5693_valstage1= [99.8,93.6,61,58,57.3,54.4,59];

em5693_teststage3= [99.4,99.95,99,99.5,98,96,91];
em5693_teststage2= [99.4,99.3,99.7,99.3,86.3,53.7,21];
em5693_teststage1= [99.3,88.1,20,20.5,20.5,20.5,20.5];

%% EM-2211
em2211_valstage3= [100  ,100   ,100   ,100  ,100    ,100   ,100];
em2211_valstage2= [100  ,100   ,100   ,100  ,100    ,99    ,100];
em2211_valstage1= [100  ,100   ,100   ,100  ,100    ,93    ,87.1];

em2211_teststage3= [99.9 ,100  ,99.0   ,99   ,99.7  ,99.4  ,98.4];
em2211_teststage2= [99.8 ,100  ,99.0   ,99   ,99.7  ,99.2  ,98.3];
em2211_teststage1= [99.6 ,99.0 ,99.1   ,98   ,92.0  ,86.1  ,71.0];
%% EM-5689
svm_em5689_valstage3= [100  ,100   ,100   ,100   ,100   ,100   ,100];
svm_em5689_valstage2= [100  ,100   ,100   ,100   ,99    ,99    ,100];
svm_em5689_valstage1= [100  ,100   ,100   ,89.9  ,59    ,61    ,57];

svm_em5689_teststage3= [100  ,100  ,100    ,100  ,99  ,99  ,99];
svm_em5689_teststage2= [99.0 ,99.9 ,99.0   ,99   ,97  ,94  ,86];
svm_em5689_teststage1= [99.0 ,99.0 ,96.1   ,79.  ,20  ,20  ,20];
%% validate plot
%valstage3=em2211_valstage3;
%valstage2=em2211_valstage2;
%valstage1=em2211_valstage1;

valstage3=em5689_valstage3;
valstage2=em5689_valstage2;
valstage1=em5689_valstage1;

figure;
plot(nosielevel,valstage3),hold on,
plot(nosielevel,valstage2),hold on,
plot(nosielevel,valstage1),hold on,
legend('stage-3 classifier','stage-2 classifier','stage-1 classifier'),
grid on,
xlabel('Total intensity division factor');
ylabel('Prediction accuracy in percent');
title('\fontsize{10}{\color{magenta}EM-5689 Valdiate set (20% of train) accuracy}');
set(gca,'XTick',nosielevel );

%% Test plot

%teststage3=em5693_teststage3;
%teststage2=em5693_teststage2;
%teststage1=em5693_teststage1;

%teststage3=em2211_teststage3;
%teststage2=em2211_teststage2;
%teststage1=em2211_teststage1;

teststage3=svm_em5689_teststage3;
teststage2=svm_em5689_teststage2;
teststage1=svm_em5689_teststage1;

figure;
plot(nosielevel,teststage3),hold on,
plot(nosielevel,teststage2),hold on,
plot(nosielevel,teststage1),hold on,
lgd=legend('stage-3 classifier','stage-2 classifier','stage-1 classifier','Location','best'),
grid on,
xlabel('Total intensity division factor','FontSize',24);
ylabel('Prediction accuracy in percent','FontSize',24);
title('\fontsize{24}{\color{magenta}EM-5689 SVM Test set accuracy}');
set(gca,'XTick',nosielevel );
set(findall(gca, 'Type', 'Line'),'LineWidth',3);
lgd.FontSize = 14;
%% Combine Plot


dt=dt_em5689_teststage3;
rf=rf_em5689_teststage3;
svm=svm_em5689_teststage3;

figure;
%plot(nosielevel,dt),hold on,
plot(nosielevel,rf),hold on,
plot(nosielevel,svm),hold on,
%lgd=legend('Decision Tree','Random Forset','SVM','Location','best'),
lgd=legend('Random Forset','SVM','Location','best'),
grid on,
xlabel('Total intensity division factor','FontSize',14);
ylabel('Prediction accuracy in percent','FontSize',14);
title('\fontsize{16}{\color{magenta}EM-5689 Stage 3 Test set accuracy}');
set(gca,'XTick',nosielevel );
set(findall(gca, 'Type', 'Line'),'LineWidth',3);
lgd.FontSize = 14;