using Test
using BandedMats
# using Symbolics
# import Symbolics: scalarize, variables

# Mat(name, n) = variables(name, 1:n, 1:n)
# Vec(name, n) = variables(name, 1:n)

@testset "BandMat" begin
  p, q = 2, 1
  # A = Mat(:a, 5)
  A = rand(5, 4)
  b = BandMat(A, p, q)
  bd1 = BandedMat(b; type="lapack")
  bd2 = BandedMat(b; type="kong")
  print(b)

  @test band_zip(b; type="kong") == bd2.data

  r1 = BandMat(bd1).data - A
  r2 = BandMat(bd2).data - A

  @test maximum(abs.(r1)) <= 1e-10
  @test maximum(abs.(r2)) <= 1e-10
end

@testset "force" begin
  A = rand(5, 5)
  force_lower!(A) # 注意会修改A
  force_upper!(A) 
  @test A == diagm(diag(A))
end

@testset "diff" begin
  # size, bandwidth = (4, 5), (1, 3)
  function test_diff(size, bandwidth)
    A = rand(size...)
    p, q = bandwidth
    force_band!(A, p, q)
    b = BandedMat(A, p, q; zipped=false)
    
    d = 2
    r = diff(b, d)
    @test Matrix(r) ≈ diff(A, d)
  end

  test_diff((4, 5), (1, 3))

  test_diff((5, 5), (1, 2))
  test_diff((5, 5), (2, 1))
  test_diff((10, 4), (2, 1))
  test_diff((4, 10), (2, 1))
end


@testset "transpose" begin
  A = rand(5, 5)
  p, q = 1, 2
  b = BandedMat(A, p, q; zipped=false)
  bt = BandedMat(A', q, p; zipped=false)
  mat_equal((b').data, bt.data)

  A = rand(5, 5)
  p, q = 2, 1
  b = BandedMat(A, p, q; zipped=false)
  bt = BandedMat(A', q, p; zipped=false)
  mat_equal((b').data, bt.data)
end

@testset "mult" begin
  function test_mult(x, y)
    x2 = BandedMat(x)
    y2 = BandedMat(y)
    @test (x * y).data ≈ x.data * y.data
    @test Matrix(x2 * y2) ≈ x.data * y.data
  end

  x = BandMat(rand(5, 4), 1, 2)
  y = BandMat(rand(4, 10), 2, 3)
  test_mult(x, y)

  x = BandMat(rand(5, 4), 1, 2)
  y = BandMat(rand(4, 5), 2, 3)
  test_mult(x, y)

  # 测试畸形矩阵
  n = 10
  x = rand(n, 8)
  y = rand(8, n)

  A = BandMat(x, 0, 3)
  B = BandMat(y, 2, 1)

  A2 = BandedMat(A)
  B2 = BandedMat(B)

  @test Matrix(A2 * B2) ≈ x * y
end
