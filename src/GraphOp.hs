module GraphOp where

import Graph

data GraphOp a next = Get a (Maybe (Colored a) -> GraphOp a next)
                    | Visit a (GraphOp a next)
                    | Yield a (GraphOp a next)
                    | Return next 

instance Functor (GraphOp a) where
  fmap f (Get x g)    = Get x (\n -> fmap f (g n))
  fmap f (Visit x op) = Visit x (fmap f op)
  fmap f (Yield x op) = Yield x (fmap f op)
  fmap f (Return op)  = fmap f (Return op)

instance Applicative (GraphOp a) where
  pure  = Return
  (<*>) = undefined

instance Monad (GraphOp a) where
  return = Return
  (Get x g) >>= f = Get x (\n -> (g n) >>= f)
  (Visit x op) >>= f = Visit x (op >>= f)
  (Yield x op) >>= f = Yield x (op >>= f)
  (Return x) >>= f = f x

get :: a -> GraphOp a (Maybe (Colored a))
get x = Get x Return

visit :: a -> GraphOp a ()
visit x = Visit x (Return ())

yield :: a -> GraphOp a ()
yield x = Yield x (Return ())

dfs :: a -> GraphOp a ()
dfs x = do
  visit x
  y <- get x
  propagate y

propagate :: Maybe (Colored a) -> GraphOp a ()
propagate Nothing                  = return ()
propagate (Just (Colored _ True))  = return ()
propagate (Just (Colored x False)) = dfs x >> yield x

data Output a = Leaving a (Output a)
              | Visited a (Output a)
              | Recorded a (Output a)
              | Done deriving (Show)

run :: (Ord a, Show a) => GraphOp a next -> Graph a -> Output a
run (Get loc f) gr = Leaving loc (run (f desc) gr) where desc = descendent loc gr
run (Visit loc op) gr = Visited loc (run op gr') where gr' = mark loc gr
run (Yield loc op) gr = Recorded loc (run op gr)
run (Return _) _  = Done

