function [node_list, elem_list] = frame2d_reader(fileName)
%% Program: frame2d_reader
%
%   @DESCRIPTION Analysis of 2d frame structures. See the documentation of
%   the input and output files in the document framelab_inputfile.pdf. @
%
%   @AUTHOR Guilherme N. Fontebasso @
%   
%   @REFERENCE truss2d by Fabiano F. Bargos, Marco L. Bittencourt. @
%
%   @CREATED June/2019 @
%
%   @REVISED 1. @                
%
%

    %% Reading the input filename
    br = ' ';
    br0(1:66) = '=';
    br1(1:66) = '-';

    disp(br0);
    fprintf(1, 'FRAME 2D\n');
    disp(br0);
    fprintf(1, '\n%s\n', br0);
    if nargin > 0
        InpFileName = fileName;
    else
        InpFileName = input('INPUT FILENAME (without extension): ', 's');
    end
    FileName    = sprintf('%s.fem', InpFileName);
    File        = fopen(FileName, 'r');
    fprintf(1, '%s', br0);

    % Sets the error message.
    message = 'FRAME2D';

    %% Reading nodal coordinates
    % Sets the keyword.
    kwCoords = '*COORDINATES';

    fprintf(1,'\nREADING NODAL COORDINATES...');
    if (FindKeyWord(kwCoords, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwCoords);
    else
        TotalNumNodes = fscanf(File, '%d', 1);
        Coords        = (fscanf(File, '%d%f%f',  [3 TotalNumNodes]))';
    end

    % deletes node numbers
    Coords(:, 1) = [];

    % Number of nodal dofs
    % NumNodalDOFs  = 3;

    %% Reading element groups
    % Sets the keyword.
    kwElemGrps = '*ELEMENT_GROUPS';

    fprintf(1,'\nREADING ELEMENT GROUPS...');
    if (FindKeyWord(kwElemGrps, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwElemGrps);
    else
        NumGroups = fscanf(File, '%d', 1);
        Groups    = (fscanf(File, '%d%d', [2 NumGroups]))';
    end

    % deletes group numbers
    Groups(:, 1) = [];

    %total number of elements
    TotalNumElements = sum(Groups);

    %% Reading incidences
    % Sets the keyword.
    kwIncid = '*INCIDENCES';

    fprintf(1,'\nREADING ELEMENT INCIDENCES...');
    if (FindKeyWord(kwIncid, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwIncid);
    else
        Incid = (fscanf(File, '%d%f%f', [3 TotalNumElements]))';
    end

    % deletes element numbers
    Incid(:, 1) = [];

    %% Reading materials
    % Sets the keyword.
    kwMaters = '*MATERIALS';

    fprintf(1,'\nREADING MATERIALS...');
    if (FindKeyWord(kwMaters, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwMaters);
    else
        NumMaters = fscanf(File, '%d', 1);
        Maters    = (fscanf(File, '%f%f%f', [3 NumMaters]))';
    end

    %% Reading geometric properties
    % Sets the keyword.
    kwGPs = '*GEOMETRIC_PROPERTIES';

    fprintf(1,'\nREADING GEOMETRIC PROPERTIES...');
    if (FindKeyWord(kwGPs, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwGPs);
    else
        NumGPs = fscanf(File, '%d', 1);
        GPs    = (fscanf(File, '%f%f%f', [2 NumGPs]))';
    end

    %% Reading boundary conditions
    % Sets the keyword.
    kwBCs = '*BCNODES';

    fprintf(1,'\nREADING BOUNDARY CONDITIONS...');
    if (FindKeyWord(kwBCs, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwBCs);
    else
        NumBCNodes = fscanf(File, '%d', 1);
        HDBCNodes  = (fscanf(File, '%d%d', [2 NumBCNodes]))';
    end

    %% Reading loads
    % Sets the keyword.
    kwLoads = '*LOADS';

    fprintf(1,'\nREADING LOADS...\n');
    if (FindKeyWord(kwLoads, File) == 0)
        warning(message, 'Keyword |%s| Not Found.', kwLoads);
    else
        NumLoadedNodes = fscanf(File, '%d', 1);
        Loads          = (fscanf(File, '%d%d%f', [3 NumLoadedNodes]))';
    end

    % Close input file
    fclose(File);
    
    %% Initialize lists of nodes, elements, blocked nodes and forces

    % Initialize list of Nodes
    init_node_array(TotalNumNodes) = InitArrayOfNode;
    node_list = ListOfNode(init_node_array);

    % Initialize list of Elements
    init_elem_array(TotalNumElements) = InitArrayOfElement;
    elem_list = ListOfElement(init_elem_array,Groups,NumGroups);

    %Initialize blocked degrees array
    bclines = zeros(1,NumBCNodes);

    % Fill list of nodes coordinates
    for i = 1:size(Coords,1)
        temp_node = Node(i, Coords(i,1), Coords(i,2));
        node_list.setNode(temp_node, i);
    end

    % Fill loads in the nodes
    for i = 1:NumLoadedNodes
        if Loads(i,2) == 1
            node_list.setNx(Loads(i,1),Loads(i,3));
        elseif Loads(i,2) == 2
            node_list.setVy(Loads(i,1),Loads(i,3));
        else
            node_list.setMz(Loads(i,1),Loads(i,3));
        end
    end
    
    % Calc Fg array
    node_list.calcFg();
    
    %Fill array of index of blocked lines in the K matrix
    for i = 1:size(HDBCNodes,1)
        if HDBCNodes(i,2) == 1
            bclines(i) = 3*HDBCNodes(i,1)-2;
        elseif HDBCNodes(i,2) == 2
            bclines(i) = 3*HDBCNodes(i,1)-1;
        else
            bclines(i) = 3*HDBCNodes(i,1);
        end
    end
    
    % Set list of blocked lines and calc coordinates
    node_list.setBClines(bclines);
    
    %Fill list of elements
    i = 1;
    for Grp = 1 : NumGroups
        E = Maters(Grp, 1);
        sigma_esc = Maters(Grp, 2);
        rho = Maters(Grp, 3);
        De = GPs(Grp, 1);
        thick = GPs(Grp, 2);

        for  TNE = 1 : Groups(Grp, 1)
            temp_elem = Element(node_list.nodes(Incid(i,1)).node, node_list.nodes(Incid(i,2)).node, E, sigma_esc, De, thick, rho);
            elem_list.elems(i).elem = temp_elem;
            i = i + 1;
        end
    end
end

