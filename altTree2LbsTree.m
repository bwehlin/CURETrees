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

function [ root_val, nodes ] = altTree2LbsTree( adj_matrix )
    % Implementation of the bijection between alternating trees and local
    % binary search trees established in [1].
    %
    % [1] Alexander Postnikov, Intransitive
    %     Trees, Journal of Combinatorial Theory, Series A, Volume 79,
    %     Issue 2, August 1997, Pages 360-366, ISSN 0097-3165,
    %     http://dx.doi.org/10.1006/jcta.1996.2735.
    %
    % Parameters:
    %   adj_matrix - Adjacency matrix of alternating tree
    %
    % Output:
    %   root_val   - Value of the root node in the LBS tree
    %   nodes      - Row vector of LBS tree nodes

    n_vertices = size(adj_matrix, 1);
    
    if size(adj_matrix, 1) ~= size(adj_matrix, 2) ...
            || isAlternating(adj_matrix, n_vertices) == 0
        error('Adjacency matrix is not an alternating tree!');
    end
    
    % Initialize nodes
    
    nodes(1, n_vertices) = BinaryNode;
    
    for i=1:n_vertices
        nodes(i).val = i;
        nodes(i).left = 0;
        nodes(i).right = 0;
    end
    
    % Get children of max vertex
    children = getChildren(adj_matrix, n_vertices, n_vertices);
    root_val = children(end);
    
    queue = n_vertices;
    
    while ~isempty(queue)
        len_queue = length(queue);
        new_queue = [];
        
        for i=1:len_queue
            
            parent_idx = queue(i);
            children = getChildren(adj_matrix, n_vertices, parent_idx);
            
            % Detach parent
            
            adj_matrix(parent_idx, :) = 0;
            adj_matrix(:, parent_idx) = 0;
            
            
            n_children = length(children);
            
            if n_children == 0
                continue;
            end
            
            new_queue = [new_queue, children];
            
            cur_child = parent_idx;
            
            if cur_child > children(1)
                for j=1:n_children
                    nodes(cur_child).left = children(n_children + 1 - j);
                    cur_child = children(n_children + 1 - j);
                end
            else
                for j=1:n_children
                    nodes(cur_child).right = children(j);
                    cur_child = children(j);
                end
            end
        end
        
        queue = new_queue;
        
    end
    
    nodes = nodes(1:n_vertices - 1);
    
end

function children = getChildren(adj_matrix, n_vertices, parent_idx)
    % Returns a list of children of node parent_idx
    %
    % Parameters:
    %   adj_matrix - Adjacency matrix of alternating tree
    %   n_vertices - Number of vertices in alternating tree
    %   parent_idx - Index of parent node
    %
    % Output:
    %   children   - List of child nodes
    
    n_children = nnz(adj_matrix(parent_idx, :));
    children = zeros(1, n_children);
    
    cur_child = 1;
    
    for i=1:n_vertices
        if adj_matrix(parent_idx, i) ~= 0
            children(cur_child) = i;
            cur_child = cur_child + 1;
        end
    end
end


