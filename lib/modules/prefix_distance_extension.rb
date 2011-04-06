module PrefixDistanceExtension
  def bin_dist_to( farPoint )
    if farPoint != nil
      nearPointArr = self.to_s
      farPointArr = farPoint.to_s
      if nearPointArr.length != farPointArr.length
        return [nearPointArr.length, farPointArr.length].min
      else
        n = nearPointArr.length
        nearPointArr.length.times do | i |
          if nearPointArr[i] == farPointArr[i]
            n -= 1
          else
            break
          end
        end
        return n
      end
    end
  end
end
