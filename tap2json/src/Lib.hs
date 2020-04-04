module Lib
    ( someFunc,
      parseStatusLine,
      TestResult(..)
    ) where

import Data.List (isPrefixOf)

someFunc :: IO ()
someFunc = putStrLn "someFunc"

data TestResult = Passed Int String |
                  Failed Int String
                  deriving (Eq, Show)

parseStatusLine :: String -> Maybe TestResult
parseStatusLine x
  | "ok " `isPrefixOf` x     =
    Just $ Passed (wordNo 1) (endFrom 2)
  | "not ok " `isPrefixOf` x =
    Just $ Failed (wordNo 2) (endFrom 3)
  | otherwise                = Nothing
  where wordList = words x
        wordNo n = read . head . drop n $ wordList
        endFrom n = unwords . drop n $ wordList
