module CalendarEvents
  ( Client
  , Event
  , ListEventResponse
  , listEvents
  , newClient
  ) where

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Array as Array
import Data.Foldable as Foldable
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Foreign (Foreign)
import Node.Encoding as Encoding
import Node.FS.Aff as FS
import Prelude (Unit, bind, discard, otherwise, pure, (<>))
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

showEvents :: Array Event -> Effect Unit
showEvents events
  | Array.null events =
      Console.log "No upcoming events found."
  | otherwise = do
      Console.log "Upcoming 10 events:"
      Foldable.for_ events \event -> do
        let
          start =
            Maybe.fromMaybe
              (Maybe.fromMaybe "" event.start.date)
              event.start.dateTime
        Console.log (start <> " - " <> event.summary)

listEvents :: forall r. { | r } -> Client -> Aff (Maybe ListEventResponse)
listEvents options client = do
  response <- Promise.toAffE (listEventsImpl options client)
  pure (SimpleJSON.read_ response)

newClient :: Aff Client
newClient = do
  credentials <- FS.readTextFile Encoding.UTF8 "credentials.json"
  token <- FS.readTextFile Encoding.UTF8 "token.json"
  liftEffect (newClientImpl credentials token)
