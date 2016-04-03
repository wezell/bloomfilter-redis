module Common where

import Data.Hashable
import Database.Redis
import qualified Data.ByteString.Char8 as BS

import Data.RedisBloom
import Data.RedisBloom.Hash
import Data.RedisBloom.Suggestions

test_key :: Key
test_key = BS.pack "tk"

test_bf :: Bloom Int
test_bf = Bloom test_key sz hb
    where
      hc = HashCount 16
      hb = hashFamilyFNV1a hc :: HashFamily Int
      kb = (*8192)
      sz = Capacity $ kb 32

createAddQuery :: Hashable a => Bloom a -> a -> Redis Bool
createAddQuery b x = createBF b >> addBF b x >> queryBF b x
createAddL :: (Hashable a, Traversable t) => Bloom a -> t a -> Redis ()
createAddL b l = createBF b >> mapM_ (addBF b) l
queryL :: (Hashable a, Traversable t) => Bloom a -> t a -> Redis (t Bool)
queryL b = mapM (queryBF b)
createAddQueryL :: (Hashable a, Traversable t) => Bloom a -> t a -> Redis (t Bool)
createAddQueryL b l = createAddL b l >> queryL b l
