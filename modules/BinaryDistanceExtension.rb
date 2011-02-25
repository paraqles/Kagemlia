module BinaryDistanceExtension
  def binDistTo( farPoint )
    nearPointArr = self.to_s.bytes.to_a
    farPointArr = farPoint.to_s.bytes.to_a
    
    if nearPointArr.length != farPointArr.length
      nearPointArr.length if nearPointArr.length > farPointArr.length
      farPointArr.length if nearPointArr.length < farPointArr.length
    else
      nearPointArr.length.times do | i |
        if nearPointArr[i] != farPointArr[i]
          return i
        end
      end
    end
  end
end