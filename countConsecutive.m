 function count = countConsecutive(matrix, target)
    [rows, cols] = size(matrix);
    count = 0;

    % Horizontal check
    for i = 1:rows
        for j = 1:(cols - 5)
            if all(matrix(i, j:(j+5)) == target)
                count = count + 1;
            end
        end
    end

    % Vertical check
    for i = 1:(rows - 5)
        for j = 1:cols
            if all(matrix(i:(i+5), j) == target)
                count = count + 1;
            end
        end
    end

    % Diagonal check (top-left to bottom-right)
    for i = 1:(rows - 5)
        for j = 1:(cols - 5)
            if all(diag(matrix(i:(i+5), j:(j+5))) == target)
                count = count + 1;
            end
        end
    end

    % Diagonal check (top-right to bottom-left)
    for i = 1:(rows - 5)
        for j = 6:cols
            if all(diag(flipud(matrix(i:(i+5), j-5:j))) == target)
                count = count + 1;
            end
        end
    end
end