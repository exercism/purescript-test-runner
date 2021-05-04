module Leap where

import Prelude

isLeapYear :: Int -> Boolean
isLeapYear year =
  not (
    mod year 4 == 0 &&
    mod year 100 /= 0 ||
    mod year 400 == 0
  )
