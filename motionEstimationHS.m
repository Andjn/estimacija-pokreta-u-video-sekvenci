function [motionVecX, motionVecY, predictImg] = motionEstimationHS(currImg, refImg, blk, p)

[r, c] = size(currImg);

yBlk = floor(r / blk);
xBlk = floor(c / blk); 

predictImg = uint8(zeros(r, c)); 

motionVecX = uint8(zeros(yBlk, xBlk));
motionVecY = uint8(zeros(yBlk, xBlk));

MAX_DIST = 256 * blk * blk;
SHP = [ 0,0; 0, -1; -1, 0; 1, 0; 0, 1; ];
LHP = [0, 0; -2, 0; -1, -2; 1, -2;  2, 0; 1, 2; -1, 2;];
iBlk = 1;
for i = 1 : blk : r-blk+1 
    jBlk = 1;
    for j = 1 : blk : c-blk+1
        currBlk = currImg(i : i+blk-1, j : j+blk-1);
        minDist = MAX_DIST;
        dx = 0;
        dy = 0;
        
        visitedPoints = [];
          
        bestdx = 0;
        bestdy = 0;
        found = false;
        while ~found
                   
            
            for k = 1 : size(LHP, 1)
                m = LHP(k, 1);
                n = LHP(k, 2);
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

            visitedPoints = [visitedPoints; i + dy + LHP(:,1), j + dx + LHP(:,2)];

            if bestdx == dx && bestdy == dy
                found = true;
                
                for k = 1 : size(SHP, 1)
                    m = SHP(k, 1);
                    n = SHP(k, 2);
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
            dy = bestdy;
                dx = bestdx;
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
