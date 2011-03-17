module BinaryDistanceExtension
  def bin_dist_to( farPoint )
    if farPoint != nil
      nearPointArr = self.to_s.bytes.to_a
      farPointArr = farPoint.to_s.bytes.to_a
      if nearPointArr.length != farPointArr.length
        if nearPointArr.length < farPointArr.length
          (farPointArr.length - nearPointArr.length).times do
            nearPointArr.push( nil )
          end
        else
          (nearPointArr.length - farPointArr.length).times do
            farPointArr.push( nil )
          end
        end
      end
      if nearPointArr != farPointArr
        n = nearPointArr.length
        nearPointArr.length.times do | i |
          if nearPointArr[i] == farPointArr[i]
            n -= 1
          end
        end
        return n
      else
        return 0
      end
    end
    nil
  end
end
