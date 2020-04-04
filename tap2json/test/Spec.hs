import Lib (parseStatusLine, TestResult(..))
import Test.Hspec (Spec, it, shouldBe)
import Test.Hspec.Runner (configFastFail, defaultConfig, hspecWith)

main :: IO ()
main = hspecWith defaultConfig {configFastFail = True} specs

specs :: Spec
specs = do

  it "detects a positive result line" $ do
    let res = parseStatusLine "ok 1 HelloWorld.helloWorld / Hello with no name"
    res `shouldBe` Just (Passed 1 "HelloWorld.helloWorld / Hello with no name")

  it "detects a negative result line" $ do
    let res =
          parseStatusLine "not ok 1 HelloWorld.helloWorld / Hello with no name"
    res `shouldBe` Just (Failed 1 "HelloWorld.helloWorld / Hello with no name")

  it "detects that a line is neither a passed nor a failed test" $ do
    let res = parseStatusLine "1..3"
    res `shouldBe` Nothing

  it "detects the test number in passing tests" $ do
    let res = parseStatusLine "ok 2 HelloWorld.helloWorld / Hello with no name"
    res `shouldBe` Just (Passed 2 "HelloWorld.helloWorld / Hello with no name")

  it "detects the test number in failing tests" $ do
    let res =
          parseStatusLine "not ok 2 HelloWorld.helloWorld / Hello with no name"
    res `shouldBe` Just (Failed 2 "HelloWorld.helloWorld / Hello with no name")

  it "detects the test name in passing tests" $ do
    let res =
          parseStatusLine "ok 2 HelloWorld.helloWorld / Hello to a sample name"
    res `shouldBe`
      Just (Passed 2 "HelloWorld.helloWorld / Hello to a sample name")

  it "detects the test name in failing tests" $ do
    let res = parseStatusLine
              "not ok 2 HelloWorld.helloWorld / Hello to a sample name"
    res `shouldBe`
      Just (Failed 2 "HelloWorld.helloWorld / Hello to a sample name")
