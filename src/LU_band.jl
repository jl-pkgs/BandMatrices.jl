"""
    LU_band(B::BandedMat{T})

带状矩阵的LU分解, Doolittle's method

```math
[i, j] => [i, j - i + p + 1] # L and A
[i, j] => [i, j - i + 1]     # U
```

- [x] 有效的减少循环次数
- [x] 压缩数据存储
"""
function LU_band(B::BandedMat{T}) where {T}
  (; p, q) = B
  A = B.data
  n = size(A, 1)
  l = zeros(T, n, p)
  u = zeros(T, n, q + 1)

  @inbounds for i = 1:n
    # l[i, p+1] = 1
    for j = i:min(i + q, n)
      u[i, j-i+1] = A[i, j-i+p+1]
      for k = max(i - p, j - q, 1):min(i - 1, j - 1)
        u[i, j-i+1] -= l[i, k-i+p+1] * u[k, j-k+1]
      end
    end

    for i2 = i+1:min(i + p, n)
      l[i2, i-i2+p+1] = A[i2, i-i2+p+1]
      for k = max(i2 - p, i - q, 1):min(i - 1, i2 - 1)
        l[i2, i-i2+p+1] -= l[i2, k-i2+p+1] * u[k, i-k+1]
      end
      l[i2, i-i2+p+1] /= u[i, 1]
    end
  end

  BL = BandedMat(l, p, 0; type="kong")
  BU = BandedMat(u, 0, q; type="kong")
  BL, BU
end


"""
    LU_band_full(A::AbstractMatrix{T}; p=2, q=1)

带状矩阵的原始矩阵解法，与LU_full类似，只是求解的过程中，跳过了空值的部分。
"""
function LU_band_full(A::AbstractMatrix{T}; p=2, q=1) where {T}
  n = size(A, 1)
  u = zeros(T, n, n)
  l = zeros(T, n, n)

  @inbounds for i = 1:n
    l[i, i] = 1
    for j = i:min(i + q, n)
      # u[i, j] = A[i, j] - sum(l[i, 1:i-1] .* u[1:i-1, j])
      u[i, j] = A[i, j]
      for k = max(i - p, j - q, 1):min(i - 1, j - 1)
        u[i, j] -= l[i, k] * u[k, j]
      end
    end

    for i2 = i+1:min(i + p, n)
      # 若是对称矩阵，则直接上答案
      # l[i2, i] = u[i, i2] / u[i, i]
      # l[i2, i] = (A[i2, i] - sum(l[i2, 1:i-1] .* u[1:i-1, i])) / u[i, i]
      l[i2, i] = A[i2, i]
      for k = max(i2 - p, i - q, 1):min(i - 1, i2 - 1)
        l[i2, i] -= l[i2, k] * u[k, i]
      end
      l[i2, i] /= u[i, i]
    end
  end
  l, u
end

# function LU_band_symmetry(A; p=2, q=1)
#   n = size(A, 1)
#   l = variables(:l, 1:p, 1:n)   # [i+k, i] -> [k, i]  ;  [i, j] -> [i-j, j]
#   u = variables(:l, 1:n, 1:q+1) # [i, i+k] -> [i, k+1];  [i, j] -> [i, j-i+1]
#   fill!(u, 0)
#   fill!(l, 0)
#   # L与U，二者不可或缺
#   for i = 1:n
#     for j = i:min(i + q, n)
#       u[i, j-i+1] = A[i, j]
#       for k = max(i - p, j - q, 1):min(i - 1, j - 1)
#         u[i, j-i+1] -= l[i-k, k] * u[k, j-k+1]
#       end
#     end
#     # 对称矩阵的福利: L = U' D^-1
#     for i2 = i+1:min(i + p, i + q, n)
#       l[i2-i, i] = u[i, i2-i+1] / u[i, 1] # u[i, i2]
#     end
#   end
#   l, u
# end
