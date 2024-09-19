function [motionVecX, motionVecY, predictImg] = motionEstimationTSS(currImg, refImg, blk, p)

[r, c] = size(currImg);

yBlk = floor(r / blk);
xBlk = floor(c / blk);

predictImg = uint8(zeros(r, c)); 

motionVecX = uint8(zeros(yBlk, xBlk)); 
motionVecY = uint8(zeros(yBlk, xBlk));

MAX_DIST = 256 * blk * blk;

iBlk = 1;
for i = 1 : blk : r-blk+1 
    jBlk = 1;
    for j = 1 : blk : c-blk+1 
        currBlk = currImg(i : i+blk-1, j : j+blk-1);
        minDist = MAX_DIST;
        dx = 0;
        dy = 0;

        stepSize = p; 
        visitedPoints = [];
        
        bestdx = 0;  
        bestdy = 0;
        while stepSize >= 1
            for m = -stepSize : stepSize : stepSize
                for n = -stepSize : stepSize : stepSize
                    ii = i + dy + m;
                    jj = j + dx + n;

                    if (ii < 1 || ii+blk-1 > r || jj < 1 || jj+blk-1 > c || isPointVisited(ii, jj, visitedPoints))
                        continue;
                    end

                    refBlk = refImg(ii : ii+blk-1, jj : jj+blk-1);
                    blkDist = sum(sum(abs(currBlk - refBlk)));

                    if (blkDist < minDist)
                        minDist = blkDist;
                        bestdy = dy + m;
                        bestdx = dx + n;
                    end
                end
            end

            visitedPoints = [visitedPoints; i + bestdy, j + bestdx];
            
            dy = bestdy;
            dx = bestdx;
            stepSize = stepSize / 2;
           
        end
        
        motionVecX(iBlk, jBlk) = dx; 
        motionVecY(iBlk, jBlk) = dy;

        predictImg(i : i+blk-1, j : j+blk-1) = refImg(i+dy : i+dy+blk-1, j+dx : j+dx+blk-1);
    jBlk = jBlk + 1;
    end
    iBlk = iBlk + 1;
end
end

function visited = isPointVisited(x, y, visitedPoints)
    if size(visitedPoints, 2) < 2
        visited = false;
        return;
    end
    visited = any(visitedPoints(:,1) == x & visitedPoints(:,2) == y);
end

