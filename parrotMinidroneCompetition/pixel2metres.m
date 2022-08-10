%PIXEL2METRES converts pixel distance to real distance in metres
% ALL vision_data COORDINATES ARE BASED ON CAMERA VIEW'S COORDINATE SYSTEM, WHERE THE MINIDRONE IS ALWAYS AT THE ORIGIN

% Convert the vision_data coordinates from pixel units to simulation background units (in meters)
% Every pixel corresponds to 0.005*abs(current_pos.Z) meter per pixel

function metres = pixel2metres(pixel_distance, height)

    metres = 0.005 * pixel_distance * height;

end