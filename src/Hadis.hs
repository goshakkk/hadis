---
import           Hadis.Base
import           Hadis.Reply
import qualified Data.Map as Map
import qualified Control.Monad.State as S
import           Control.Monad.State hiding (get)
import           System.IO
---

data Command = SET Key Value
             | GET Key
             | GETSET Key Value
             | DEL Key
             | RENAME Key Key
             | KEYS
             deriving (Show, Read)

fff (a, b)= return (replyVal a, b)

runCommand :: Command -> KVMap -> IO (String, KVMap)
runCommand (SET k v)    m = runStateT (set k v) m    >>= fff
runCommand (GET k)      m = runStateT (get k)   m    >>= fff
runCommand (GETSET k v) m = runStateT (getset k v) m >>= fff
runCommand (DEL k)      m = runStateT (del k) m      >>= fff
runCommand (RENAME o n) m = runStateT (rename o n) m >>= fff
runCommand KEYS         m = runStateT keys m         >>= fff

rc :: StateKVIO ()
rc = do
  line <- liftIO prompt
  m <- S.get
  let command = read line :: Command
  (r,n) <- liftIO . runCommand command $ m
  modify (const n)
  liftIO $ putStrLn r
  rc

main :: IO ()
main = evalStateT rc $ Map.fromList [("a", "123")]

prompt = do
  putStr "> "
  hFlush stdout
  getLine