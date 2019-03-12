module Main where

import CalendarEvents (Event)
import CalendarEvents as CalendarEvents
import Data.Array as Array
import Data.Foldable as Foldable
import Data.JSDate as JSDate
import Data.Maybe as Maybe
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Node.Process as Process
import Prelude (Unit, bind, discard, map, otherwise, pure, (<>))

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

main :: Effect Unit
main = Aff.launchAff_ do
  args <- liftEffect (map (Array.drop 2) Process.argv)
  Console.logShow args
  jsDate <- liftEffect JSDate.now
  timeMin <- liftEffect (JSDate.toISOString jsDate)
  client <- CalendarEvents.newClient
  responseMaybe <-
    CalendarEvents.listEvents
      { calendarId: "primary"
      , maxResults: 10
      , orderBy: "startTime"
      , singleEvents: true
      , timeMin
      }
      client
  response <-
    liftEffect
      (Maybe.maybe
        (Exception.throw "JSON parse error")
        pure
        responseMaybe)
  liftEffect (showEvents response.data.items)
