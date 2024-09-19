function [motionVecX, motionVecY, predictImg] = motionEstimationCSA(currImg, refImg, blk, p)
    
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
        
        bestdx = 0;    
        bestdy = 0;
        
        bestm = 0;
        bestn = 0;
        while stepSize >= 1
              points = [ 0, 0; -stepSize, -stepSize; stepSize, stepSize;
                         -stepSize, stepSize; stepSize, -stepSize;];
 
               for k = 1:size(points, 1) 
                    m = points(k, 1);
                    n = points(k, 2);
                    ii = i + dy + m;
                    jj = j + dx + n;

                    if (ii < 1 || ii+blk-1 > r || jj < 1 || jj+blk-1 > c)
                        continue;
                    end
                    
                    refBlk = refImg(ii : ii+blk-1, jj : jj+blk-1);
                    blkDist = sum(sum(abs(currBlk - refBlk)));
                    
                    if (blkDist < minDist)
                        minDist = blkDist;
                        bestdy = dy + m;
                        bestdx = dx + n;
                        bestm = m;
                        bestn = n;
                    end
               end
                dy = bestdy;
                dx = bestdx;
                stepSize = floor(stepSize / 2);
        end

        if (bestm == 1 && bestn == -1) || (bestm == -1 && bestn == 1)
                finalPoints = [ 0, 0; -1, 0; 0, -1; 1, 0; 0, 1; ];
        else
                finalPoints = [ 0, 0; -1, -1; 1, -1; 1, 1; -1, 1;]; 
        end
        
        for k = 1:size(finalPoints, 1)   
            m = finalPoints(k, 1);    
            n = finalPoints(k, 2);
     
            ii = i + dy + m;
            jj = j + dx + n;
        
            if (ii < 1 || ii+blk-1 > r || jj < 1 || jj+blk-1 > c)
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
        dy =  bestdy;
        dx = bestdx;
        
        motionVecX(iBlk, jBlk) = dx; 
        motionVecY(iBlk, jBlk) = dy;
            
        predictImg(i:i+blk-1, j:j+blk-1) = refImg(i+dy:i+dy+blk-1, j+dx:j+dx+blk-1);
        
        jBlk = jBlk + 1;
    end
    iBlk = iBlk + 1;
end





