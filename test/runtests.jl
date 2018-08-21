using Juno
using Test

@test Juno.isactive() == false

@test Juno.plotsize() == [100, 100]

@test_throws Exception selector(["foo", "bar", "baz"])

let i = 0, x
  x = @progress for _ = 1:100
    i += 1
  end
  @test i == 100
  @test x == nothing
end

let i = 0, x
  x = @progress "named" for _ = 1:100
    i += 1
  end
  @test i == 100
  @test x == nothing
end

let i = 0, j = 0, x
  x = @progress for _ = 1:10, __ = 1:20
    i += 1
  end
  @test i == 200
end

let x,y
  x = @progress y = [i+3j for i=1:3, j=1:4]
  @test y == reshape(4:15,3,4)
  @test x == y
end


@test Juno.notify("hi") == nothing
