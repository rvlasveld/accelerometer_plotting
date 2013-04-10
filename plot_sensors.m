#! /usr/local/bin/octave -f

# Octave implementation to plot SensorLogger transformed files to one graph
#
#
# Roemer Vlasveld (roemer.vlaseld@gmail.com)

# Usage: call with paramter directory with accelerometer.csv, rotation.csv etc files
# Output: png plots for each file and multiplot with accelerometer, lin_acceleration,
# magnetic_field and rotation

# Depends on "load_SensorLogger_directory.m" function file, which should be in
# the same directory.

clear all;

source('./load_SensorLogger_directory.m')

# get directory to work on
arg_list = argv();
directory = arg_list{1};

files = load_directory(directory)

# Determine of path already has trailing slash
separator = "";
if substr(directory, -1, 1) != '/'
  separator = "/";
end

# Plot normal grahs

for i = 1 : length(files)
  clf;
  metric = files{i};
  plot_command = cstrcat("plot(", metric, "(:,2),", metric, "(:,3:5), '-')");
  lines = eval(plot_command);
  print_location = strcat(directory, separator, "_", metric, ".png")
  title (strrep(print_location, '_', '\_'))
  eval( cstrcat("print -dpng ", print_location, ' "-S1700,800"') );
end


# create a multiplot file with acceleromter, lin_acceleration, rotation, magnetic_field

plot_metrics = {'accelerometer', 'lin_acceleration', 'magnetic_field', 'rotation'};
clf;

for i = 1 : length(plot_metrics)

  # Set index for this subplot
  subplot(length(plot_metrics), 1, i );

  metric = plot_metrics{i};
  plot_command = cstrcat("plot(", metric, "(:,2),", metric, "(:,3:5), '-')");
  lines = eval(plot_command);
  title(strrep(plot_metrics{i}, '_', '\_'));
  print_location = strcat(directory, separator, "_accumulated.png")

  eval( cstrcat("print -dpng ", print_location, ' "-S1700,1200"') );
end

close all;

pause(0.1);