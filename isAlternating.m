% Copyright (c) 2015, UC San Diego CURE Program
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function alternating = isAlternating(adj_matrix, n_vertices)
    % Checks if an adjacency matrix corresponds to an alternating tree
    %
    % Parameters:
    %    adj_matrix - Adjacency matrix to check
    %    n_vertices - Number of vertices in tree
    %
    % Output:
    %    alternating - 0: not alternating
    %                  1: alternating

    alternating = 1; % Assume alternating
    
    for i=2:n_vertices
        
        left_positive = 0;
        right_positive = 0;
        
        for j=1:i-1
            if adj_matrix(i,j) == 1
                left_positive = 1;
                break;
            end
        end
        
        for j=i+1:n_vertices
            if adj_matrix(i,j) == 1
                right_positive = 1;
            end
        end
        
        % If adj_matrix has ones on both sides of the main diagonal,
        % the tree is not alternating, so return 0.
        if left_positive == 1 && right_positive == 1
            alternating = 0;
            break;
        end
        
    end
end

