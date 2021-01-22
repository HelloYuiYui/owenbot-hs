{-# LANGUAGE OverloadedStrings #-}

module Admin (sendInstanceChan, gitLocal, gitRemote, commitsAhead, sendInstanceInfo) where
import Data.Text as T
import Discord.Types (ChannelId, Message(messageChannel) )
import Discord ( DiscordHandler, RestCallErrorCode )
import Utils (sendMessageChan, isRole, captureCommandOutput)
import UnliftIO(liftIO)
import Discord.Internal.Types (Channel(channelId))
import Data.Char (isSpace)

rstrip :: Text -> Text
rstrip = T.reverse . T.dropWhile isSpace . T.reverse

sendInstanceChan :: Message -> DiscordHandler (Either RestCallErrorCode Message)
sendInstanceChan m = do 
  b1 <- isRole m "OwenDev"
  if b1
    then
      sendInstanceInfo $ messageChannel m
    else sendMessageChan (messageChannel m) "Insufficient privileges."

gitLocal, gitRemote, commitsAhead :: IO T.Text 
gitLocal = captureCommandOutput "git" ["rev-parse", "HEAD"]
gitRemote = captureCommandOutput "git" ["rev-parse", "origin/main"]
commitsAhead = captureCommandOutput "git" ["rev-list", "--count", "HEAD", "^origin/main"]

sendInstanceInfo :: ChannelId  -> DiscordHandler (Either RestCallErrorCode Message)
sendInstanceInfo chan = do
  loc <- liftIO gitLocal
  remote <- liftIO gitRemote
  commits <- liftIO commitsAhead
  sendMessageChan chan ("Instance Info: \n" <>
                        "Local at: " <> loc <>  --as all things returned by captureCommandOuput has a newline at the end
                        "Remote at: " <> remote <>
                        "Remote is " <> rstrip commits <> " commits ahead")