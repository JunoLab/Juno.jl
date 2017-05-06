using Juno
using Base.Test

@test Juno.isactive() == false

@test_throws Exception selector(["foo", "bar", "baz"])

let i = 0
  @progress for _ = 1:100
    i += 1
  end
  @test i == 100
end

let i = 0
  @progress "named" for _ = 1:100
    i += 1
  end
  @test i == 100
end

@test Juno.notify("hi")
