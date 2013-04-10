# Octave implementation to load a directory with SensorLogger files.
# This file can be included via the source function in other files.
#
# Expected files: accelerometer, lin_acceleration, light, rotation,
# magnetic_field, gravity, proximity, orientation
#
#
#
# Usage: this file creates eight global vars (see files_to_load).
# If a = accelerometer, l = lin_acceleration, r = rotation, then:
#
# clf;
# figure("Position", [0, 0, 1700, 800])
# hold on;
# plot(a(:,2), a(:,[3:5]));
# plot(l(:,2), l(:,3),'m', l(:,2), l(:,4),'c',l(:,2), l(:,5),'k');
# plot(r(:,2), r(:,3),'.m', r(:,2), r(:,4),'.c',r(:,2), r(:,5),'.k');
#
#
# Roemer Vlasveld (roemer.vlasveld@gmail.com)

1;

global files_to_load = {"accelerometer", "lin_acceleration", "light", "rotation", "magnetic_field", "gravity", "proximity", "orientation"};

# Create global variables
for i = 1 : length(files_to_load)
  eval( cstrcat("global ", files_to_load{i}));
end

function files = load_directory(directory)
  global files_to_load;

  # Determine of path already has trailing slash
  separator = "";
  if substr(directory, -1, 1) != '/'
    separator = "/";
  end


  for i = 1 : length(files_to_load)
    new_data = load("-ascii", char(strcat(directory, separator, files_to_load{i}, ".csv")));

    # Transform unix nanoseconds timestamp to microseconds offset from start
    new_data(:,1) = (new_data(:,1) - new_data(1,1))/1000;

    # Register global vars in this function
    eval( cstrcat("global ", files_to_load{i}));

    # Assign values to global vars
    eval( strcat(files_to_load{i}, "= new_data;") );
  end
  files = files_to_load;
endfunction


# Plot the axis (e.g. 3 for the x) of a specific metric.
# Draw the mean (dashed black line) and standard deviation
# (blue dotted) of a half-overlapping window of width samples.
# Optionally use absolute values
# usage: plot_mean_std('lin_acceleration', 3, 80, true )
function plot_mean_std(metric, axis, width = 50, absolute = false )
  global files_to_load;

  for i = 1 : length(files_to_load)
    eval( cstrcat("global ", files_to_load{i}));
  end

  clf;
  hold on;
  eval( strcat("values = ", metric,";" ) );

  # Original values, solid line
  plot(values(:,2), values(:,axis), ':r');

  means = [];
  stds = [];
  times = [];

  for i = width + 1 : width/2 : size(values,1)
    window = values(i-width:i, axis);
    if absolute
      window = abs(window);
    end
    time = values(i,2);
    m = mean(window);
    s = std(window);
    times(end+1) = time;
    means(end+1) = m;
    stds(end+1) = s;
  end

  stairs(times, means, '--k')
  stairs(times, means+stds, ':b')
  stairs(times, means-stds, ':b')

endfunction

# Plot the pairwise correlations for three axis of a specific metric.
# Calculate over a window of width samples.
# usage: plot_corr( 'accelerometer', 25 )
function plot_corr(metric, width = 50)
  global files_to_load;

  for i = 1 : length(files_to_load)
    eval( cstrcat("global ", files_to_load{i}));
  end

  % clf;
  hold on;
  eval( strcat("values = ", metric,";" ) );

  coeff = [];
  times = [];

  for i = width + 1 : width/2 : size(values,1)
    window = values(i-width:i, 3:5);

    time = values(i,2);
    c = corr(window);
    times(end+1) = time;
    coeff = [coeff; c(1,2) c(1,3) c(2,3)];
  end

  stairs(times, coeff )

  legend('x-y correlation coefficient', 'x-z correlation coefficient', 'y-x correlation coefficient')

endfunction



# Plot the global variables:
# accelerometer, lin_acceleration, rotation, magnetic_field
# accelerometer is default false, because it is the same as lin_acceleration,
# but with the gravity included. Helpful for orientation though.
# magnetic_field is default false, gives orientation to magnetic north.
function plot_values(a = false, l = true, r = true, m = false)
  global files_to_load;

  for i = 1 : length(files_to_load)
    eval( cstrcat("global ", files_to_load{i}));
  end

  clf;
  hold on;

  labels = {};

  if a
    acc = accelerometer;
    plot(acc(:,2), acc(:,[3:5]), '-');
    labels = cat(2, labels, {'X acc', 'Y acc', 'Z acc'});
  end

  if l
    lin = lin_acceleration;
    plot(lin(:,2), lin(:,3), '-m', lin(:,2), lin(:,4),'-c', lin(:,2), lin(:,5),'-k');
    labels = cat(2, labels, {'X lin', 'Y lin', 'Z lin'});
  end

  if r
    r = rotation;

    if (a||l||m)
      printf "Scaling rotation for visual inspection\n";
      r(:,3:5) = rotation(:,3:5) * 10;
    end

    plot(r(:,2), r(:,3),'.r', r(:,2), r(:,4),'.g', r(:,2), r(:,5),'.b');
    labels = cat(2, labels, {'X rot', 'Y rot', 'Z rot'});
  end

  if m
    m = magnetic_field;
    plot(m(:,2), m(:,3),'.m', m(:,2), m(:,4),'.c', m(:,2), m(:,5),'.k');
    labels = cat(2, labels, {'X mag', 'Y mag', 'Z mag'});
  end

  legend(labels);

endfunction