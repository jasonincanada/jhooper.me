{-# LANGUAGE OverloadedStrings #-}

{- Hakyll source for jhooper.me

   This is an unnecessarily convoluted but really cool way to build a homepage :)
-}

import Data.Monoid ((<>))
import Hakyll
import ReportCards (interpolateReportBody)

main :: IO ()
main = hakyllWith config $ do

    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateBodyCompiler

    -- Links to our site memberships around the internet
    match "links.html"  $ compile templateBodyCompiler
    match "links/*.md" $ compile pandocCompiler

    -- Main homepage, show links for now to mirror old site
    match "index.html" $ do
      route idRoute
      compile $ do
        links <- loadAll "links/*.md"

        let ctx = listField "links" defaultContext (return links)

        getResourceBody
          >>= applyAsTemplate ctx
          >>= loadAndApplyTemplate "templates/site.html" defaultContext


    -- Table of primary/secondary school years
    match "school-years/grade-*.md" $ compile pandocCompiler
    match "school-years.html" $ do
      route idRoute
      compile $ do
        grades <- loadAll "school-years/grade-*.md"

        -- Our markdown bodies have custom [report:...:...] fields
        let gradeCtx = reportBodyField <>
                       defaultContext

        let ctx      = listField "grades" gradeCtx (return grades) <>
                       defaultContext

        getResourceBody
          >>= applyAsTemplate ctx
          >>= loadAndApplyTemplate "templates/subpage.html" defaultContext

    match "music.html" $ do
      route idRoute
      compile $ do

        getResourceBody
          >>= applyAsTemplate defaultContext
          >>= loadAndApplyTemplate "templates/subpage.html" defaultContext


--------------------------------------------------------------------------------
-- Custom fields
--------------------------------------------------------------------------------

-- Parse our custom [report:...:...] fields into html <li> elements
reportBodyField :: Context String
reportBodyField = field "body" context
  where
    context = return . interpolateReportBody . itemBody

--------------------------------------------------------------------------------
-- Custom dev configuration, allow previews from my host PC
--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration { previewHost = "0.0.0.0" }

