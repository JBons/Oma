module Main where

import Prelude hiding (words)
import Data.Char hiding (isSpace)
import Data.List (reverse)
import GHC.Exts (sortWith)
import Control.Monad (forM, liftM)
import Trie
import System.Environment
import System.TimeIt
import Text.Printf

-- Expanded definition of "white space" for word splitter
isSpace :: Char -> Bool
isSpace c = not (isLetter c)

-- Own implementation of more accurate word splitter
words :: String -> [String]
words s = let clean = dropWhile isSpace s in
    case clean of
        ""  -> []
        str -> first : (words rest)
            where (first, rest) = span isLetter str 

-- Implements lexicon as Trie to count occurences of the words in a list
counts :: [String] -> [(String, Int)] 
counts = toList . foldl (update counting) (Trie.empty :: Trie Char Int) where
    counting Nothing = Just 1
    counting (Just n)  = Just (n+1)

--Words of a text together with their frequencies, sorted highest->lowest
wordFreqs :: String ->  [(String,Int)]  
wordFreqs = reverse . sortWith snd . counts . words . (fmap toLower)

main = timeIt proc --get running time

--Actual main UI task
proc = do args <- getArgs
          let n = (read $ args!! 0) :: Int
          let filename  = args!! 1
          text   <- readFile filename
          let result = wordFreqs text
          display $ take n result
          let wcount = length $ words text
          let uwords = length result
          putStrLn $ "Total words: " ++ (show wcount)
          putStrLn $ "Different words: " ++ (show uwords)
          putStrLn $ "Size of trie: " ++ (show $ trieSize text)

--Pretty-print the results
display xs = mapM putStrLn $ fmap disp xs where
    disp (x,y) = printf "%15s :   %4d" x y 

trieSize = size . (foldl (update counting) (Trie.empty :: Trie Char Int)) . words . (fmap toLower) where
    counting Nothing = Just 1
    counting (Just n)  = Just (n+1)    
