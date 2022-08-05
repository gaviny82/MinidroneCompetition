function [takeoff_complete, landing_ready, landing_zone_detected, target_x, target_y, target_z, motion_history] = plan_path_simulink_func(current_pos, vision_data, motion_history)
%PLAN_PATH_SIMULINK_FUNC Provides navigation point in traking stage and determines if the landing zone is detected
%   Detailed explanation goes here

    % Record current motion
    x_history = motion_history(1,:);
    y_history = motion_history(2,:);
    z_history = motion_history(3,:);

    x_hitory = [current_pos.X, x_history(1:end - 1)];
    y_hitory = [current_pos.Y, y_history(1:end - 1)];
    z_hitory = [current_pos.Z, z_history(1:end - 1)];

    motion_history = [x_history;y_history;z_history];

    % TODO: process vision data
    takeoff_complete = 0;
    landing_ready = 0;
    landing_zone_detected = 0;
    target_x = 0;
    target_y = 1;
    target_z = 0;

end

