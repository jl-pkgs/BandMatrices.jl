using Test
# using Symbolics
# import Symbolics: scalarize, variables

# Mat(name, n) = variables(name, 1:n, 1:n)
# Vec(name, n) = variables(name, 1:n)

@testset "BandMat" begin
  p, q = 2, 1
  # A = Mat(:a, 5)
  A = rand(5, 5)
  b = BandMat(A, p, q)
  bd1 = BandedMat(b; type="lapack")
  bd2 = BandedMat(b; type="kong")
  print(b)

  r1 = BandMat(bd1).data - A
  r2 = BandMat(bd2).data - A

  @test maximum(abs.(r1)) <= 1e-10
  @test maximum(abs.(r2)) <= 1e-10
end

@testset "transpose" begin
  A = rand(5, 5)
  p, q = 1, 2
  b = BandedMat(A, p, q; zipped=false)
  bt = BandedMat(A', q, p; zipped=false)
  mat_equal(transpose(b).data, bt.data)

  A = rand(5, 5)
  p, q = 2, 1
  b = BandedMat(A, p, q; zipped=false)
  bt = BandedMat(A', q, p; zipped=false)
  mat_equal(transpose(b).data, bt.data)
end

# @testset "mult" 
begin
  A = rand(5, 4)
  p, q = 1, 2
  force_band!(A, p, q)
  x = BandMat(A, p, q)
  x2 = BandedMat(A, p, q; zipped=false)

  B = rand(4, 10)
  p, q = 2, 3
  force_band!(B, p, q)
  y = BandMat(B, p, q)
  y2 = BandedMat(B, p, q; zipped=false)
  # x * y ≈ A * B
end
# , r + q] # 列的最大值
