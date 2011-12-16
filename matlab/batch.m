
% location of cities on original grid (25x25m)
stm_p = [454 620; 567 452; 674 638; 528 542; 328 785; 623 372];
fri_p = [667 503; 596 534; 693 607; 599 227; 612 459; 546 417; 255 223; 662 399; 412 655; 510 689; 523 514; 418 366; 418 570; 267 669];

% location of cities on reduced grid (500x500m)
stm_p = [23 31;29 23;34 32;27 28;17 40;32 19];
fri_p = [34 26;30 27;35 31;30 12;31 23;28 21;13 12;34 20;21 33;26 35;27 26;21 19;21 29;14 34];


%dur = 25;                       % Durability
%inten = 10;                     % Intensity
%vis = 0.3, 1, 4;                        % Visability
%importance = 1.6;
%location = 'fri'
%numframes = 100

for vis=[0.3 1 4]
    for dur = [5 25 50]
        for inten = [5 10 30]
            for importance = [0.5 1 1.6]
                smDriver(dur, inten, vis, importance, 'fri', 100);
                smDriver(dur, inten, vis, importance, 'stm', 100);
            end
        end
    end
end