module Main where

import Graph
import GraphOp
import RGraphOp

main :: IO ()
main =  do 
  let fast  = rGraphOp (rdfs 1) $ Return :: GraphOp Int ()
  let slow  = dfs 1
  let output = run fast (initGraph 10000) 
  print output





