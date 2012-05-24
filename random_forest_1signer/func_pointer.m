%provides a pointer to a function indexed by a number
function fp = func_pointer(num)
    switch num
        case 1
            fp = @unary;
        case 2
            fp = @binary1;
        case 3
            fp = @binary2;
        case 4
            fp = @binary3;
        otherwise
            fp = @unary;
    end
end

function val = unary(feature)
    val = feature(1);
end

function val = binary1(features)
    val = features(1) - features(2);
end

function val = binary2(features)
    val = abs(features(1)-features(2));
end

function val = binary3(features)
    val = features(1)+features(2);
end
