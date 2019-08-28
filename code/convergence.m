clear;clc;close all;
% p_0 = [0;0;0]
cr_gn_1 = [76.8115   44.9062    0.0724    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452
];


% p_0 = [95;10;15]
cr_gn_2 = [83.9643  194.1597    8.6785    0.0448    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452
];

% p_0 = [29;50;50]
cr_gn_3 = [7.1414    0.0404    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452    0.0452];

%% convergence rate
figure;
semilogy(cr_gn_1, 'LineWidth', 2);
hold on
semilogy(cr_gn_2, 'LineWidth', 2);
hold on
semilogy(cr_gn_3, 'LineWidth', 2);
legend({'Far','Very Far','Close'}, 'FontSize',15);
xlabel('Number of iterations', 'FontSize',15);
ylabel('Convergence Rate (log)', 'FontSize',15);
title('Convergence Rate Curve', 'FontSize', 25);
