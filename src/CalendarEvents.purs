module CalendarEvents
  ( Client
  , Event
  , ListEventResponse
  , listEvents
  , newClient
  ) where

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign (Foreign)
import Node.Encoding as Encoding
import Node.FS.Aff as FS
import Node.Path as Path
import Prelude (bind, pure)
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import listEventsImpl ::
  forall r. { | r } -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type Event =
  { start ::
    { date :: Maybe String
    , dateTime :: Maybe String
    }
  , summary :: String
  }

type ListEventResponse =
  { data ::
    { items :: Array Event
    }
  }

listEvents :: forall r. { | r } -> Client -> Aff (Maybe ListEventResponse)
listEvents options client = do
  response <- Promise.toAffE (listEventsImpl options client)
  pure (SimpleJSON.read_ response)

newClient :: String -> Aff Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  liftEffect (newClientImpl credentials token)
