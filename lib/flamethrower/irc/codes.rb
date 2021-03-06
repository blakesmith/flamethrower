module Flamethrower
  module Irc
    module Codes
      RPL_WLCM = '001'
      RPL_UMODEIS = 221
      RPL_UNAWAY = 305
      RPL_NOWAWAY = 306
      RPL_ENDOFWHO = 315
      RPL_CHANNELMODEIS = 324
      RPL_TOPIC = 332
      RPL_WHOREPLY = 352
      RPL_NAMEREPLY = 353
      RPL_ENDOFNAMES = 366
      RPL_MOTD = 372
      RPL_MOTDSTART = 375
      RPL_ENDOFMOTD = 376

      ERR_UNKNOWNCOMMAND = 421
      ERR_BADCHANNELKEY = 475
    end
  end
end
