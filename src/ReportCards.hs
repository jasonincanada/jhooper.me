{- ReportCards.hs

   This module exports interpolateReportBody, which looks through the body of a
   file in school-years/*.md for a [report] segment, eg:

     [report:Grade-5-Term-1.jpg:Progress Report - November]

   and converts it to an HTML <li> element, eg:

     <li><a href="images/report-cards/Grade-5-Term-1.jpg">Progress Report - November</a></li>

-}

module ReportCards (
  interpolateReportBody
) where

import Control.Applicative (many, (<|>))
import Text.Printf         (printf)
import NanoParsec          (char, item, Parser, run, satisfy, string)

data ReportBody = Character Char
                | Report String String
                deriving (Show)

-- concatMap :: Foldable t => (a -> [b]) -> t a -> [b]
interpolateReportBody :: String -> String
interpolateReportBody body = concatMap toString parsed
  where
    toString :: ReportBody -> String
    toString (Character c)          = [c]
    toString (Report filename desc) = printf template filename desc

    template = "<li>"
               ++ "<a href=\"images/report-cards/%s\">%s</a>" ++
               "</li>"

    parsed :: [ReportBody]
    parsed = run reportBody body

    reportBody :: Parser [ReportBody]
    reportBody = many (reportReport <|> reportChar)
      where
        reportChar, reportReport :: Parser ReportBody
        reportChar   = Character <$> item
        reportReport = Report <$> (string "[report:" *> notChar ':')
                              <*> (string ":"        *> notChar ']' <* char ']')

        notChar :: Char -> Parser String
        notChar c = many $ satisfy (/=c)

