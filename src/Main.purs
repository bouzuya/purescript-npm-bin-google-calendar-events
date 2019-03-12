module Main
  ( main
  ) where

import Bouzuya.CommandLineOption as CommandLineOption
import CalendarEvents (Event)
import CalendarEvents as CalendarEvents
import Data.Array as Array
import Data.Either as Either
import Data.Foldable as Foldable
import Data.JSDate as JSDate
import Data.Maybe (Maybe(..))
import Data.Maybe as Maybe
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Node.Process as Process
import Prelude (Unit, bind, const, discard, map, otherwise, pure, (<<<), (<>), (==))
import Simple.JSON as SimpleJSON

showEventsAsJSON :: Array Event -> Effect Unit
showEventsAsJSON = Console.log <<< SimpleJSON.writeJSON

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

help :: String
help =
  Array.intercalate
    "\n"
    [ "Usage: google-calendar-events [options]"
    , ""
    , "Options:"
    , "  -d, --directory <DIRECTORY> {credentials,token}.json directory(default:.)"
    , "  -f, --format <json|text>    format (default:text)"
    , "  -i, --id <ID>               calendar id (default:primary)"
    , "  -h, --help                  help"
    , ""
    ]

main :: Effect Unit
main = do
  args <- map (Array.drop 2) Process.argv
  { options } <-
      Either.either
        (const (Exception.throw "invalid options"))
        pure
        (CommandLineOption.parse
          { directory:
              CommandLineOption.stringOption
                "directory"
                (Just 'd')
                "<DIRECTORY>"
                "{credentials,token}.json directory"
                "."
          , format:
              CommandLineOption.stringOption
                "format" (Just 'f') "<json|text>" "format" "text"
          , id:
              CommandLineOption.stringOption
                "id" (Just 'i') "<ID>" "calendar id" "primary"
          , help: CommandLineOption.booleanOption "help" (Just 'h') "help" }
          args)
  if options.help
    then Console.log help
    else Aff.launchAff_ do
      jsDate <- liftEffect JSDate.now
      timeMin <- liftEffect (JSDate.toISOString jsDate)
      client <- CalendarEvents.newClient options.directory
      responseMaybe <-
        CalendarEvents.listEvents
          { calendarId: options.id
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
      let
        formatter =
          if options.format == "json" then showEventsAsJSON else showEvents
      liftEffect (formatter response.data.items)
