##################################################################
###########        FEM Lab Course -by Saurabh Singh    ###########
##################################################################
push!(LOAD_PATH,"./")

using LinearAlgebra
using Plots
using functions

function main()
  # Write a program to solve a general 2D truss problem using FEM
  # Daryl Logan Example 3.5
  # antonio ferreira 2008
  # Modified by Ahmed Rashed
  # Units used are ft lb

  # Material properties
  E_vec = 70e3*ones(11)
  A_vec = 30e3*ones(11)

  # Generation of coordinates and connectivities
  nodesCoords = [
      0.0 0.0;
      0.0 3000.0;
      3000.0 0.0;
      3000.0 3000.0;
      6000.0 0.0;
      6000.0 3000.0
  ]
  numberNodes = size(nodesCoords, 1)

  elementNodes = [
    1 2;  
    1 3;  
    2 3;  
    2 4;  
    1 4;  
    3 4;  
    3 6;  
    4 5;  
    4 6;  
    3 5;  
    5 6 
  ]
  numberElements = size(elementNodes, 1)

  # GDof: total number of degrees of freedom
  GDof = 2 * numberNodes

  # Assembly stiffness matrix
  K_assembly = formStiffness2Dtruss(GDof, numberElements, elementNodes, nodesCoords, E_vec, A_vec)

  # Boundary conditions
  prescribedDof = [1, 2, 10]

  # Force vector
  F_col = fill(NaN, GDof)
  F_col[4] = -50.0e3
  F_col[8] = -100.0e3
  F_col[12] = -50.0e3

  for idof in [3,5,6,7,9,11]
    F_col[idof] = 0.
  end

  # Displacement vector
  D_col = fill(NaN, GDof)
  for idof in prescribedDof D_col[idof] = 0.0 end

  # Solution
  D_col, F_col = solution(prescribedDof, K_assembly, D_col, F_col)

  ### POST PROCESSING
  # Deformation components
  us = 1:2:(2 * numberNodes - 1)
  vs = 2:2:(2 * numberNodes)

  # Extract the x and y components of the displacement
  XX = D_col[us]
  YY = D_col[vs]

  # Calculate the maximum norm of the displacements
  dispNorm = maximum(sqrt.(XX.^2 .+ YY.^2))

  # Scale factor for displacements
  scaleFact = 15000 * dispNorm

  # Adjust node coordinates with displacements for visualization
  adjustedCoords = nodesCoords .+ scaleFact * hcat(XX, YY)

  # Initial plot setup
  plot1 = plot(aspect_ratio=:equal)

  # Draw the original mesh
  drawingMesh(plot1, nodesCoords, elementNodes,:black, :dot)

  # Draw the deformed mesh
  drawingMesh(plot1,adjustedCoords, elementNodes,:red,:solid)

  # Save the plot
  savefig("problem2_truss2d_3.png")
  # Stress at elements
  stress = stresses2Dtruss(numberElements, elementNodes, nodesCoords, D_col, E_vec)

  # Optional drawing part would be implemented here using a Julia plotting library
  
end

main()