{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}

module Access where

import Data.IORef 

data ReadOnly
data ReadWrite
data Access a b = Access b

class Ref m ref a where
  newRef   :: a -> m (ref a)
  readRef  :: ref a -> m a
  writeRef :: ref a -> a -> m ()

create :: (Monad m, Ref m ref a) => a -> m (Access c (ref a))
create = fmap Access . newRef

set :: (Monad m, Ref m ref a) => Access ReadWrite (ref a) -> a -> m ()
set (Access r) x = writeRef r x

get :: (Monad m, Ref m ref a) => Access c (ref a) -> m a
get (Access x) = readRef x

readonly :: Access c (ref a) -> Access ReadOnly (ref a)
readonly (Access x) = Access x

instance Ref IO IORef a where
  newRef   = newIORef
  readRef  = readIORef
  writeRef = writeIORef

test :: IO ()
test = do 
  -- Will not compile with ReadOnly
  aref <- create 5 :: IO (Access ReadWrite (IORef Int))
  set aref 44

{-

GHC CORE OUTPUT -  NO PERFORMANCE OVERHEAD

main1 ::
    GHC.Prim.State# GHC.Prim.RealWorld
    -> (# GHC.Prim.State# GHC.Prim.RealWorld, () #)
  {- Arity: 1, HasNoCafRefs, Strictness: <S,U>,
     Unfolding: InlineRule (1, True, False)
                (\ (s :: GHC.Prim.State# GHC.Prim.RealWorld)[OneShot] ->
                 case GHC.Prim.newMutVar#
                        @ GHC.Types.Int
                        @ GHC.Prim.RealWorld
                        (GHC.Types.I# 5#)
                        s of ds { (#,#) ipv ipv1 ->
                 case GHC.Prim.writeMutVar#
                        @ GHC.Prim.RealWorld
                        @ GHC.Types.Int
                        ipv1
                        (GHC.Types.I# 44#)
                        ipv of s2# { DEFAULT ->
                 (# s2#, GHC.Tuple.() #) } }) -}
-}

-- CLEANER GHC CORE VERSION
-- newMutVar# :: a -> State# s -> (# State# s, MutVar# s a #)
-- newMutVar# = newMutVar#

-- writeMutVar# :: MutVar# s a -> a -> State# s -> State# s
-- writeMutVar# = writeMutVar#

-- main1 :: GHC.Prim.State# GHC.Prim.RealWorld -> (# GHC.Prim.State# GHC.Prim.RealWorld, () #)
-- main1 = \ (s0 :: GHC.Prim.State# GHC.Prim.RealWorld) ->
--   case GHC.Prim.newMutVar# (GHC.Types.I# 5#) s0 of { (#,#) s1 mv ->
--    case GHC.Prim.writeMutVar# mv (GHC.Types.I# 44#) s1 of s2# { DEFAULT ->
--     (# s2#, GHC.Tuple.() #) } 
--   }) 