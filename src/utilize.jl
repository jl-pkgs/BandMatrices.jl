# include("main_symb.jl")

# funcs = [:size, :-, :+]
# for func in funcs
#   @eval Base.$func(b::BandMatrix) = Base.$func(b.A)
# end
# Base.getindex(x::BandMatrix, i, j) = x.A[i, j]
# Base.setindex!(x::BandMatrix, v, i, j) = x.A[i, j] = v;

function Base.show(io::IO, x::AbstractBandMatrix{T}) where {T<:Real}
  printstyled(io, "$(typeof(x)): p = $(x.p), q = $(x.q) \n", color=:blue, underline=true)
  display(x.data)
  nothing
end


# 代数余子式; algebraic complement
function complement(A::AbstractArray, i=1, j=1; verbose=false)
  i, j = j, i
  m, n = size(A)
  _A = A[setdiff(1:m, i), setdiff(1:n, j)]
  verbose && display(_A)
  (-1)^(i + j) * det(_A)
end

function complement(A::AbstractArray)
  R = similar(A)
  fill!(R, 0)
  m, n = size(A)
  for i = 1:m, j = 1:n
    R[i, j] = complement(A, i, j) # 代数余子式需要进行一次转置，才能得到A* = C'
  end
  R
end

export complement