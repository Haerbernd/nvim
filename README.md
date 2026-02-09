# Neovim Config
## Dependencies
- Neovim version 0.10 or higher
- A [Nerd Font](https://nerdfonts.com) for Icons (I use Noto Sans Mono, but use whatever you like)
- If you want to use the LSPs you'll need (you can install all of them with Mason which is a part of this config):
    - clangd
    - lua-language-server
    - marksman
- If you want the Wakastat Data you'll need to setup wakastat (you can use my instance of [wakapi](https://wakapi.dev) [wakapi.haerbernd.dev](https://wakapi.haerbernd.dev) if you want)

## Installation
Easiest is if you do the following (this will delete your old config, which you might want to backup):

```bash
rm -r ~/.config/nvim
git clone https://github.com/Haerbernd/nvim ~/.config/nvim
```

Afterwards you'll only have to start Neovim once for it to automatically fetch all plugins that it needs (except clangd in the case that you'll want to use it; you'll have to install it yourself)
