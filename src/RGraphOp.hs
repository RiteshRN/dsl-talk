{-# LANGUAGE DeriveFunctor, RankNTypes #-}

module RGraphOp where

import Graph
import GraphOp

newtype RGraphOp a next = RGraphOp {rGraphOp :: forall b. (next -> GraphOp a b) -> (GraphOp a b)}
  deriving (Functor)

instance Applicative (RGraphOp a) where
  pure  = undefined
  (<*>) = undefined

instance Monad (RGraphOp a) where
  return x = RGraphOp (\k -> k x)
  (RGraphOp f) >>= g = RGraphOp (\h -> f (\n -> rGraphOp (g n) h))

up :: GraphOp a next -> RGraphOp a next
up gop = RGraphOp (\k -> gop >>= k)

down :: RGraphOp a next -> GraphOp a next
down (RGraphOp rgop) = rgop Return

rget :: a -> RGraphOp a (Maybe (Colored a))
rget x = up $ get x

rvisit :: a -> RGraphOp a ()
rvisit x = up $ visit x

ryield :: a -> RGraphOp a ()
ryield x = up $ yield x

rdfs :: a -> RGraphOp a ()
rdfs x = do 
  rvisit x
  y <- rget x
  rpropagate y

rpropagate :: Maybe (Colored a) -> RGraphOp a ()
rpropagate Nothing                  = return ()
rpropagate (Just (Colored _ True))  = return ()
rpropagate (Just (Colored x False)) = rdfs x >> (ryield x)


