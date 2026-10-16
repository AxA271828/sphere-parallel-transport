%% 球面与圆锥展开同步对比 + 输出 GIF（扇形完整显示版）
clear; clc; close all;

%% 参数设置
R = 0.8;                     % 球体半径（缩小）
theta0 = pi/4;              % 45° 纬线
nFrames = 60;
phi = linspace(0, 2*pi, nFrames);
k = cos(theta0);

% 解析解
A_theta0 = 1; A_phi0 = 0;
A_theta = A_theta0 * cos(k * phi) + sin(theta0) * A_phi0 * sin(k * phi);
A_phi = -(1/sin(theta0)) * A_theta0 * sin(k * phi) + A_phi0 * cos(k * phi);
A_phys_phi = sin(theta0) * A_phi;

%% 创建图形窗口
fig = figure('Color', 'w', 'Position', [100, 100, 1200, 600]);

% ========== 左栏：球面 ==========
ax1 = subplot(1, 2, 1);
hold on; axis equal; view(135, 30);
title('球面纬线 (45°)');

% 球体
[X, Y, Z] = sphere(40);
surf(R*X, R*Y, R*Z, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'FaceColor', [0.8 0.8 0.8]);

% 纬线
lat_theta = pi/2 - theta0;
lat_x = R * sin(lat_theta) * cos(phi);
lat_y = R * sin(lat_theta) * sin(phi);
lat_z = R * cos(lat_theta) * ones(size(phi));
plot3(lat_x, lat_y, lat_z, 'b-', 'LineWidth', 1.5);

% 固定轴范围
axis([-1.3, 1.3, -1.3, 1.3, -1.3, 1.3]);
xlabel('X'); ylabel('Y'); zlabel('Z');

% 占位
h_arrow_s = quiver3(0, 0, 0, 0, 0, 0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);
h_trail_s = plot3(nan, nan, nan, 'r--', 'LineWidth', 1);
trail_s = [];

% ========== 右栏：扇形（缩小+居中+扩大轴范围） ==========
ax2 = subplot(1, 2, 2);
hold on; axis equal;
title('圆锥展开（扇形）');

% 扇形参数（缩小）
r_cone = 0.8;                % 半径缩小
alpha = 2 * pi * sin(theta0);
theta_fan = linspace(0, alpha, 50);

% 原始扇形坐标（顶点在原点）
x_fan_raw = r_cone * sin(theta_fan);
y_fan_raw = r_cone * (1 - cos(theta_fan));

% 平移到视图中心
x_center = mean([0, x_fan_raw, 0]);
y_center = mean([0, y_fan_raw, 0]);
x_fan = x_fan_raw - x_center;
y_fan = y_fan_raw - y_center;

% 画扇形
fill([0 - x_center, x_fan, 0 - x_center], [0 - y_center, y_fan, 0 - y_center], ...
    [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 1);

% 标记缺口角
gap_angle = 2*pi - alpha;
text(0.15, 0.15, sprintf('缺口角 = %.1f°', rad2deg(gap_angle)), ...
    'FontSize', 10, 'Color', 'k', 'HorizontalAlignment', 'center');

% ===== 关键修改：轴范围扩大 =====
axis_limit = 1.6;   % 从 1.2 扩大到 1.6
axis([-axis_limit, axis_limit, -axis_limit, axis_limit]);
xlabel('X'); ylabel('Y');

% 初始参考方向
quiver(0.2, 0.2, 0.3, 0, 'k--', 'LineWidth', 1, 'AutoScale', 'off');
text(0.25, 0.15, '初始方向', 'FontSize', 8, 'Color', 'k');

% 占位
h_vec_f = quiver(0, 0, 0, 0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);
h_trail_f = plot(nan, nan, 'r--', 'LineWidth', 1);
trail_f = [];

%% 初始化 GIF
gifFile = 'parallel_transport_compare.gif';
delayTime = 0.05;

%% 主循环
for i = 1:nFrames
    % ----- 左栏：球面 -----
    subplot(1, 2, 1);
    P = [lat_x(i), lat_y(i), lat_z(i)];
    
    e_theta = [-cos(theta0)*cos(phi(i)), -cos(theta0)*sin(phi(i)), sin(theta0)];
    e_theta = e_theta / norm(e_theta);
    e_phi = [-sin(phi(i)), cos(phi(i)), 0];
    e_phi = e_phi / norm(e_phi);
    
    V_s = A_theta(i) * e_theta + A_phys_phi(i) * e_phi;
    V_s = V_s / norm(V_s);
    
    delete(h_arrow_s);
    h_arrow_s = quiver3(P(1), P(2), P(3), V_s(1), V_s(2), V_s(3), ...
        'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.5, 'AutoScale', 'off');
    
    tip_s = P + V_s;
    trail_s = [trail_s; tip_s];
    delete(h_trail_s);
    h_trail_s = plot3(trail_s(:,1), trail_s(:,2), trail_s(:,3), 'r--', 'LineWidth', 1);
    
    % ----- 右栏：扇形 -----
    subplot(1, 2, 2);
    ang = alpha * (i-1) / (nFrames-1);
    x_start = r_cone * sin(ang) - x_center;
    y_start = r_cone * (1 - cos(ang)) - y_center;
    
    V_f = [1, 0];
    V_f = V_f / norm(V_f);
    
    delete(h_vec_f);
    h_vec_f = quiver(x_start, y_start, V_f(1), V_f(2), ...
        'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.5, 'AutoScale', 'off');
    
    tip_f = [x_start + V_f(1), y_start + V_f(2)];
    trail_f = [trail_f; tip_f];
    delete(h_trail_f);
    h_trail_f = plot(trail_f(:,1), trail_f(:,2), 'r--', 'LineWidth', 1);
    
    drawnow;
    
    % ----- 捕获帧 -----
    frame = getframe(fig);
    im = frame2im(frame);
    im = imresize(im, 0.6);
    [imind, cm] = rgb2ind(im, 256);
    if i == 1
        imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
    else
        imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
    end
end

%% 输出
fprintf('GIF 已保存为: %s\n', gifFile);
fprintf('球面和乐角: %.2f°\n', rad2deg(2*pi - k*2*pi));
fprintf('扇形缺口角: %.2f°\n', rad2deg(2*pi - 2*pi*sin(theta0)));