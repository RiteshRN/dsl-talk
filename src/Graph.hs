module Graph where

import Data.Map.Strict (Map)
import qualified Data.Map.Strict as M

import Debug.Trace

-- Directed graph with maximum outdegree 1.
data Graph a = Graph { ancestors   :: Map a a
                     , descendents :: Map a a
                     , visited     :: Map a Bool
                     } deriving (Show)

initGraph :: Int -> Graph Int
initGraph n = Graph a d v 
  where d = M.fromList [(i, i+1) | i <- [1..(n-1)]]
        a = M.fromList [(i, i-1) | i <- [2..n]]
        v = M.fromList [(i, False) | i <- [1..n]]

-- Append each node with info about whether we've seen it before
-- Useful type for graph traversals
data Colored a = Colored {node :: a, marked :: Bool} deriving (Show)

descendent :: Ord a => a -> Graph a -> Maybe (Colored a)
descendent x gr = case M.lookup x (descendents gr) of
  Nothing -> Nothing
  Just y  -> case M.lookup y (visited gr) of
    Nothing -> Just (Colored y False)
    Just b  -> Just (Colored y b)

mark :: Ord a => a -> Graph a -> Graph a
mark x gr = gr { visited = M.insert x True (visited gr) }

trace' :: Show a => String -> a -> a
trace' s x = trace (s ++ "; " ++ show x) x

