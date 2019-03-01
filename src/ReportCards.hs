module ReportCards (
  interpolateReportBody
) where

import Control.Applicative (many, (<|>))
import Text.Printf         (printf)
import NanoParsec

data ReportBody = Character Char
                | Report String String
                deriving (Show)

template = "<li>"
           ++ "<a href=\"images/report-cards/%s\">%s</a>" ++
           "</li>"

reportBody :: Parser [ReportBody]
reportBody = many (reportReport <|> reportChar)

reportReport :: Parser ReportBody
reportReport = Report <$> (string "[report:" *> notChar ':')
                      <*> (char ':' *> notChar ']' <* char ']')
  where
    notChar :: Char -> Parser String
    notChar c = many $ satisfy (/=c)

reportChar :: Parser ReportBody
reportChar = Character <$> item

interpolateReportBody :: String -> String
interpolateReportBody src = concatMap toString (run reportBody src)
  where
    toString :: ReportBody -> String
    toString (Character c)          = [c]
    toString (Report filename desc) = printf template filename desc

