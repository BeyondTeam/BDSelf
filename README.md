# [Self-Bot](https://telegram.me/BeyondTeam)

An advanced and powerful administration bot based on NEW TG-CLI


* * *

## Commands

| Use help |
|:--------|:------------|
| [#!/]help | just send help in your group and get the commands |

**You can use "#", "!", or "/" to begin all commands

* * *

# Installation

```sh
# Let's install the bot.
cd $HOME
git clone https://github.com/BeyondTeam/Self-BotV2.git
cd Self-BotV2
chmod +x beyond.sh
./beyond.sh install
./beyond.sh # Enter a phone number & confirmation code.
```
### One command
To install everything in one command, use:
```sh
cd $HOME && git clone https://github.com/BeyondTeam/Self-BotV2.git && cd Self-BotV2 && chmod +x beyond.sh && ./beyond.sh install && ./beyond.sh
```

* * *

### Sudo And Bot
After you run the bot for first time, send it `!id`. Get your ID and stop the bot.

Open ./bot/bot.lua and add your ID to the "sudo_users" section in the following format:
```
    sudo_users = {
    157059515,
    0,
    YourID
  }
```
add your bot ID at line 4 in bot.lua
add your ID in config.lua
add your ID at line 362 in tools.lua
Then restart the bot.

# Support and development

More information [Beyond Development](https://telegram.me/joinchat/AAAAAD9JFZlMveUl8q99gA)

# Special thanks to
[@MrPars](httpa://telegram.me/MrPars)

[@MrHalix](https://github.com/MrHalix)

[@Vysheng](https://github.com/vysheng)

* * *

# Developers!

[SoLiD](https://github.com/solid021) ([Telegram](https://telegram.me/SoLiD))

[MAKAN](https://github.com/makanj) ([Telegram](https://telegram.me/MAKAN))

[Civey](https://github.com/Oysof) ([Telegram](https://telegram.me/Civey))

### Our Telegram channel:

[@BeyondTeam](https://telegram.me/BeyondTeam)
