clc;
close all;
imtool close all;
clear;

%PLEASE READ, when running the code, a crop window will pop up, I'd like to ask you
%to select the playingfield (every element relevant to the game), then double
%clicking to save it

%Features that work: 
%-Image input, and processing

%-Figure 1, and the included rotation

%-Grid detection and sketching to see if most of the lines were detected

%-The code segment responsible for Dividing the picture into cells is left in the code, but i does not work
%as intented, and because of the limited time left available, and my
%deteriorating sanity, it is left in its half completed state

%-Figure 2 is made using dummy data, representing the end goal of
%collecting all data into a matrix featuring 0, 1 ,2 s and creating a
%graph based on that

%-Write outs are using the same dummy data, the included function is a bit
%hit or miss, since it completed its task around 50% of the time


%Sources and Partners used:
%ChatGPT was used mostly for code correction, and minor changes, such as
%using the inbuilt hough function, not the one made in the lab
%BlackboxAI was used for creating data in figure 2 and write outs

%Kristóf P., Zalán T., Benedek V. were my partners, whom i spent
%time chating on discord while writing the code,but we dont have much in common in our codes,
%since they went a route of using all 3 color channels while i instantly
%changed it to Grayscale

%Hudra Eszter and Tarnai Csongor were my conversing partners, whom my code
%may have parts in common, we created the idea of using Theta in line
%detection, some image processing steps, the segmentation (which sadly did not work for me).


%1) Loads the image into a variable
I = imread('input/img05.png');
I = rgb2gray(I);

%2)Applies histogram operations
I_stretched = imadjust(I, [] , [] , 15);


%3) Apply Fourier transform to get pase and magnitude matrices

F = fft2(I_stretched);
F = fftshift(F);
P = double(angle(F));
M = double(abs(F));
L = log(M + 0.01);


%4)Uses  hough transfom to restore the rotation of the image
I_cropped = imcrop(I_stretched , [0  0  150 150 ]);

RA = zeros(1, size(I, 3));
for c = 1:size(I, 3)
    GC = I(:,:,c);
    edges_rot = edge(GC, 'canny');
    [H, theta, rho] = hough(edges_rot);
    [~, ind] = max(H(:));
    [row, col] = ind2sub(size(H), ind);
    RA(c) = theta(col);

end

%Rotation and some additional Image manipulation, to make the image have more
%contrast
R = max(RA);
I_rotated = imrotate(I_stretched, R, "bilinear" , "loose" );
tmp = uint8(I_rotated == 0);
I_rotated = tmp*256 + I_rotated;

%5) divides the playing field into squares (according to the original grid)

[I_playingfield, rect] = imcrop(I_rotated);
edge_grid = edge(I_playingfield , 'canny');
%Using theta, i limit the outcome to only feature vertical or horizontal lines
%Vertical
theta_grid = 0;
[H_grid , T_grid , R_grid] = hough(edge_grid, 'Theta' , theta_grid);
peaks = houghpeaks(H_grid, size(I_playingfield , 1));
lines = houghlines(I_playingfield, T_grid, R_grid , peaks);
%Horizontal
theta_gridd = -90;
[H_grid , T_grid , R_grid] = hough(edge_grid, 'Theta' , theta_gridd);
peaks = houghpeaks(H_grid, size(I_playingfield , 2));
liness = houghlines(I_playingfield, T_grid, R_grid , peaks);



% Sort v_lines by the x-coordinate of point1
x_coords = zeros(length(lines), 1);
for k = 1:length(lines)
    x_coords(k) = lines(k).point1(1);
end

[sorted_x, ~] = sort(x_coords);

% Sort h_lines by the y-coordinate of point2
y_coords = zeros(length(liness), 1);
for k = 1:length(liness)
    y_coords(k) = liness(k).point2(2);
end

[sorted_y, ~] = sort(y_coords);

%The aformentioned cell divider, which does not work in my case
subimage = I_playingfield(sorted_x(3):sorted_x(4), sorted_y(3):sorted_y(4));
numel(sorted_y)
numel(sorted_x)
cell = zeros(numel(sorted_y), numel(sorted_x));
% Divide the image into cells
for j = 1:numel(sorted_y)+1
    if j == 1
        y1 = 1;
        y2 = sorted_y(j);
    else
        if j == numel(sorted_y)+1
            y1 = sorted_y(j-1);
            y2 = size(I_playingfield,1);
        else
            y1 = sorted_y(j-1);
            y2 = sorted_y(j);
        end
    end


    for i = 1:numel(sorted_x)+1
        if i == 1
            x1 = 1;
            x2 = sorted_x(i);
        else
            if i == numel(sorted_x)+1
                x1 = sorted_x(i-1);
                x2 = size(I_playingfield,2);
            else
                x1 = sorted_x(i-1);
                x2 = sorted_x(i);
            end
        end
        subimage = I_playingfield(y1:y2, x1:x2, :);
        cells{i, j} = subimage;
    end
end

cells = zeros(numel(sorted_y), numel(sorted_x));
subimage = I_playingfield(y1:y2, x1:x2, :);
luminance = sum(subimage(:))/numel(subimage);
if luminance < 20
    cells(j, i) = 1;
end



%Plotting & writeout
%The Dummy data
marks = [1 0 0 0 0;
    0 1 0 2 2;
    2 0 1 2 0;
    0 0 0 1 0;
    0 0 0 2 1];

figure(1);
subplot(121); imshow(I); title('Original Input');
subplot(122); imshow(I_rotated); colormap gray; title(strcat ('Corrected image, rotated by ' , num2str(R) , ' degrees'));

figure(2)
cmap = [
    1 1 1
    1 0 0
    0 0 1];

imagesc(marks); colormap(cmap); grid on;

%Writeout

num_of_1 = 0;
num_of_2 = 0;

for i = 1:size(marks, 1)
    for j = 1:size(marks, 2)
        if marks(i, j) == 1
            num_of_1 = num_of_1 + 1;
        elseif marks(i, j) == 2
            num_of_2 = num_of_2 + 1;
        end
    end
end

disp(['Player 1 symbol count: ', num2str(num_of_1)]);
disp(['Player 2 symbol count: ', num2str(num_of_2)]);
diff = abs(num_of_1 - num_of_2);
if diff > 1
    disp('Game invalid');
else
    disp('Game valid');
end


consec_1 = countConsecutive(marks, 1);
consec_2 = countConsecutive(marks, 2);
if consec_2 == 5
    disp('Player 2 won');
elseif consec_1 == 5
    dips('Player 1 won');
end


figure(3);
subplot(131); imshow(edge_grid);
hold on
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'r');
end
for k = 1:length(liness)
    xy = [liness(k).point1; liness(k).point2];
    plot(xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'r');
end
hold off;

